# 18xx Engine Developer Guide  
*Overview for Core Architecture and Game Extensions*

---

## **1. Core Architecture Overview**

The 18xx engine uses an **object-oriented pattern** split into four main layers:

### **Game::Base**
- **Role:** Common logic for all games, extended by individual titles.
- **Key Methods:**
  ```ruby
  setup                # Initializes bank, players, corporations
  operating_round(num) # Starts an OR set
  stock_round          # Initiates a stock round
  route_trains(entity) # Resolves train runs and revenue
  buy_train(entity, train, price) # Handles train purchase
  merge(entities)      # Handles corporation mergers (overridden by games)
  ```
- **Usage Example:**
  ```ruby
  game = Engine::Game::G1862.new(players)
  round = game.operating_round(1)
  action = Engine::Action::BuyTrain.new(entity, train, price: 300)
  round.process_action(action)
  ```

---

### **Round::Base**
- **Responsible for:** Executing ordered game steps per round.
- **Patterns:**
  ```ruby
  steps.each(&:actions)       # Collect allowed actions for entity
  round.process_action(action) # Delegates to the active Step
  ```

---

### **Step::* Modules**
Defines **atomic phases** of gameplay like buying trains or issuing shares.

- **Examples:**
  - `Step::BuyTrain`
  - `Step::SellShares`
  - `Step::Merge`
  - `Step::Route`
- **Common API:**
  ```ruby
  actions(entity)           # Returns allowed actions
  process_buy_train(action) # Executes train purchase
  process_merge(action)     # Executes merger logic
  ```

---

### **Action::* Classes**
Represent player actions flowing through rounds and steps.

- **Common Patterns:**
  ```ruby
  Engine::Action::BuyTrain.new(entity, train, price)
  Engine::Action::SellShares.new(entity, shares)
  
  action.to_h       # Serialize to hash
  Action.from_h(h)  # Deserialize
  ```

---

## **2. Call Sequence**

```text
Game.new(players)
  -> setup()
  -> stock_round()
  -> operating_round()
       -> each step
          actions(entity)
          process_action(action)
```

---

## **3. Advanced Mechanics from several Titles (Examples)**

The following **special rules** exist in variants and serve as extension hooks:

✔ **National Companies**  
- Used in 1844/1854 for creating large “state-owned” systems later in play.
- Implemented via:
  - `Step::Merge` logic for token, train, share migration.
  - Extended `Game#merge` for payout.

✔ **Mergers (1828, 1841)**  
- Complex stock conversions and asset transfers.
- Engine Pattern:
  ```ruby
  process_merge(action)
  merge_corporations(old_corp, new_corp)
  ```

✔ **Combining Trains (1862)**  
- Mechanics allow two smaller trains → combined larger train.
- Custom method:
  ```ruby
  combine_trains(entity, train_a, train_b)
  ```

✔ **Ferries & Ports (18MEX, 18Scandinavian)**  
- Add tile or token bonuses connected to sea or port hexes.
- Often realized via:
  - `Step::Assign` for ferry tokens.
  - `hex.assignments` for bonus handling.

✔ **Sea Zones & Province Crossing (18OE)**  
- Adds cost/barriers to routes:
  - Track-laying and route validators check **zone crossing costs**.
  - Example: `hex.province` or `hex.sea_zone` attributes.

---

## **4. Useful Test Patterns**

Specs often demonstrate real usage patterns:

```ruby
expect(game.round.active_step.actions(entity))
```

Typical sequence:

```ruby
round = game.operating_round(1)
buy_action = Engine::Action::BuyTrain.new(corp, train, price: 200)
round.process_action(buy_action)

merge_action = Engine::Action::Merge.new(corp_a, corp_b)
round.process_action(merge_action)
```

---

## **5. Developer Extension Hooks**

When adding new features:
- Add relevant `Step` for new phase/action.
- Extend `Game::merge`, `Game::route_trains` etc. if needed.
- Wire allowed actions in `actions(entity)`.


> **Tip:** Start by scanning `lib/engine/game/g_18_*` for similar mechanics.  

---
# 18xx Abilities

Extracted from engine analysis of 112 entities.rb files (1,111 COMPANIES, 1,241 CORPORATIONS).

---

## 1. Ability Type Frequency Table

| Ability type | Occurrences | Games | Key fields |
|---|---|---|---|
| `exchange` | 260 | 31 | `corporations:`, `from:`, `when:` |
| `tile_lay` | 232 | 59 | `count:`, `when:`, `free:`, `tiles:`, `hexes:`, `consume_tile_lay:`, `closed_when_used_up:` |
| `blocks_hexes` | 180 | 40 | `hexes:` |
| `no_buy` | 175 | 35 | (no extra fields) |
| `shares` | 124 | 43 | `shares:` (e.g. `'PRR_0'`) |
| `close` | 108 | 38 | `when:`, `corporation:`, `on_phase:` |
| `revenue_change` | 92 | 14 | `revenue:`, `on_phase:` |
| `assign_hexes` | 82 | 34 | `hexes:` |
| `reservation` | 78 | 11 | `hexes:` |
| `hex_bonus` | 54 | 10 | `hexes:`, `amount:` |
| `token` | 53 | 27 | `price:`, `count:`, `corporation:` |
| `base` | 50 | 8 | `description:` |
| `tile_discount` | 44 | 28 | `terrain:`, `discount:` |
| `assign_corporation` | 34 | 21 | `corporations:` |
| `blocks_hexes_consent` | 32 | 4 | (blocking released when owner consents — concessions) |
| `description` | 21 | 8 | `description:` |
| `choose_ability` | 19 | 6 | (no standard fields) |
| `manual_close_company` | 19 | 1 | (no standard fields) |
| `sell_company` | 19 | 2 | (no standard fields) |
| `train_discount` | 16 | 12 | `discount:`, `trains:` |
| `teleport` | 16 | 12 | `hexes:`, `tiles:` |
| `tile_income` | 10 | 9 | (no standard fields) |
| `train_limit` | 9 | 6 | (no standard fields) |
| `generic` | 8 | 1 | `desc:` |
| `additional_token` | 7 | 7 | (no standard fields) |
| `train_buy` | 6 | 6 | (no standard fields) |
| `acquire_company` | 6 | 2 | (no standard fields) |
| `borrow_train` | 2 | 2 | (no standard fields) |
| `blocks_partition` | 2 | 2 | (no standard fields) |
| `train_scrapper` | 1 | 1 | (no standard fields) |
| `purchase_train` | 1 | 1 | (no standard fields) |

---


## 2. Ability Structure in Ruby (`entities.rb`)

Standard ability hash:

```ruby
{
  type: 'tile_lay',           # required
  owner_type: 'player',       # 'player' | 'corporation'
  when: 'track',              # string or array; see §4
  count: 2,                   # number of uses; omit = unlimited
  hexes: %w[A1 B2],           # hex restriction
  tiles: %w[57 58],           # tile number restriction
  free: true,                 # waives tile cost
  closed_when_used_up: true,  # close company when count → 0
  reachable: true,            # must be reachable from home
  consume_tile_lay: true,     # consumes one of corp's normal lay slots
  terrain: 'mountain',        # (on tile_discount) terrain type
  discount: 20,               # (on tile_discount/train_discount) amount
  trains: %w[2+2 3+3],        # (on train_discount) train types
  corporations: %w[GWR LNWR], # (on exchange/token/assign_corp)
  from: 'par',                # (on exchange) source
  description: 'text',        # (on base/description/generic)
  price: 0,                   # (on token) placement cost
  corporation: 'GWR',         # (on token/close) specific corp
  on_phase: 'Phase 4',        # (on close/revenue_change) phase trigger
  revenue: 20,                # (on revenue_change) new value
  amount: 30,                 # (on hex_bonus) bonus amount
}
```

---

## 3. `when:` Field Complete Vocabulary

649 occurrences across 75 games; 27 distinct values.
Source: `lib/engine/game/base.rb#ability_right_time?`

### 3A — OR Step-Scoped (active during a specific OR step)

| Value | Active when | Ability types |
|---|---|---|
| `'track'` | `Step::Track` | `tile_lay`, `tile_discount` |
| `'special_track'` | `Step::SpecialTrack` | `tile_lay`, `teleport` |
| `'token'` | `Step::Token` | `token` |
| `'special_token'` | `Step::SpecialToken` | `token`, `teleport` |
| `'route'` | `Step::Route` | `generic` |
| `'track_and_token'` | `Step::TrackAndToken` | `tile_lay`, `token` |
| `'buy_train'` | `Step::BuyTrain` | `train_discount` |
| `'buying_train'` | During train purchase (alias) | `train_discount` |
| `'single_depot_train_buy'` | Variant buy train step | `train_discount` |
| `'dividend'` | `Step::Dividend` | `generic`, `revenue_change` |
| `'exchange'` | SR `Step::Exchange` | `exchange` |

### 3B — OR Turn-Scoped (any time owning entity's OR turn is active)

| Value | Condition |
|---|---|
| `'owning_corp_or_turn'` | OR active AND current operator is ability's corp (155 occurrences) |
| `'owning_player_or_turn'` | OR active AND president is ability's player |
| `'owning_player_track'` | OR active AND president == ability.player AND in Track step |
| `'owning_player_token'` | OR active AND president == ability.player AND in Token step |
| `'or_between_turns'` | OR active AND `!current_operator_acted` |
| `'or_start'` | OR active AND `@round.at_start` |

### 3C — SR Turn-Scoped

| Value | Condition |
|---|---|
| `'owning_player_sr_turn'` | SR active AND current entity is ability's player (155 occurrences) |
| `'stock_round'` | SR active, any player, any turn |

### 3D — Event-Triggered (on `close` abilities only)

| Value | Triggered by |
|---|---|
| `'bought_train'` | `base.rb#buy_train` → `close_companies_on_event!` |
| `'ran_train'` | `step/dividend.rb` → `close_companies_on_event!` |
| `'operated'` | `step/dividend.rb#pass!` → `close_companies_on_event!` |
| `'par'` | `base.rb#after_par` → `close_companies_on_event!` |
| `'sold'` | `step/buy_company.rb` fires `'sold'` abilities |
| `'auction_end'` | Game-specific (g_1828 only) |
| `'has_train'` | Revenue-change at OR start when corp has trains |

### 3E — Meta / Any-Round

| Value | Meaning |
|---|---|
| `'any'` | Usable at any time. Short-circuits all other checks. |

### Always-Valid Values (never need validation)

`any`, `owning_corp_or_turn`, `owning_player_or_turn`, `owning_player_track`,
`owning_player_token`, `owning_player_sr_turn`, `stock_round`, `or_between_turns`,
`or_start` — these 9 have no step prerequisite.

---

## 4. `blocks_hexes_consent` vs `blocks_hexes`

- `blocks_hexes`: unconditional — blocked until company purchased or closed
- `blocks_hexes_consent`: blocking released when the owning player consents (used for
  concession cards — released when concession transferred or major is parred)

---

## 5. Exchange Ability `from:` Field Values

- `'par'` — concession pattern: company exchanged to float a corporation at par
- `'ipo'` — exchange for a share from IPO
- `'market'` — exchange for a share from secondary market
- `%w[ipo market]` — either source
- `%i[reserved]` — reserved share

---
