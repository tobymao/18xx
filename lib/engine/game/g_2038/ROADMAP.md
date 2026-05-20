# 2038: Tycoons of the Asteroid Belt — Implementation Roadmap

## Current State Assessment

**What's in good shape:**
- `meta.rb` — solid, minimal changes needed
- `game.rb` — good skeleton: market, phases, train list (XdYc naming), corporation groups, AL event hooks
- `step/waterfall_auction.rb` — the auction structure is working, minor capitalization logic is there
- `2038 Feature List` — confirms the developer already thought through the scope

**What needs significant work:**
- `entities.rb` — has bugs and missing mechanics (see Phase 1)
- `map.rb` — tiles are placeholder-quality; unexplored hex behavior not wired up
- No step files beyond the auction
- No custom route/train runner (the biggest engineering challenge)
- No claim/mine/exploration system

---

## Recommended File Structure (New Steps Needed)

```
g_2038/
  step/
    waterfall_auction.rb           ← exists
    special_track.rb               ← exploration/tile draw during routing
    buy_sell_par_shares.rb         ← custom stock round with growth corp launch
    operating_round.rb             ← custom OR entity ordering
    route.rb                       ← spaceship route runner (XdYc model)
    buy_spaceship.rb               ← mandatory ship purchase logic
    buy_infrastructure.rb          ← bases, refueling stations, claims
    form_growth_corporation.rb     ← independent → Growth Corp (cf. 1835 FormPrussian)
    form_asteroid_league.rb        ← AE owner triggers AL (cf. 1835 FormPrussian)
    merge_into_league.rb           ← independents join AL (cf. 1835 MergeToPrussian)
```

---

## Phase 1: Entity & Data Fixes (Prerequisite for everything else)

**Goal:** Get the data layer correct before building mechanics on top of it.

### 1a. Fix `entities.rb`
- [x] Fix Torch minor: `sym: 'TT'` → `sym: 'TH'`
- [x] Fix Ice Finder minor: `coordinates: 'G7'` → `coordinates: 'M13'`
- [x] Fix VP corporation: `coordinates: 'J1'` → `coordinates: 'J2'` (J1 is not on the map)
- [x] Fix all corporation `type:` values from strings to symbols (were `'group_a'` etc.; `game.rb` compares with `:group_a` — would silently break group partitioning)
- [x] Fix AL `type: 'groupD'` → `type: :group_d` (inconsistent casing and wrong type)
- [x] Fix `color: :'#xxxxxx'` (Ruby symbol) → `color: '#xxxxxx'` (string) for VP, OPC, RCC, AL
- [x] Remove placeholder `tile_lay` abilities from TS, VA, RS; replaced with TODO comments pointing to Phase 5
- [x] Fix AE's `when: ['Phase 3', 'Phase 4']` → `when: %w[3 4]` to match framework phase name strings
- [x] Fix same `when:` guard on all independent company exchange abilities (FB, IF, DH, OC, TH, LY)
- [ ] Verify that the dual COMPANIES/MINORS structure (same sym appears in both) works correctly in the framework — COMPANIES is the auctioned certificate, MINORS is the operating entity

### 1b. Fix `map.rb`
- [x] Fix LOCATION_NAMES typo: `'J18' => 'OCP'` → `'J18' => 'OPC'`
- [x] Ice Finder LOCATION_NAMES entry was already correct at M13 — the bug was only in the MINORS coordinates (fixed in 1a)
- [x] Revise asteroid tile definitions (2001–2022) to correctly model N/I/R labels, ore shade system (N: 2 shades, I/R: 3 shades), and unclaimed/claimed revenue values from physical tile counts
- [x] Verify double-mine tile structure — `city=;city=` with DP6 paths connecting all 6 edges to junction + both cities
- [x] Define base tile 2023 (gray, count=40) — junction + revenue:0 city; placed when a corp establishes a base
- [x] Add Lawson junction track to all mine tiles via SP6/DP6 path constants; set `TILE_TYPE = :lawson` in game.rb
- [x] Add invisible-track junction paths to all blue unexplored hexes (pre-printed in HEXES, not in TILES)
- [ ] Verify all remaining LOCATION_NAMES coordinates are correct
- [ ] Add mechanism to track which hexes have been explored (deferred to Phase 5)

