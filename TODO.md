Markdown
# 18xx Universal Tournament Command Center — Project Roadmap

## Developer Setup Quickstart
Every time you open a new terminal or switch computers, run these commands to set up your shell path:
```bash
cd 18xx
conda activate env18xx

Phase 1: Data Extraction
[x] Extract core game engine states using host Ruby 3.4.5 environment
[ ] Automate compilation of active state drops straight into desktop-shell/src/current_game_state.json
Phase 2: Standalone Desktop Shell Setup
[x] Bypassed system-level dependency bottlenecks via isolated env18xx Conda sandbox
[x] Initialize Node 20+ execution base and register package.json
[x] Install native Electron dependencies inside the desktop-shell/ subdirectory
[x] Save multi-window controller script (src/main.js)
[x] Implement data bridge preloader (src/renderer.js) and foundational layout (index.html)
[x] Verify execution of the 4 independent floating dashboard panels (Map, Timeline, Market, Ledger)
Phase 3: Live View Integration [NEXT UP]
[ ] Render data payloads dynamically into each respective view layout
[ ] Wire up automated refreshing triggers whenever the JSON source updates

---

## Next Steps
We are ready to move to **Phase 3: Live View Integration** where we will start parsing your extraction payload so the Map window shows map data, the Market window shows stock positions, etc. 

Should we write a mock `current_game_state.json` directly into `desktop-shell/src/` right now to test the live presentation logic, or would you prefer to look at how the individual window layouts will differentiate themselves?