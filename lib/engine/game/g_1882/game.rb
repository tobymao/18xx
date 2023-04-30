# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1882
      class Game < Game::Base
        include_meta(G1882::Meta)
        include Entities
        include Map

        register_colors(green: '#237333',
                        gray: '#9a9a9d',
                        red: '#d81e3e',
                        blue: '#0189d1',
                        yellow: '#FFF500',
                        brown: '#7b352a')

        CORPORATIONS_WITHOUT_NEUTRAL = %w[CPR CN].freeze

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 9000

        CERT_LIMIT = { 2 => 20, 3 => 14, 4 => 11, 5 => 10, 6 => 9 }.freeze

        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[76
             82
             90
             100p
             112
             126
             142
             160
             180
             200
             225
             250
             275
             300
             325
             350e],
          %w[70
             76
             82
             90p
             100
             112
             126
             142
             160
             180
             200
             220
             240
             260
             280
             300],
          %w[65
             70
             76
             82p
             90
             100
             111
             125
             140
             155
             170
             185
             200],
          %w[60y 66 71 76p 82 90 100 110 120 130],
          %w[55y 62 67 71p 76 82 90 100],
          %w[50y 58y 65 67p 71 75 80],
          %w[45o 54y 63 67 69 70],
          %w[40o 50y 60y 67 68],
          %w[30b 40o 50y 60y],
          %w[20b 30b 40o 50y],
          %w[10b 20b 30b 40o],
        ].freeze

        PHASES = [
          {
            name: '2',
            on: '2',
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
            status: ['can_buy_companies'],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '5',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: ['can_buy_companies'],
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 6 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 5 },
                  { name: '4', distance: 4, price: 300, rusts_on: 'D', num: 4 },
                  {
                    name: '5',
                    distance: 5,
                    price: 450,
                    num: 3,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  { name: '6', distance: 6, price: 630, num: 3 },
                  {
                    name: 'D',
                    distance: 999,
                    price: 1100,
                    num: 20,
                    available_on: '6',
                    discount: { '4' => 300, '5' => 300, '6' => 300 },
                  }].freeze

        MUST_BID_INCREMENT_MULTIPLE = true
        SELL_BUY_ORDER = :sell_buy_sell
        TRACK_RESTRICTION = :permissive
        DISCARDED_TRAINS = :remove
        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'nwr' => ['North West Rebellion',
                    'Remove all yellow tiles from NWR-marked hexes. Station markers remain']
        ).freeze

        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_round, bank: :full_or }.freeze
        # Two lays or one upgrade, second tile costs 20
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false, cost: 20 }].freeze

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1882::Step::HomeToken,
            G1882::Step::BuySellParShares,
          ])
        end

        def new_auction_round
          Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G1882::Step::WaterfallAuction,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            G1882::Step::SpecialNWR,
            G1882::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1882::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def home_token_locations(corporation)
          raise NotImplementedError unless corporation.name == 'SC'

          # SC, find all locations with neutral or no token
          cn_corp = corporations.find { |x| x.name == 'CN' }
          hexes = @hexes.dup
          hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) || city.tokened_by?(cn_corp) }
          end
        end

        def add_extra_train_when_sc_pars(corporation)
          first = depot.upcoming.first
          train = @sc_reserve_trains.find { |t| t.name == first.name }
          @sc_company = nil
          return unless train

          # Move events other than NWR rebellion earlier.
          train.events, first.events = first.events.partition { |e| e['type'] != 'nwr' }

          @log << "#{corporation.name} adds an extra #{train.name} train to the depot"
          train.reserved = false
          @depot.unshift_train(train)
        end

        def init_train_handler
          depot = super

          # Grab the reserve trains that SC can add
          trains = %w[3 4 5 6]

          @sc_reserve_trains = []
          trains.each do |train_name|
            train = depot.upcoming.reverse.find { |t| t.name == train_name }
            @sc_reserve_trains << train
            depot.remove_train(train)
            train.reserved = true
          end

          # Due to SC adding an extra train this isn't quite a phase change, so the event needs to be tied to a train.
          nwr_train = trains[rand % trains.size]
          @log << "NWR Rebellion occurs on purchase of the first #{nwr_train} train"
          train = depot.upcoming.find { |t| t.name == nwr_train }
          train.events << { 'type' => 'nwr' }

          depot
        end

        def setup
          cp = @companies.find { |company| company.name == 'Canadian Pacific' }
          cp.add_ability(Ability::Close.new(
            type: :close,
            when: 'bought_train',
            corporation: abilities(cp, :shares).shares.first.corporation.name,
          ))
        end

        def init_company_abilities
          @companies.each do |company|
            next unless (ability = abilities(company, :exchange))

            next unless ability.from.include?(:par)

            exchange_corporations(ability).first.par_via_exchange = company
            @sc_company = company
          end
          super
        end

        def init_corporations(stock_market)
          min_price = stock_market.par_prices.map(&:price).min

          corporations = self.class::CORPORATIONS.map do |corporation|
            corporation[:needs_token_to_par] = true if corporation[:sym] == 'CN'
            Corporation.new(
              min_price: min_price,
              capitalization: self.class::CAPITALIZATION,
              **corporation,
            )
          end

          # CN's tokens use a neutral logo, but as layed become owned by cn but don't block other players
          cn_corp = corporations.find { |x| x.name == 'CN' }
          logo = '/logos/1882/neutral.svg'
          corporations.each do |x|
            unless CORPORATIONS_WITHOUT_NEUTRAL.include?(x.name)
              x.tokens << Token.new(cn_corp, price: 0, logo: logo, simple_logo: logo, type: :neutral)
            end
          end
          corporations
        end

        def event_nwr!
          @log << '-- Event: North West Rebellion! --'
          name = 'NWR'
          @hexes.each do |hex|
            next unless hex.tile.icons.any? { |icon| icon.name == name }

            next unless hex.tile.color == :yellow
            next unless hex.tile != hex.original_tile

            @log << "Rebellion destroys tile #{hex.name}"
            old_tile = hex.tile
            hex.lay_downgrade(hex.original_tile)
            tiles << old_tile
          end

          # Some companies might no longer have valid routes
          @graph.clear_graph_for_all
        end

        def revenue_for(route, stops)
          revenue = super

          # East offboards I1, B2
          east = stops.find { |stop| %w[I1 B2].include?(stop.hex.name) }
          # Hudson B12
          west = stops.find { |stop| stop.hex.name == 'B12' }
          revenue += 100 if east && west

          revenue
        end

        def action_processed(action)
          if action.is_a?(Action::LayTile) && action.tile.name == 'R2'
            action.tile.location_name = 'Regina'
            return
          end

          return unless @sc_company
          return if !@sc_company.closed? && !@sc_company&.owner&.corporation?

          @log << 'Saskatchewan Central can no longer be converted to a public corporation'
          @corporations.reject! { |c| c.id == 'SC' }
          @sc_company = nil
        end

        def count_available_tokens(corporation)
          corporation.tokens.sum { |t| t.used || t.corporation != corporation ? 0 : 1 }
        end

        def token_string(corporation)
          # All neutral tokens belong to CN, so it will count them normally.
          "#{count_available_tokens(corporation)}"\
            "/#{corporation.tokens.sum { |t| t.corporation != corporation ? 0 : 1 }}"\
            "#{', N' if corporation.tokens.any? { |t| t.corporation != corporation }}"
        end

        def token_note
          'N = neutral token'
        end

        def token_ability_from_owner_usable?(_ability, _corporation)
          true
        end

        def fishing_exit
          @fishing_exit ||= hex_by_id('B6')
        end
      end
    end
  end
end
