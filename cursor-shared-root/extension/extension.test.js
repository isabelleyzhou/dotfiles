const assert = require("node:assert/strict");
const Module = require("node:module");

const extensionPath = require.resolve("./extension");

async function runCase(paths, expectedAdds) {
  const adds = [];
  const listeners = [];
  const mockVscode = {
    FileType: { Directory: 2 },
    Uri: {
      file(fsPath) {
        return { scheme: "file", fsPath };
      },
    },
    workspace: {
      workspaceFolders: paths.map((fsPath) => ({
        uri: { scheme: "file", fsPath },
      })),
      fs: {
        async stat() {
          return { type: 2 };
        },
      },
      updateWorkspaceFolders(start, deleteCount, folder) {
        adds.push({ start, deleteCount, folder });
        return true;
      },
      onDidChangeWorkspaceFolders(listener) {
        listeners.push(listener);
        return { dispose() {} };
      },
    },
  };

  const originalLoad = Module._load;
  Module._load = function load(request, parent, isMain) {
    return request === "vscode"
      ? mockVscode
      : originalLoad.call(this, request, parent, isMain);
  };

  try {
    delete require.cache[extensionPath];
    const extension = require("./extension");
    const context = { subscriptions: [] };
    extension.activate(context);
    await new Promise((resolve) => setImmediate(resolve));
    assert.equal(adds.length, expectedAdds);
    assert.equal(context.subscriptions.length, 1);
    if (expectedAdds) {
      assert.equal(adds[0].folder.uri.fsPath, "/home/vscode/shared");
      assert.equal(adds[0].folder.name, "Shared");
    }
  } finally {
    Module._load = originalLoad;
  }
}

async function main() {
  await runCase(["/workspaces/obsidian"], 1);
  await runCase(["/workspaces/obsidian", "/home/vscode/shared"], 0);
  await runCase(["/workspaces/another-project"], 0);
  console.log("cursor-shared-root tests passed");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
