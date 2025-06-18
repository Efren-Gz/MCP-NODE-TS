import { McpServer } from "@modelcontextprotocol/sdk/server/mcp";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio";
import { z } from "zod";
import { Octokit } from "@octokit/rest";
import simpleGit from 'simple-git';
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

// Herramienta: Crear un repositorio
server.tool(
  "githubCreateRepo",
  "Create a new GitHub repository",
  {
    name: z.string(),
    description: z.string().optional(),
    private: z.boolean().optional(),
  },
  async ({ name, description, private: isPrivate }) => {
    try {
      const { data } = await octokit.repos.createForAuthenticatedUser({
        name,
        description,
        private: isPrivate ?? false,
      });
      return {
        content: [
          {
            type: "text",
            text: `Created repository: ${data.full_name}\nURL: ${data.html_url}`,
          },
        ],
      };
    } catch (e: any) {
      return {
        content: [
          {
            type: "text",
            text: `Error creating repository: ${e.message}`,
          },
        ],
      };
    }
  }
);

// ...existing code...

// Herramienta: Crear una nueva rama en un repositorio
server.tool(
  "githubCreateBranch",
  "Create a new branch in a GitHub repository",
  {
    owner: z.string(),
    repo: z.string(),
    branch: z.string(),
    fromBranch: z.string()
  },
  async ({ owner, repo, branch, fromBranch }) => {
    try {
      // Obtiene el SHA de la rama base
      const { data: baseBranch } = await octokit.repos.getBranch({
        owner,
        repo,
        branch: fromBranch
      });

      // Crea la nueva rama usando el SHA de la rama base
      await octokit.git.createRef({
        owner,
        repo,
        ref: `refs/heads/${branch}`,
        sha: baseBranch.commit.sha
      });

      return {
        content: [
          {
            type: "text",
            text: `Branch '${branch}' created from '${fromBranch}' in ${owner}/${repo}.`
          }
        ]
      };
    } catch (e: any) {
      return {
        content: [
          {
            type: "text",
            text: `Error creating branch: ${e.message}`
          }
        ]
      };
    }
  }
);

// ...existing code...

server.tool(
  "githubCreateRepoWithReadmeAndMain",
  "Create a new GitHub repository with a default README and a main file for the specified technology",
  {
    name: z.string(),
    technology: z.string(),
    description: z.string().optional(),
    private: z.boolean().optional(),
  },
  async ({ name, technology, description, private: isPrivate }) => {
    try {
      // 1. Crear el repositorio
      const { data: repo } = await octokit.repos.createForAuthenticatedUser({
        name,
        description,
        private: isPrivate ?? false,
        auto_init: false,
      });

      // 2. Crear el README.md
      const readmeContent = `# ${name}\n\nRepositorio creado automáticamente.`;
      await octokit.repos.createOrUpdateFileContents({
        owner: repo.owner.login,
        repo: name,
        path: "README.md",
        message: "Add README.md",
        content: Buffer.from(readmeContent).toString("base64"),
      });

      // 3. Crear el archivo main según la tecnología
      const mainFiles: Record<string, { filename: string; content: string }> = {
        go: { filename: "main.go", content: 'package main\n\nimport "fmt"\n\nfunc main() {\n    fmt.Println("Hello, Go!")\n}\n' },
        py: { filename: "main.py", content: 'print("Hello, Python!")\n' },
        js: { filename: "main.js", content: 'console.log("Hello, JavaScript!");\n' },
        ts: { filename: "main.ts", content: 'console.log("Hello, TypeScript!");\n' },
        java: { filename: "Main.java", content: 'public class Main {\n    public static void main(String[] args) {\n        System.out.println("Hello, Java!");\n    }\n}\n' },
        // Agrega más tecnologías si lo deseas
      };

      const main = mainFiles[technology.toLowerCase()];
      if (main) {
        await octokit.repos.createOrUpdateFileContents({
          owner: repo.owner.login,
          repo: name,
          path: main.filename,
          message: `Add ${main.filename}`,
          content: Buffer.from(main.content).toString("base64"),
        });
      }

      return {
        content: [
          {
            type: "text",
            text: `Created repository: ${repo.full_name}\nURL: ${repo.html_url}\nREADME.md and ${main ? main.filename : "no main file"} added.`,
          },
        ],
      };
    } catch (e: any) {
      return {
        content: [
          {
            type: "text",
            text: `Error creating repository: ${e.message}`,
          },
        ],
      };
    }
  }
);

// ...existing code...

server.tool(
  "githubDeleteRepo",
  "Delete a GitHub repository",
  {
    owner: z.string(),
    repo: z.string(),
  },
  async ({ owner, repo }) => {
    try {
      await octokit.repos.delete({
        owner,
        repo,
      });
      return {
        content: [
          {
            type: "text",
            text: `Repository '${owner}/${repo}' deleted successfully.`,
          },
        ],
      };
    } catch (e: any) {
      return {
        content: [
          {
            type: "text",
            text: `Error deleting repository: ${e.message}`,
          },
        ],
      };
    }
  }
);

server.tool(
  "gitAddCommitPush",
  "Add all changes, commit with a message, and push to the current branch",
  {
    repoPath: z.string(),
    message: z.string(),
  },
  async ({ repoPath, message }) => {
    try {
      const git = simpleGit(repoPath);

      // Detectar la rama actual
      const status = await git.status();
      const currentBranch = status.current;

      // git add .
      await git.add('.');

      // git commit -m "mensaje"
      await git.commit(message);

      // git push origin <currentBranch>
      await git.push;

      return {
        content: [
          {
            type: "text",
            text: `Cambios agregados, commit realizado y push hecho a la rama '${currentBranch}'.`,
          },
        ],
      };
    } catch (e: any) {
      return {
        content: [
          {
            type: "text",
            text: `Error al hacer commit y push: ${e.message}`,
          },
        ],
      };
    }
  }
);

// Inicializa el transporte
const transport = new StdioServerTransport();
await server.connect(transport);
