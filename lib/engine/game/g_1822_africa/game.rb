# frozen_string_literal: true

require_relative '../g_1822/game'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1822Africa
      class Game < G1822::Game
        include_meta(G1822Africa::Meta)
        include G1822Africa::Entities
        include G1822Africa::Map

        attr_accessor :gold_mine_token

        CERT_LIMIT = { 2 => 99, 3 => 99, 4 => 99 }.freeze

        BIDDING_TOKENS = {
          '2': 3,
          '3': 2,
          '4': 2,
        }.freeze

        EXCHANGE_TOKENS = {
          'NAR' => 2,
          'WAR' => 2,
          'EAR' => 2,
          'CAR' => 2,
          'SAR' => 2,
        }.freeze

        STARTING_CASH = { 2 => 500, 3 => 375, 4 => 300 }.freeze

        STARTING_COMPANIES = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12 C1 C2 C3 C4 C5
                                M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12].freeze

        STARTING_CORPORATIONS = %w[1 2 3 4 5 6 7 8 9 10 11 12
                                   NAR WAR EAR CAR SAR].freeze

        CURRENCY_FORMAT_STR = 'A%s'

        BANK_CASH = 99_999

        MARKET = [
          %w[40 50p 60xp 70xp 80xp 95m 115 140 170 205 250 300 350e 400e],
        ].freeze

        MUST_SELL_IN_BLOCKS = true
        SELL_MOVEMENT = :left_per_10_if_pres_else_left_one

        GAME_END_CHECK = { stock_market: :current_or, bid_boxes: :full_or }.freeze
        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          bid_boxes: 'Cannot refill bid boxes'
        )

        ASSIGNMENT_TOKENS = {
          P15: '/icons/1822_africa/coffee.svg',
        }.freeze

        TOKEN_PRICE = 100

        PRIVATES_IN_GAME = 12

        EXTRA_TRAINS = %w[2P P+ LP S].freeze
        EXTRA_TRAIN_PERMANENTS = %w[2P LP].freeze

        PRIVATE_TRAINS = %w[P1 P2 P3 P4 P18].freeze
        PRIVATE_MAIL_CONTRACTS = [].freeze # Stub
        PRIVATE_PHASE_REVENUE = %w[P16].freeze
        PRIVATE_REMOVE_REVENUE = %w[P13].freeze

        COMPANY_10X_REVENUE = 'P16'
        COMPANY_REMOVE_TOWN = 'P9'
        COMPANY_ADD_TOWN = 'P5'
        COMPANY_EXTRA_TILE_LAYS = %w[P7 P8 P12].freeze
        COMPANY_TOKEN_SWAP = 'P13'
        COMPANY_RECYCLED_TRAIN = 'P6'
        COMPANY_SELL_SHARE = 'P17'

        COMPANY_COFFEE_PLANTATION = 'P15'
        COFFEE_PLANTATION_PLACEMENT_BONUS = 30
        COFFEE_PLANTATION_ROUTE_BONUS = 20

        COMPANY_GOLD_MINE = 'P14'
        GOLD_MINE_BONUS = 20

        COMPANY_RESERVE_THREE_TILES = 'P8'

        GAME_RESERVE_TILE = 'GR'
        GAME_RESERVE_MULTIPLIER = 5

        SAFARI_TRAIN_BONUS = 20

        MINOR_BIDBOX_PRICE = 100
        BIDDING_BOX_MINOR_COUNT = 3

        STOCK_ROUND_NAME = 'Stock'
        STOCK_ROUND_COUNT = 2

        # Disable 1822-specific rules
        MINOR_14_ID = nil
        COMPANY_LCDR = nil
        COMPANY_EGR = nil
        COMPANY_DOUBLE_CASH = nil
        COMPANY_GSWR = nil
        COMPANY_GSWR_DISCOUNT = nil
        COMPANY_BER = nil
        COMPANY_LSR = nil
        COMPANY_OSTH = nil
        COMPANY_LUR = nil
        COMPANY_5X_REVENUE = nil
        COMPANY_HSBC = nil
        FRANCE_HEX = nil
        CARDIFF_HEX = nil
        ENGLISH_CHANNEL_HEX = nil
        MERTHYR_TYDFIL_PONTYPOOL_HEX = nil
        UPGRADABLE_S_HEX_NAME = nil
        BIDDING_BOX_START_PRIVATE = nil
        BIDDING_BOX_START_MINOR = nil
        DOUBLE_HEX = [].freeze

        PRIVATE_COMPANIES_ACQUISITION = {
          'P1' => { acquire: %i[major minor], phase: 1 },
          'P2' => { acquire: %i[major], phase: 2 },
          'P3' => { acquire: %i[major], phase: 2 },
          'P4' => { acquire: %i[major minor], phase: 3 },
          'P5' => { acquire: %i[major minor], phase: 2 },
          'P6' => { acquire: %i[major minor], phase: 3 },
          'P7' => { acquire: %i[major minor], phase: 3 },
          'P8' => { acquire: %i[major minor], phase: 1 },
          'P9' => { acquire: %i[major minor], phase: 2 },
          'P10' => { acquire: %i[major minor], phase: 3 },
          'P11' => { acquire: %i[major minor], phase: 3 },
          'P12' => { acquire: %i[major minor], phase: 1 },
          'P13' => { acquire: %i[major], phase: 5 },
          'P14' => { acquire: %i[major], phase: 3 },
          'P15' => { acquire: %i[major minor], phase: 1 },
          'P16' => { acquire: %i[major minor], phase: 2 },
          'P17' => { acquire: %i[major], phase: 2 },
          'P18' => { acquire: %i[major minor], phase: 3 },
        }.freeze

        COMPANY_SHORT_NAMES = {
          'P1' => 'P1 (Permanent L-train)',
          'P2' => 'P2 (Permanent 2-train)',
          'P3' => 'P3 (Permanent 2-train)',
          'P4' => 'P4 (Pullman)',
          'P5' => 'P5 (Add Town)',
          'P6' => 'P6 (Recycled train)',
          'P7' => 'P7 (Extra tile)',
          'P8' => 'P8 (Reserve Three Tiles)',
          'P9' => 'P9 (Remove Town)',
          'P10' => 'P10 (Game Reserve)',
          'P11' => 'P11 (Mountain Rebate)',
          'P12' => 'P12 (Fast Sahara Building)',
          'P13' => 'P13 (Station Swap)',
          'P14' => 'P14 (Gold Mine)',
          'P15' => 'P15 (Coffee Plantation)',
          'P16' => 'P16 (A10x Phase)',
          'P17' => 'P17 (Bank Share Buy)',
          'P18' => 'P18 (Safari Bonus)',
          'C1' => 'NAR',
          'C2' => 'WAR',
          'C3' => 'EAR',
          'C4' => 'CAR',
          'C5' => 'SAR',
          'M1' => '1',
          'M2' => '2',
          'M3' => '3',
          'M4' => '4',
          'M5' => '5',
          'M6' => '6',
          'M7' => '7',
          'M8' => '8',
          'M9' => '9',
          'M10' => '10',
          'M11' => '11',
          'M12' => '12',
        }.freeze

        EVENTS_TEXT = {
          'close_concessions' =>
            ['Concessions close', 'All concessions close without compensation, major companies float at 50%'],
          'full_capitalisation' =>
            ['Full capitalisation', 'Major companies receive full capitalisation when floated'],
          'phase_revenue' =>
            ['Phase revenue company closes', 'P16 closes if not owned by a major company'],
        }.freeze

        STATUS_TEXT = G1822::Game::STATUS_TEXT.merge(
          'can_acquire_minor_bidbox' => ['Acquire a minor from bidbox',
                                         'Can acquire a minor from bidbox for A100, must have connection '\
                                         'to start location'],
          'minor_float_phase1' => ['Minors receive A100 in capital', 'Minors receive A100 capital with A50 stock value'],
          'minor_float_phase2' => ['Minors receive 2X stock value in capital',
                                   'Minors receive 2X stock value as capital '\
                                   'and float at between A50 to A80 stock value based on bid'],
          'minor_float_phase3on' => ['Minors receive winning bid as capital',
                                     'Minors receive entire winning bid as capital '\
                                     'and float at between A50 to A80 stock value based on bid'],
        ).freeze

        MARKET_TEXT = G1822::Game::MARKET_TEXT.merge(max_price: 'Maximum price for a minor').freeze

        PHASES = [
          {
            name: '1',
            on: '',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            status: ['minor_float_phase1'],
            operating_rounds: 1,
          },
          {
            name: '2',
            on: %w[2 3],
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            status: %w[can_convert_concessions minor_float_phase2],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains can_convert_concessions minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5/E',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains
                       can_acquire_minor_bidbox
                       can_par
                       minors_green_upgrade
                       minor_float_phase3on],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6/E',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            status: %w[can_buy_trains
                       can_acquire_minor_bidbox
                       can_par
                       full_capitalisation
                       minors_green_upgrade
                       minor_float_phase3on],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: 'L',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 10,
            price: 50,
            rusts_on: '3',
            variants: [
              {
                name: '2',
                distance: 2,
                price: 100,
                rusts_on: '5/E',
                available_on: '1',
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            num: 5,
            price: 160,
            rusts_on: '6/E',
          },
          {
            name: '5/E',
            distance: 5,
            num: 3,
            price: 350,
            events: [
              {
                'type' => 'close_concessions',
              },
            ],
          },
          {
            name: '6/E',
            distance: 6,
            num: 99,
            price: 400,
            events: [
              {
                'type' => 'full_capitalisation',
              },
              {
                'type' => 'phase_revenue',
              },
            ],
          },
          {
            name: '2P',
            distance: 2,
            num: 2,
            price: 0,
          },
          {
            name: 'LP',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 1,
            price: 0,
          },
          {
            name: 'P+',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 99,
                'visit' => 99,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 1,
            price: 0,
          },
          {
            name: 'LR',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 1,
            price: 50,
          },
          {
            name: '2R',
            distance: 2,
            num: 1,
            price: 100,
          },
          {
            name: '3R',
            distance: 3,
            num: 1,
            price: 160,
          },
          {
            name: 'S',
            distance: 2,
            num: 1,
            price: 0,
          },
        ].freeze

        TRAIN_AUTOROUTE_GROUPS = [
          %w[E/5 E/6],
        ].freeze

        UPGRADE_COST_L_TO_2 = 70

        @bidbox_cache = []
        @bidbox_companies_size = false

        def init_companies(_players)
          game_companies.map do |company|
            Company.new(**company)
          end.compact
        end

        def setup_companies
          minors = @companies.select { |c| minor?(c) }
          concessions = @companies.select { |c| concession?(c) }
          privates = @companies.select { |c| private?(c) }.sort_by! { rand }

          @companies.clear
          @companies.concat(minors)
          @companies.concat(concessions)
          @companies.concat(privates.take(self.class::PRIVATES_IN_GAME))

          unused_privates = privates.drop(self.class::PRIVATES_IN_GAME)
          @log << "Private companies not in this game: #{unused_privates.map(&:name).join(', ')}"

          # Randomize from preset seed to get same order
          @companies.sort_by! { rand }

          # Put closest concessions to slots 1 and 4 of timeline
          reordered_companies = reorder_on_concession(@companies)
          @companies = reordered_companies[0..2] + reorder_on_concession(reordered_companies[3..-1])

          # Set the min bid on the Concessions and Minors
          @companies.each do |c|
            c.min_price = case c.id[0]
                          when self.class::COMPANY_CONCESSION_PREFIX, self.class::COMPANY_MINOR_PREFIX
                            c.value
                          else
                            0
                          end
            c.max_price = 10_000
          end

          # Setup company abilities
          @company_trains = {}
          @company_trains['P1'] = find_and_remove_train_by_id('LP-0', buyable: false)
          @company_trains['P2'] = find_and_remove_train_by_id('2P-0', buyable: false)
          @company_trains['P3'] = find_and_remove_train_by_id('2P-1', buyable: false)
          @company_trains['P4'] = find_and_remove_train_by_id('P+-0', buyable: false)
          @company_trains['P18'] = find_and_remove_train_by_id('S-0', buyable: false)

          @recycled_trains = [
            find_and_remove_train_by_id('LR-0', buyable: false),
            find_and_remove_train_by_id('2R-0', buyable: false),
            find_and_remove_train_by_id('3R-0', buyable: false),
          ].freeze
        end

        def reorder_on_concession(companies)
          index = companies.find_index { |c| concession?(c) }

          # Only reorder if next concession is not the first company
          return companies if index.zero?

          head = companies[0..index - 1]
          tail = companies[index..-1]

          tail + head
        end

        def setup_bidboxes
          # Set the owner to bank for the companies up for auction this stockround
          bidbox_refill!
          bidbox.each do |company|
            company.owner = @bank
          end
        end

        def bidbox
          bank_companies.first(self.class::BIDDING_BOX_MINOR_COUNT)
        end

        def bank_companies
          @companies.select do |c|
            (!c.owner || c.owner == @bank) && !c.closed?
          end
        end

        def timeline
          timeline = []

          companies = bank_companies.map do |company|
            "#{self.class::COMPANY_SHORT_NAMES[company.id]}#{'*' if bidbox.any? { |c| c == company }}"
          end

          timeline << companies.join(', ') unless companies.empty?

          timeline
        end

        def unowned_purchasable_companies(_entity)
          bank_companies
        end

        def bidbox_refill!
          @bidbox_cache = bank_companies
                                        .first(self.class::BIDDING_BOX_MINOR_COUNT)
                                        .select { |c| minor?(c) }
                                        .map(&:id)

          # Set the reservation color of all the minors in the bid boxes
          @bidbox_cache.each do |company_id|
            corporation_by_id(company_id[1..-1]).reservation_color = self.class::BIDDING_BOX_MINOR_COLOR
          end

          @bidbox_companies_size = bidbox.length
        end

        def init_stock_market
          G1822Africa::StockMarket.new(game_market, [])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            G1822::Step::PendingToken,
            G1822::Step::FirstTurnHousekeeping,
            G1822::Step::AcquireCompany,
            G1822::Step::DiscardTrain,
            G1822::Step::SpecialChoose,
            G1822Africa::Step::LayGameReserve,
            G1822Africa::Step::SpecialTrack,
            G1822Africa::Step::SpecialToken,
            G1822Africa::Step::Assign,
            G1822::Step::Track,
            G1822::Step::DestinationToken,
            G1822Africa::Step::Token,
            G1822Africa::Step::Route,
            G1822::Step::Dividend,
            G1822Africa::Step::BuyTrain,
            G1822Africa::Step::MinorAcquisition,
            G1822::Step::PendingToken,
            G1822::Step::DiscardTrain,
            G1822Africa::Step::IssueShares,
          ], round_num: round_num)
        end

        def stock_round(round_num = 1)
          G1822Africa::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1822::Step::BuySellParShares,
          ], round_num: round_num)
        end

        def total_rounds(name)
          case name
          when self.class::OPERATING_ROUND_NAME
            @operating_rounds
          when self.class::STOCK_ROUND_NAME
            self.class::STOCK_ROUND_COUNT
          end
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              if @round.round_num == 1
                new_stock_round(@round.round_num + 1)
              else
                @operating_rounds = @phase.operating_rounds
                reorder_players
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

        def new_stock_round(round_num = 1)
          @log << "-- #{round_description('Stock', round_num)} --"
          @round_counter += 1
          stock_round(round_num)
        end

        def concession?(company)
          company.id[0] == self.class::COMPANY_CONCESSION_PREFIX
        end

        def minor?(company)
          company.id[0] == self.class::COMPANY_MINOR_PREFIX
        end

        def private?(company)
          company.id[0] == self.class::COMPANY_PRIVATE_PREFIX
        end

        def game_end_check_bid_boxes?
          bidbox.length < self.class::BIDDING_BOX_MINOR_COUNT
        end

        def reset_sold_in_sr!
          @nothing_sold_in_sr = true
        end

        def must_remove_town?(entity)
          entity.id == self.class::COMPANY_REMOVE_TOWN
        end

        def must_add_town?(entity)
          entity.id == self.class::COMPANY_ADD_TOWN
        end

        def train_help(entity, runnable_trains, _routes)
          help = super

          hybrid_trains = runnable_trains.any? { |t| can_be_express?(t) }

          if hybrid_trains
            help << '5/E and 6/E trains can run either as usual, or as Express. '\
                    "Express trains run unlimited distance, only count cities that have a #{entity.name} token "\
                    'and double the revenue.'
          end

          help
        end

        def revenue_for(route, stops)
          revenue = super

          revenue += plantation_bonus(route)
          revenue += gold_mine_bonus(route, stops)
          revenue += safari_train_bonus(route)

          revenue
        end

        def plantation_bonus(route)
          route.all_hexes.any? { |hex| plantation_assigned?(hex) } ? self.class::COFFEE_PLANTATION_ROUTE_BONUS : 0
        end

        def gold_mine_corp
          @gold_mine_corp ||= Corporation.new(
            sym: 'MINE',
            name: 'Gold Mine',
            logo: '1822_africa/gold_mine',
            tokens: [0],
          )
        end

        def gold_mine_bonus(route, stops)
          return 0 unless @gold_mine_token

          gold_stop = stops&.find { |s| s.hex == @gold_mine_token.hex }

          return 0 unless gold_stop
          return 0 if train_type(route.train) == :etrain && !gold_stop.tokened_by?(route.train.owner)

          self.class::GOLD_MINE_BONUS
        end

        def safari_train_bonus(route)
          return 0 unless safari_train_attached?(route.train)

          self.class::SAFARI_TRAIN_BONUS * find_game_reserves(route.all_hexes).count
        end

        def revenue_str(route)
          str = super

          str += ' +20 (Coffee Plantation) ' if plantation_bonus(route).positive?
          str += ' +20 (Gold Mine)' if gold_mine_bonus(route, route.stops).positive?

          safari_bonus = safari_train_bonus(route)
          str += " + #{safari_bonus} (Safari)" if safari_bonus.positive?

          str
        end

        def train_type(train)
          train.name[0] == 'E' ? :etrain : :normal
        end

        def route_trains(entity)
          entity.runnable_trains.reject { |t| pullman_train?(t) || safari_train?(t) }
        end

        def safari_train?(t)
          t.name == 'S'
        end

        def safari_train_attached?(t)
          t.name[-1] == 'S'
        end

        def can_be_express?(train)
          train.name[-1] == 'E'
        end

        def company_ability_extra_track?(company)
          self.class::COMPANY_EXTRA_TILE_LAYS.include?(company.id)
        end

        def tile_game_reserve?(tile)
          tile.name == self.class::GAME_RESERVE_TILE
        end

        def plantation_assigned?(hex)
          hex.assigned?(self.class::COMPANY_COFFEE_PLANTATION)
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return true if special && tile_game_reserve?(to)
          return false if from.color == :yellow && plantation_assigned?(from.hex)

          # Special case for P5 where we add a town to a tile
          if self.class::TRACK_PLAIN.include?(from.name) && self.class::TRACK_TOWN.include?(to.name)
            return Engine::Tile::COLORS.index(to.color) == (Engine::Tile::COLORS.index(from.color) + 1)
          end

          result = super

          return result unless reserve_tiles_owner_active?

          result && @reserved_tiles.any? { |t| t.name == to.name }
        end

        def reserve_tiles_owner_active?
          return false if !@tile_reservations_done || @reserved_tiles.none?

          current_entity == company_reserve_tiles&.owner
        end

        def find_game_reserves(hexes)
          hexes.select { |h| h.tile.color == :purple }
        end

        def pay_game_reserve_bonus!(entity)
          reserves = find_game_reserves(hexes)
          bonus = hex_crow_distance_not_inclusive(*reserves) * self.class::GAME_RESERVE_MULTIPLIER

          return if bonus.zero?

          corporation = entity.owner

          @log << "#{corporation.id} receives a Game Reserve bonus of #{format_currency(bonus)} from the bank"

          @bank.spend(bonus, corporation)
        end

        def hex_crow_distance_not_inclusive(start, finish)
          dx = (start.x - finish.x).abs - 1
          dy = (start.y - finish.y).abs - 1
          dx + [0, (dy - dx) / 2].max
        end

        # This game has two back-to-back SRs so we need to manually disable auto-pass on round end
        def check_programmed_actions
          @programmed_actions.each do |entity, action_list|
            action_list.reject! do |action|
              if action&.disable?(self) || action.instance_of?(Engine::Action::ProgramSharePass)
                player_log(entity, "Programmed action '#{action}' removed due to round change")
                true
              end
            end
          end
        end

        def company_choices(company, time)
          case company.id
          when self.class::COMPANY_TOKEN_SWAP
            company_choices_chpr(company, time)
          when self.class::COMPANY_RECYCLED_TRAIN
            company_choices_recycled_train(company, time)
          when self.class::COMPANY_SELL_SHARE
            company_choices_sell_share(company, time)
          when self.class::COMPANY_RESERVE_THREE_TILES
            company_choices_reserve_three_tiles(company, time)
          else
            {}
          end
        end

        def company_choices_recycled_train(company, time)
          return {} if time != :buy_train || !company.owner&.corporation?
          return {} unless room?(company.owner)

          choices = {}

          @depot.trains.group_by(&:name).each do |name, trains|
            train = trains.first
            next unless train.rusted

            choices[name] = "Buy #{name} for #{format_currency(train.price)}"
          end

          choices
        end

        def company_choices_sell_share(company, time)
          return {} if !company.owner&.corporation? || !%i[token track buy_train issue acquire_minor].include?(time)
          return {} if company.owner.num_treasury_shares.zero?

          corp = company.owner

          { sell: "Sell #{corp.name} treasury share for #{format_currency(corp.share_price.price)}" }
        end

        def company_choices_reserve_three_tiles(company, _time)
          return {} if !company.owner&.corporation? || @tile_reservations_done

          choices = {}

          available_tiles = tiles.reject { |t| t.color == :purple }.group_by(&:name)

          available_tiles.each do |name, tiles|
            choices[name] = "##{name} × #{tiles.size}"
          end

          choices
        end

        def company_made_choice(company, choice, _time)
          case company.id
          when self.class::COMPANY_TOKEN_SWAP
            company_made_choice_chpr(company, choice)
          when self.class::COMPANY_RECYCLED_TRAIN
            company_made_choice_recycled_train(company, choice)
          when self.class::COMPANY_SELL_SHARE
            company_made_choice_sell_share(company, choice)
          when self.class::COMPANY_RESERVE_THREE_TILES
            company_made_choice_reserve_three_tiles(company, choice)
          end
        end

        def company_made_choice_recycled_train(company, choice)
          train = @recycled_trains.find { |t| t.name.start_with?(choice) }
          buy_train(company.owner, train)
          @log << "#{company.owner.name} buys a recycled #{train.name} train for #{format_currency(train.price)}"

          company.close!
          @log << "#{company.name} closes"
        end

        def company_made_choice_sell_share(company, _choice)
          share_pool.sell_shares(ShareBundle.new(company.owner.treasury_shares.first))

          @log << "#{company.name} closes"
          company.close!
        end

        def company_made_choice_reserve_three_tiles(company, choice)
          return if @tile_reservations_done

          tile = @tiles.find { |t| t.name == choice }

          @reserved_tiles ||= []
          @reserved_tiles << tile

          @tiles.delete(tile)

          @log << "#{company.owner.name} reserves tile ##{tile.name}"

          finish_tile_reservations(company) if @reserved_tiles.size == 3
        end

        def finish_tile_reservations(company)
          @tile_reservations_done = true
          update_tile_reservations!
          @log << "#{company.owner.name} can only lay reserved tiles until all of them are placed"
        end

        def update_tile_reservations!
          company_reserve_tiles.revenue = 5 * @reserved_tiles.size

          return if @reserved_tiles.any?

          @log << "#{company_reserve_tiles.name} closes"
          company_reserve_tiles.close!
        end

        def update_tile_lists(tile, old_tile)
          if reserve_tiles_owner_active? && @reserved_tiles&.include?(tile)
            @tiles << tile
            @reserved_tiles.delete(tile)
            update_tile_reservations!
          end

          super
        end

        def company_reserve_tiles
          @company_reserve_tiles ||= company_by_id(self.class::COMPANY_RESERVE_THREE_TILES)
        end

        def tiles
          return @tiles unless reserve_tiles_owner_active?

          @reserved_tiles + @tiles
        end

        def room?(entity)
          entity.trains.count { |t| !extra_train?(t) } < train_limit(entity)
        end

        def company_status_str(company)
          if company == company_reserve_tiles && @reserved_tiles&.any?
            return "[#{@reserved_tiles.map { |t| "##{t.name}" }.join(', ')}]"
          end

          super
        end

        # Stubbed out because this game doesn't use it, but base 22 does
        def bidbox_minors = []
        def bidbox_concessions = []
        def bidbox_privates = []
        def company_tax_haven_bundle(choice); end
        def company_tax_haven_payout(entity, per_share); end
        def num_certs_modification(_entity) = 0

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['Dividend 0 or withheld', '1 ←'],
            ['Dividend < share price', 'none'],
            ['Dividend ≥ share price, < 2x share price ', '1 →'],
            ['Dividend ≥ 2x share price', '2 →'],
            ['Minor company dividend > 0', '1 →'],
            ['Each share sold (if sold by director)', '1 ←'],
            ['One or more shares sold (if sold by non-director)', '1 ←'],
          ]
        end
      end
    end
  end
end
