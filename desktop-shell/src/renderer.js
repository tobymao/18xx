// File: desktop-shell/src/renderer.js
const { ipcRenderer } = require('electron');

window.addEventListener('DOMContentLoaded', () => {
    const params = new URLSearchParams(window.location.search);
    // Force lowercase to match your HTML element IDs securely
    const currentView = (params.get('view') || 'map').toLowerCase();
    
    const targetPanel = document.getElementById(`view-${currentView}`);
    if (targetPanel) {
        targetPanel.classList.add('active-view');
    }

    // Direct connection to the Electron broadcast channel
    ipcRenderer.on('game-state-update', (event, data) => {
        if (!data) {
            displayError('No data payload received from backend.');
            return;
        }
        
        switch (currentView) {
            case 'map':
                renderMapData(data.tiles_laid, data.tokens);
                break;
            case 'timeline':
                renderTimelineData(data.operating_round, data.timeline);
                break;
            case 'market':
                renderMarketData(data.market?.current_prices);
                break;
            case 'ledger':
                renderLedgerData(data.ledger);
                break;
        }
    });
});

function displayError(message) {
    const activePanel = document.querySelector('.active-view');
    if (activePanel) {
        activePanel.innerHTML += `<div style="color: #f38ba8; margin-top: 10px;">⚠️ Error: ${message}</div>`;
    }
}

function renderMapData(tiles, tokens) {
    const container = document.getElementById('map-content');
    const tileList = tiles && Object.keys(tiles).length > 0 
        ? Object.entries(tiles).map(([hex, tile]) => `<tr><td>${hex}</td><td>Tile ${tile}</td></tr>`).join('')
        : '<tr><td colspan="2">No active tiles placed on map.</td></tr>';

    container.innerHTML = `
        <table>
            <thead><tr><th>Hex Coordinate</th><th>Status/Tile No.</th></tr></thead>
            <tbody>${tileList}</tbody>
        </table>`;
}

function renderTimelineData(or, timeline) {
    const container = document.getElementById('timeline-content');
    const currentRound = or ?? 'Pre-Game Phase';
    const activePhase = timeline?.current_phase ?? 'Phase 1';
    
    container.innerHTML = `
        <p><strong>Operating Round:</strong> ${currentRound}</p>
        <p><strong>Active Game Phase:</strong> ${activePhase}</p>`;
}

function renderMarketData(prices) {
    const container = document.getElementById('market-content');
    if (!prices || Object.keys(prices).length === 0) {
        container.innerHTML = `<p style="color: #a6adc8; font-style: italic;">Market indexes offline. No current stock prices evaluated.</p>`;
        return;
    }

    const priceRows = Object.entries(prices).map(([company, price]) => 
        `<tr><td>${company}</td><td>${price} M</td></tr>`
    ).join('');

    container.innerHTML = `
        <table>
            <thead><tr><th>Company</th><th>Share Price</th></tr></thead>
            <tbody>${priceRows}</tbody>
        </table>`;
}

function renderLedgerData(ledger) {
    const container = document.getElementById('ledger-content');
    const logs = ledger?.recent_transactions ?? [];
    const isSimulated = ledger?.error_simulation ?? false;

    const logItems = logs.length > 0 
        ? logs.map(entry => `<li>${entry}</li>`).join('')
        : '<li>No recent transactions logged.</li>';

    container.innerHTML = `
        <p><strong>Simulation Execution Context:</strong> ${isSimulated ? 'Active Sandbox Strain' : 'Standard Pipeline'}</p>
        <h3>Transaction Registry</h3>
        <ul>${logItems}</ul>`;
}