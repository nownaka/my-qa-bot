import { Container, CosmosClient, Database } from "@azure/cosmos";
import {
  DefaultAzureCredential,
  ManagedIdentityCredential,
} from "@azure/identity";
import { ChatHistoryParam } from "./types/chatHistoryParam";

export class ChatDataClient extends CosmosClient {
  private databaseName: string;
  private containerName: string;

  constructor(
    endpoint: string,
    credential: DefaultAzureCredential,
    dataBaseName: string,
    containerName: string
  ) {
    super({
      endpoint: endpoint,
      aadCredentials: credential,
    });
    this.databaseName = dataBaseName;
    this.containerName = containerName;
  }

  public async getDatabaseAndContainer() {
    const { database } = await this.databases.createIfNotExists({
      id: this.databaseName,
    });
    const { container } = await database.containers.createIfNotExists({
      id: this.containerName,
    });
    return { database, container };
  }

  async saveChat(...data: ChatHistoryParam[]) {
    const { database, container } = await this.getDatabaseAndContainer();
    for (const item of data) {
      await container.items.create(item);
    }
  }

  async getChatHistory(userId: string, records: number) {
    const { database, container } = await this.getDatabaseAndContainer();
    const { resources } = await container.items
      .query(
        {
          query: "SELECT * from c WHERE c.userId = @userId",
          parameters: [{ name: "@userId", value: userId }],
        },
        { maxItemCount: records }
      )
      .fetchAll();
    const chatHistory = resources as ChatHistoryParam[];
    return chatHistory;
  }
}