### 1c. Fix spaceship train data model
- [x] **Naming convention:** Spaceships are now named `movement/cargo_holds` (e.g. `'3/2'`, `'5/1'`) matching the physical spaceship cards. `distance:` holds movement points; `cargo_holds:` is the custom field for max mine pickups. All phase `on:` triggers, `rusts_on:` arrays, and `discount:` keys updated to match.
- [x] **Added `cargo_holds:` field** to every entry in TRAINS (top-level and variants). The base engine stores unknown keys safely in `Train#@opts` — no errors. A `G2038::Train` subclass (Phase 4) will expose `cargo_holds` as a proper accessor; until then readable via `train.instance_variable_get(:@opts)[:cargo_holds]`.
- [x] **Added `rusts_on:` to variant sub-hashes** — they were previously missing from variants, meaning the engine would use the primary train's rusts_on for all variants of a group.
- [x] **Probe documented:** 4 movement, 0 cargo holds. Belongs to TSI; not bought from bank. Retirement on TSI's first real spaceship purchase is handled by the ST private's close ability. Full probe modeling deferred to Phase 6.
- [ ] Verify train obsolescence (`rusts_on:`) matches the rules chart exactly — deferred to Phase 6 when probe retirement logic is implemented.

---

## Phase 2: Auction Round

**Goal:** Complete the initial auction so the game can start.

- [ ] **2a. Verify minor capitalization rounding** — rule is `$100 + ½ of (price - $100)`, rounded down. Current code: `capital = (price - 100) / 2`. Confirm this is correct integer division.
- [ ] **2b. TSI share distribution** — when ST is bought, buyer gets TSI president cert and TSI is parred at $100 (full) or $67 (short game). Verify `after_buy_company` in game.rb works; confirm MARKET array has `100p` and `67p` par values at the right positions.
- [ ] **2c. AE certificate timing** — AE is sold in Phase 1 but grants the AL president cert only in Phase 3/4. Add a hook at Phase 3 start that gives AE's owner the AL president certificate (AL must already exist in `@corporations` via `event_asteroid_league_can_form!`).
- [ ] **2d. All-pass resolution** — verify that `all_passed!` → `round_end_auction_complete` correctly resolves all pending bids on independents before transitioning to the stock round.
- [ ] **2e. Auction ordering** — confirm companies are auctioned in order "0" through "11" (PI, then TS/VA/RS/ST/AE as privates, then FB/IF/DH/OC/TH/LY as independents)

---

## Phase 3: Operating Round Structure

**Goal:** Implement the OR sequence and independent/corporation turn flow.

- [x] **3a. OR entity ordering** — `operating_order` in `game.rb` returns independents in MINOR_OPERATING_ORDER (FB→IF→DH→OC→TH→LY), then floated corporations sorted via `Corporation#sort_order_key` (descending price, then top-to-bottom within same price box — matches the 2038 rule exactly). TSI probe deferred to Phase 6.
- [x] **3b. Private company income** — `payout_companies` (called in base `Round::Operating#setup`) handles all private revenues. `G2038::Round::Operating#setup` calls `super` then adds Fast Buck's $15 to its minor treasury separately (FB has `revenue: 0` so it's skipped by the base payout).
- [x] **3c/3d. Turn sequence scaffolding** — `operating_round` in `game.rb` uses `G2038::Round::Operating` with a step stack: `Bankrupt`, `DiscardTrain`, `BuyTrain` (placeholder), `BuyCompany` (blocks, for corps buying privates). TODO stubs for Route, Dividend, PlaceBase, PlaceRefuelingStation, PlaceClaim are in place with Phase labels.
- [x] **3e. OR cleanup hook** — `or_round_finished` overrides the base no-op; TODO Phase 5 stubs for Used Mine removal and Claim marker flip are in place.

