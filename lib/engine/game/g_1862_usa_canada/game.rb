# frozen_string_literal: true

# Developed with Claude (Anthropic) AI assistance — claude.ai/code

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative 'step/buy_sell_par_shares'
require_relative 'step/company_pending_par'
require_relative 'step/dividend'
require_relative 'step/repay_bond'
require_relative 'step/token'
require_relative '../base'

module Engine
  module Game
    module G1862UsaCanada
      class Game < Game::Base
        include_meta(G1862UsaCanada::Meta)
        include Entities
        include Map

        # ---------------------------------------------------------------------------
        # Corporation groups — unlocked progressively
        # Group 1 available from game start.
        # Group 2 unlocks when ALL Group 1 companies have floated.
        # Group 3 unlocks when ALL Group 2 companies have floated.
        #
        # Director share sizes by group (from rulebook):
        #   Group 1 (NYH, NYC, CP):       30% Director + 7×10%
        #   Group 2 (CPR, UP, ATS, SP):   20% Director + 8×10%
        #   Group 3 (NP, CN, GMO):        20% Director + 8×10%
        #   Group 3 (TP, ORN, WP):        30% Director + 7×10%  ← mixed within group
        # ---------------------------------------------------------------------------
        CORP_GROUPS = {
          1 => %w[NYH NYC CP],
          2 => %w[CPR UP ATS SP],
          3 => %w[NP CN TP ORN WP GMO],
        }.freeze

        # ---------------------------------------------------------------------------
        # Bonus markers (Bonusplättchen) — 8 corporations, pre-placed on cities.
        # Activation: corporation's route passes through BOTH its home hex AND the
        # bonus hex. Director then chooses: take cash immediately (marker removed)
        # OR keep as permanent +N revenue bonus each OR the route visits that city.
        # Each bonus is counted at most once per OR.
        #
        # FIXME: V/P/S/L (Vancouver/Portland/Sacramento/Los Angeles) and El Paso
        # hex groups need confirmation against physical map before activation works.
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
          # FIXME: TP El Paso bonus omitted until bonus amount confirmed from rulebook
        }.freeze

        # ---------------------------------------------------------------------------
        # SLC (Salt Lake City / Promontory Summit) transcontinental bonus
        # CPR and UP each earn a per-OR route bonus when their route passes through SLC.
        # When BOTH have connected through SLC for the first time the "Golden Spike"
        # fires: a one-time shareholder bonus is paid from the bank and both stock
        # prices advance one step.
        #
        # FIXME: SLC hex coordinate unconfirmed — placeholder until map verified.
        # FIXME: GOLDEN_SPIKE_SHAREHOLDER_BONUS amount unconfirmed from rulebook.
        # ---------------------------------------------------------------------------
        SLC_HEX                        = 'G9'.freeze
        SLC_CORPS                      = %w[CPR UP].freeze
        SLC_ROUTE_BONUS                = 30   # per OR while route passes through SLC
        SLC_ROUTE_BONUS_SOC            = 15   # reduced while SOC (P7) is open
        GOLDEN_SPIKE_SHAREHOLDER_BONUS = 50   # FIXME: per 10% share, paid from bank on completion

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 12_000

        CERT_LIMIT = { 3 => 27, 4 => 22, 5 => 18, 6 => 15, 7 => 13 }.freeze

        STARTING_CASH = { 3 => 750, 4 => 600, 5 => 500, 6 => 440, 7 => 400 }.freeze

        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER    = :sell_buy_sell

        # Players can hold up to 100% of a company; monopoly fees apply above 60%
        MARKET_SHARE_LIMIT = 100

        # Selling drops stock price; buying into pool does not raise it
        SELL_MOVEMENT = :down_per_10
        POOL_SHARE_DROP = :down_block

        # Companies are never required to buy a train to operate
        MUST_BUY_TRAIN = :never

        # Place all home tokens at OR start so the graph is populated before any
        # entity queries connected_hexes — avoids stale-cache bug on shared home hexes.
        HOME_TOKEN_TIMING = :operating_round

        # 60% of par price paid into company on float; remainder drips in as shares sell
        CAPITALIZATION = :incremental

        # ---------------------------------------------------------------------------
        # Stock market — 2D ledge layout, Kurstabelle 1863
        # p = valid par/IPO cell
        # e = end-game zone (any marker reaching these cells ends the game after
        #     the current OR set)
        # Rows read top (row 0) to bottom (row 9); columns left to right.
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
        # Phases
        # Phase name = first train type purchased that triggers it.
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
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '7',
            on: '7',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        # ---------------------------------------------------------------------------
        # Trains
        #
        # Each base type (2–7) has an E-variant (Express).
        # E-trains use the distance-array format: pay: N stops, visit: 999.
        # This allows them to traverse unlimited intermediate cities/towns while
        # only collecting revenue at N chosen stops (true express behaviour).
        #
        # Rusting (confirmed from rulebook summary card):
        #   2/2E  → rusts on first 4/4E purchase
        #   3/3E  → rusts on first 6/6E purchase
        #   4/4E  → rusts on first 8 purchase
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
              { name: '2E', distance: [{ nodes: %w[city offboard town], pay: 2, visit: 999 }], price: 150 },
            ],
          },
          {
            name: '3',
            distance: 3,
            price: 200,
            rusts_on: '6',
            num: 6,
            variants: [
              { name: '3E', distance: [{ nodes: %w[city offboard town], pay: 3, visit: 999 }], price: 300 },
            ],
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '8',
            num: 5,
            variants: [
              { name: '4E', distance: [{ nodes: %w[city offboard town], pay: 4, visit: 999 }], price: 400 },
            ],
          },
          {
            name: '5',
            distance: 5,
            price: 550,
            num: 4,
            variants: [
              { name: '5E', distance: [{ nodes: %w[city offboard town], pay: 5, visit: 999 }], price: 700 },
            ],
          },
          {
            name: '6',
            distance: 6,
            price: 650,
            num: 3,
            variants: [
              { name: '6E', distance: [{ nodes: %w[city offboard town], pay: 6, visit: 999 }], price: 800 },
            ],
          },
          {
            name: '7',
            distance: 7,
            price: 750,
            num: 2,
            variants: [
              { name: '7E', distance: [{ nodes: %w[city offboard town], pay: 7, visit: 999 }], price: 900 },
            ],
          },
          {
            name: '8',
            distance: 999,
            price: 900,
            num: 20,
          },
        ].freeze

        # ---------------------------------------------------------------------------
        # Game end
        # Triggers: bank empty OR any stock price marker reaches a cell > 310.
        # After trigger: finish current OR set, then end.
        # ---------------------------------------------------------------------------
        GAME_END_CHECK = { bank: :current_round, stock_market: :current_round }.freeze

        # ---------------------------------------------------------------------------
        # Setup
        # ---------------------------------------------------------------------------
        def setup
          @available_par_groups = [1]
          @slc_bonus_paid = false
          @slc_connected  = {}       # { corp_sym => true } when first route through SLC
          @first_dividend_paid = {}  # { corp_sym => true } for P5/P6 close triggers
          @corp_bonds = {} # { corp_sym => Integer } outstanding Schuldschein per corp
          # Bonus state: [corp_sym, bonus_index] => :unactivated / :permanent / :cash
          @bonus_state = {}
          CORP_BONUSES.each do |sym, bonuses|
            bonuses.each_index { |i| @bonus_state[[sym, i]] = :unactivated }
          end
        end

        # ---------------------------------------------------------------------------
        # Bond (Schuldschein) helpers
        # One bond per corporation; amount is face value rounded up to nearest $100.
        # Available from phase 3 (first 3/3E purchase).
        # Director cannot sell the corp's shares while a bond is outstanding.
        # Outstanding bonds at game end: Director is personally liable.
        # FIXME: actual share-halving (50% buyback action) not yet implemented.
        # ---------------------------------------------------------------------------
        def corp_bond(corporation)
          @corp_bonds[corporation.id] || 0
        end

        def bond?(corporation)
          corp_bond(corporation).positive?
        end

        def issue_bond!(corporation, amount)
          @corp_bonds[corporation.id] = amount
          @log << "#{corporation.name} issues a $#{amount} bond (Schuldschein)"
        end

        def repay_bond!(corporation)
          owed = corp_bond(corporation)
          return if owed.zero?

          paid = [owed, corporation.cash].min
          @corp_bonds[corporation.id] = owed - paid
          corporation.spend(paid, @bank)
          msg = "#{corporation.name} repays $#{paid} bond"
          msg += " ($#{@corp_bonds[corporation.id]} remaining)" if @corp_bonds[corporation.id].positive?
          @log << msg
        end

        def buyback_available?
          @phase.name.to_i >= 3
        end

        # ---------------------------------------------------------------------------
        # Bonus markers (Bonusplättchen)
        # ---------------------------------------------------------------------------

        # Called from our Dividend step before super to permanently record activations.
        # FIXME: should offer cash-vs-permanent choice; auto-chooses permanent for now.
        def activate_new_bonuses!(corporation, routes)
          return unless (bonuses = CORP_BONUSES[corporation.id])

          home_hex = corporation.coordinates
          bonuses.each_with_index do |bonus, i|
            next unless @bonus_state[[corporation.id, i]] == :unactivated
            next unless routes.any? { |r| would_activate?(bonus, r, home_hex) }

            @bonus_state[[corporation.id, i]] = :permanent
            @log << "#{corporation.name} activates #{bonus[:name]} bonus " \
                    "(permanent +#{format_currency(bonus[:route_bonus])} per route)"
          end
        end

        # Bonuses are per-route in revenue_for so the route display matches the payout.
        def revenue_for(route, stops)
          super + slc_revenue_for(route, stops) + corp_bonus_revenue_for(route, stops)
        end

        # Called from dividend step (before super) each time a corporation runs routes.
        # Marks first-time SLC connections and fires the Golden Spike event when both
        # CPR and UP have connected.
        def check_golden_spike!(corporation, routes)
          return unless SLC_CORPS.include?(corporation.id)
          return if @slc_connected[corporation.id]
          return unless routes.any? { |r| r.visited_stops.any? { |s| s.hex.id == SLC_HEX } }

          @slc_connected[corporation.id] = true
          @log << "#{corporation.name} reaches Salt Lake City — transcontinental route active"

          return unless SLC_CORPS.all? { |sym| @slc_connected[sym] }
          return if @slc_bonus_paid

          @slc_bonus_paid = true
          golden_spike_event!
        end

        private

        def golden_spike_event!
          @log << '-- GOLDEN SPIKE! Transcontinental railroad complete --'
          SLC_CORPS.each do |sym|
            corp = corporation_by_id(sym)
            next unless corp&.floated?

            corp.share_holders.each do |entity, percent|
              next unless entity.player?

              bonus = (percent / 10) * GOLDEN_SPIKE_SHAREHOLDER_BONUS
              @bank.spend(bonus, entity)
              @log << "#{entity.name} receives #{format_currency(bonus)} Golden Spike bonus " \
                      "(#{percent}% #{corp.name})"
            end

            @stock_market.move_up(corp)
            @log << "#{corp.name} stock advances to #{format_currency(corp.share_price.price)}"
          end
        end

        def slc_revenue_for(route, stops)
          corp = route.train.owner
          return 0 unless SLC_CORPS.include?(corp.id)
          return 0 unless stops.any? { |s| s.hex.id == SLC_HEX }

          soc = company_by_id('SOC')
          soc && !soc.closed? ? SLC_ROUTE_BONUS_SOC : SLC_ROUTE_BONUS
        end

        def corp_bonus_revenue_for(route, stops)
          corp = route.train.owner
          return 0 unless (bonuses = CORP_BONUSES[corp.id])

          home_hex = corp.coordinates
          stop_ids = stops.map { |s| s.hex.id }
          bonuses.each_with_index.sum do |bonus, i|
            state = @bonus_state[[corp.id, i]]
            next 0 if state == :cash

            on_route = bonus[:hexes].any? { |h| stop_ids.include?(h) }
            next 0 unless on_route
            next 0 if state == :unactivated && !stop_ids.include?(home_hex)

            bonus[:route_bonus]
          end
        end

        def would_activate?(bonus, route, home_hex)
          stop_ids = route.visited_stops.map { |s| s.hex.id }
          bonus[:hexes].any? { |h| stop_ids.include?(h) } && stop_ids.include?(home_hex)
        end

        public

        # ---------------------------------------------------------------------------
        # GS_TOR is placed on a preprinted gray hex, bypassing normal color progression
        # and phase gating. Both overrides are needed only for this one special tile.
        def upgrades_to_correct_color?(from, to, selected_company: nil)
          return true if to.name == 'GS_TOR'

          super
        end

        # GS_MTL_GR carries label=M and label=NY; the base engine only checks the last
        # label on the tile, so we check any label when the tile has more than one.
        def upgrades_to_correct_label?(from, to)
          return to.labels.any? { |l| l == from.label } if to.labels.size > 1

          super
        end

        def tile_valid_for_phase?(tile, hex: nil, phase_color_cache: nil)
          return true if tile.name == 'GS_TOR'

          super
        end

        def status_str(corporation)
          "#{corporation.presidents_percent}% President's Share"
        end

        # Tile lays
        # Phase 2:  1 lay or upgrade
        # Phase 3+: 2 yellow lays OR 1 upgrade  (:not_if_upgraded blocks 2nd lay after upgrade)
        # ---------------------------------------------------------------------------
        def tile_lays(entity)
          return super unless @phase.name.to_i >= 3

          [
            { lay: true, upgrade: true, cost: 0 },
            { lay: :not_if_upgraded, upgrade: false, cost: 0 },
          ]
        end

        # ---------------------------------------------------------------------------
        # Group unlock — called after every float event
        # ---------------------------------------------------------------------------
        def float_corporation(corporation)
          super
          check_group_unlock!(corporation)
          close_private_on_float!(corporation)
        end

        # Base after_par sums all shares in a :shares ability without filtering by corporation.
        # SOC holds [CPR_1, UP_1]; without this override CPR is overpaid (for UP_1 too)
        # and UP receives nothing for its pre-sold share.
        def after_par(corporation)
          if corporation.capitalization == :incremental
            all_companies_with_ability(:shares) do |company, ability|
              corp_shares = ability.shares.select { |s| s.corporation == corporation }
              next if corp_shares.empty?

              amount = corp_shares.sum { |share| corporation.par_price.price * share.num_shares }
              @bank.spend(amount, corporation)
              @log << "#{corporation.name} receives #{format_currency(amount)} from #{company.name}"
            end
          end
          close_companies_on_event!(corporation, 'par')
        end

        def check_group_unlock!(corporation)
          current_group = corp_group(corporation)
          return unless current_group
          return unless CORP_GROUPS[current_group].all? { |sym| corporation_by_id(sym).floated? }
          return unless CORP_GROUPS[current_group + 1]
          return if @available_par_groups.include?(current_group + 1)

          @available_par_groups << (current_group + 1)
          @log << "-- All Group #{current_group} companies floated; "\
                  "Group #{current_group + 1} is now available --"
        end

        def corp_group(corporation)
          CORP_GROUPS.each { |group, syms| return group if syms.include?(corporation.id) }
          nil
        end

        # SOC (P7) closes when CPR or UP floats
        def close_private_on_float!(corporation)
          return unless %w[CPR UP NYH].include?(corporation.id)

          soc  = company_by_id('SOC')
          nhsc = company_by_id('NHSC')

          if soc && !soc.closed? && %w[CPR UP].include?(corporation.id)
            soc.close!
            @log << "#{soc.name} closes as #{corporation.name} has floated"
          end

          return if !nhsc || nhsc.closed? || corporation.id != 'NYH'

          nhsc.close!
          @log << "#{nhsc.name} closes as #{corporation.name} has floated"
        end

        # ---------------------------------------------------------------------------
        # Corporation availability — gated by par group
        # ---------------------------------------------------------------------------
        def can_par?(corporation, parrer)
          return false unless @available_par_groups.include?(corp_group(corporation))

          super
        end

        # ---------------------------------------------------------------------------
        # Monopoly fee — owning > 60% of a company costs 20% of face value per share
        # FIXME: implement monopoly fee collection in step/buy_sell_par_shares.rb
        # ---------------------------------------------------------------------------
        def monopoly_threshold
          60
        end

        def monopoly_fee(share)
          (share.price * 0.20).to_i
        end

        # ---------------------------------------------------------------------------
        # P5/P6 close triggers — called from dividend step when a company first pays
        # FIXME: hook this into step/dividend.rb
        # ---------------------------------------------------------------------------
        def check_private_close_on_dividend!(corporation)
          psc = company_by_id('PSC')
          fny = company_by_id('FNY')

          if psc && !psc.closed? && corporation.id == 'WP'
            psc.close!
            @log << "#{psc.name} closes as #{corporation.name} has paid its first dividend"
          end

          return if !fny || fny.closed? || corporation.id != 'NYC'

          fny.close!
          @log << "#{fny.name} closes as #{corporation.name} has paid its first dividend"
        end

        # ---------------------------------------------------------------------------
        # Game end check — stock price > 310 triggers end after current OR set
        # ---------------------------------------------------------------------------
        def game_ending_description
          _, after = game_end_check
          return unless after

          after == :current_round ? 'Game ends at the end of the current OR set' : super
        end

        # ---------------------------------------------------------------------------
        # Round definitions
        # ---------------------------------------------------------------------------
        def init_round
          new_auction_round
        end

        def new_auction_round
          Round::Auction.new(self, [
            G1862UsaCanada::Step::CompanyPendingPar,
            Engine::Step::WaterfallAuction,
          ])
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G1862UsaCanada::Step::CompanyPendingPar,
            G1862UsaCanada::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            G1862UsaCanada::Step::Token,
            Engine::Step::Route,
            G1862UsaCanada::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            # FIXME: G1862UsaCanada::Step::StockBuyback — share-halving action (phase 3+)
            G1862UsaCanada::Step::RepayBond,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end
      end
    end
  end
end
