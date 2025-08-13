# Positron Tutorial Helpers

Author: **Anish Talla**

A Visual Studio Code and Positron extension for R tutorial authors. It provides:

* A **Tutorials** pane that lists installed `learnr` tutorials with search and a **Run** button
* Quick commands that call `tutorial.helpers::make_exercise(...)` to insert exercise templates
* A status bar button for fast insertion

Runs best in **Positron** with an active R session.

Skip to Line 227 for Publishing Steps

VSIX File: https://drive.google.com/drive/u/2/folders/14Pxd9xvifYJsMG66lCkSL1bjPQFBm5v5

---

## Features

* Tutorials pane

  * Uses `learnr::available_tutorials()` when available, otherwise falls back to `vignette()`
  * Search by package, tutorial name or title
  * Run a tutorial and see a clickable URL inside the pane (you can also open it in your browser)
* Exercise helpers

  * Commands for `make_exercise("code" | "no-answer" | "yes-answer")`
  * Picker to choose the exercise type
* Console friendly

  * Large R blocks are written to a temp script and executed with `source(...)` to avoid flooding the Console

---

## Folder layout

This project is nested. Open the inner folder when you build and run.

```
tutorial.helpers/
└─ extension/
   └─ positron-tutorial-helpers/          <- open this folder in VS Code or Positron
      ├─ src/                             TypeScript source
      │  └─ extension.ts
      ├─ dist/                            Build output (generated)
      ├─ media/                           Icons and assets
      ├─ package.json                     Extension manifest
      ├─ package-lock.json
      ├─ tsconfig.json
      ├─ esbuild.js                       Bundler script
      ├─ eslint.config.mjs
      ├─ .vscodeignore
      ├─ README.md
      └─ CHANGELOG.md
```

If you keep the parent folder open, use a custom launch config that points at the nested folder. See Dev Host below.

---

## Prerequisites

* Positron or VS Code 1.99 or later
* R installed and on your PATH
* R packages

  * `learnr` for tutorials
  * `jsonlite` for JSON output
  * `tutorial.helpers` when inserting exercises
* Node.js 18 or later (Node 20 is fine)

---

## Development setup

From the nested folder:

```powershell
cd C:\Users\922485\tutorial.helpers\extension\positron-tutorial-helpers
npm ci
npm run compile
```

Open that folder in VS Code or Positron, then press **F5** to launch the Extension Development Host.

### Scripts

```powershell
# one time install	npm ci
# build once		npm run compile
# typecheck only	npm run check-types
# lint			npm run lint
# rebuild on change	npm run watch
```

---

## Run in the Extension Development Host

### Option A (simplest)

1. Open the nested folder: `positron-tutorial-helpers`
2. Build

   ```powershell
   npm ci
   npm run compile
   ```
3. Press **F5**

### Option B (keep parent folder open)

Create `.vscode/launch.json` in the parent folder `extension`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "extensionHost",
      "request": "launch",
      "name": "Run Extension (nested)",
      "runtimeExecutable": "${execPath}",
      "args": [
        "--extensionDevelopmentPath=${workspaceFolder}/positron-tutorial-helpers",
        "--extensions-dir=${workspaceFolder}/positron-tutorial-helpers/.dev-extensions",
        "--disable-workspace-trust"
      ],
      "outFiles": ["${workspaceFolder}/positron-tutorial-helpers/dist/**/*.js"],
      "preLaunchTask": "npm: compile (nested)"
    }
  ]
}
```

Create `.vscode/tasks.json` in the parent folder `extension`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "npm: compile (nested)",
      "type": "npm",
      "script": "compile",
      "path": "positron-tutorial-helpers",
      "group": { "kind": "build", "isDefault": true },
      "problemMatcher": "$tsc"
    }
  ]
}
```

Select **Run Extension (nested)** in the debug dropdown, then press **F5**.

---

## Using the extension

* Exercise insertion

  * Status bar button labeled `+ Exercise`
  * Command Palette

    * Insert Exercise: code
    * Insert Exercise: no-answer
    * Insert Exercise: yes-answer
    * Insert Exercise (choose type)
* Tutorials pane

  * Activity Bar icon: Tutorials
  * Pane: Installed Tutorials
  * Use the search box
  * Click **Run**
  * A link to the running tutorial appears above the table

Notes

* If R is still starting, the pane shows a waiting message
* Install `learnr` and `jsonlite` in R if missing

---

## Manifest overview

Key `package.json` entries (example):

