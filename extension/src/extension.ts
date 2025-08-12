import * as vscode from 'vscode';
import { tryAcquirePositronApi, inPositron, previewUrl } from '@posit-dev/positron';
import type { RuntimeCodeExecutionMode } from '@posit-dev/positron';
const log = vscode.window.createOutputChannel('Positron Tutorial Helpers');


// ---------- Exercise helpers ----------

async function runMakeExercise(type: string) {
  if (!inPositron()) {
    vscode.window.showErrorMessage('This command requires Positron with an active R session.');
    return;
  }
  const api = tryAcquirePositronApi();
  if (!api) {
    vscode.window.showErrorMessage('Positron API not available.');
    return;
  }

  const r = `
    if (!"tutorial.helpers" %in% .packages()) {
      suppressMessages(try(library(tutorial.helpers), silent = TRUE))
    }
    if (!"tutorial.helpers" %in% .packages()) {
      stop("Package 'tutorial.helpers' is not loaded. Please install it and run library(tutorial.helpers) first.")
    }
    make_exercise("${type}")
  `;

  await api.runtime.executeCode('r', r, false, false, 'Interactive' as RuntimeCodeExecutionMode);
}

async function chooseExerciseType() {
  const choice = await vscode.window.showQuickPick(
    [
      { label: 'Code Exercise', type: 'code' },
      { label: 'No-Answer Exercise', type: 'no-answer' },
      { label: 'Yes-Answer Exercise', type: 'yes-answer' }
    ],
    { placeHolder: 'Choose exercise type to insert' }
  );
  if (choice) {
    await runMakeExercise(choice.type);
  }
}

// ---------- Tutorials webview provider ----------

class TutorialsViewProvider implements vscode.WebviewViewProvider {
  public static readonly viewId = 'tutorialHelpers.tutorialPane';

  constructor(private readonly context: vscode.ExtensionContext) {}

  resolveWebviewView(webviewView: vscode.WebviewView) {
    const webview = webviewView.webview;
    webview.options = { enableScripts: true };
    webview.html = this.getHtml();

    webview.onDidReceiveMessage(async (msg) => {
      if (msg.type === 'ready' || msg.type === 'refresh') {
        if (!inPositron()) {
          webview.postMessage({
            type: 'data',
            rows: [],
            error: 'Not running in Positron. Open in Positron with an active R session.'
          });
          return;
        }

        webview.postMessage({ type: 'status', message: 'Waiting for R session...' });
        const waitErr = await this.waitForR(20000, 500);
        if (waitErr) {
          webview.postMessage({ type: 'data', rows: [], error: waitErr });
          return;
        }

        const data = await this.fetchTutorials();
        webview.postMessage({ type: 'data', rows: data.rows, error: data.error });
        return;
      }

      if (msg.type === 'run' && msg.name && msg.pkg) {
        webview.postMessage({ type: 'status', message: 'Launching tutorial...' });
        const waitErr = await this.waitForR(10000, 400);
        if (waitErr) {
          vscode.window.showErrorMessage(waitErr);
          webview.postMessage({ type: 'status', message: '' });
          return;
        }
        await this.runTutorial(msg.name, msg.pkg, webview);
        webview.postMessage({ type: 'status', message: '' });
      }
    });
  }

  private async waitForR(maxMs = 20000, intervalMs = 500): Promise<string | undefined> {
    const api = tryAcquirePositronApi();
    if (!api) {
      return 'Positron API not available.';
    }
    const start = Date.now();
    while (Date.now() - start < maxMs) {
      try {
        await api.runtime.executeCode('r', 'invisible(TRUE)', false, false, 'Interactive' as RuntimeCodeExecutionMode);
        return undefined;
      } catch {
        await new Promise((r) => setTimeout(r, intervalMs));
      }
    }
    return 'R session is not running. Start R, then click Refresh.';
  }

