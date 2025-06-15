import { spawn } from "child_process";

const server = spawn("node", ["mcp-server.ts"], {
  stdio: ["pipe", "pipe", "inherit"]
});

server.stdout.on('data', (data) => {
  try {
    const response = JSON.parse(data.toString());
    console.log('Respuesta del servidor:', response);
  } catch (e) {
    console.log('Salida del servidor:', data.toString());
  }
});

// Mensaje para ejecutar add
const addMessage = {
  jsonrpc: "2.0",
  id: 1,
  method: "runTool",
  params: {
    toolName: "add",
    params: { a: 5, b: 3 }
  }
};

// Mensaje para ejecutar githubRepoInfo
const githubMessage = {
  jsonrpc: "2.0",
  id: 2,
  method: "runTool",
  params: {
    toolName: "githubRepoInfo",
    params: { owner: "microsoft", repo: "vscode" }
  }
};

// Mensaje para listar issues
const listIssuesMessage = {
  jsonrpc: "2.0",
  id: 3,
  method: "runTool",
  params: {
    toolName: "githubListIssues",
    params: { owner: "microsoft", repo: "vscode", state: "open" }
  }
};

// Mensaje para obtener info del usuario autenticado
const userInfoMessage = {
  jsonrpc: "2.0",
  id: 4,
  method: "runTool",
  params: {
    toolName: "githubUserInfo",
    params: {}
  }
};

// Enviar mensajes después de un breve retraso para que el servidor esté listo
setTimeout(() => {
  console.log("Enviando petición add...");
  server.stdin.write(JSON.stringify(addMessage) + "\n");
  
  setTimeout(() => {
    console.log("Enviando petición githubRepoInfo...");
    server.stdin.write(JSON.stringify(githubMessage) + "\n");
    
    setTimeout(() => {
      console.log("Enviando petición githubListIssues...");
      server.stdin.write(JSON.stringify(listIssuesMessage) + "\n");
      
      setTimeout(() => {
        console.log("Enviando petición githubUserInfo...");
        server.stdin.write(JSON.stringify(userInfoMessage) + "\n");
      }, 1000);
    }, 1000);
  }, 1000);
}, 1000);