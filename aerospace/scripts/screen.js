#!/usr/bin/osascript -l JavaScript
/*
  Usage:
  osascript -l JavaScript screen.js prev
  osascript -l JavaScript screen.js next

  Moves the frontmost window to the previous/next monitor (desktop bounds),
  keeping relative position as much as possible.
*/

function toInt(n) { return Math.round(Number(n)); }

function getArgs() {
    ObjC.import('Foundation');
    const nsArgs = $.NSProcessInfo.processInfo.arguments;
    const args = [];
    for (let i = 0; i < nsArgs.count; i++) args.push(ObjC.unwrap(nsArgs.objectAtIndex(i)));
    return args.slice(4);
}

function getFrontWindowAndSE() {
    const se = Application('System Events');
    se.includeStandardAdditions = true;

    const procs = se.applicationProcesses.whose({ frontmost: { '=': true } });
    if (!procs || procs.length === 0) throw new Error('No frontmost application process found.');
    const proc = procs[0];

    const wins = proc.windows();
    if (!wins || wins.length === 0) throw new Error('No window found for the frontmost app.');
    return { se, win: wins[0] };
}

function desktopsBounds(se) {
    const desktops = se.desktops();
    const arr = [];
    for (let i = 0; i < desktops.length; i++) {
        const b = desktops[i].bounds(); // [L,T,R,B]
        arr.push(b);
    }
    return arr;
}

function desktopIndexForPoint(boundsArr, x, y) {
    for (let i = 0; i < boundsArr.length; i++) {
        const b = boundsArr[i];
        if (x >= b[0] && x <= b[2] && y >= b[1] && y <= b[3]) return i;
    }
    return 0;
}

function clamp(v, min, max) { return Math.max(min, Math.min(max, v)); }

(function main() {
    const args = getArgs();
    const dir = (args[0] || 'next').toLowerCase();

    const { se, win } = getFrontWindowAndSE();
    const pos = win.position(); // [x,y]
    const size = win.size();    // [w,h]
    const cx = pos[0] + size[0] / 2;
    const cy = pos[1] + size[1] / 2;

    const bs = desktopsBounds(se);
    if (bs.length <= 1) return;

    const cur = desktopIndexForPoint(bs, cx, cy);
    const target = (dir === 'prev')
          ? (cur - 1 + bs.length) % bs.length
          : (cur + 1) % bs.length;

    const cB = bs[cur], tB = bs[target];
    const cL = cB[0], cT = cB[1], cR = cB[2], cBtm = cB[3];
    const tL = tB[0], tT = tB[1], tR = tB[2], tBtm = tB[3];

    const cW = cR - cL, cH = cBtm - cT;
    const tW = tR - tL, tH = tBtm - tT;

    // relative top-left in current monitor
    const relX = (pos[0] - cL) / cW;
    const relY = (pos[1] - cT) / cH;

    let nx = tL + relX * tW;
    let ny = tT + relY * tH;

    // keep window on-screen (basic clamp)
    nx = clamp(nx, tL + 8, tR - size[0] - 8);
    ny = clamp(ny, tT + 8, tBtm - size[1] - 8);

    win.position.set([toInt(nx), toInt(ny)]);
})();