```json
{
  "name": "positron-tutorial-helpers",
  "displayName": "Positron Tutorial Helpers",
  "publisher": "anishtalla27",
  "version": "0.1.0",
  "engines": { "vscode": ">=1.99.0" },
  "main": "./dist/extension.js",
  "activationEvents": [
    "onStartupFinished",
    "onLanguage:r",
    "onView:tutorialHelpers.tutorialPane",
    "onCommand:tutorialHelpers.showPane",
    "onCommand:makeExercise.code",
    "onCommand:makeExercise.no",
    "onCommand:makeExercise.yes",
    "onCommand:makeExercise.pick"
  ],
  "contributes": {
    "commands": [
      { "command": "makeExercise.code", "title": "Insert Exercise: code" },
      { "command": "makeExercise.no", "title": "Insert Exercise: no-answer" },
      { "command": "makeExercise.yes", "title": "Insert Exercise: yes-answer" },
      { "command": "makeExercise.pick", "title": "Insert Exercise (choose type)" },
      { "command": "tutorialHelpers.showPane", "title": "Tutorials: Show Pane" }
    ],
    "viewsContainers": {
      "activitybar": [
        { "id": "tutorialHelpers", "title": "Tutorials", "icon": "media/book.svg" }
      ]
    },
    "views": {
      "tutorialHelpers": [
        { "id": "tutorialHelpers.tutorialPane", "name": "Installed Tutorials" }
      ]
    }
  }
}
```

---

## Step by step publishing (Open VSX for Positron)

Positron uses Open VSX. Publish here so users can install your extension from Positron.

### One time tasks

1. Create an account at `open-vsx.org` and create or join the publisher namespace you will use. Example: `anishtalla27`.
2. In `package.json` set `publisher` to that exact namespace. Example: `"publisher": "anishtalla27"`.
3. Generate a Personal Access Token in your Open VSX account.

### Every release

1. Bump the `version` in `package.json` using semver
2. Build

   ```powershell
   cd C:\Users\922485\tutorial.helpers\extension\positron-tutorial-helpers
   npm ci
   npm run compile
   npm i -D @vscode/vsce ovsx
   ```
3. Package a VSIX (optional but useful)

   ```powershell
   npx vsce package
   $vsix = (Get-ChildItem -Filter *.vsix | Select-Object -First 1).FullName
   ```
4. Set your token for the session

   ```powershell
   $env:OVSX_PAT = "<YOUR_OPEN_VSX_PAT>"
   ```
5. Ensure your namespace exists (no harm if it already exists)

   ```powershell
   npx ovsx create-namespace anishtalla27 --pat $env:OVSX_PAT
   ```
6. Publish

   * Directly from the folder

     ```powershell
     npx ovsx publish --pat $env:OVSX_PAT
     ```
   * Or publish the VSIX you created

     ```powershell
     npx ovsx publish $vsix --pat $env:OVSX_PAT
     ```
7. Verify

   ```powershell
   npx ovsx view anishtalla27/positron-tutorial-helpers
   npx ovsx search "positron tutorial helpers"
   ```
8. Install in Positron

   * Open Positron, open Extensions, search for your display name or full id `anishtalla27.positron-tutorial-helpers`

### Common publish errors

* Namespace not found: run `ovsx create-namespace <your-namespace>` and make sure `publisher` in `package.json` matches it
* Not authorized: the PAT must belong to the same namespace as `publisher`
* Version already exists: bump `version`, rebuild, publish again
* ENOENT for `*.vsix`: run `npx vsce package` again and use the actual filename or publish from the folder

---

## Optional publishing to VS Code Marketplace

This is separate from Open VSX. Only needed if you want it in the VS Code Marketplace too.

1. Create a publisher at the Visual Studio Marketplace
2. Create an Azure DevOps PAT with Packaging scope
3. Login and publish

```powershell
npx vsce login <your-vscode-marketplace-publisher>
# publish using package.json version
npx vsce publish
# or publish a specific VSIX
npx vsce publish --packagePath .\positron-tutorial-helpers-X.Y.Z.vsix
```

---

## Keep the VSIX small

`.vscodeignore` should exclude sources and dev files so your VSIX only ships runtime assets.

Example `.vscodeignore`:

```
**/.git/**
**/.github/**
**/.vscode/**
src/**
out/**
tmp/**
.vscode-test/**
*.tsbuildinfo
**/*.map
.eslintrc.*
eslint.config.mjs
tsconfig.json
esbuild.js
```

---

## Versioning

* Use semver
* Bump patch for fixes, minor for features, major for breaking changes
* Every publish requires a new version

---

## Troubleshooting

* Dev host looks for `dist` in the wrong folder

  * Open the nested folder or use the nested launch config with `--extensionDevelopmentPath`
* Pane says no data provider

  * The view id in `package.json` must match the id you register in `registerWebviewViewProvider`
* Command already exists

  * An older installed copy may be active. Disable it in the dev host
* Cannot execute R code

  * Start an R session in Positron. The pane will wait and then load
* `learnr` or `jsonlite` not found

  * Install them in R: `install.packages("learnr")` and `install.packages("jsonlite")`
* Console is flooded with code

  * Use the temp script plus `source(...)` approach (already implemented)

---

## License

MIT. Add a `LICENSE` file to your repository if not already present.
