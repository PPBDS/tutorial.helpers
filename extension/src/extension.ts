import * as vscode from 'vscode';
import { tryAcquirePositronApi, inPositron } from '@posit-dev/positron';
import type { RuntimeCodeExecutionMode } from '@posit-dev/positron';

async function runMakeExercise(type: string) {
  if (!inPositron()) {
    vscode.window.showErrorMessage('This command requires Positron with an active R session.');
    return;
  }

  const positronApi = tryAcquirePositronApi();
  if (!positronApi) {
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

  await positronApi.runtime.executeCode(
    'r',
    r,
    true,
    false,
    'Interactive' as RuntimeCodeExecutionMode
  );
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
  if (choice) {await runMakeExercise(choice.type);}
}

export function activate(context: vscode.ExtensionContext) {
  console.log('Make Exercise Positron extension activated');

  const cmdCode = vscode.commands.registerCommand('makeExercise.code', () => runMakeExercise('code'));
  const cmdNo   = vscode.commands.registerCommand('makeExercise.no',   () => runMakeExercise('no-answer'));
  const cmdYes  = vscode.commands.registerCommand('makeExercise.yes',  () => runMakeExercise('yes-answer'));
  const cmdPick = vscode.commands.registerCommand('makeExercise.pick', chooseExerciseType);

  const sb = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
  sb.text = '$(add) Exercise';
  sb.tooltip = 'Insert Exercise (choose type)';
  sb.command = 'makeExercise.pick';
  sb.show();

  context.subscriptions.push(cmdCode, cmdNo, cmdYes, cmdPick, sb);
}

export function deactivate() {}