  // New: launch in-app by capturing URL to a file, then opening via previewUrl
  private async runTutorial(name: string, pkg: string, webview?: vscode.Webview) {
    const api = tryAcquirePositronApi();
    if (!api) {
      vscode.window.showErrorMessage('Positron API not available.');
      return;
    }
  
    // prepare a small file to capture the URL
    await vscode.workspace.fs.createDirectory(this.context.globalStorageUri);
    const urlFile = vscode.Uri.joinPath(this.context.globalStorageUri, 'launch-url.txt');
    try { await vscode.workspace.fs.delete(urlFile); } catch { /* ignore */ }
    const urlPath = urlFile.fsPath.replace(/\\/g, '/');
  
    const r = `
      if (!requireNamespace("learnr", quietly = TRUE)) {
        stop("Package 'learnr' is not installed.")
      }
  
      p <- normalizePath("${urlPath}", winslash = "/", mustWork = FALSE)
      capture_url <- function(url, ...) {
        try({
          con <- file(p, open = "w", encoding = "UTF-8")
          writeLines(url, con, sep = "\\n")
          close(con)
        }, silent = TRUE)
        TRUE
      }
  
      # ensure any viewer paths also surface the URL
      options(shiny.launch.browser = capture_url, viewer = capture_url)
  
      learnr::run_tutorial(
        ${JSON.stringify(name)},
        package = ${JSON.stringify(pkg)},
        shiny_args = list(launch.browser = capture_url, host = "127.0.0.1")
      )
    `;
  
    // run quietly
    await api.runtime.executeCode('r', r, false, false, 'Interactive' as RuntimeCodeExecutionMode);
  
    // wait up to 30 seconds for the URL to appear
    const deadline = Date.now() + 30000;
    let url: string | undefined;
    while (Date.now() < deadline) {
      try {
        const buf = await vscode.workspace.fs.readFile(urlFile);
        const txt = new TextDecoder().decode(buf).trim();
        if (txt) { url = txt; break; }
      } catch { /* not yet */ }
      await new Promise(res => setTimeout(res, 200));
    }
  
    if (!url) {
      vscode.window.showWarningMessage('Could not capture the tutorial URL. Try Refresh, then Run again after R is ready.');
      return;
    }
  
    // show in the pane
    try { webview?.postMessage({ type: 'launched', url }); } catch {}
  
    // toast with quick actions
    const OPEN = 'Open in browser';
    const COPY = 'Copy link';
    const choice = await vscode.window.showInformationMessage(`Tutorial URL: ${url}`, OPEN, COPY);
    if (choice === OPEN) {
      await vscode.env.openExternal(vscode.Uri.parse(url));
    } else if (choice === COPY) {
      await vscode.env.clipboard.writeText(url);
      vscode.window.showInformationMessage('Link copied to clipboard');
    }
  }  

