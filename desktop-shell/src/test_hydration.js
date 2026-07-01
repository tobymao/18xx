const http = require('http');

console.log("[Test Routine] Querying local server cluster over port 8085...");

// Request the shared game state file over the server layer
http.get('http://127.0.0.1:8085/desktop-shell/src/current_game_state.json', (res) => {
    let rawData = '';
    res.on('data', (chunk) => { rawData += chunk; });
    res.on('end', () => {
        try {
            const parsedData = JSON.parse(rawData);
            console.log("\n=================== TEST RESULT ===================");
            console.log(`[*] HTTP Status Code: ${res.statusCode}`);
            console.log(`[*] Target Game Title: ${parsedData.title}`);
            console.log(`[*] Target Game ID:    ${parsedData.id}`);
            console.log(`[*] Total Game Actions: ${parsedData.actions ? parsedData.actions.length : 0}`);
            
            if (parsedData.id === "hs_zmzlzwyx_1782892264" && parsedData.title === "1830") {
                console.log("[SUCCESS] Real 1830 payload is alive and cleanly served via network context.");
            } else {
                console.log("[FAILURE] Server delivered wrong blueprint framework metadata format.");
            }
            console.log("===================================================\n");
        } catch (e) {
            console.error("[CRITICAL FAILURE] Could not parse JSON response stream data from local network.", e.message);
        }
    });
}).on('error', (err) => {
    console.error("[CRITICAL FAILURE] Local server unreached. Ensure Electron application is running.", err.message);
});