import {
  ActivityHandler,
  ActivityTypes,
  BotHandler,
  TurnContext,
} from "botbuilder";
import { DefaultAzureCredential } from "@azure/identity";
import { AIClient } from "./aiClient";
import { ChatDataClient } from "./chatDataClient";
import { config } from "./config";
import { ChatCompletionMessageParam } from "openai/resources";
import { ChatHistoryParam } from "./types/chatHistoryParam";
import { IndexDataParam } from "./types/indexDataParam";

export class BotClient extends ActivityHandler {
  private aiClient: AIClient;
  private chatDataClient: ChatDataClient;

  constructor() {
    super();
    const credential = new DefaultAzureCredential();
    this.aiClient = new AIClient(config.openAI.apiKey);
    this.chatDataClient = new ChatDataClient(
      config.cosmosDB.endpoint,
      credential,
      config.cosmosDB.databaseName,
      {
        chatHistory: config.cosmosDB.containerNames.chatHistory,
        index: config.cosmosDB.containerNames.index,
      }
    );
    this.onMessage(this.generateAnswer);

    this.onMembersAdded(async (context, next) => {
      const membersAdded = context.activity.membersAdded || [];
      const welcomeMessage = config.prompt.welcome;
      for (let cnt = 0; cnt < membersAdded.length; cnt++) {
        if (membersAdded[cnt].id && welcomeMessage) {
          await context.sendActivity(welcomeMessage);
          break;
        }
      }
      await next();
    });
  }

  private generateAnswer: BotHandler = async (context, next) => {
    await context.sendActivity({ type: ActivityTypes.Typing });

    const channelData = context.activity.channelData;
    const userId = channelData.userId || context.activity.recipient.id;
    const userName = channelData.userName || context.activity.recipient.name;

    const chatHistory: readonly ChatHistoryParam[] =
      await this.chatDataClient.getChatHistory(
        userId,
        config.cosmosDB.includesRecords.chat
      );

    const messages: ChatCompletionMessageParam[] = [];

    const removedMentionText = TurnContext.removeRecipientMention(
      context.activity
    );
    const prompt = removedMentionText
      .toLowerCase()
      .replace(/\n|\r/g, "")
      .trim();

    const queryEmbedding: number[] = (
      await this.aiClient.createEmbeddingResponseData(
        config.openAI.models.embedding,
        prompt
      )
    ).embedding;

    const information = await this.getInformationFromIndex(queryEmbedding);

    const requestMessage: ChatCompletionMessageParam = {
      role: "user",
      content: prompt,
    };

    const requestMessages: ChatCompletionMessageParam[] =
      this.generateRequestMessages(requestMessage, ...chatHistory);

    const chatCompletionChoice = await this.aiClient.createChatCompletionChoice(
      config.openAI.models.chat,
      [
        {
          role: "system",
          content: (config.prompt.system + information)
            .replace(/\n|\r/g, "")
            .trim(),
        },
        ...requestMessages,
      ],
      config.openAI.maxTokens,
      config.openAI.temperature,
      config.openAI.topP
    );

    const replyMessage = chatCompletionChoice.message;
    if (replyMessage.content) {
      await context.sendActivity(replyMessage.content);
    }

    messages.push(requestMessage, replyMessage);

    await this.chatDataClient.saveChat({
      userId: userId,
      userName: userName,
      conversationId: context.activity.id,
      messages: messages,
    });

    await next();
  };

  private generateRequestMessages(
    message: ChatCompletionMessageParam,
    ...chatHistory: readonly ChatHistoryParam[]
  ): ChatCompletionMessageParam[] {
    const requestMessages: ChatCompletionMessageParam[] = [];
    chatHistory.forEach((element) => {
      element.messages.forEach((message) => {
        requestMessages.push(message);
      });
    });
    requestMessages.push(message);
    return requestMessages;
  }

  private async getInformationFromIndex(
    queryEmbedding: number[]
  ): Promise<string> {
    const similarityRanks: {
      content: IndexDataParam;
      similarityRank: number;
    }[] = await this.chatDataClient.getSimilarityRanks(
      queryEmbedding,
      config.cosmosDB.similarityRank,
      config.cosmosDB.includesRecords.index
    );

    let information = `
    ## Provided Information: 
    `;

    if (similarityRanks.length > 0) {
      const informationTemplate = `
      - Question: <question>
      - Answer: <answer>
      - Reference URL: <reference>
      `;
      similarityRanks.forEach((item) => {
        information += informationTemplate
          .replace("<question>", item.content.question)
          .replace("<answer>", item.content.answer)
          .replace(
            "<reference>",
            item.content.urls ? item.content.urls?.join(", \n") : "none"
          );
      });
    } else {
      information += "none";
    }

    return information;
  }
}
