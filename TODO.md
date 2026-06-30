Markdown
# 18xx Universal Tournament Command Center — Project Roadmap & Handover Prompt

Git Synchronization & Repository Tracking
This project is securely tracked upstream. Use these commands to sync your progress between your Apple Intel and Apple Silicon hosts:
Repository Link: https://github.com/sbleeck/18xx-tournament.git
To pull latest changes before starting work:
```bash
git pull origin main
To save and push changes at the end of a session:
Bash
git add .
git commit -m "Describe your changes"
git push origin main
1. Project Overview & Current State
Main Question: How do we transform live serialized JSON engine arrays into highly readable, responsive semantic layout panels for tournament environments without causing process-level thread blocking?
Pipeline Architecture:
[Ruby Game Engine Engine State] ──> Drops JSON ──> [desktop-shell/src/current_game_state.json] ──> Native fs.watch Broadcast ──> [src/main.js IPC WebContents] ──> Secure IPC Consumer ──> [src/renderer.js DOM Injection] ──> View Layouts ──> [index.html Framework Panels]
2. Directory & File Map
18xx/                               # Project Repository Root
├── TODO.md                         # Active project tracking documentation (UPDATED)
├── .gitignore                      # Configured to ignore desktop-shell/node_modules/
├── rip18xx/                        # Legacy folder (obsolete)
└── desktop-shell/                  # Isolated Desktop Application Subsystem
    ├── package.json                # Shell dependency manifest and start script routing
    ├── index.html                  # Unified HTML template view utilized by all 4 frames
    ├── test-harness.js             # Simulation utility for injecting broken/empty data states
    └── src/
        ├── main.js                 # Electron Main Process (Active FS watcher & IPC broadcast loop)
        ├── renderer.js             # Electron Renderer Layer (Case-insensitive parameter routing)
        └── current_game_state.json # Active target landing strip for live engine metrics
3. Active Progress Metrics
Phase 1: Data Extraction
[x] Bypassed container virtualization restrictions to interact directly with host Ruby 3.4.5 binaries.
[x] Re-aligned backend pipeline target to deposit live state data arrays straight into desktop-shell/src/current_game_state.json.
Phase 2: Standalone Desktop Shell Setup
[x] Resolved environment performance and dependency blockages by constructing a dedicated env18xx Conda environment utilizing Node v20.
[x] Formulated explicit asset dependency trees via a clean package.json manifest layer.
[x] Coded a centralized window orchestration manager (src/main.js) capable of cascading 4 concurrent window structures across the host display workspace.
Phase 3: Live View Integration & Data Telemetry
[x] Resolved IPC window boundary insulation limits using clean native ipcRenderer configurations.
[x] Implemented case-insensitive URL query parameter formatting (.toLowerCase()) to eliminate silent structural look-up failures between Electron window titles and HTML element IDs.
[x] Embedded an automated filesystem state watcher using fs.watch inside src/main.js to automatically broadcast data payloads when changes are written to disk.
[x] Developed and verified an automated test harness (test-harness.js) to prove rendering stability against both ideal structures and missing/null values without causing software crashes.
Phase 4: Semantic Presentation Layouts (IN PROGRESS)
[x] Constructed functional layout wireframes for all four core panels within a single unified markup tree.
[ ] Enhance CSS grid styling rules inside index.html to separate corporate data matrices cleanly.
[ ] Map out actual 1835 entity data structures (e.g., Pre-Game phase variants, direct player certificate arrays) into scannable views.
4. Next Steps for Next Thread Execution
The underlying backend monitoring loops, data telemetry, and multi-window routing systems are verified and streaming fluidly. The current goal is to transform the functional wire tables into visually polished dashboards:
Map Display Improvements: Format the layout of tiles_laid into block components resembling physical tracks.
Market Pricing Boards: Arrange corporate values into a grid matching classical 18xx stock boards, emphasizing color changes when tracking metrics shift.
Ledger Layouts: Separate transaction lists chronologically, and add targeted alert warnings (e.g., text highlighting when a company's treasury dips near zero or capital values change drastically).