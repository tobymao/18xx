const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const fs = require('fs');

const windows = {};
const WINDOW_TYPES = ['Map', 'Timeline', 'Market', 'Ledger'];

function createTournamentWindow(type, index) {
    const win = new BrowserWindow({
        width: 850,
        height: 650,
        x: 80 + (index * 30),
        y: 80 + (index * 30),
        title: `18xx Tournament CC — ${type}`,
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            preload: path.join(__dirname, 'renderer.js')
        }
    });

    win.loadFile(path.join(__dirname, '../index.html'), { query: { view: type } });
    windows[type] = win;

    win.on('closed', () => { delete windows[type]; });
}

function initShell() {
    WINDOW_TYPES.forEach((type, index) => createTournamentWindow(type, index));
}

app.whenReady().then(() => {
    initShell();
    app.on('activate', () => { if (Object.keys(windows).length === 0) initShell(); });
});

app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });

ipcMain.handle('get-game-state', async () => {
    try {
        const filePath = path.join(__dirname, 'current_game_state.json');
        if (!fs.existsSync(filePath)) {
            return { error: `Waiting for active game state file at: ${filePath}` };
        }
        const data = fs.readFileSync(filePath, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        return { error: `Failed to read game state: ${error.message}` };
    }
});