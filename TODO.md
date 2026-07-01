# 18XX TOURNAMENT TRACKING ENVIRONMENT MANIFEST

## 1. Project Overview & Current State
* **Core Milestone Reached:** The containerized decoupled backend engine is stabilized and listening natively on port 9292.
* **Architecture Strategy:** Transitioning the heavyweight visual tracking layers from a fragile Opal-compiled SPA web layout to a Headless Ruby processing pipeline paired with your robust, high-fidelity Native Java interface.
* **Data Interface Contract:** Java passes action lists -> Headless Ruby executes logical game state rules -> Ruby returns updated structural state JSON mappings directly back to Java.

## 2. Directory & File Structure Map
18xx/
├── Gemfile                     # Master Ruby dependency engine (STABILIZED)
├── Gemfile.lock                # Verified cross-platform multi-architecture locks
├── docker-compose.override.yml # Anonymous masking volumes and production ports
└── .rerun                      # Development engine path filter exclusion rules

## 3. Completed Progress Metrics
* [x] Bypassed architectural compilation limits on ARM64 by binding pre-compiled wheel binaries.
* [x] Decoupled host file leaks from container boundaries using anonymous named execution volumes.
* [x] Terminated the macOS framework recursive symlink watch trap using a hard path rule exception.
* [x] Completed database schema synchronization and verified local port connection binding on 9292.

## 4. Immediate Tasks for the Next Phase
- [ ] Implement `engine_pipe.rb`: Create a single-file, lightweight headless bridge script inside the Ruby layer to parse flat JSON action arrays without hitting standard Rails route blocks.
- [ ] Connect Java UI `ProcessBuilder`: Hook your native Java rails tracking layouts up to the headless Ruby execution string to capture data payloads seamlessly.
- [ ] Validate 1835 Initial State Arrays: Feed the backend pipeline the genuine initial parameters for 1835 (including national company relationships and the Prussian 5% distribution loops) to verify structural integrity.