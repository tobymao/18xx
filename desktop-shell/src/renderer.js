const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('tournamentAPI', {
    getViewType: () => {
        const params = new URLSearchParams(window.location.search);
        return params.get('view') || 'Dashboard';
    },
    getGameState: () => ipcRenderer.invoke('get-game-state')
});

window.addEventListener('DOMContentLoaded', async () => {
    const params = new URLSearchParams(window.location.search);
    const viewType = params.get('view') || 'Dashboard';
    
    const titleEl = document.getElementById('view-title');
    if (titleEl) titleEl.innerText = `${viewType} Console`;

    const dataContainer = document.getElementById('data-payload');
    if (dataContainer) {
        const state = await ipcRenderer.invoke('get-game-state');
        
        if (state && state.error) {
            dataContainer.innerText = state.error;
            return;
        }

        // --- START FIX ---
        // Dynamically parse out only the properties matching this specific window view
        const lowerView = viewType.toLowerCase();
        
        if (state && state[lowerView]) {
            const viewData = {
                game: state.game,
                operating_round: state.operating_round,
                [lowerView]: state[lowerView]
            };
            dataContainer.innerText = JSON.stringify(viewData, null, 2);
        } else {
            // Fallback for unexpected or custom view types
            dataContainer.innerText = JSON.stringify({
                game: state.game,
                operating_round: state.operating_round,
                error: `No explicit data group found for view: ${viewType}`
            }, null, 2);
        }
        // --- END FIX ---
    }
});