<h1 align="center">MCP-NODE-TS-GITHUB ✨</h1> 

<p align="left">

[<img src='https://cdn.jsdelivr.net/npm/simple-icons@3.0.1/icons/github.svg' alt='github' height='40'>](https://github.com/Efren-Gz) 
[<img src='https://cdn.jsdelivr.net/npm/simple-icons@3.0.1/icons/dev-dot-to.svg' alt='dev' height='40'>](https://dev.to/mogaka_dev) 
[<img src='https://cdn.jsdelivr.net/npm/simple-icons@3.0.1/icons/instagram.svg' alt='instagram' height='40'>](https://www.instagram.com/daviid_1308/)

</p>
<br>

<h2>About this project 😃</h2>

<p align="left">
✨ <b>GitHub API Tool Server</b> built with <code>@modelcontextprotocol/sdk</code>, <code>Octokit</code>, <code>simple-git</code>, and more.<br>
🔧 Provides a set of tools to interact with the GitHub API, including: repo info, issues, branches, repositories, commits, and more.<br>
⚙️ Automates common GitHub tasks, like creating repos with a README and main file, managing branches, listing issues, and pushing commits.<br>
🌎 Designed to be extended and integrated with context-driven workflows.<br>
<br>
</p>
<br>

<h2>Tech Stack 👨🏻‍💻</h2>
<p align="left">
  <a href="https://skillicons.dev">
    <img src="https://skillicons.dev/icons?i=ts,nodejs,github,git,js,bash,linux,vercel,postman,vscode&perline=10" />
  </a>
  <img src="https://img.shields.io/badge/-Octokit-blue?logo=github" height="28"/>
  <img src="https://img.shields.io/badge/-ModelContextProtocol-4B275F" height="28"/>
  <img src="https://img.shields.io/badge/-simplegit-FFCA28" height="28"/>
  <img src="https://img.shields.io/badge/-zod-0068B8" height="28"/>
</p>
<br>

<h2>Features 🛠️</h2>

- ℹ️ Get repository info
- 🐞 List and create issues
- 📝 Create repositories (with README and main file)
- 🌿 Create branches from any base
- 👤 Get authenticated user info
- 🗑️ Delete repositories
- 🚀 Add, commit, and push with git
- 🔄 Easy to extend with new tools

<br>

<h2>Quick Example</h2>

```ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp";
import { Octokit } from "@octokit/rest";
import simpleGit from 'simple-git';
import { z } from "zod";

// Example: Get basic repo info
const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });
const { data } = await octokit.repos.get({ owner: "Efren-Gz", repo: "example-repo" });
console.log(data.full_name, data.description, data.stargazers_count);
```

<br>

<h2>GitHub :octocat:</h2>
<p align="center">
  <img src="https://github-readme-stats.vercel.app/api?username=Efren-Gz&show_icons=true&theme=tokyonight" alt="Efren-Gz stats" height="180"/>
  <img src="https://github-readme-stats.vercel.app/api/top-langs/?username=Efren-Gz&layout=compact&theme=tokyonight" alt="Efren-Gz top langs" height="180"/>
</p>

---

## NPM Dependencies

To install all the required libraries, run in your project root:

```bash
npm install @modelcontextprotocol/sdk @octokit/rest simple-git zod dotenv typescript ts-node
```

---

## How to get your GitHub token

1. Go to [https://github.com/settings/tokens](https://github.com/settings/tokens).
2. Click **"Generate new token"** (choose classic or fine-grained as needed).
3. Add a name and select the necessary permissions (for example: `repo`, `user`, etc.).
4. Click **"Generate token"** and copy the generated token.
5. **Store it in a safe place** and never share it.

---

## Setting the token in VSCode

1. Find or create the `settings.json` file inside the hidden `.vscode` folder in your project.
2. Add the following line inside the file, replacing `YOUR_GITHUB_TOKEN_HERE` with your actual token:

```json
{
  "env": {
    "GITHUB_TOKEN": "YOUR_GITHUB_TOKEN_HERE"
  }
}
```

> The token must be set before running the server.

---

## How to run the MCP Server in VSCode

1. Press `Ctrl + P` on Windows (or `Cmd + P` on Mac).
2. Type `> mcp: List servers` and select it.
3. Look for the server named **mcp-github** and run it.
4. The server will use the token configured in `.vscode/settings.json`.

> **Make sure your token is properly set in `settings.json` before running the server!**

---

<h2>Contact</h2>

- 📫 Email: <b>efren.garza.z@gmail.com</b>
- 🌐 [GitHub](https://github.com/Efren-Gz)

---
