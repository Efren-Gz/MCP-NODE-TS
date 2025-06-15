import { McpServer } from "@modelcontextprotocol/sdk/server/mcp";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio";
import { z } from "zod";
import { Octokit } from "@octokit/rest";
import 'dotenv/config';


// Usa el token de GitHub definido en las variables de entorno
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const octokit = new Octokit({ auth: GITHUB_TOKEN });

const server = new McpServer({
  name: "MCP Server GitHub API",
  version: "1.0.0",
});

// Herramienta: Info básica de un repo
server.tool(
  "githubRepoInfo",
  "Get basic info from a GitHub repository",
  { owner: z.string(), repo: z.string() },
  async ({ owner, repo }) => {
    try {
      const { data } = await octokit.repos.get({ owner, repo });
      return {
        content: [
          {
            type: "text",
            text: `Repo: ${data.full_name}\nDescription: ${data.description}\nStars: ${data.stargazers_count}\nURL: ${data.html_url}`,
          },
        ],
      };
    } catch (e: any) {
      return {
        content: [
          {
            type: "text",
            text: `Error fetching repo info: ${e.message}`,
          },
        ],
      };
    }
  }
);

// Herramienta: Listar issues de un repo
server.tool(
  "githubListIssues",
  "List issues from a GitHub repository",
  { owner: z.string(), repo: z.string(), state: z.enum(["open", "closed", "all"]).default("open") },
  async ({ owner, repo, state }) => {
    try {
      const { data } = await octokit.issues.listForRepo({ owner, repo, state });
      if (!data.length) {
        return {
          content: [{ type: "text", text: "No issues found." }],
        };
      }
      return {
        content: [
          {
            type: "text",
            text: data.map(issue => `#${issue.number}: ${issue.title} [${issue.state}]`).join('\n'),
          },
        ],
      };
    } catch (e: any) {
      return {
        content: [
          {
            type: "text",
            text: `Error fetching issues: ${e.message}`,
          },
        ],
      };
    }
  }
);

// Herramienta: Crear un issue
server.tool(
  "githubCreateIssue",
  "Create a new GitHub issue",
  {
    owner: z.string(),
    repo: z.string(),
    title: z.string(),
    body: z.string().optional(),
  },
  async ({ owner, repo, title, body }) => {
    try {
      const { data } = await octokit.issues.create({ owner, repo, title, body });
      return {
        content: [
          {
            type: "text",
            text: `Created issue #${data.number}: ${data.title}\nURL: ${data.html_url}`,
          },
        ],
      };
    } catch (e: any) {
      return {
        content: [
          {
            type: "text",
            text: `Error creating issue: ${e.message}`,
          },
        ],
      };
    }
  }
);

// Herramienta: Obtener usuario autenticado
server.tool(
  "githubUserInfo",
  "Get information about the authenticated GitHub user",
  {},
  async () => {
    try {
      const { data } = await octokit.users.getAuthenticated();
      return {
        content: [
          {
            type: "text",
            text: `User: ${data.login}\nName: ${data.name}\nBio: ${data.bio}\nURL: ${data.html_url}`,
          },
        ],
      };
    } catch (e: any) {
      return {
        content: [
          {
            type: "text",
            text: `Error fetching user info: ${e.message}`,
          },
        ],
      };
    }
  }
);

// Puedes seguir agregando herramientas para pull requests, ramas, releases, comentarios, etc.

// Inicializa el transporte
const transport = new StdioServerTransport();
await server.connect(transport);

console.log("MCP GitHub API server is ready!");