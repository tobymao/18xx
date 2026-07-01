// File: desktop-shell/src/main.js

const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const fs = require('fs');
const http = require('http');

// Spin up a zero-dependency local background server to host repository assets over HTTP
const localServer = http.createServer((req, res) => {
    try {
        const url = new URL(req.url, `http://${req.headers.host}`);
        let filePath = '';
        
        const isAsset = url.pathname.endsWith('.js') || 
                        url.pathname.endsWith('.css') || 
                        url.pathname.endsWith('.json') || 
                        url.pathname.endsWith('.svg');

        if (!isAsset && url.pathname.startsWith('/hotseat/')) {
            filePath = path.join(__dirname, '../index.html');
        } else {
            let cleanPath = url.pathname;
            
            // Normalize path routing for absolute asset paths requested by Opal scripts
            if (cleanPath.includes('/public/')) {
                cleanPath = '/public/' + cleanPath.split('/public/')[1];
            } else if (cleanPath.startsWith('/assets/') || cleanPath.startsWith('/images/')) {
                cleanPath = '/public' + cleanPath;
            }

            filePath = path.join(__dirname, '../..', cleanPath);
        }
        
        console.log(`[HTTP Server] Request: ${url.pathname} -> Resolved File: ${filePath}`);

        fs.readFile(filePath, (err, data) => {
            if (err) {
                res.statusCode = 404;
                res.end('Asset Not Found');
            } else {
                if (filePath.endsWith('.js')) res.setHeader('Content-Type', 'application/javascript');
                if (filePath.endsWith('.html')) res.setHeader('Content-Type', 'text/html');
                if (filePath.endsWith('.json')) res.setHeader('Content-Type', 'application/json');
                if (filePath.endsWith('.svg')) res.setHeader('Content-Type', 'image/svg+xml');
                res.end(data);
            }
        });
    } catch (serverError) {
        res.statusCode = 500;
        res.end('Internal Server Error');
    }
});
localServer.listen(8085, '127.0.0.1');


const windows = {};
let launcherWindow = null;
const WINDOW_TYPES = ['Map', 'Timeline', 'Market', 'Ledger'];

function createLauncherWindow() {
    launcherWindow = new BrowserWindow({
        width: 600,
        height: 450,
        title: "18xx Tournament — Setup Wizard",
        webPreferences: { nodeIntegration: true, contextIsolation: false }
    });

    launcherWindow.loadURL(`http://localhost:8085/hotseat/1830/launcher?view=launcher`);

    launcherWindow.webContents.openDevTools();
    launcherWindow.on('closed', () => { launcherWindow = null; });
}


function createTournamentWindow() {
    const win = new BrowserWindow({
        width: 1400,
        height: 900,
        title: "18xx Tournament Console",
        webPreferences: { nodeIntegration: false, contextIsolation: true }
    });

    // Load the living local server instance directly instead of a static asset hack
    win.loadURL(`http://localhost:9292/hotseat/1830/hs_zmzlzwyx_1782892264`);
}

ipcMain.on('initialize-engine', (event, config) => {
    // Open the single monolithic display panel view
    createTournamentWindow();
    if (launcherWindow) launcherWindow.close();
});
app.whenReady().then(() => { createLauncherWindow(); });
app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });