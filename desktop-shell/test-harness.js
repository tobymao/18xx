// File: desktop-shell/test-harness.js
const fs = require('fs');
const path = require('path');

const TARGET_PATH = path.join(__dirname, 'src', 'current_game_state.json');

// State A: A fully formed, structurally ideal 1835 snapshot
const robustState = {
    game: "1835",
    operating_round: "OR 1.1",
    timeline: {
        current_phase: "Phase 2 (2-Train)",
        export_limit: 4
    },
    market: {
        current_prices: {
            "Prusse": 100,
            "Bavaria": 90,
            "Saxe": 75
        }
    },
    ledger: {
        error_simulation: false,
        recent_transactions: [
            "Prusse floated at 100M.",
            "Player Stefan purchased 1 Share of Bavaria."
        ]
    }
};

// State B: A chaotic, missing-key payload designed to break basic rendering loops
const chaosState = {
    game: "1835-MALFORMED-STRESS",
    operating_round: null,
    timeline: {}, // Missing current_phase keys
    market: {
        current_prices: null // Testing our nullish coalescing safety net
    },
    ledger: {
        error_simulation: true,
        recent_transactions: [] // Empty transaction array
    }
};

let toggle = true;

function runSimulation() {
    const payload = toggle ? robustState : chaosState;
    
    try {
        fs.writeFileSync(TARGET_PATH, JSON.stringify(payload, null, 2), 'utf-8');
        console.log(`[Test Harness] Successfully injected state: ${payload.game}`);
    } catch (err) {
        console.error(`[Test Harness] Failed to write file: ${err.message}`);
    }

    toggle = !toggle;
}

// Spin the harness to inject data updates every 5 seconds
console.log("Starting 18xx State Simulation Subsystem... Press Ctrl+C to terminate.");
setInterval(runSimulation, 5000);
runSimulation();