  private async fetchTutorials(): Promise<{ rows: any[]; error?: string }> {
    const api = tryAcquirePositronApi();
    if (!api) {
      return { rows: [], error: 'Positron API not available.' };
    }

    try {
      await vscode.workspace.fs.createDirectory(this.context.globalStorageUri);

      const fileUri = vscode.Uri.joinPath(this.context.globalStorageUri, 'tutorials.json');
      const tmpUri  = vscode.Uri.joinPath(this.context.globalStorageUri, 'tutorials.tmp.json');
      const filePath = fileUri.fsPath.replace(/\\/g, '/');
      const tmpPath  = tmpUri.fsPath.replace(/\\/g, '/');

      const r = `
        write_list <- function(path_tmp, path_final) {
          tryCatch({
            if (!requireNamespace("jsonlite", quietly = TRUE)) stop("Install 'jsonlite' first")

            rows <- NULL
            if (requireNamespace("learnr", quietly = TRUE)) {
              fun <- learnr::available_tutorials
              args <- names(formals(fun))
              df <- if ("all" %in% args) fun(all = TRUE) else fun()
              df <- tryCatch(as.data.frame(df), error = function(e) NULL)
              if (!is.null(df) && nrow(df) > 0) {
                if (!"package" %in% names(df) && "pkg" %in% names(df)) names(df)[names(df) == "pkg"] <- "package"
                if (!"name" %in% names(df) && "tutorial" %in% names(df)) names(df)[names(df) == "tutorial"] <- "name"
                if (!"title" %in% names(df)) df$title <- NA_character_
                keep <- intersect(c("package","name","title"), names(df))
                df <- df[, keep, drop = FALSE]
                df[] <- lapply(df, function(x) if (is.factor(x)) as.character(x) else x)
                rows <- df
              }
            }

            if (is.null(rows)) {
              v <- tryCatch(vignette()[['results']], error = function(e) NULL)
              if (!is.null(v) && nrow(v) > 0) {
                rows <- data.frame(
                  package = as.character(v[, 'Package']),
                  name    = as.character(v[, 'Item']),
                  title   = NA_character_,
                  stringsAsFactors = FALSE
                )
              } else {
                rows <- data.frame(package=character(), name=character(), title=character())
              }
            }

            jsonlite::write_json(rows, path_tmp, dataframe = "rows", auto_unbox = TRUE)
            file.rename(path_tmp, path_final)
            invisible(TRUE)
          }, error = function(e) {
            jsonlite::write_json(list(__error__ = as.character(e)), path_tmp, auto_unbox = TRUE)
            file.rename(path_tmp, path_final)
            FALSE
          })
        }
        p_tmp   <- normalizePath("${tmpPath}",   winslash = "/", mustWork = FALSE)
        p_final <- normalizePath("${filePath}",  winslash = "/", mustWork = FALSE)
        write_list(p_tmp, p_final)
      `;

      await api.runtime.executeCode('r', r, false, false, 'Interactive' as RuntimeCodeExecutionMode);

      // Wait up to 3s for the file to appear
      const deadline = Date.now() + 3000;
      // eslint-disable-next-line no-constant-condition
      while (true) {
        try {
          await vscode.workspace.fs.stat(fileUri);
          break;
        } catch {
          if (Date.now() > deadline) {
            return { rows: [], error: 'Timed out waiting for tutorials.json to be written.' };
          }
          await new Promise((r2) => setTimeout(r2, 100));
        }
      }

      const buf = await vscode.workspace.fs.readFile(fileUri);
      const text = new TextDecoder().decode(buf);
      const parsed = JSON.parse(text);

      if (!Array.isArray(parsed) && parsed && parsed.__error__) {
        return { rows: [], error: String(parsed.__error__) };
      }

      const rows = Array.isArray(parsed) ? parsed : (parsed.rows || []);
      return { rows };
    } catch (e: any) {
      return { rows: [], error: `Failed to read tutorials file: ${String(e?.message || e)}` };
    }
  }

