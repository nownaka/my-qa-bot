import OpenAI from "openai";
import {
  ChatCompletion,
  ChatCompletionMessageParam,
  CreateEmbeddingResponse,
  Embedding,
} from "openai/resources";

export class AIClient extends OpenAI {
  constructor(apiKey: string) {
    super({ apiKey: apiKey });
  }

  public async createChatCompletionChoice(
    model: string,
    messages: ChatCompletionMessageParam[]
  ): Promise<ChatCompletion.Choice> {
    try {
      const chatCompletion = await this.chat.completions
        .create({
          model: model,
          messages: messages,
          stream: false,
        })
        .then((res) => {
          return res as ChatCompletion;
        });
      return chatCompletion.choices[0];
    } catch (error) {
      console.error("ChatCompletion取得に失敗しました。");
      throw error;
    }
  }

  public async createEmbeddingResponseData(
    model: string,
    query: string
  ): Promise<Embedding> {
    let embeddingResponse: CreateEmbeddingResponse;
    try {
      embeddingResponse = await this.embeddings.create({
        input: query,
        model: model,
      });
    } catch (error) {
      console.error("Embedding取得に失敗しました。");
      throw error;
    }
    return embeddingResponse.data[0];
  }
}
