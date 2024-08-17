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
      config.cosmosDB.containerName
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
        config.cosmosDB.includesRecords
      );

    const messages: ChatCompletionMessageParam[] = [];

    const removedMentionText = TurnContext.removeRecipientMention(
      context.activity
    );
    const prompt = removedMentionText
      .toLowerCase()
      .replace(/\n|\r/g, "")
      .trim();

    const requestMessage: ChatCompletionMessageParam = {
      role: "user",
      content: prompt,
    };
    const requestMessages: ChatCompletionMessageParam[] =
      this.generateRequestMessages(requestMessage, ...chatHistory);

    const chatCompletionChoice = await this.aiClient.createChatCompletionChoice(
      config.openAI.models.chat,
      requestMessages
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
}
