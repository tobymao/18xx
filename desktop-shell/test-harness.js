const fs = require('fs');
const path = require('path');

const targetPath = path.join(__dirname, 'src', 'current_game_state.json');

// Malformed/Empty test payload structure
const brokenState = {
    game: "1835-MALFORMED-TEST",
    operating_round: "UNKNOWN_OR",
    // Explicitly omitting the 'map' property to check fallback error tracking
    timeline: {}, // Empty view block
    market: {
        current_prices: null // Null field value test
    },
    ledger: {
        error_simulation: true,
        recent_transactions: ["System stress test initiated."]
    }
};

function runHarness() {
    console.log("=== Launching Shell Destruction Test ===");
    try {
        fs.writeFileSync(targetPath, JSON.stringify(brokenState, null, 2), 'utf8');
        console.log(`[SUCCESS] Injected broken test state into: ${targetPath}`);
        console.log("Action: Run 'npm start' now to inspect how your floating view consoles render missing keys.");
    } catch (err) {
        console.error(`[ERROR] Failed to write test file: ${err.message}`);
    }
}

runHarness();