# frozen_string_literal: true

# Developed with Claude (Anthropic) AI assistance — claude.ai/code

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../base'

module Engine
  module Game
    module G1862UsaCanada
      class Game < Game::Base
        include_meta(G1862UsaCanada::Meta)
        include Entities
        include Map

        # ---------------------------------------------------------------------------
        # Corporation groups — unlocked progressively.
        # Group 1 available when ALL private companies have been sold.
        # Group 2 unlocks when ALL Group 1 IPO shares have been sold.
        # Group 3 unlocks when ALL Group 2 corporations have floated.
        #
        # Director share sizes by group (from rulebook):
        #   Group 1 (NYH, NYC, CP):       30% Director + 7×10%
        #   Group 2 (CPR, UP, ATS, SP):   20% Director + 8×10%
        #   Group 3 (NP, CN, GMO):        20% Director + 8×10%
        #   Group 3 (TP, ORN, WP):        30% Director + 7×10%
        # ---------------------------------------------------------------------------
        CORP_GROUPS = {
          1 => %w[NYH NYC CP],
          2 => %w[CPR UP ATS SP],
          3 => %w[NP CN TP ORN WP GMO],
        }.freeze

        # ---------------------------------------------------------------------------
        # Bonus markers (Bonusplättchen) — pre-placed on cities.
        # Activation: corporation's route passes through BOTH home hex AND bonus hex.
        # Director chooses: take cash immediately OR keep as permanent +N revenue bonus.
        # ---------------------------------------------------------------------------
        CORP_BONUSES = {
          'CP' => [
            { hexes: %w[E25],          cash: 100, route_bonus: 30,  name: 'Toronto'     },
            { hexes: %w[B20],          cash: 200, route_bonus: 60,  name: 'Thunder Bay' },
            { hexes: %w[B2 C1 G3 I5], cash: 300, route_bonus: 100, name: 'V/P/S/L' },
          ],
          'NYH' => [
            { hexes: %w[F20],          cash: 100, route_bonus: 30,  name: 'Chicago'     },
            { hexes: %w[K19],          cash: 200, route_bonus: 60,  name: 'New Orleans' },
          ],
          'CPR' => [
            { hexes: %w[F14],          cash: 100, route_bonus: 30,  name: 'Omaha'       },
          ],
          'UP' => [
            { hexes: %w[K19],          cash: 100, route_bonus: 30,  name: 'New Orleans' },
            { hexes: %w[J10],          cash: 200, route_bonus: 60,  name: 'El Paso'     },
          ],
          'ATS' => [
            { hexes: %w[B2 C1 G3 I5], cash: 200, route_bonus: 60, name: 'V/P/S/L' },
          ],
          'NP' => [
            { hexes: %w[F20], cash: 100, route_bonus: 30, name: 'Chicago' },
          ],
          'CN' => [
            { hexes: %w[B2 C1 G3 I5], cash: 100, route_bonus: 30, name: 'V/P/S/L' },
            { hexes: %w[B10], cash: 200, route_bonus: 60, name: 'Regina' },
          ],
          # FIXME: TP El Paso bonus amount unconfirmed from rulebook — entry omitted until confirmed
        }.freeze

        # ---------------------------------------------------------------------------
        # SLC (Salt Lake City) transcontinental bonus.
        # CPR and UP each earn a per-OR route bonus when route passes through SLC.
        # When BOTH connect through SLC for the first time the "Golden Spike" fires.
        # FIXME: GOLDEN_SPIKE_SHAREHOLDER_BONUS amount unconfirmed from rulebook.
        # ---------------------------------------------------------------------------
        SLC_HEX                        = 'G9'.freeze
        SLC_CORPS                      = %w[CPR UP].freeze
        SLC_ROUTE_BONUS                = 30
        SLC_ROUTE_BONUS_SOC            = 15
        GOLDEN_SPIKE_SHAREHOLDER_BONUS = 50 # FIXME: amount unconfirmed from rulebook

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 12_000

        CERT_LIMIT = { 3 => 27, 4 => 22, 5 => 18, 6 => 15, 7 => 13 }.freeze

        STARTING_CASH = { 3 => 750, 4 => 600, 5 => 500, 6 => 440, 7 => 400 }.freeze

        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER    = :sell_buy

        MARKET_SHARE_LIMIT = 100

        SELL_MOVEMENT = :down_per_10
        POOL_SHARE_DROP = :down_block

        MUST_BUY_TRAIN = :never

        HOME_TOKEN_TIMING = :operate

        CAPITALIZATION = :full

        # ---------------------------------------------------------------------------
        # Stock market — 2D ledge layout, Kurstabelle 1863.
        # p = valid par/IPO cell
        # e = end-game zone (stock price > 310 triggers game end after current OR set)
        # ---------------------------------------------------------------------------
        MARKET = [
          ['', '', '85', '92', '100p', '110', '120', '132', '146', '162', '180', '200', '225', '250', '280', '310',
           '340e', '370e'],
          ['', '70', '80', '85', '92p', '100', '110', '120', '132', '146', '162', '180', '200', '225', '250', '280',
           '315e', '350e'],
          %w[55 65 75 80 85p 92 100 110 120 132 146 162 180 200 225 250],
          %w[50 60 70 75 80p 85 92 100 110 120 132 146 162 180],
          %w[45 55 65 70 75p 80 85 92 100 110 120 132],
          %w[40 50 60 65 70p 75 80 85 92 100],
          %w[35 45 55 62 68 72 75 80],
          %w[30 40 50 60 65 70],
          %w[25 35 45 55],
          %w[20 30],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          'par' => 'Valid par price',
          'end_game' => 'Stock price reaches this cell; game ends after current OR set'
        ).freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par: :yellow,
          end_game: :orange
        ).freeze

        # ---------------------------------------------------------------------------
        # Tile-lay budget — phase-gated.
        # Phase 2:   1 yellow tile only.
        # Phase 3+:  2 yellow tiles OR 1 upgrade (no mixing).
        # ---------------------------------------------------------------------------
        YELLOW_TILE_LAY = [{ lay: true, upgrade: false }].freeze
        TWO_TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: :not_if_upgraded, upgrade: false },
        ].freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'two_tile_lays' => ['Two tile lays', 'Corporations may lay 2 yellow tiles OR 1 upgrade tile per OR']
        ).freeze

        # ---------------------------------------------------------------------------
        # Phases
        # FIXME: verify exact operating_rounds count per phase from rulebook.
        # ---------------------------------------------------------------------------
        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['two_tile_lays'],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['two_tile_lays'],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: ['two_tile_lays'],
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: ['two_tile_lays'],
          },
          {
            name: '7',
            on: '7',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
            status: ['two_tile_lays'],
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
            status: ['two_tile_lays'],
          },
        ].freeze

        # ---------------------------------------------------------------------------
        # Trains — base types 2–8; each of 2–7 has an E-variant (express).
        # E-trains pay N stops, visit unlimited nodes.
        # Rusting (confirmed from rulebook summary card):
        #   2/2E → first 4/4E purchase
        #   3/3E → first 6/6E purchase
        #   4/4E → first 8 purchase
        #   5/5E, 6/6E, 7/7E, 8 → never rust
        # ---------------------------------------------------------------------------
        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 7,
            variants: [
              { name: '2E', distance: [{ 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 999 }], price: 150 },
            ],
          },
          {
            name: '3',
            distance: 3,
            price: 200,
            rusts_on: '6',
            num: 6,
            variants: [
              { name: '3E', distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 999 }], price: 300 },
            ],
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '8',
            num: 5,
            variants: [
              { name: '4E', distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 999 }], price: 400 },
            ],
          },
          {
            name: '5',
            distance: 5,
            price: 550,
            num: 4,
            variants: [
              { name: '5E', distance: [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 999 }], price: 700 },
            ],
          },
          {
            name: '6',
            distance: 6,
            price: 650,
            num: 3,
            variants: [
              { name: '6E', distance: [{ 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 999 }], price: 800 },
            ],
          },
          {
            name: '7',
            distance: 7,
            price: 750,
            num: 2,
            variants: [
              { name: '7E', distance: [{ 'nodes' => %w[city offboard town], 'pay' => 7, 'visit' => 999 }], price: 900 },
            ],
          },
          { name: '8', distance: 999, price: 900, num: 20 },
        ].freeze

        GAME_END_CHECK = { bank: :current_round, stock_market: :current_round }.freeze

        # ---------------------------------------------------------------------------
        # Tile-lay budget override.
        # ---------------------------------------------------------------------------
        def tile_lays(_entity)
          @phase.status.include?('two_tile_lays') ? self.class::TWO_TILE_LAYS : self.class::YELLOW_TILE_LAY
        end

        # ---------------------------------------------------------------------------
        # Home token — placed automatically at start of corp's first OR turn.
        # Base place_home_token calls city.place_token directly (bypasses step
        # layer) so clear_graph_for_entity is never called. Override to flush the
        # graph cache immediately, otherwise the corp sees zero connected hexes
        # and cannot lay track on the same turn.
        # ---------------------------------------------------------------------------
        def place_home_token(corporation)
          super
          clear_graph_for_entity(corporation)
        end

        # ---------------------------------------------------------------------------
        # Corporation group unlock logic.
        # ---------------------------------------------------------------------------
        def corp_group(corporation)
          CORP_GROUPS.find { |_, syms| syms.include?(corporation.id) }&.first
        end

        def all_privates_sold?
          @companies.all? { |c| c.owner&.player? || c.closed? }
        end

        def group_available?(group_num)
          case group_num
          when 1 then all_privates_sold?
          when 2 then CORP_GROUPS[1].all? { |sym| corporation_by_id(sym).num_ipo_shares.zero? }
          when 3 then CORP_GROUPS[2].all? { |sym| corporation_by_id(sym).floated? }
          else true
          end
        end

        def can_par?(corporation, parrer)
          return false unless super

          group_available?(corp_group(corporation))
        end

        # ---------------------------------------------------------------------------
        # Round definitions — engine defaults only; custom steps added in later PRs.
        # ---------------------------------------------------------------------------
        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
          ], round_num: round_num)
        end
      end
    end
  end
end
