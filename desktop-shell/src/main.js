// File: desktop-shell/src/main.js

const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');

const windows = {};
let launcherWindow = null;
const WINDOW_TYPES = ['Map', 'Timeline', 'Market', 'Ledger'];

function createLauncherWindow() {
    launcherWindow = new BrowserWindow({
        width: 600,
        height: 450,
        title: "18xx Tournament — Setup Wizard",
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        }
    });

    launcherWindow.loadFile(path.join(__dirname, '../index.html'), { query: { view: 'launcher' } });
    launcherWindow.on('closed', () => { launcherWindow = null; });
}

function createTournamentWindow(type, index) {
    const win = new BrowserWindow({
        width: 850,
        height: 650,
        x: 80 + (index * 30),
        y: 80 + (index * 30),
        title: `18xx Tournament CC — ${type}`,
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        }
    });

    win.loadFile(path.join(__dirname, '../index.html'), { query: { view: type } });
    windows[type] = win;
    win.on('closed', () => { delete windows[type]; });
}

// Intercept the frontend launcher settings over IPC channel
ipcMain.on('initialize-engine', (event, config) => {
    console.log("[Main Process] Intercepted 'initialize-engine' event. Config:", config);
    const { gameType, players } = config;

    // Build a shell-safe, single-line command utilizing project bundler configurations
    const targetCommand = `bundle exec ruby -Ilib -e "require './lib/engine'; game = Engine::Game.const_get('${gameType}')::Game.new('${players.join(',')}'.split(',')); payload = { game: '${gameType}', operating_round: game.round.name, timeline: { current_phase: game.phase.current[:name] }, market: { current_prices: game.companies.each_with_object({}) { |c, h| h[c.id] = c.value } }, ledger: { error_simulation: false, recent_transactions: ['Game initialized with players: ${players.join(", ")}'] } }; File.write('desktop-shell/src/current_game_state.json', JSON.pretty_generate(payload))"`;

    console.log("[Main Process] Spawning login shell wrapper to evaluate local environment pathing...");

// Execute through an interactive shell context (-i) to natively preserve base environment paths
    const rubyProcess = spawn(process.env.SHELL || '/bin/zsh', ['-i', '-c', targetCommand], {
        cwd: path.join(__dirname, '../..'),
        env: process.env
    });

    rubyProcess.stdout.on('data', (data) => {
        console.log(`[Ruby Engine stdout]: ${data}`);
    });

    rubyProcess.stderr.on('data', (data) => {
        console.error(`[Ruby Engine stderr]: ${data}`);
    });

    rubyProcess.on('close', (code) => {
        console.log(`[Main Process] Background Ruby runtime execution finished with exit code ${code}`);
        if (code === 0) {
            console.log("[Main Process] State array written safely. Initializing dashboard layout windows...");
            WINDOW_TYPES.forEach((type, index) => createTournamentWindow(type, index));
            
            if (launcherWindow) {
                launcherWindow.close();
            }
        } else {
            console.error(`[Main Process] Ruby execution failed with non-zero status code: ${code}`);
        }
    });
});

app.whenReady().then(() => {
    createLauncherWindow();
    app.on('activate', () => { if (Object.keys(windows).length === 0 && !launcherWindow) createLauncherWindow(); });
});

app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });

// File-system monitor loop
const targetStateFile = path.join(__dirname, 'current_game_state.json');
fs.watch(targetStateFile, (eventType) => {
    if (eventType === 'change') {
        try {
            const rawData = fs.readFileSync(targetStateFile, 'utf8');
            const gameState = JSON.parse(rawData);
            Object.values(windows).forEach((win) => {
                if (!win.isDestroyed()) { win.webContents.send('game-state-update', gameState); }
            });
        } catch (error) {
            console.error("[Main Process Pipeline Error]:", error);
        }
    }
});