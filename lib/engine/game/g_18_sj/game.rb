# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18SJ
      class Game < Game::Base
        include_meta(G18SJ::Meta)
        include Entities
        include Map

        attr_reader :edelsward
        attr_accessor :requisition_turn

        register_colors(
          black: '#0a0a0a', # STJ
          brightGreen: '#7bb137', # UGJ
          brown: '#7b352a', # BJ
          green: '#237333', # SWB
          lavender: '#baa4cb', # SNJ
          olive: '#808000', # TGOJ (not right)
          orange: '#f48221', # MOJ
          red: '#d81e3e', # OSJ
          violet: '#4d2674', # OKJ
          white: '#ffffff', # KFJr
          yellow: '#FFF500' # MYJ
        )

        CURRENCY_FORMAT_STR = '%s kr'

        BANK_CASH = 10_000

        CERT_LIMIT = {
          10 => { 2 => 39, 3 => 26, 4 => 20, 5 => 16, 6 => 13 },
          9 => { 2 => 35, 3 => 23, 4 => 18, 5 => 14, 6 => 12 },
          8 => { 2 => 30, 3 => 20, 4 => 15, 5 => 12, 6 => 10 },
          7 => { 2 => 26, 3 => 17, 4 => 13, 5 => 11, 6 => 9 },
        }.freeze

        STARTING_CASH = { 2 => 1200, 3 => 800, 4 => 600, 5 => 480, 6 => 400 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          endgame: 'Game end at end of current operating round',
          max_price: 'Double jump if double revenue if stock price is at least 90 kr',
          multiple_buy: 'Can buy more than one share in the corporation per turn, redeem all shares at no cost',
          no_cert_limit: 'Corporation shares do not count towards cert limit, redeem one shares at half cost (rounded down)',
          par: 'Available par values',
          unlimited: 'Corporation shares can be held above 60%, redeem all shares at half cost (rounded down)',
        ).freeze

        # New track must be usable, or upgrade city value
        TRACK_RESTRICTION = :semi_restrictive

        MARKET = [
          %w[82m 90 100p 110 125 140 160 180 200 225 250 275 300 325 350 375e 400e],
          %w[76 82m 90p 100 110 125 140 160 180 200 220 240 260 280 300],
          %w[71 76 82pm 90 100 110 125 140 155 170 185 200],
          %w[67 71 76p 82m 90 100 110 120 140],
          %w[65 67 71p 76 82m 90 100],
          %w[63y 65 67p 71 76 82],
          %w[60y 63y 65 67 71],
          %w[50o 60y 63y 65],
          %w[40b 50o 60y],
          %w[30b 40b 50o],
          %w[20b 30b 40b],
        ].freeze

        PHASES = [
          {
            name: '2',
            on: '2',
            train_limit: 4,
            tiles: %i[yellow],
            operating_rounds: 1,
            status: %w[incremental],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[incremental can_buy_companies],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[incremental can_buy_companies],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[fullcap],
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
            status: %w[fullcap],
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
            status: %w[fullcap],
          },
          {
            name: 'E',
            on: 'E',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
            status: %w[fullcap],
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 7 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 5 },
                  {
                    name: '4',
                    distance: 4,
                    price: 300,
                    rusts_on: 'D',
                    num: 4,
                    events: [{ 'type' => 'nationalization' }],
                  },
                  {
                    name: '5',
                    distance: 5,
                    price: 530,
                    num: 3,
                    events: [{ 'type' => 'close_companies' }, { 'type' => 'full_cap' }],
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 630,
                    num: 2,
                    events: [{ 'type' => 'nationalization' }],
                  },
                  {
                    name: 'D',
                    distance: 999,
                    price: 1100,
                    num: 20,
                    available_on: '6',
                    discount: { '4' => 300, '5' => 300, '6' => 300 },
                    variants: [
                      {
                        name: 'E',
                        price: 1300,
                        discount: { '4' => 300, '5' => 300, '6' => 300 },
                      },
                    ],
                    events: [{ 'type' => 'nationalization' }],
                  }].freeze

        # Stock market 350 triggers end of game in same OR, but bank full OR set
        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :full_or }.freeze

        SELL_BUY_ORDER = :sell_buy_sell

        # At most a corporation/minor can do two tile lay / upgrades but two is
        # only allowed if one improves main line situation. This means a 2nd
        # tile lay/upgrade might not be allowed.
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: true }].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'full_cap' => ['Full Capitalization',
                         'Unsold corporations becomes Full Capitalization and move shares to IPO. Partially sold, '\
                         'not yet floated, corporations continue to be Incremental Capitalization the rest of the '\
                         'game. (See rules, §12.13)'],
          'nationalization' => ['Nationalization check', 'The topmost corporation without trains are nationalized'],
        ).freeze

        STATUS_TEXT = {
          'incremental' => [
            'Incremental Cap',
            'New corporations will be capitalized for all 10 shares as they are sold',
          ],
          'fullcap' => [
            'Incremental/Full Cap',
            'Unsold corporations when first 5 train is sold will use Full Capitalization for the rest of the game. '\
            'When this corporation is floated (60% sold) it receives 10 x par price as treasury. Remaining '\
            "corporations still uses 'Incremental Cap' status.  (See rules, §12.13)",
          ],
        }.merge(Base::STATUS_TEXT).freeze

        OPTIONAL_PRIVATE_A = %w[NE AEvR].freeze
        OPTIONAL_PRIVATE_B = %w[NOJ FRY].freeze
        OPTIONAL_PRIVATE_C = %w[NOHAB MV].freeze
        OPTIONAL_PRIVATE_D = %w[GKB SB].freeze
        OPTIONAL_PUBLIC = %w[STJ TGOJ ÖSJ MYJ].freeze

        MAIN_LINE_ORIENTATION = {
          # Stockholm-Malmo main line
          'F9' => [2, 5],
          'E8' => [2, 5],
          'D7' => [2, 5],
          'C6' => [2, 5],
          'B5' => [2, 5],
          'A4' => [1, 5],
          # Stockholm-Goteborg main line
          'F11' => [0, 3],
          'E12' => [0, 3],
          'D13' => [0, 2],
          'C12' => [2, 5],
          'B11' => [2, 5],
          # Stockholm-Lulea main line
          'G12' => [1, 3],
          'F13' => [0, 3],
          'E14' => [0, 4],
          'E16' => [1, 4],
          'E18' => [1, 4],
          'E20' => [1, 4],
          'E22' => [1, 4],
          'E24' => [1, 5],
          'F25' => [2, 5],
        }.freeze

        MAIN_LINE_COUNT = {
          'M-S' => 6,
          'G-S' => 5,
          'L-S' => 9,
        }.freeze

        MAIN_LINE_DESCRIPTION = {
          'M-S' => 'Stockholm-Malmö',
          'G-S' => 'Stockholm-Göteborg',
          'L-S' => 'Stochholm-Luleå',
        }.freeze

        MAIN_LINE_ICONS = %w[M-S G-S L-S].freeze

        BONUS_ICONS = %w[N S O V M m_lower_case B b_lower_case].freeze

        ASSIGNMENT_TOKENS = {
          'SB' => '/icons/18_sj/sb_token.svg',
          'GKB50' => '/icons/18_sj/50.svg',
          'GKB30' => '/icons/18_sj/30.svg',
          'GKB20' => '/icons/18_sj/20.svg',
        }.freeze

        GKB_HEXES = %w[C8 C12 C16 E8].freeze

        def gkb_hexes
          @gkb_hexes ||= GKB_HEXES.map { |h| hex_by_id(h) }
        end

        def gkb_hex_assigned?(hex)
          ASSIGNMENT_TOKENS.each do |id, _|
            next if id == 'SB'

            return true if hex.assigned?(id)
          end
          false
        end

        EDELSWARD_PLAYER_ID = -1

        def oscarian_era
          @optional_rules&.include?(:oscarian_era)
        end

        def two_player_variant
          # The two player variant will add a third, bot, so need to remember original player count
          @original_player_count ||= @players.size
          @original_player_count == 2
        end

        def init_corporations(stock_market)
          corporations = super
          removed_corporation = select(OPTIONAL_PUBLIC)
          to_close = corporations.find { |corp| corp.name == removed_corporation }
          corporations.delete(to_close)
          @log << "Removed corporation: #{to_close.full_name} (#{to_close.name})"

          return corporations unless oscarian_era

          # Make all corporations full cap
          corporations.map do |c|
            c.capitalization = :full
            c
          end
        end

        def init_companies(players)
          companies = super
          @removed_companies = []
          [OPTIONAL_PRIVATE_A, OPTIONAL_PRIVATE_B, OPTIONAL_PRIVATE_C, OPTIONAL_PRIVATE_D].each do |optionals|
            to_remove = find_company(companies, optionals)
            to_remove.close!
            # companies.delete(to_remove)
            @removed_companies << to_remove
          end
          @log << "Removed companies: #{@removed_companies.map(&:name).join(', ')}"

          # Handle Priority Deal Chooser private (NEFT)
          # It is removed if Nils Ericsson is removed (as it does not appear among the buyable ones).
          # If Nils Ericsson remains, put NEFT last and let bank be owner, so it wont disturb auction,
          # and it will be assigned to NE owner in the auction.
          pdc = companies.find { |c| c.sym == 'NEFT' }
          if @removed_companies.find { |c| c.sym == 'NE' }
            @removed_companies << pdc
          else
            pdc.owner = @bank
          end

          companies - @removed_companies
        end

        def game_corporations
          self.class::CORPORATIONS.each { |c| c[:always_market_price] = !oscarian_era }
          self.class::CORPORATIONS
        end

        def game_phases
          return self.class::PHASES unless oscarian_era

          self.class::PHASES.map do |p|
            p[:status] -= ['fullcap']
            p
          end
        end

        def init_starting_cash(players, bank)
          cash = self.class::STARTING_CASH
          cash = cash[player_count]

          players.each do |player|
            bank.spend(cash, player)
          end
        end

        def select(collection)
          collection[rand % collection.size]
        end

        def find_company(companies, collection)
          sym = select(collection)
          to_find = companies.find { |comp| comp.sym == sym }
          @log << "Could not find company with sym='#{sym}' in #{@companies}" unless to_find
          to_find
        end

        def minor_khj
          @minor_khj ||= minor_by_id('KHJ')
        end

        def company_khj
          @company_khj ||= company_by_id('KHJ')
        end

        def nils_ericsson
          @nils_ericsson ||= company_by_id('NE')
        end

        def priority_deal_chooser
          @priority_deal_chooser ||= company_by_id('NEFT')
        end

        def sveabolaget
          @sveabolaget ||= company_by_id('SB')
        end

        def motala_verkstad
          @motala_verkstad ||= company_by_id('MV')
        end

        def nydqvist_och_holm
          @nydqvist_och_holm ||= company_by_id('NOHAB')
        end

        def gkb
          @gkb ||= company_by_id('GKB')
        end

        def gc
          @gc ||= company_by_id('GC')
        end

        def bot_corporation?(entity)
          two_player_variant && entity&.corporation? && bot_player?(entity.player)
        end

        def bot_player?(player)
          two_player_variant && player&.id == EDELSWARD_PLAYER_ID
        end

        def ipo_name(entity)
          entity&.capitalization == :incremental ? 'Treasury' : 'IPO'
        end

        def setup
          # Possibly remove from map icons belonging to closed companies
          @removed_companies.each { |c| close_cleanup(c) }

          @minors.each do |minor|
            train = @depot.upcoming[0]
            train.buyable = false
            buy_train(minor, train, :free)
            hex = hex_by_id(minor.coordinates)
            hex.tile.cities[0].place_token(minor, minor.next_token)
          end

          if nils_ericsson && !nils_ericsson.closed?
            nils_ericsson.add_ability(Ability::Close.new(
              type: :close,
              when: 'bought_train',
              corporation: abilities(nils_ericsson, :shares).shares.first.corporation.name,
            ))
          end

          @special_tile_lays = []

          @main_line_built = {
            'M-S' => 0,
            'G-S' => 0,
            'L-S' => 0,
          }

          # Create virtual SJ corporation
          @sj = Corporation.new(
            sym: 'SJ',
            name: 'Statens Järnvägar',
            logo: '18_sj/SJ',
            simple_logo: '18_sj/SJ.alt',
            tokens: [],
          )
          @sj.owner = @bank

          @pending_nationalization = false

          @sj_tokens_passable = false
          @requisition_turn = 0

          if two_player_variant
            @log << 'The rules for "A.W. Edelswärd 2 Player Variant" is used when playing at 2'
            @log << 'Here an A.W. Edelswärd "bot" plays the 3rd player. See rule book for details'
            @edelsward = Player.new(EDELSWARD_PLAYER_ID, 'A.W. Edelswärd')
            @players << @edelsward
          end

          @stockholm_tile_gray ||= @tiles.find { |t| t.name == '131' }

          return unless oscarian_era

          # Remove full cap event as all corporations are full cap
          @depot.trains.each do |t|
            t.events = t.events.reject { |e| e[:type] == 'full_cap' }
          end
        end

        def cert_limit(_player = nil)
          current_cert_limit
        end

        def num_certs(entity)
          count = super
          count -= 1 if priority_deal_chooser&.owner == entity
          count
        end

        def next_round!
          @round =
            case @round
            when G18SJ::Round::Choices
              @requisition_turn = @turn
              @operating_rounds = @phase.operating_rounds
              new_operating_round
            when Engine::Round::Stock
              reorder_players
              if two_player_variant && @turn.even? && @requisition_turn < turn
                G18SJ::Round::Choices.new(self, [
                  G18SJ::Step::Requisition,
                ], round_num: @round.round_num)
              else
                @operating_rounds = @phase.operating_rounds
                new_operating_round
              end
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        def new_auction_round
          G18SJ::Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G18SJ::Step::WaterfallAuction,
          ])
        end

        def stock_round
          G18SJ::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18SJ::Step::ChoosePriority,
            G18SJ::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G18SJ::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::DiscardTrain,
            G18SJ::Step::AssignGotaKanalbolaget,
            G18SJ::Step::AssignSveabolaget,
            G18SJ::Step::SpecialTrack,
            G18SJ::Step::BuyCompany,
            G18SJ::Step::IssueShares,
            Engine::Step::HomeToken,
            G18SJ::Step::Track,
            G18SJ::Step::Token,
            G18SJ::Step::BuyTrainBeforeRunRoute,
            G18SJ::Step::Route,
            G18SJ::Step::Dividend,
            G18SJ::Step::SpecialBuyTrain,
            G18SJ::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        class WithNameAdapter
          def initialize(host, receivership)
            @host = host
            @receivership = receivership
          end

          def name
            "Bot:#{@receivership.name}"
          end
        end

        def acting_for_entity(entity)
          return super unless bot_corporation?(entity)

          WithNameAdapter.new(@edelsward, operator_for_edelsward_corporation)
        end

        def place_home_token(entity)
          return super unless bot_corporation?(entity)

          entity_or_order = @round.entities.index(entity)
          return super if @round.entities.find { |e| bot_corporation?(e) && @round.entities.index(e) < entity_or_order }

          @log << "-- #{operator_for_edelsward_corporation.name} has the highest value at the moment, and should use "\
                  "Master Mode to make actions for any of #{@edelsward.name}'s corporations"
          @log << 'Refer to the 2 player rules for the appropriate actions and choices'
          super
        end

        def reorder_players(order = nil, log_player_order: false)
          return super unless two_player_variant

          player = @round.entities[@round.entity_index]
          @players.rotate!(@players.index(player))
          @log << "#{@players.first.name} has priority deal"
        end

        # Check if tile lay action improves a main line hex
        # If it does return the main line name
        # If not remove nil
        # Side effect: Remove the main line icon from the hex if improvement is done
        def main_line_improvement(action)
          main_line_icon = action.hex.tile.icons.find { |i| MAIN_LINE_ICONS.include?(i.name) }
          return if !main_line_icon || !connects_main_line?(action.hex)

          main_line_icon_name = main_line_icon.name
          @log << "Main line #{MAIN_LINE_DESCRIPTION[main_line_icon_name]} was "\
                  "#{main_line_completed?(main_line_icon_name) ? 'completed!' : 'improved'}"
          remove_icon(action.hex, [main_line_icon_name])
        end

        def special_tile_lay(action)
          @special_tile_lays << action
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?
          return [] unless round.steps.find { |step| step.instance_of?(G18SJ::Step::IssueShares) }.active?

          type = entity.share_price.type

          share_price = stock_market.find_share_price(entity, :current).price
          share_price = 0 if brown?(type)
          share_price = (share_price.to_f / 2).floor if orange?(type) || yellow?(type)

          bundle_max_size = 1
          bundle_max_size = 10 if brown?(type) || orange?(type)

          bundles_for_corporation(share_pool, entity)
            .each { |bundle| bundle.share_price = share_price }
            .reject { |bundle| bundle.shares.size > bundle_max_size }
            .reject { |bundle| entity.cash < bundle.price }
        end

        def orange?(type)
          type == :unlimited
        end

        def yellow?(type)
          type == :no_cert_limit
        end

        def brown?(type)
          type == :multiple_buy
        end

        def revenue_for(route, stops)
          ensure_route_does_not_passthrough_blocked_city(route, stops)
          revenue = super

          icons = visited_icons(stops)

          [lapplandspilen_bonus(icons),
           east_west_bonus(icons, stops),
           bergslagen_bonus(icons),
           orefields_bonus(icons),
           sveabolaget_bonus(route),
           gkb_bonus(route)].map { |b| b[:revenue] }.each { |r| revenue += r }

          return revenue unless route.train.name == 'E'

          # E trains double any city revenue if corporation's token (or SJ) is present
          revenue + stops.sum do |stop|
            friendly_city?(route, stop) ? stop.route_revenue(route.phase, route.train) : 0
          end
        end

        def revenue_str(route)
          stops = route.stops
          stop_hexes = stops.map(&:hex)
          str = route.hexes.map do |h|
            stop_hexes.include?(h) ? h&.name : "(#{h&.name})"
          end.join('-')

          icons = visited_icons(stops)

          [lapplandspilen_bonus(icons),
           east_west_bonus(icons, stops),
           bergslagen_bonus(icons),
           orefields_bonus(icons),
           sveabolaget_bonus(route),
           gkb_bonus(route)].map { |b| b[:description] }.compact.each { |d| str += " + #{d}" }

          str
        end

        def clean_up_after_dividend(entity)
          # Remove Gellivare Company tile lay ability if it has been used this OR
          unless @special_tile_lays.empty?
            abilities(gc, :tile_lay) do |ability|
              gc.remove_ability(ability)
              @log << "#{gc.name} tile lay ability removed"
            end
          end
          @special_tile_lays = []

          make_sj_tokens_impassable

          require_automa_trains(entity) if bot_corporation?(entity)
        end

        # Make SJ passable if current corporation has E train
        # This is a workaround that is not perfect in case a
        # corporation has E train + other train, but very unlikely
        def make_sj_tokens_passable_for_electric_trains(entity)
          return unless owns_electric_train?(entity)

          @sj.tokens.each { |t| t.type = :neutral }
          @sj_tokens_passable = true
        end

        def make_sj_tokens_impassable
          return unless @sj_tokens_passable

          @sj.tokens.each { |t| t.type = :blocking }
          @sj_tokens_passable = false
        end

        def require_automa_trains(entity)
          return unless automa_needs_to_require_trains?(entity)

          train = @depot.depot_trains.first

          # Automa prefer E train before D, as it depletes the bank quicker
          train.name = 'E' if train.name == 'D'

          # Require first train
          @log << "#{entity.name} requisition a #{train.name} train from #{train.owner.name}"
          source = train.owner
          buy_train(entity, train, :free)
          @phase.buying_train!(entity, train, source)
          perform_nationalization if pending_nationalization?

          require_automa_trains(entity)
        end

        def buying_power(entity, **)
          return 999 if bot_corporation?(entity)

          super
        end

        def automa_needs_to_require_trains?(entity)
          return false if entity.trains.size >= 2
          return true if entity.trains.empty?

          entity.trains.first.rusts_on
        end

        def event_close_companies!
          @companies.each { |c| close_cleanup(c) }
          super

          return if minor_khj.closed?

          @log << "Minor #{minor_khj.name} closes and its home token is removed"
          minor_khj.spend(minor_khj.cash, @bank) if minor_khj.cash.positive?
          minor_khj.tokens.first.remove!
          minor_khj.close!
        end

        def event_full_cap!
          @corporations
            .select { |c| c.percent_of(c) == 100 && !c.closed? }
            .each do |c|
              @log << "#{c.name} becomes full capitalization corporation as it has not been parred"
              c.capitalization = :full
              c.ipo_owner = @bank
              c.share_holders.keys.each do |sh|
                next if sh == @bank

                sh.shares_by_corporation[c].dup.each { |share| transfer_share(share, @bank) }
              end
            end
        end

        def event_nationalization!
          @pending_nationalization = true
        end

        def pending_nationalization?
          @pending_nationalization
        end

        def perform_nationalization
          @pending_nationalization = false
          candidates = @corporations.select { |c| !c.closed? && c.operated? && c.trains.empty? }
          candidates.reject! { |c| bot_corporation?(c) } if two_player_variant
          if candidates.empty?
            extra = two_player_variant ? " (excluding any run by #{@edelsward.name})" : ''
            @log << "Nationalization skipped as no trainless floated corporations#{extra}"
            return
          end

          # Merge the corporation with highest share price, and use the first operated as tie break
          merged = candidates.max_by { |c| [c.share_price.price, -@round.entities.find_index(c)] }

          nationalize_major(merged)
        end

        # If there are 2 station markers on the same city the
        # merged corporation must remove one and return it to its charter.
        # Return number of duplications.
        def remove_duplicate_tokens(target, merged)
          merged_tokens = merged.tokens.map(&:city).compact
          duplicate_count = 0
          target.tokens.each do |token|
            city = token.city
            if merged_tokens.include?(city)
              token.remove!
              duplicate_count += 1
            end
          end
          duplicate_count
        end

        def remove_reservation(merged)
          hex = hex_by_id(merged.coordinates)
          tile = hex.tile
          cities = tile.cities
          city = cities.find { |c| c.reserved_by?(merged) } || cities.first
          city.remove_reservation!(merged)
        end

        def transfer_home_token(target, merged)
          merged_home_token = merged.tokens.first
          return unless merged_home_token.city

          transfer_token(merged_home_token, merged, target)
        end

        def transfer_non_home_tokens(target, merged)
          merged.tokens.each do |token|
            next unless token.city

            transfer_token(token, merged, target)
          end
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil)
          upgrades = super

          return upgrades unless tile_manifest

          # Handle Stockholm tile manifest
          upgrades |= [@stockholm_tile_gray] if @stockholm_tile_gray && tile.name == '299SJ'

          upgrades
        end

        def requisit_corporation(name)
          requisited = corporation_by_id(name)
          @log << "#{operator_for_edelsward_requisition.name} selects #{requisited.name} to be requisited by #{@edelsward.name}"
          shares = requisited.shares_of(requisited)
          @share_pool.transfer_shares(Engine::ShareBundle.new(shares), @edelsward, price: 0)
          @stock_market.set_par(requisited, @stock_market.par_prices.find { |p| p.price == 67 })

          # Give the company free tile lays.
          ability = Engine::Ability::TileLay.new(type: 'tile_lay', tiles: [], hexes: [], closed_when_used_up: false,
                                                 reachable: true, free: true, special: false, when: 'track')
          requisited.add_ability(ability)
          ability = Ability::Token.new(type: 'token', hexes: [], extra_slot: false, from_owner: true, price: 0)
          requisited.add_ability(ability)
        end

        def sold_out_increase?(corporation)
          !bot_corporation?(corporation)
        end

        def operating_order
          floated_edelsward, floated = @corporations.select(&:floated?).partition { |c| bot_corporation?(c) }
          @minors.select(&:floated?) + floated.sort + floated_edelsward.sort_by(&:name)
        end

        def purchasable_companies(entity)
          return [] if bot_corporation?(entity)

          super
        end

        def entity_can_use_company?(entity, company)
          return false if bot_corporation?(entity) || (company == nydqvist_och_holm && company.owner != entity)

          super
        end

        def player_value(player)
          return 0 if bot_player?(player)

          super
        end

        def result
          return super unless two_player_variant

          @players.reject { |p| bot_player?(p) }
            .map { |p| [p.id, player_value(p)] }
            .sort_by { |_, v| v }
            .reverse
            .to_h
        end

        def operator_for_edelsward_corporation
          # The player to act as bot during OR has the highest value (with nearest to PD as tie breaker)
          @players.reject { |p| bot_player?(p) }.min_by { |p| [-p.value, @players.index(p)] }
        end

        def operator_for_edelsward_requisition
          # The player to select requisition has the lowest value (with nearest to PD as tie breaker)
          @players.reject { |p| bot_player?(p) }.min_by { |p| [p.value, @players.index(p)] }
        end

        def gkb_bonuses_details(route)
          gkb_bonuses = []
          route.stops.each do |s|
            next unless gkb_hex_assigned?(s.hex)

            key = ASSIGNMENT_TOKENS.find { |id, _| s.hex.assigned?(id) }.first
            gkb_bonuses << { hex: s.hex, key: key, amount: key.sub('GKB', '').to_i }
          end
          gkb_bonuses
        end

        private

        def main_line_hex?(hex)
          MAIN_LINE_ORIENTATION[hex.name]
        end

        def connects_main_line?(hex)
          return unless (orientation = MAIN_LINE_ORIENTATION[hex.name])

          paths = hex.tile.paths
          exits = [orientation[0], orientation[1]]
          paths.any? { |path| (path.exits & exits).size == 2 } ||
            (path_to_city(paths, orientation[0]) && path_to_city(paths, orientation[1]))
        end

        def path_to_city(paths, edge)
          paths.find { |p| p.exits == [edge] }
        end

        def main_line_completed?(main_line_icon_name)
          @main_line_built[main_line_icon_name] += 1
          @main_line_built[main_line_icon_name] == MAIN_LINE_COUNT[main_line_icon_name]
        end

        def current_cert_limit
          available_corporations = @corporations.count { |c| !c.closed? }
          available_corporations = 10 if available_corporations > 10

          certs_per_player = CERT_LIMIT[available_corporations]
          raise GameError, "No cert limit defined for #{available_corporations} corporations" unless certs_per_player

          set_cert_limit = certs_per_player[player_count]
          raise GameError, "No cert limit defined for #{@players.size} players" unless set_cert_limit

          set_cert_limit
        end

        def nationalize_major(major)
          @log << "#{major.name} is nationalized"
          @log << "#{major.name} closes and its tokens becomes #{@sj.name} tokens"

          remove_reservation(major)
          transfer_home_token(@sj, major)
          transfer_non_home_tokens(@sj, major)

          major.companies.dup.each(&:close!)

          # Decrease share price two step and then give compensation with this price
          old_price = major.share_price
          @stock_market.move_left(major)
          @stock_market.move_left(major)
          log_share_price(major, old_price)
          refund = major.share_price.price
          @players.each do |p|
            refund_amount = 0
            p.shares_of(major).dup.each do |s|
              next unless s

              refund_amount += (s.percent / 10) * refund
              s.transfer(major)
            end
            next unless refund_amount.positive?

            @log << "#{p.name} receives #{format_currency(refund_amount)} in share compensation"
            @bank.spend(refund_amount, p)
          end

          # Transfer bank pool shares to IPO
          @share_pool.shares_of(major).dup.each do |s|
            s.transfer(major)
          end

          major.spend(major.cash, @bank) if major.cash.positive?
          major.close!

          # Cert limit changes as the number of corporations decrease
          @log << "Certificate limit is now #{cert_limit}"
        end

        def transfer_token(token, merged, target_corporation)
          city = token.city

          if tokened_hex_by(city.hex, target_corporation)
            @log << "#{merged.name}'s token in #{token.city.hex.name} is removed "\
                    "as there is already an #{target_corporation.name} token there"
            token.remove!
          else
            @log << "#{merged.name}'s token in #{city.hex.name} is replaced with an #{target_corporation.name} token"
            token.remove!
            replacement_token = Engine::Token.new(target_corporation)
            target_corporation.tokens << replacement_token
            city.place_token(target_corporation, replacement_token, check_tokenable: false)
          end
        end

        def visited_icons(stops)
          icons = []
          stops.each do |s|
            s.hex.tile.icons.each do |icon|
              next unless BONUS_ICONS.include?(icon.name)

              icons << icon.name
            end
          end
          icons.sort!
        end

        def lapplandspilen_bonus(icons)
          bonus = { revenue: 0 }

          if icons.include?('N') && icons.include?('S')
            bonus[:revenue] += 100
            bonus[:description] = 'N/S'
          end

          bonus
        end

        def east_west_bonus(icons, stops)
          bonus = { revenue: 0 }
          hexes = stops.map { |s| s.hex.id }

          if icons.include?('O') && icons.include?('V') && hexes.include?('H9') && (hexes.include?('A2') || hexes.include?('A10'))
            bonus[:revenue] += 120
            bonus[:description] = 'Ö/V'
          end

          bonus
        end

        def bergslagen_bonus(icons)
          bonus = { revenue: 0 }

          if icons.include?('B') && icons.count('b_lower_case') == 1
            bonus[:revenue] += 50
            bonus[:description] = 'b/B'
          end
          if icons.include?('B') && icons.count('b_lower_case') > 1
            bonus[:revenue] += 100
            bonus[:description] = 'b/B/b'
          end

          bonus
        end

        def orefields_bonus(icons)
          bonus = { revenue: 0 }

          if icons.include?('M') && icons.count('m_lower_case') == 1
            bonus[:revenue] += 50
            bonus[:description] = 'm/M'
          end
          if icons.include?('M') && icons.count('m_lower_case') > 1
            bonus[:revenue] += 100
            bonus[:description] = 'm/M/m'
          end

          bonus
        end

        def sveabolaget_bonus(route)
          bonus = { revenue: 0 }

          steam = sveabolaget&.id
          revenue = 0
          if route.corporation == sveabolaget&.owner &&
            (port = route.stops.map(&:hex).find { |hex| hex.assigned?(steam) })
            revenue += 30 * port.tile.icons.count { |icon| icon.name == 'port' }
          end
          if revenue.positive?
            bonus[:revenue] = revenue
            bonus[:description] = 'Port'
          end

          bonus
        end

        def gkb_bonus(route)
          bonus = { revenue: 0 }

          return bonus if !gkb || route.train.owner != gkb.owner

          gkb_bonuses_details(route).each do |gbd|
            bonus[:revenue] += gbd[:amount]
            details = "#{gbd[:key]}(#{gbd[:hex].name})"
            if bonus[:description]
              bonus[:description] += " + #{details}"
            else
              bonus[:description] = details
            end
          end

          bonus
        end

        def close_cleanup(company)
          cleanup_gkb(company) if company.sym == 'GKB'
          cleanup_sb(company) if company.sym == 'SB'
        end

        def cleanup_gkb(company)
          @log << "Removes icons for #{company.name}"
          remove_icons(GKB_HEXES, %w[GKB])
        end

        def cleanup_sb(company)
          @log << "Removes icons and token for #{company.name}"
          remove_icons(%w[A6 C2 D5 F19 F23 G26], %w[port sb_token])
          steam = sveabolaget&.id
          @hexes.select { |hex| hex.assigned?(sveabolaget.id) }.each { |h| h.remove_assignment!(steam) } if steam
        end

        def remove_icons(to_be_cleaned, icon_names)
          @hexes.each { |hex| remove_icon(hex, icon_names) if to_be_cleaned.include?(hex.name) }
        end

        def remove_icon(hex, icon_names)
          icon_names.each do |name|
            icons = hex.tile.icons
            icons.reject! { |i| name == i.name }
            hex.tile.icons = icons
          end
        end

        def friendly_city?(route, stop)
          corp = route.train.owner
          tokened_hex_by(stop.hex, corp)
        end

        def tokened_hex_by(hex, corporation)
          hex.tile.cities.any? { |c| c.tokened_by?(corporation) }
        end

        def owns_electric_train?(entity)
          entity.trains.any? { |t| t.name == 'E' }
        end

        def player_count
          # Two player variant will add a third player during setup but we need
          # to handle setup of cash and cert limit so that it includes the bot.
          two_player_variant ? 3 : @players.size
        end

        def ensure_route_does_not_passthrough_blocked_city(route, stops)
          return if stops.size < 3 || !owns_electric_train?(route.train.owner) || route.train.name == 'E'

          # Check if a stop (excluding start and stop) does not allow pass-through
          # due to temporary passable SJ token
          stops[1...-1].each do |s|
            next if !s.city? || s.tokened_by?(route.train.owner)

            raise GameError, "Cannot passthrough blocked city in #{s.hex.name}" if s.tokens.all? { |t| t&.corporation }
          end
        end

        # just a basic share move without payment or president change (taken from 1862)
        def transfer_share(share, new_owner)
          corp = share.corporation
          corp.share_holders[share.owner] -= share.percent
          corp.share_holders[new_owner] += share.percent
          share.owner.shares_by_corporation[corp].delete(share)
          new_owner.shares_by_corporation[corp] << share
          share.owner = new_owner
        end
      end
    end
  end
end
