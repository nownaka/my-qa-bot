import { ChatCompletionMessageParam } from "openai/resources";

export interface ChatHistoryParam {
  userId: string;
  userName: string;
  conversationId: string | undefined;
  messages: ChatCompletionMessageParam[];
}
