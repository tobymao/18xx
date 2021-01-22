# frozen_string_literal: true

require_relative '../config/game/g_18_cz'
require_relative 'base'
require_relative 'stubs_are_restricted'

module Engine
  module Game
    class G18CZ < Base
      register_colors(brightGreen: '#c2ce33',
                      beige: '#e5d19e',
                      lightBlue: '#1EA2D6',
                      mintGreen: '#B1CEC7',
                      yellow: '#ffe600',
                      lightRed: '#F3B1B3')

      load_from_json(Config::Game::G18CZ::JSON)

      GAME_LOCATION = 'Czech Republic'
      GAME_RULES_URL = 'https://www.lonny.at/app/download/9940504884/rules_English.pdf'
      GAME_DESIGNER = 'Leonhard Orgler'
      GAME_PUBLISHER = :lonny_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18CZ'

      SELL_BUY_ORDER = :sell_buy
      SELL_MOVEMENT = :left_block

      MUST_BUY_TRAIN = :always

      HOME_TOKEN_TIMING = :operate

      STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
        par: :red,
        par_2: :green,
        par_overlap: :blue
      ).freeze

      PAR_RANGE = {
        small: [50, 55, 60, 65, 70],
        medium: [60, 70, 80, 90, 100],
        large: [90, 100, 110, 120],
      }.freeze

      MARKET_TEXT = {
        par: 'Small Corporation Par',
        par_overlap: 'Medium Corporation Par',
        par_2: 'Large Corporation Par',
      }.freeze

      COMPANY_VALUES = [40, 45, 50, 55, 60, 65, 70, 75, 80, 90, 100, 110, 120].freeze

      OR_SETS = [1, 1, 1, 1, 2, 2, 2, 3].freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'medium_corps_available' => ['Medium Corps Available',
                                     '5-share corps ATE, BN, BTE, KFN, NWB are available to start'],
        'large_corps_available' => ['Large Corps Available',
                                    '10-share corps By, kk, Sx, Pr, Ug are available to start']
      ).freeze

      TRAINS_FOR_CORPORATIONS = {
        '2a' => :small,
        '2b' => :small,
        '3c' => :small,
        '3d' => :small,
        '4e' => :small,
        '4f' => :small,
        '5g' => :small,
        '5h' => :small,
        '5i' => :small,
        '5j' => :small,
        '2+2b' => :medium,
        '2+2c' => :medium,
        '3+3d' => :medium,
        '3+3e' => :medium,
        '4+4f' => :medium,
        '4+4g' => :medium,
        '5+5h' => :medium,
        '5+5i' => :medium,
        '5+5j' => :medium,
        '3Ed' => :large,
        '3Ee' => :large,
        '4EF' => :large,
        '4Eg' => :large,
        '5E' => :large,
        '6E' => :large,
        '8E' => :large,
      }.freeze

      include StubsAreRestricted

      def setup
        @or = 0
        # We can modify COMPANY_VALUES and OR_SETS if we want to support the shorter variant
        @last_or = COMPANY_VALUES.size
        @recently_floated = []

        # Only small companies are available until later phases
        @corporations, @future_corporations = @corporations.partition { |corporation| corporation.type == :small }

        block_lay_for_purple_tiles
      end

      def init_round
        Round::Draft.new(self,
                         [Step::G18CZ::Draft],
                         snake_order: true)
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::G18CZ::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::G18CZ::HomeTrack,
          Step::SpecialTrack,
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::G18CZ::Dividend,
          Step::DiscardTrain,
          Step::G18CZ::BuyTrain,
          [Step::BuyCompany, { blocks: true }],
        ], round_num: round_num)
      end

      def init_stock_market
        StockMarket.new(self.class::MARKET, [], zigzag: true)
      end

      def new_operating_round
        @or += 1
        @companies.each do |company|
          company.value = COMPANY_VALUES[@or - 1]
          company.min_price = 1
          company.max_price = company.value
        end

        super
      end

      def or_round_finished
        @recently_floated.clear
      end

      def end_now?(_after)
        @or == @last_or
      end

      def timeline
        @timeline = [
          'At the end of each set of ORs the next available train will be exported
           (removed, triggering phase change as if purchased)',
        ]
        @timeline.append("Game ends after OR #{@last_or}")
        @timeline.append("Current value of each private company is #{COMPANY_VALUES[[0, @or - 1].max]}")
        @timeline.append("Next set of Operating Rounds will have #{OR_SETS[@turn - 1]} ORs")
      end

      def par_prices(corp)
        par_nodes = stock_market.par_prices
        available_par_prices = PAR_RANGE[corp.type]
        par_nodes.select { |par_node| available_par_prices.include?(par_node.price) }
      end

      def event_medium_corps_available!
        medium_corps, @future_corporations = @future_corporations.partition do |corporation|
          corporation.type == :medium
        end
        @corporations.concat(medium_corps)
        @log << '-- Medium corporations now available --'
      end

      def event_large_corps_available!
        @corporations.concat(@future_corporations)
        @future_corporations.clear
        @log << '-- Large corporations now available --'
      end

      def float_corporation(corporation)
        @recently_floated << corporation
        super
      end

      def or_set_finished
        depot.export!
      end

      def next_round!
        @round =
          case @round
          when Round::Stock
            @operating_rounds = OR_SETS[@turn - 1]
            reorder_players(:most_cash)
            new_operating_round
          when Round::Operating
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
            reorder_players(:least_cash)
            new_stock_round
          end
      end

      def tile_lays(entity)
        return super unless @recently_floated.include?(entity)

        [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
      end

      def corporation_size(entity)
        # For display purposes is a corporation small, medium or large
        entity.type
      end

      def status_str(corp)
        corp.type.capitalize
      end

      def block_lay_for_purple_tiles
        @tiles.each do |tile|
          tile.blocks_lay = true if tile.name.end_with?('p')
        end
      end

      def must_buy_train?(entity)
        !entity.rusted_self &&
        !depot.depot_trains.empty? &&
        (entity.trains.empty? ||
          (entity.type == :medium && entity.trains.none? { |item| train_of_size?(item, :medium) }) ||
          (entity.type == :large && entity.trains.none? { |item| train_of_size?(item, :large) }))
      end

      def train_of_size?(item, size)
        name = if item.is_a?(Hash)
                 item[:name]
               else
                 item.name
               end

        TRAINS_FOR_CORPORATIONS[name] == size
      end

      def home_token_locations(corporation)
        coordinates = COORDINATES_FOR_LARGE_CORPORATION[corporation.id]
        hexes.select { |hex| coordinates.include?(hex.coordinates) }
      end

      def place_home_token(corporation)
        return unless corporation.next_token # 1882
        # If a corp has laid it's first token assume it's their home token
        return if corporation.tokens.first&.used

        if corporation.coordinates.is_a?(Array)
          @log << "#{corporation.name} (#{corporation.owner.name}) must choose tile for home location"

          hexes = corporation.coordinates.map { |item| hex_by_id(item) }

          @round.pending_tracks << {
            entity: corporation,
            hexes: hexes,
          }

          @round.clear_cache!
        else
          hex = hex_by_id(corporation.coordinates)

          tile = hex&.tile

          cities = tile.cities
          city = cities.find { |c| c.reserved_by?(corporation) } || cities.first
          token = corporation.find_token_by_type
          return unless city.tokenable?(corporation, tokens: token)

          @log << "#{corporation.name} places a token on #{hex.name}"
          city.place_token(corporation, token)
        end
      end

      def upgrades_to?(from, to, special = false)
        return true if from.color == :white && to.color == :red

        super
      end

      def potential_tiles(corporation)
        tiles.select { |tile| tile.label&.to_s == corporation.name }
      end

      def rust_trains!(train, entity)
        rusted_trains = []
        owners = Hash.new(0)

        trains.each do |t|
          next if t.rusted

          # entity is nil when a train is exported. Then all trains are rusting
          train_symbol_to_compare = entity.nil? ? train.sym : train.name
          should_rust = t.rusts_on == train_symbol_to_compare
          next unless should_rust
          next unless rust?(t)

          rusted_trains << t.name
          owners[t.owner.name] += 1
          entity.rusted_self = true if entity && entity == t.owner
          rust(t)
        end

        @log << "-- Event: #{rusted_trains.uniq.join(', ')} trains rust " \
          "( #{owners.map { |c, t| "#{c} x#{t}" }.join(', ')}) --" if rusted_trains.any?
      end
    end
  end
end