---

## Phase 4: Spaceship Routing (Biggest Engineering Challenge)

**Goal:** Implement the custom route runner for XdYc spaceships.

- [ ] **4a. Hex-based movement model** — override `route_distance(route)` to count hex transitions (cf. 18Ireland):
  ```ruby
  route.chains.sum { |conn| hex_edge_cost(conn) }
  ```
- [ ] **4b. Dual constraint enforcement** — override `check_distance` to enforce both:
  - hex count ≤ movement points (second number)
  - pickup count ≤ cargo holds (first number)
- [ ] **4c. Route origin/destination rules**:
  - [ ] Route must **start** at one of the company's bases
  - [ ] Route must **end** at any base OR a transshipment point
  - [ ] Ending at a transshipment point with an **empty** cargo hold earns the lower (transshipment) value
- [ ] **4d. Refueling station bonus** — when a ship belonging to the owning corporation enters a refueling station hex, remaining MPs are bumped to `min(3, original_movement_allowance)`
- [ ] **4e. Used Mine enforcement** — only one pickup per mine per OR; place Used Mine marker after pickup selection is confirmed (not mid-route); cannot pick up at a Used Mine
- [ ] **4f. Claimed mine access** — any ship can pick up at unclaimed mines (lower value); only the owning company's ships can pick up at claimed mines (higher value)
- [ ] **4g. Route valuation and pickup selection**:
  - [ ] After the player confirms their full route path, present a list of all eligible pickups along that path
  - [ ] Pre-populate with the highest-scoring combination (up to cargo hold limit) as the default selection
  - [ ] Player may override the selection before confirming
  - [ ] Revenue = sum of confirmed pickup values + delivery bonuses from destination base
  - [ ] See Architectural Decision C for implementation details
- [ ] **4h. Exploration mid-route (see also Phase 4i)**:
  - [ ] Spending 1 extra MP on an unexplored hex draws a random tile from the bag and places it immediately (visible to all players)
  - [ ] Owning company receives $10 exploration bonus to treasury (not counted as route revenue)
  - [ ] Explored hex can be passed through without exploring (no extra MP needed once explored)
  - [ ] Drawn tile is placed into `@mine_state` immediately upon draw
- [ ] **4i. Exploration undo policy** — tiles are revealed immediately when drawn (faithful to physical game). Undo is permitted but any undo during an OR is permanently logged to the game chat as *"Player X undid actions [step Y through step Z]"* so other players can police peeking. See Architectural Decision B for full implementation requirements.
- [ ] **4j. Multiple ships per company** — more than one ship can operate per OR; each runs one route separately

---

## Phase 5: Mine, Claim & Base Infrastructure

**Goal:** Implement persistent state objects for claims, bases, and refueling stations.

- [ ] **5a. Asteroid tile state** — for each explored hex, track:
  - [ ] Number of mines (1 or 2) and ore type per mine (N/I/R)
  - [ ] Unclaimed value and claimed value per mine
  - [ ] Which company (if any) owns a claim on each mine
  - [ ] Whether there is a Used Mine marker on each mine this OR
  - [ ] Recommendation: store in a `@mine_state` hash on game object; override `revenue_for_stop` to look up dynamically
- [ ] **5b. Claims**:
  - [ ] Cost $60 for first claim per round, $100 for second; RU's first claim each round is free (i.e. $0/$100); AL may place 3: $60/$75/$100
  - [ ] Must be within range of at least one of the company's spaceships
  - [ ] Mark the mine as claimed by that company
  - [ ] Claims are permanent; cannot be removed or transferred
  - [ ] Cannot place a claim on a mine that already has one
- [ ] **5c. Bases**:
  - [ ] Cost $50 (exception: Mars Mining pays $25)
  - [ ] Placed on any explored asteroid tile that doesn't already have a **claim** on it
  - [ ] Flip tile to its gray base side when placed
  - [ ] Mark hex as a route starting point for that company
  - [ ] Only one base may be placed per round per company
