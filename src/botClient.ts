import {
  ActivityHandler,
  ActivityTypes,
  BotHandler,
  TurnContext,
} from "botbuilder";
import { AIClient } from "./aiClient";
import { config } from "./config";

export class BotClient extends ActivityHandler {
  private aiClient: AIClient;

  constructor() {
    super();
    this.aiClient = new AIClient(config.openAI.apiKey);
    this.onMessage(this.generateAnswer);
  }

  private generateAnswer: BotHandler = async (context, next) => {
    await context.sendActivity({ type: ActivityTypes.Typing });
    const removedMentionText = TurnContext.removeRecipientMention(
      context.activity
    );
    const prompt = removedMentionText
      .toLowerCase()
      .replace(/\n|\r/g, "")
      .trim();

    const chatCompletionChoice = await this.aiClient.createChatCompletionChoice(
      config.openAI.models.chat,
      [{ role: "user", content: prompt }]
    );

    const replyMessage = chatCompletionChoice.message.content;
    if (replyMessage) {
      await context.sendActivity(replyMessage);
    }

    await next();
  };
}
