#!/usr/bin/osascript -l JavaScript
/*
  Usage:
  osascript -l JavaScript snap.js left|right|top|bottom
  osascript -l JavaScript snap.js top-left|top-right|bottom-left|bottom-right
  osascript -l JavaScript snap.js left-third|center-third|right-third
  osascript -l JavaScript snap.js left-two-thirds|right-two-thirds
  osascript -l JavaScript snap.js maximize|center
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
    return { se, win: wins[0] };
}

function getDesktopBoundsForPoint(se, x, y) {
    const desktops = se.desktops();
    for (let i = 0; i < desktops.length; i++) {
        const b = desktops[i].bounds(); // [L,T,R,B]
        const L = b[0], T = b[1], R = b[2], B = b[3];
        if (x >= L && x <= R && y >= T && y <= B) return b;
    }
    return desktops[0].bounds();
}

function setRect(win, x, y, w, h, padding) {
    const p = (padding == null) ? 8 : padding;
    const nx = toInt(x + p);
    const ny = toInt(y + p);
    const nw = Math.max(200, toInt(w - 2 * p));
    const nh = Math.max(120, toInt(h - 2 * p));
    win.position.set([nx, ny]);
    win.size.set([nw, nh]);
}

(function main() {
    const action = ((getArgs()[0] || 'left') + '').toLowerCase();

    const { se, win } = getFrontWindow();

    const pos = win.position(); // [x, y]
    const size = win.size();    // [w, h]
    const cx = pos[0] + size[0] / 2;
    const cy = pos[1] + size[1] / 2;

    const db = getDesktopBoundsForPoint(se, cx, cy);
    const L = db[0], T = db[1], R = db[2], B = db[3];
    const W = R - L;
    const H = B - T;

    // helpers
    const third = W / 3;
    const twoThird = (2 * W) / 3;

    if (action === 'left') {
        setRect(win, L, T, W / 2, H, 8);
    } else if (action === 'right') {
        setRect(win, L + W / 2, T, W / 2, H, 8);

    } else if (action === 'top') {
        setRect(win, L, T, W, H / 2, 8);
    } else if (action === 'bottom') {
        setRect(win, L, T + H / 2, W, H / 2, 8);

    } else if (action === 'top-left') {
        setRect(win, L, T, W / 2, H / 2, 8);
    } else if (action === 'top-right') {
        setRect(win, L + W / 2, T, W / 2, H / 2, 8);
    } else if (action === 'bottom-left') {
        setRect(win, L, T + H / 2, W / 2, H / 2, 8);
    } else if (action === 'bottom-right') {
        setRect(win, L + W / 2, T + H / 2, W / 2, H / 2, 8);

    } else if (action === 'left-third') {
        setRect(win, L, T, third, H, 8);
    } else if (action === 'center-third') {
        setRect(win, L + third, T, third, H, 8);
    } else if (action === 'right-third') {
        setRect(win, L + 2 * third, T, third, H, 8);

    } else if (action === 'left-two-thirds') {
        setRect(win, L, T, twoThird, H, 8);
    } else if (action === 'right-two-thirds') {
        setRect(win, L + third, T, twoThird, H, 8);

    } else if (action === 'maximize') {
        setRect(win, L, T, W, H, 8);

    } else if (action === 'center') {
        const cw = W * 0.70;
        const ch = H * 0.80;
        const x0 = L + (W - cw) / 2;
        const y0 = T + (H - ch) / 2;
        setRect(win, x0, y0, cw, ch, 8);

    } else {
        setRect(win, L, T, W / 2, H, 8);
    }
})();