- [ ] **5d. Refueling stations**:
  - [ ] Cost $50 (exceptions per corp — see Company and Corporation Summary)
  - [ ] Must be placed at **any** base within range of the placing corporation's spaceships — the base does not need to belong to the placing corporation (rule 7.42); whichever corporation places a refueling station at a base first owns it
  - [ ] Grants +3 MP (capped at ship's max) to ships of the owning company
  - [ ] Only one refueling station per base

---

## Phase 6: TSI Probe

**Goal:** Model TSI's special probe mechanics.

- [ ] **6a. Probe entity** — model the probe as a special entity belonging to TSI (not a purchasable train)
- [ ] **6b. Probe operation** — before independents operate each OR: if TSI has not yet bought a spaceship, the ST private owner flies the probe from TSI's base; exploration bonuses ($10/hex) go to TSI's treasury; no revenue earned
- [ ] **6c. Probe retirement** — when TSI buys its first spaceship, ST is removed from the game and the probe is retired (the `close: { when: 'bought_train', corporation: 'TSI' }` ability on ST handles the closure; verify probe retirement is also triggered)
- [ ] **6d. Inactive TSI fallback** — if TSI is not active, the owner of the Space Transportation Co. (ST) flies the probe from the TSI base

---

## Phase 7: Independent Company Special Abilities

**Goal:** Wire up each independent's unique ability.

- [ ] **Fast Buck (FB)** — $15/round added to its treasury (like a private company income; already partially modeled)
- [ ] **Ice Finder (IF)** — $10 bonus per Ice ore delivered; must draw a second tile when exploring if the first tile drawn has no Ice mines
- [ ] **Drill Hound (DH)** — $10 bonus per Rare ore delivered; must draw a second tile when exploring if the first tile drawn has no Rare mines
- [ ] **Ore Crusher (OC)** — $10 bonus per Nickel ore delivered
- [ ] **Torch (TH)** — all Torch spaceships get +1 movement point
- [ ] **Lucky (LY)** — draws 2 tiles when exploring a hex, then chooses which to place (discard the other)
- [ ] **Pilot bonuses** — when an independent forms a Growth Corporation or merges into the AL, its pilot certificate transfers to the new corporation and provides the same bonuses to one assigned spaceship per OR

---

## Phase 8: Growth Corporation Formation

**Goal:** Allow independents to convert into Growth Corporations.

Reference: `g_1835/step/form_prussian.rb` and `game.rb::merge_entity_to_prussian!()`.

- [ ] **8a. Trigger** — player announces conversion during their stock round turn (Phases 2 or 3, before the Asteroid League forms)
- [ ] **8b. Create `step/form_growth_corporation.rb`** — handles the conversion sequence:
  - [ ] Player selects an available Growth Corporation president's certificate (20%)
  - [ ] Independent's spaceship(s) transfer to new Growth Corp
  - [ ] Independent's base, claims, and remaining cash transfer to new Growth Corp
  - [ ] Independent's certificate replaced by Growth Corp president's certificate
  - [ ] Growth Corp starts with stock price $10, par $67
  - [ ] Growth Corp is immediately active
  - [ ] Pilot certificate transfers to Growth Corp (placed in corp until Phase 5)
  - [ ] Independent is removed from the game
- [ ] **8c. Corporation group unlocking** — Groups unlock when all corps of the previous group have been launched (already in `after_par` in game.rb; verify logic):
  - Group A: TSI, RU (available from start)
  - Group B: VP, LE, MM (unlock when all Group A launched)
  - Group C: OPC, RCC (unlock when all Group B launched)
- [ ] **8d. Growth Corp stock round behavior** — Growth Corp shares purchased from the Growth share box go to its treasury; Public Corp shares go to bank

---

## Phase 9: Asteroid League Formation

**Goal:** Model the AL formation, analogous to the Prussian in 1835.

Reference: `g_1835/step/form_prussian.rb` and `step/merge_to_prussian.rb`.

- [ ] **9a. Formation trigger** — AE owner may form the AL when Phase 3 begins; if they don't, they may do so at the start of any Phase 3/4 Stock or Operating Round; it **must** form before Phase 4 begins
- [ ] **9b. Create `step/form_asteroid_league.rb`**:
  - [ ] AE owner declares formation, receiving the AL president's certificate (they already held AE)
  - [ ] AL starts with $250 capital
  - [ ] AL par value: $125
  - [ ] AE is removed from the game after AL acquires a spaceship (`close: { when: 'bought_train', corporation: 'AL' }` — already in entities.rb)
- [ ] **9c. Voluntary mergers** — in clockwise order after AL forms, each independent may merge:
  - [ ] Owner receives ½ of independent's treasury cash (rounded down)
  - [ ] Owner receives 1 AL share (10%)
  - [ ] Independent's spaceship(s), base, and claims transfer to AL
  - [ ] Pilot certificate transfers to AL
  - [ ] Independent is removed from the game
- [ ] **9d. Create `step/merge_into_league.rb`** — handles the sequential merge offers per clockwise player order
- [ ] **9e. Mandatory merger at Phase 5** — any independent still operating at the start of Phase 5 must join the AL; enforce this
- [ ] **9f. Mandatory merger on bankruptcy** — an independent that cannot buy a required spaceship (7.39) must merge into the AL
- [ ] **9g. AL ship limits** — AL may not buy its last spaceship (reducing it to zero); no one may buy the AL's last spaceship (7.37)
- [ ] **9h. AL reserve bases/claims** — AL must reserve 1 base and 2 claims for each remaining independent that has not yet merged (8.12)

---

## Phase 10: Private Company Special Abilities (Post-Auction)

**Goal:** Wire up TS, VA, RS special abilities when owned by corporations.

- [ ] **Tunnel Systems (TS)** — once per OR when owned by a corp: place 1 free base on any explored, unclaimed tile (anywhere on the map, not just within range)
- [ ] **Vacuum Associates (VA)** — once per OR when owned by a corp: place 1 free refueling station within range of the owning corporation's spaceships
- [ ] **Robot Smelters (RS)** — once per OR when owned by a corp: place 1 free claim within range of the owning corporation's spaceships
- [ ] Replace placeholder `tile_lay` ability types in entities.rb with the correct custom ability types for all three

---

## Phase 11: Endgame & Scoring

**Goal:** Implement bankruptcy detection and final scoring.

- [ ] **11a. Bank depletion** — when the bank runs out during an OR, complete that OR; then play one more SR + 2 ORs; then end the game
- [ ] **11b. Bankruptcy** — if a corporation president cannot fund a required spaceship purchase (even after selling all personal shares), the game ends immediately
- [ ] **11c. Final scoring**:
  - [ ] Each player's score = cash on hand + stock portfolio value (at current stock prices) + face value of any Private Companies still held (if game ends before Phase 5)
  - [ ] Assets held in company/corporation treasuries do not count for players
  - [ ] AL shares count at AL's current stock price
  - [ ] Implement "spreadsheet" mode for final OR (see Let's Play! Figure 10)

---

## Phase 12: Frontend Artwork — Corporation Token Photography

**Goal:** Replace the SVG text logos with photographic images of the actual physical counter artwork for the final release.

- [ ] **12a. Photograph each counter** — high-res photos of the physical TSI, RU, VP, LE, MM, OPC, RCC, and AL counters; crop to the token face and export as square PNG or SVG-embedded image
- [ ] **12b. Replace SVG placeholders** — update `public/logos/g_2038/{CORP}.svg` with the photographic version; keep the `.alt.svg` as the simplified text circle (it renders too small for photos to be legible)
- [ ] **12c. Verify rendering** — check token display on the map, in the stock market panel, and on the entity cards at various zoom levels

---

## Phase 13: Frontend Artwork — Asteroid Mine Tile Rendering

**Goal:** Give mine tiles 2001–2022 the visual appearance of the physical game tiles.

Physical description: a grayish-purple asteroid with craters in the foreground, on a dark purplish-black starfield with small pinpoints of light in white, red, and blue.

- [ ] **13a. Create game-specific SVG tile renderer** — add `assets/app/view/game/g_2038/` and create a custom tile rendering component that overrides the default solid-color fill for tiles with IDs 2001–2022
- [ ] **13b. Starfield background layer** — dark purplish-black fill (`#1a0a20` or similar) with randomly seeded but deterministic pinpoints of light in white, red, and blue; use tile ID as RNG seed so the same tile always looks the same
- [ ] **13c. Asteroid foreground layer** — grayish-purple irregular blob (`#8a7a9a` or similar) with crater markings (small filled circles with dark ring) rendered in SVG
- [ ] **13d. Overlay mine data readably** — ensure N/I/R label, revenue values, and double-mine second city are still clearly legible over the artwork
- [ ] **13e. Base tile (2023)** — solid dark gray fill is fine; no starfield needed since this represents a developed asteroid

---

## Recommended Implementation Order

1. - [ ] Phase 1 — Data fixes (foundation for everything)
2. - [ ] Phase 3a — OR structure (needed to test anything)
3. - [ ] Phase 4a–4b — Basic routing without exploration (get ships running)
4. - [ ] Phase 5 — Mine/claim state (needed for routing to earn revenue)
5. - [ ] Phase 4c–4i — Exploration mid-route
6. - [ ] Phase 7 — Independent special abilities
7. - [ ] Phase 2 — Complete auction mechanics
8. - [ ] Phase 6 — TSI probe
9. - [ ] Phase 8 — Growth Corp formation
10. - [ ] Phase 9 — Asteroid League formation
11. - [ ] Phase 10 — Private company post-auction abilities
12. - [ ] Phase 11 — Endgame scoring

---

## Key Architectural Decisions

### A. Mine revenue model
- [x] **Chosen approach:** Store mine state in a `@mine_state` hash on the game object; override `revenue_for_stop` to look up claimed/unclaimed values dynamically. Do **not** bake revenue into static tile codes.
- [x] **Bases and mines are mutually exclusive on a hex.** Placing a base flips the asteroid tile to its gray base side, which has no mines. Therefore `@mine_state` only ever needs to track un-based explored hexes. Once a base token is placed, that hex drops out of mine consideration entirely — no need to check for base+claim conflicts at the code level (the rules already prevent it: bases can only be placed on tiles without claims, and the flip removes mines).

### B. Exploration undo policy
- [x] **Chosen approach:** Stay fully faithful to the physical game — asteroid tiles are revealed immediately when explored, mid-route. Undo is **not** blocked. Instead, any undo action during an operating round is permanently logged to the game log with a visible announcement so other players can police suspected peeking.

  **How the engine works (important context):**
  - When an undo arrives, `Game::Base#process_action` immediately calls `return clone(@raw_actions)` — the game is completely rebuilt from scratch. No game-specific hooks (`preprocess_action`, etc.) fire for undo actions.
  - `@log` is rebuilt from scratch on every clone/undo.
  - `Action::Log` (which extends `Action::Message`) is **never** filtered out by `filtered_actions` — messages survive all undos and are replayed in the correct chronological position.
  - `initialize_actions` is overridable in a game subclass without touching engine code.

  **Implementation approach — override `initialize_actions` in `G2038::Game`:**
  - After calling `super` (which replays all actions and builds `@log`), scan `@raw_all_actions` for any `{ 'type' => 'undo' }` entries
  - For each undo found, look up the player via `action['user']`, identify the action ID range that was undone via `action['action_id']`
  - Append a styled log entry: `"⚠ [UNDO] PlayerName undid action(s) #Y–#Z"`
  - These entries appear at the bottom of the log (not inline), but are permanent — they survive all further undos because they are regenerated fresh on every rebuild

  **Implementation tasks:**
  - [ ] Override `initialize_actions` in `G2038::Game`; after `super`, scan `@raw_all_actions` for undo entries and build log entries
  - [ ] Only emit undo log entries during Operating Rounds (check round type at the action's point in history, or always log and rely on the action ID range being self-explanatory)
  - [ ] Format the log entry to include: player name, action ID range undone, and round/turn context if determinable
  - [ ] Undo announcements must persist even if the player subsequently undoes further actions (guaranteed by the rebuild approach above)
  - [ ] Investigate whether `self.filtered_actions` override could instead inject a synthetic `message`-type hash at the undo's chronological position, which would make the log entry appear in-order rather than at the bottom — this is a stretch goal if in-order logging matters

### C. Spaceship distance model and pickup selection
- [x] **Chosen approach:** Keep spaceships in TRAINS for purchase/obsolescence tracking. Write a custom `Route` class and `Step::Route` for 2038 that uses hex-traversal (cf. 18Ireland) with a separate cargo hold constraint.
- [x] **Pickup selection UX:** The player traces their full intended route path first (spending movement points and exploring as they go). At the end of the route, just before scoring, the player is presented with a list of all eligible mine pickups along the path and selects which ones to count, up to their cargo hold limit. The list is pre-populated with the highest-scoring combination as the default suggestion, but the player can override this selection.
  - [ ] Implement `eligible_pickups(route)` — returns all mines along the route that are accessible by this ship this OR (not Used, and if claimed, owned by this company)
  - [ ] Implement `best_pickups(eligible, cargo_holds)` — greedy or optimal selection of up to `cargo_holds` mines by descending value; used to pre-populate the UI default
  - [ ] Implement the pickup selection step as a distinct UI interaction after path confirmation
  - [ ] Apply Used Mine markers only after pickup selection is confirmed (not mid-route)

### D. Unexplored hex representation
- [x] **Chosen approach:** Use a tile pool (bag) of asteroid tiles that are drawn randomly. Track the bag state as part of game state so that undo correctly returns drawn tiles to the bag. When a tile is drawn and placed (exploration), update `@mine_state` immediately so the mine is visible to all players at once — consistent with Decision B above.

### E. Infrastructure placement model
- [x] **Bases → Token system.** Strong structural match: tokens occupy a city slot (one base per hex), have placement costs, belong to a corporation, and establish route origins. The 13 pre-printed starting bases map to home tokens at each entity's starting coordinates. Phase-based base limits will need custom enforcement on top of the standard token array (see Phase 5).
  - [x] **Independent companies have exactly one base — their home base — and may never place additional bases.** Their token array should reflect this: one free home token, no additional tokens. Claims are handled separately (see below).
- [x] **Refueling Stations → Modifier on a base.** Stored as a `@refueling_stations` hash (`hex_id → corporation`). When any ship owned by the station's corporation enters that hex, its remaining MP is increased by 3, capped at the ship's original MP allowance: `new_remaining = [remaining + 3, original_mp].min`. A given refueling station may only be used once per ship per OR (track visited stations per ship during route traversal). Refueling stations are attached to bases — a base must exist on the hex first.
- [x] **Claims → Revenue modifier only.** Stored in `@mine_state`. A claim marks a mine as owned by a specific company; that company's ships pick up at the higher (claimed) value, all others at the lower (unclaimed) value. Claims have no effect on routing or movement.
  - [x] **Independent companies each have 2 claims** (not modeled as tokens — handled as custom claim state in `@mine_state`). These are placed and tracked separately from bases.
- [x] **Bases and claims are mutually exclusive** — enforced by rule (bases require a tile without claims; the tile flip removes mines). No need for code-level guards between the two.

---

## Reference: Key Files in Other Games

| Mechanism | Game | File |
|---|---|---|
| BY-share privates (shares ability) | 1835 | `g_1835/entities.rb` |
| Minor-to-major conversion (Prussian) | 1835 | `g_1835/step/form_prussian.rb`, `g_1835/game.rb` |
| Sequential merger step | 1835 | `g_1835/step/merge_to_prussian.rb` |
| Distance-based train routing | 18Ireland | `g_18_ireland/game.rb` (`route_distance`, `check_distance`) |
| Minor company operating model | 1835, 1861 | `g_1835/minor.rb`, `g_1861/game.rb` |
