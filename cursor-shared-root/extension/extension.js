const vscode = require("vscode");

const OBSIDIAN_PATH = "/workspaces/obsidian";
const SHARED_PATH = "/home/vscode/shared";

async function addSharedRoot() {
  const folders = vscode.workspace.workspaceFolders || [];
  const hasObsidian = folders.some(
    (folder) => folder.uri.scheme === "file" && folder.uri.fsPath === OBSIDIAN_PATH,
  );
  const hasShared = folders.some(
    (folder) => folder.uri.scheme === "file" && folder.uri.fsPath === SHARED_PATH,
  );

  if (!hasObsidian || hasShared) {
    return;
  }

  const sharedUri = vscode.Uri.file(SHARED_PATH);
  try {
    const stat = await vscode.workspace.fs.stat(sharedUri);
    if (!(stat.type & vscode.FileType.Directory)) {
      return;
    }
  } catch {
    return;
  }

  vscode.workspace.updateWorkspaceFolders(folders.length, 0, {
    name: "Shared",
    uri: sharedUri,
  });
}

function activate(context) {
  void addSharedRoot();
  context.subscriptions.push(
    vscode.workspace.onDidChangeWorkspaceFolders(() => {
      void addSharedRoot();
    }),
  );
}

function deactivate() {}

module.exports = { activate, deactivate };
