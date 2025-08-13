import * as vscode from 'vscode';
import { tryAcquirePositronApi, inPositron } from '@posit-dev/positron';

// Run R code quietly. Prefer NonInteractive to avoid clogging the Console,
// but fall back to Interactive on older Positron builds.
async function execR(code: string, requireComplete = true): Promise<void> {
  const api = tryAcquirePositronApi();
  if (!api) {
    throw new Error('Positron API not available.');
  }
  try {
    await api.runtime.executeCode('r', code, false, requireComplete, 'NonInteractive' as any);
  } catch {
    await api.runtime.executeCode('r', code, false, requireComplete, 'Interactive' as any);
  }
}

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

  await execR(r);
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

async function writeTempR(context: vscode.ExtensionContext, filename: string, code: string): Promise<vscode.Uri> {
  await vscode.workspace.fs.createDirectory(context.globalStorageUri);
  const uri = vscode.Uri.joinPath(context.globalStorageUri, filename);
  await vscode.workspace.fs.writeFile(uri, Buffer.from(code, 'utf8'));
  return uri;
}

async function sourceTempR(uri: vscode.Uri) {
  const p = uri.fsPath.replace(/\\/g, '/');
  const src = `source(normalizePath("${p}", winslash = "/"), echo = FALSE, print.eval = FALSE)`;
  await execR(src);
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

        const result = await this.fetchTutorials();
        webview.postMessage({ type: 'data', rows: result.rows, error: result.error });
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
    const start = Date.now();
    while (Date.now() - start < maxMs) {
      try {
        await execR('invisible(TRUE)');
        return undefined;
      } catch {
        await new Promise((r) => setTimeout(r, intervalMs));
      }
    }
    return 'R session is not running. Start R, then click Refresh.';
  }

  // Run only learnr::run_tutorial, and capture the local URL so the user can click it
  private async runTutorial(name: string, pkg: string, webview?: vscode.Webview) {
    const api = tryAcquirePositronApi();
    if (!api) {
      vscode.window.showErrorMessage('Positron API not available.');
      return;
    }

    await vscode.workspace.fs.createDirectory(this.context.globalStorageUri);
    const urlFile = vscode.Uri.joinPath(this.context.globalStorageUri, 'launch-url.txt');
    try {
      await vscode.workspace.fs.delete(urlFile);
    } catch {
      // ignore
    }
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

      options(shiny.launch.browser = capture_url, viewer = capture_url)

      learnr::run_tutorial(
        ${JSON.stringify(name)},
        package = ${JSON.stringify(pkg)},
        shiny_args = list(launch.browser = capture_url, host = "127.0.0.1")
      )
    `;

    await execR(r);

    // Wait up to 30s for the URL to appear
    const deadline = Date.now() + 30000;
    let url: string | undefined;
    while (Date.now() < deadline) {
      try {
        const buf = await vscode.workspace.fs.readFile(urlFile);
        const txt = Buffer.from(buf).toString('utf8').trim();
        if (txt) {
          url = txt;
          break;
        }
      } catch {
        // not yet
      }
      await new Promise((res) => setTimeout(res, 200));
    }

    if (!url) {
      vscode.window.showInformationMessage('Tutorial launched. If no browser opened, check the R Console or click Refresh and Run again.');
      return;
    }

    try {
      webview?.postMessage({ type: 'launched', url });
    } catch {
      // ignore
    }

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
    try {
      await vscode.workspace.fs.createDirectory(this.context.globalStorageUri);
  
      const fileUri  = vscode.Uri.joinPath(this.context.globalStorageUri, 'tutorials.json');
      const tmpUri   = vscode.Uri.joinPath(this.context.globalStorageUri, 'tutorials.tmp.json');
      const filePath = fileUri.fsPath.replace(/\\/g, '/');
      const tmpPath  = tmpUri.fsPath.replace(/\\/g, '/');
  
      // Long R code goes into a temp script, then we source() it quietly
      const rCode = `
        write_list <- function(path_tmp, path_final) {
          tryCatch({
            if (!requireNamespace("jsonlite", quietly = TRUE)) stop("Install 'jsonlite' first")
  
            rows <- NULL
            if (requireNamespace("learnr", quietly = TRUE)) {
              fun  <- learnr::available_tutorials
              args <- names(formals(fun))
              df   <- if ("all" %in% args) fun(all = TRUE) else fun()
              df   <- tryCatch(as.data.frame(df), error = function(e) NULL)
              if (!is.null(df) && nrow(df) > 0) {
                if (!"package" %in% names(df) && "pkg" %in% names(df)) names(df)[names(df) == "pkg"] <- "package"
                if (!"name"    %in% names(df) && "tutorial" %in% names(df)) names(df)[names(df) == "tutorial"] <- "name"
                if (!"title"   %in% names(df)) df$title <- NA_character_
                keep <- intersect(c("package","name","title"), names(df))
                df   <- df[, keep, drop = FALSE]
                df[] <- lapply(df, function(x) if (is.factor(x)) as.character(x) else x)
                rows <- df
              }
            }
  
            if (is.null(rows)) {
              v <- tryCatch(vignette()[["results"]], error = function(e) NULL)
              if (!is.null(v) && nrow(v) > 0) {
                rows <- data.frame(
                  package = as.character(v[, "Package"]),
                  name    = as.character(v[, "Item"]),
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
            # Write a simple error sentinel
            jsonlite::write_json(list(error = as.character(e)), path_tmp, auto_unbox = TRUE)
            file.rename(path_tmp, path_final)
            FALSE
          })
        }
  
        p_tmp   <- normalizePath("${tmpPath}",  winslash = "/", mustWork = FALSE)
        p_final <- normalizePath("${filePath}", winslash = "/", mustWork = FALSE)
        write_list(p_tmp, p_final)
      `;
  
      // helpers you already added earlier:
      //   writeTempR(context, filename, code)
      //   sourceTempR(uri)
      const scriptUri = await writeTempR(this.context, 'write-tutorials.R', rCode);
      await sourceTempR(scriptUri);
  
      // Wait up to 3s for the file to appear
      const deadline = Date.now() + 3000;
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
  
      const buf    = await vscode.workspace.fs.readFile(fileUri);
      const text   = Buffer.from(buf).toString('utf8');
      const parsed = JSON.parse(text);
  
      // Adjusted to match the new sentinel shape
      if (!Array.isArray(parsed) && parsed && (parsed as any).error) {
        return { rows: [], error: String((parsed as any).error) };
      }
  
      const rows = Array.isArray(parsed) ? parsed : ((parsed as any).rows || []);
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
      const msg = (e && e.data) ? e.data : {};
      let statusEl = document.getElementById('status');
      if (!statusEl) {
        statusEl = document.createElement('div');
        statusEl.id = 'status';
        document.body.prepend(statusEl);
      }
      let errorEl = document.getElementById('error');
      if (!errorEl) {
        errorEl = document.createElement('div');
        errorEl.id = 'error';
        document.body.prepend(errorEl);
      }
      let launchEl = document.getElementById('launch');
      if (!launchEl) {
        launchEl = document.createElement('div');
        launchEl.id = 'launch';
        document.body.insertBefore(launchEl, document.getElementById('table'));
      }

      switch (msg.type) {
        case 'status': {
          statusEl.textContent = msg.message || '';
          return;
        }
        case 'data': {
          statusEl.textContent = '';
          errorEl.textContent = msg.error ? String(msg.error) : '';
          rows = Array.isArray(msg.rows) ? msg.rows : [];
          render();
          return;
        }
        case 'launched': {
          if (msg.url) {
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
          }
          statusEl.textContent = '';
          errorEl.textContent = '';
          return;
        }
        case 'error': {
          statusEl.textContent = '';
          errorEl.textContent = String(msg.message || 'Unknown error');
          return;
        }
        default:
          return;
      }
    });

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

