# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative 'scenarios'

module Engine
  module Game
    module G18GB
      class Game < Game::Base
        include_meta(G18GB::Meta)
        include Entities
        include Map
        include Scenarios

        GAME_END_CHECK = { final_train: :current_or, stock_market: :current_or }.freeze

        BANKRUPTCY_ALLOWED = false

        BANK_CASH = 99_999

        CURRENCY_FORMAT_STR = '£%d'

        PRESIDENT_SALES_TO_MARKET = true

        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true
        ONLY_HIGHEST_BID_COMMITTED = true

        CAPITALIZATION = :full

        SELL_BUY_ORDER = :sell_buy

        SOLD_OUT_INCREASE = false

        NEXT_SR_PLAYER_ORDER = :first_to_pass

        MUST_SELL_IN_BLOCKS = true

        SELL_AFTER = :any_time

        TRACK_RESTRICTION = :restrictive

        HOME_TOKEN_TIMING = :float

        DISCARDED_TRAINS = :remove

        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: true }].freeze

        IMPASSABLE_HEX_COLORS = %i[gray red].freeze

        MARKET_SHARE_LIMIT = 100

        SHOW_SHARE_PERCENT_OWNERSHIP = true

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          unlimited: 'May buy shares from IPO in excess of 60%',
        )

        MARKET = [
          %w[50o 55o 60o 65o 70p 75p 80p 90p 100p 115 130 160 180 200 220 240 265 290 320 350e 380e],
        ].freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          unlimited: :yellow,
        )

        PHASES = [
          {
            name: '2+1',
            train_limit: { '5-share': 3, '10-share': 4 },
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3+1',
            on: '3+1',
            train_limit: { '5-share': 3, '10-share': 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4+2',
            on: '4+2',
            train_limit: { '5-share': 2, '10-share': 3 },
            tiles: %i[yellow green blue],
            operating_rounds: 2,
          },
          {
            name: '5+2',
            on: '5+2',
            train_limit: { '5-share': 2, '10-share': 3 },
            tiles: %i[yellow green blue brown],
            operating_rounds: 2,
          },
          {
            name: '4X',
            on: '4X',
            train_limit: 2,
            tiles: %i[yellow green blue brown],
            operating_rounds: 2,
          },
          {
            name: '5X',
            on: '5X',
            train_limit: 2,
            tiles: %i[yellow green blue brown],
            operating_rounds: 2,
          },
          {
            name: '6X',
            on: '6X',
            train_limit: 2,
            tiles: %i[yellow green blue brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2+1',
            distance: [
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => %w[city offboard town],
                'pay' => 2,
                'visit' => 2,
              },
            ],
            price: 80,
            rusts_on: '4+2',
          },
          {
            name: '3+1',
            distance: [
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => %w[city offboard town],
                'pay' => 3,
                'visit' => 3,
              },
            ],
            price: 200,
            rusts_on: '4X',
          },
          {
            name: '4+2',
            distance: [
              {
                'nodes' => ['town'],
                'pay' => 2,
                'visit' => 2,
              },
              {
                'nodes' => %w[city offboard town],
                'pay' => 4,
                'visit' => 4,
              },
            ],
            price: 300,
            rusts_on: '6X',
          },
          {
            name: '5+2',
            distance: [
              {
                'nodes' => ['town'],
                'pay' => 2,
                'visit' => 2,
              },
              {
                'nodes' => %w[city offboard town],
                'pay' => 5,
                'visit' => 5,
              },
            ],
            price: 500,
          },
          {
            name: '4X',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 4,
                'visit' => 4,
              },
            ],
            price: 550,
          },
          {
            name: '5X',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 5,
                'visit' => 5,
              },
            ],
            price: 650,
          },
          {
            name: '6X',
            distance: [
              {
                'nodes' => %w[city offboard],
                'pay' => 6,
                'visit' => 6,
              },
            ],
            price: 700,
          },
        ].freeze

        def init_scenario(optional_rules)
          num_players = @players.size
          two_east_west = optional_rules.include?(:two_player_ew)
          four_alternate = optional_rules.include?(:four_player_alt)

          case num_players
          when 2
            SCENARIOS[two_east_west ? '2EW' : '2NS']
          when 3
            SCENARIOS['3']
          when 4
            SCENARIOS[four_alternate ? '4Alt' : '4Std']
          when 5
            SCENARIOS['5']
          else
            SCENARIOS['6']
          end
        end

        def init_optional_rules(optional_rules)
          optional_rules = super(optional_rules)
          @scenario = init_scenario(optional_rules)
          optional_rules
        end

        def optional_hexes
          case @scenario['map']
          when '2NS'
            self.class::HEXES_2P_NW
          when '2EW'
            self.class::HEXES_2P_EW
          else
            self.class::HEXES
          end
        end

        def num_trains(train)
          @scenario['train_counts'][train[:name]]
        end

        def game_cert_limit
          @scenario['cert-limit']
        end

        def game_companies
          scenario_comps = @scenario['companies']
          self.class::COMPANIES.select { |comp| scenario_comps.include?(comp['sym']) }
        end

        def game_corporations
          scenario_corps = @scenario['corporations'] + @scenario['corporation-extra'].sort_by { rand }.take(1)
          self.class::CORPORATIONS.select { |corp| scenario_corps.include?(corp['sym']) }
        end

        def game_tiles
          if @scenario['gray-tiles']
            self.class::TILES.merge(self.class::GRAY_TILES)
          else
            self.class::TILES
          end
        end

        def init_starting_cash(players, bank)
          cash = @scenario['starting-cash']
          players.each do |player|
            bank.spend(cash, player)
          end
        end

        def setup
          tiers = {}
          delayed = 0
          @corporations.sort_by { rand }.each do |corp|
            if (corp.id != 'LNWR') && (delayed < @scenario['tier2-corps'])
              tiers[corp.id] = 2
              delayed += 1
            else
              tiers[corp.id] = 1
            end
          end

          @log << "Corporations available SR1: #{tiers.select { |_, t| t == 1 }.map { |c, _| c }.sort.join(', ')}"
          @log << "Corporations available SR2: #{tiers.select { |_, t| t == 2 }.map { |c, _| c }.sort.join(', ')}"
          @tiers = tiers
        end

        def sorted_corporations
          ipoed, others = @corporations.reject { |corp| @tiers[corp.id] > @round_counter }.partition(&:ipoed)
          ipoed.sort + others
        end

        def required_bids_to_pass
          @scenario['required_bids']
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G18GB::Step::WaterfallAuction,
          ])
        end

        def init_round_finished
          @players.sort_by! { |p| [p.cash, -@companies.count { |c| c.owner == p }] }
        end
        
        def check_new_layer
        end

        def par_prices(corp)
          stock_market.par_prices
        end

        def bundles_for_corporation(share_holder, corporation, shares: nil)
          return [] unless corporation.ipoed

          shares = (shares || share_holder.shares_of(corporation)).sort_by(&:price)

          shares.flat_map.with_index do |share, index|
            bundle = shares.take(index + 1)
            percent = bundle.sum(&:percent)
            bundles = [Engine::ShareBundle.new(bundle, percent)]
            if share.president
              normal_percent = corporation.share_percent
              difference = corporation.presidents_percent - normal_percent
              num_partial_bundles = difference / normal_percent
              (1..num_partial_bundles).each do |n|
                bundles.insert(0, Engine::ShareBundle.new(bundle, percent - (normal_percent * n)))
              end
            end
            bundles.each { |b| b.share_price = (b.price_per_share / 2).to_i if corporation.trains.empty? }
            bundles
          end
        end

        def player_value(player)
          player.cash +
            player.shares.select { |s| s.corporation.ipoed & s.corporation.trains.any? }.sum(&:price) +
            player.shares.select { |s| s.corporation.ipoed & s.corporation.trains.none? }
            .sum { |s| (s.price / 2).to_i } + player.companies.sum(&:value)
        end

        def liquidity(player)
          player.cash +
            player.shares.select { |s| s.corporation.ipoed & s.corporation.trains.any? }.sum(&:price) +
            player.shares.select { |s| s.corporation.ipoed & s.corporation.trains.none? }
            .sum { |s| (s.price / 2).to_i }
        end

        def place_home_token(corporation)
          return if corporation.tokens.first&.used

          hex = hex_by_id(corporation.coordinates)

          tile = hex&.tile
          if !tile || (tile.reserved_by?(corporation) && tile.paths.any?)

            # If the tile has no paths at the present time, clear up the ambiguity when the tile is laid
            # Otherwise, for yellow tiles the corporation is placed disconnected and for other tiles it
            # chooses now
            if tile.color == :yellow
              cities = tile.cities
              city = cities[1]
              token = corporation.find_token_by_type
              return unless city.tokenable?(corporation, tokens: token)

              @log << "#{corporation.name} places a token on #{hex.name}"
              city.place_token(corporation, token)
            else
              @log << "#{corporation.name} must choose city for home token"
              @round.pending_tokens << {
                entity: corporation,
                hexes: [hex],
                token: corporation.find_token_by_type,
              }
            end

            return
          end

          cities = tile.cities
          city = cities.find { |c| c.reserved_by?(corporation) } || cities.first
          token = corporation.find_token_by_type
          return unless city.tokenable?(corporation, tokens: token)
          @log << "#{corporation.name} places a token on #{hex.name}"
          city.place_token(corporation, token)
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::Exchange,
            Engine::Step::HomeToken,
            Engine::Step::BuySellParSharesCompanies,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::HomeToken,
            G18GB::Step::TrackAndToken,
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
