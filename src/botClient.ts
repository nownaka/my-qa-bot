import { ActivityHandler, TurnContext } from "botbuilder";

export class BotClient extends ActivityHandler {
  constructor() {
    super();
    this.onMessage(async (context, next) => {
      console.log("Running with Message Activity.");
      const removedMentionText = TurnContext.removeRecipientMention(
        context.activity
      );
      const txt = removedMentionText.toLowerCase().replace(/\n|\r/g, "").trim();
      await context.sendActivity(`Echo: ${txt}`);
      // By calling next() you ensure that the next BotHandler is run.
      await next();
    });
  }
}
