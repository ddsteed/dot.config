#!/usr/bin/osascript -l JavaScript
/*
Usage:
  osascript -l JavaScript nudge.js dx dy dw dh
Example:
  nudge.js 40 0 0 0     # move right
  nudge.js 0 0 60 40    # resize bigger
*/

function toInt(n) { return Math.round(Number(n)); }

function getArgs() {
  ObjC.import('Foundation');
  const nsArgs = $.NSProcessInfo.processInfo.arguments;
  const args = [];
  for (let i = 0; i < nsArgs.count; i++) args.push(ObjC.unwrap(nsArgs.objectAtIndex(i)));
  return args.slice(4);
}

function getFrontWindow() {
  const se = Application('System Events');
  se.includeStandardAdditions = true;

  const procs = se.applicationProcesses.whose({ frontmost: { '=': true } });
  if (!procs || procs.length === 0) throw new Error('No frontmost application process found.');
  const proc = procs[0];

  const wins = proc.windows();
  if (!wins || wins.length === 0) throw new Error('No window found for the frontmost app.');
  return wins[0];
}

(function main() {
  const a = getArgs().map(x => toInt(x || 0));
  const dx = a[0] || 0;
  const dy = a[1] || 0;
  const dw = a[2] || 0;
  const dh = a[3] || 0;

  const win = getFrontWindow();
  const pos = win.position();
  const size = win.size();

  const nx = toInt(pos[0] + dx);
  const ny = toInt(pos[1] + dy);
  const nw = Math.max(200, toInt(size[0] + dw));
  const nh = Math.max(120, toInt(size[1] + dh));

  win.position.set([nx, ny]);
  win.size.set([nw, nh]);
})();

