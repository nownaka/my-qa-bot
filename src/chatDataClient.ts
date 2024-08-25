import { Container, CosmosClient, Database } from "@azure/cosmos";
import {
  DefaultAzureCredential,
  ManagedIdentityCredential,
} from "@azure/identity";
import { ChatHistoryParam } from "./types/chatHistoryParam";
import { IndexDataParam } from "./types/indexDataParam";

export class ChatDataClient extends CosmosClient {
  private databaseName: string;
  private containerNames: { chatHistory: string; index: string };
  private index: IndexDataParam[] | undefined;

  constructor(
    endpoint: string,
    credential: DefaultAzureCredential,
    dataBaseName: string,
    containerNames: { chatHistory: string; index: string }
  ) {
    super({
      endpoint: endpoint,
      aadCredentials: credential,
    });
    this.databaseName = dataBaseName;
    this.containerNames = containerNames;
    this.index = undefined;
  }

  public async getDatabaseAndContainer(containerName: string) {
    const { database } = await this.databases.createIfNotExists({
      id: this.databaseName,
    });
    const { container } = await database.containers.createIfNotExists({
      id: containerName,
    });
    return { database, container };
  }

  async saveChat(...data: ChatHistoryParam[]) {
    const { database, container } = await this.getDatabaseAndContainer(
      this.containerNames.chatHistory
    );
    for (const item of data) {
      await container.items.create(item);
    }
  }

  async getChatHistory(userId: string, records: number) {
    const { database, container } = await this.getDatabaseAndContainer(
      this.containerNames.chatHistory
    );
    const { resources } = await container.items
      .query({
        query: "SELECT TOP @records * from c WHERE c.userId = @userId",
        parameters: [
          { name: "@userId", value: userId },
          { name: "@records", value: records },
        ],
      })
      .fetchAll();
    const chatHistory = resources as ChatHistoryParam[];
    return chatHistory;
  }

  private async getIndex() {
    const { database, container } = await this.getDatabaseAndContainer(
      this.containerNames.index
    );
    const { resources } = await container.items
      .query({
        query: "SELECT * from c",
      })
      .fetchAll();
    this.index = resources as IndexDataParam[];
    return;
  }

  private getCosineSimilarity(vecA: number[], vecB: number[]): number {
    const dotProduct = vecA.reduce((sum, a, idx) => sum + a * vecB[idx], 0);
    const magnitudeA = Math.sqrt(vecA.reduce((sum, a) => sum + a * a, 0));
    const magnitudeB = Math.sqrt(vecB.reduce((sum, b) => sum + b * b, 0));
    return dotProduct / (magnitudeA * magnitudeB);
  }

  public async getSimilarityRanks(queryEmbedding: number[]) {
    let similarityRanks: {
      content: IndexDataParam;
      similarityRank: number;
    }[] = [];
    if (!this.index) {
      await this.getIndex();
    } else {
      for (const element of this.index) {
        const similarityRank: number = this.getCosineSimilarity(
          queryEmbedding,
          element.embedding
        );
        similarityRanks.push({
          content: element,
          similarityRank: similarityRank,
        });
        similarityRanks.sort((lhs, rhs) => {
          return rhs.similarityRank - lhs.similarityRank;
        });
        similarityRanks = similarityRanks.filter((item) => {
          return item.similarityRank > 0.5;
        });
      }
    }
    return similarityRanks.slice(0, 2);
  }
}