  private getHtml(): string {
    const nonce = String(Date.now());
    return `<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="Content-Security-Policy"
      content="default-src 'none'; style-src 'unsafe-inline'; script-src 'nonce-${nonce}';">
<style>
  body { font: 13px/1.4 var(--vscode-font-family); color: var(--vscode-foreground); padding: 8px; }
  #controls { display:flex; gap:6px; align-items:center; margin-bottom:8px; }
  #search { flex:1; padding:6px; }
  .row { display:grid; grid-template-columns: 1fr 1fr auto; gap:8px; align-items:center; padding:4px 0; }
  .hdr { font-weight:600; border-bottom:1px solid var(--vscode-editorWidget-border); padding-bottom:4px; }
  #error { color: var(--vscode-errorForeground); margin-top:4px; }
  #status { opacity:0.7; margin:4px 0; }
  button { padding:2px 6px; }
</style>
</head>
<body>
  <div id="controls">
    <input id="search" type="text" placeholder="Search tutorials or packages...">
    <button id="refresh">Refresh</button>
  </div>
  <div id="status"></div>
  <div id="error"></div>
  <div id="launch" style="margin:8px 0;"></div>
  <div class="row hdr"><div>Package</div><div>Tutorial</div><div>Action</div></div>
  <div id="table"></div>

  <script nonce="${nonce}">
    const vscode = acquireVsCodeApi();
    let rows = [];
    let filter = '';

    document.getElementById('search').addEventListener('input', (e) => {
      filter = (e.target.value || '').toLowerCase();
      render();
    });
    document.getElementById('refresh').addEventListener('click', () => {
      vscode.postMessage({ type: 'refresh' });
    });

    function render() {
      const table = document.getElementById('table');
      table.innerHTML = '';
      const data = rows.filter(r =>
        !filter ||
        String(r.package || '').toLowerCase().includes(filter) ||
        String(r.name || '').toLowerCase().includes(filter) ||
        String(r.title || '').toLowerCase().includes(filter)
      );
      for (const r of data) {
        const div = document.createElement('div');
        div.className = 'row';
        const pkg = document.createElement('div');
        pkg.textContent = r.package || '';
        const name = document.createElement('div');
        name.textContent = r.name || '';
        const act = document.createElement('div');
        const btn = document.createElement('button');
        btn.textContent = 'Run';
        btn.addEventListener('click', () => vscode.postMessage({ type: 'run', name: r.name, pkg: r.package }));
        act.appendChild(btn);
        div.appendChild(pkg);
        div.appendChild(name);
        div.appendChild(act);
        table.appendChild(div);
      }
    }

    window.addEventListener('message', (e) => {
      const msg = e.data || {};
      const statusEl = document.getElementById('status');
      const errorEl  = document.getElementById('error');
      const launchEl = document.getElementById('launch'); // make sure this exists in HTML

      if (msg.type === 'status') {
        statusEl.textContent = msg.message || '';
        return;
      }

      if (msg.type === 'data') {
        statusEl.textContent = '';
        errorEl.textContent = msg.error ? String(msg.error) : '';
        rows = Array.isArray(msg.rows) ? msg.rows : [];
        render();
        return;
      }

      if (msg.type === 'launched' && msg.url) {
        // Show a clickable URL for the running tutorial
        launchEl.innerHTML = '';
        const label = document.createElement('span');
        label.textContent = 'Tutorial URL: ';
        const a = document.createElement('a');
        a.href = msg.url;
        a.textContent = msg.url;
        a.target = '_blank';
        a.rel = 'noreferrer noopener';
        launchEl.appendChild(label);
        launchEl.appendChild(a);

        statusEl.textContent = '';
        errorEl.textContent = '';
        return;
      }

      if (msg.type === 'error' && msg.message) {
        statusEl.textContent = '';
        errorEl.textContent = String(msg.message);
      }
    });


    // initial load
    vscode.postMessage({ type: 'ready' });
  </script>
</body>
</html>`;
  }
}

// ---------- Activate and deactivate ----------

export function activate(context: vscode.ExtensionContext) {
  console.log('Positron Tutorial Helpers extension activated');

  // Exercise commands
  context.subscriptions.push(
    vscode.commands.registerCommand('makeExercise.code', () => runMakeExercise('code')),
    vscode.commands.registerCommand('makeExercise.no', () => runMakeExercise('no-answer')),
    vscode.commands.registerCommand('makeExercise.yes', () => runMakeExercise('yes-answer')),
    vscode.commands.registerCommand('makeExercise.pick', chooseExerciseType)
  );

  // Status bar
  const sb = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
  sb.text = '$(add) Exercise';
  sb.tooltip = 'Insert Exercise (choose type)';
  sb.command = 'makeExercise.pick';
  sb.show();
  context.subscriptions.push(sb);

  // Tutorials pane
  context.subscriptions.push(
    vscode.window.registerWebviewViewProvider(
      TutorialsViewProvider.viewId,
      new TutorialsViewProvider(context)
    ),
    vscode.commands.registerCommand('tutorialHelpers.showPane', async () => {
      await vscode.commands.executeCommand('workbench.view.extension.tutorialHelpers');
      await vscode.commands.executeCommand(`${TutorialsViewProvider.viewId}.focus`);
    })
  );
}

export function deactivate() {}



