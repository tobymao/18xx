# frozen_string_literal: true

require_relative '../config/game/g_18_mag.rb'
require_relative 'base'

module Engine
  module Game
    class G18Mag < Base
      attr_reader :tile_groups, :unused_tiles, :sik, :skev, :ldsteg, :mavag, :raba, :snw, :gc

      load_from_json(Config::Game::G18Mag::JSON)

      GAME_LOCATION = 'Hungary'
      GAME_RULES_URL = 'https://www.lonny.at/app/download/10079056984/18Mag_rules_KS.pdf?t=1609359467'
      GAME_DESIGNER = 'Leonhard "Lonny" Orgler'
      GAME_PUBLISHER = :lonny_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Mag'

      # DEV_STAGE = :alpha

      EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
      EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
      HOME_TOKEN_TIMING = :float
      SELL_AFTER = :any_time
      SELL_BUY_ORDER = :sell_buy
      MARKET_SHARE_LIMIT = 100

      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded, cost: 10 }].freeze

      START_PRICES = [60, 60, 65, 65, 70, 70, 75, 75, 80, 80].freeze
      MINOR_STARTING_CASH = 50

      TRAIN_PRICE_MIN = 1

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'first_three' => ['First 3', 'Advance phase'],
        'first_four' => ['First 4', 'Advance phase'],
        'first_six' => ['First 6', 'Advance phase'],
      ).freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'end_game_triggered' => ['End Game', 'After next SR, final three ORs are played'],
      ).freeze

      def setup
        @sik = @corporations.find { |c| c.name == 'SIK' }
        @skev = @corporations.find { |c| c.name == 'SKEV' }
        @ldsteg = @corporations.find { |c| c.name == 'LdStEG' }
        @mavag = @corporations.find { |c| c.name == 'MAVAG' }
        @raba = @corporations.find { |c| c.name == 'RABA' }
        @snw = @corporations.find { |c| c.name == 'SNW' }
        @gc = @corporations.find { |c| c.name == 'G&C' }

        @tile_groups = init_tile_groups
        update_opposites
        @unused_tiles = []

        # start with first minor tokens placed (as opposed to just reserved)
        @mine = @minors.find { |m| m.name == 'mine' }
        @minors.delete(@mine)
        @minors.each do |minor|
          hex = hex_by_id(minor.coordinates)
          hex.tile.cities[minor.city || 0].place_token(minor, minor.next_token)
        end

        # Place all mine tokens and mark them as non-blocking
        # route restrictions will be handled elsewhere
        @mine.coordinates.each do |coord|
          hex = hex_by_id(coord)
          hex.tile.cities[0].place_token(@mine, @mine.next_token)
        end
        @mine.tokens.each { |t| t.type = :neutral }

        # IPO and float all corporations with semi-randomly chosen prices
        # They will start off in receivership with all shares in market
        rand_prices = START_PRICES.sort_by { rand }
        @corporations.each do |corp|
          share_price = @stock_market.par_prices.find { |p| p.price == rand_prices[0] }
          rand_prices.shift
          @stock_market.set_par(corp, share_price)
          corp.ipoed = true

          corp.ipo_shares.each do |share|
            @share_pool.transfer_shares(
              share.to_bundle,
              share_pool,
              spender: share_pool,
              receiver: @bank,
              price: 0
            )
          end
          corp.owner = @share_pool
        end

        @trains_left = %w[3 4 6]
      end

      def init_tile_groups
        [
          %w[7],
          %w[8 9],
          %w[3],
          %w[58 4],
          %w[5 57],
          %w[6],
          %w[L32],
          %w[L33],
          %w[16 19],
          %w[20],
          %w[23 24],
          %w[25],
          %w[26 27],
          %w[28 29],
          %w[30 31],
          %w[204],
          %w[88 87],
          %w[619],
          %w[14 15],
          %w[209],
          %w[236],
          %w[237],
          %w[238],
          %w[8858],
          %w[8859],
          %w[8860],
          %w[8863],
          %w[8864],
          %w[8865],
          %w[39 40],
          %w[41 42],
          %w[43 70],
          %w[44 47],
          %w[45 46],
          %w[G17],
          %w[611],
          %w[L17],
          %w[L34],
          %w[L35],
          %w[L38],
          %w[455],
          %w[X9],
          %w[L36],
          %w[L37],
        ]
      end

      # set opposite correctly for two-sided tiles
      def update_opposites
        by_name = @tiles.group_by(&:name)
        @tile_groups.each do |grp|
          next unless grp.size == 2

          name_a, name_b = grp
          num = by_name[name_a].size
          raise GameError, 'Sides of double-sided tiles need to have same number' if num != by_name[name_b].size

          num.times.each do |idx|
            tile_a = tile_by_id("#{name_a}-#{idx}")
            tile_b = tile_by_id("#{name_b}-#{idx}")

            tile_a.opposite = tile_b
            tile_b.opposite = tile_a
          end
        end
      end

      def float_minor(minor)
        minor.float!
        train = @depot.upcoming[0]
        buy_train(minor, train, :free)
        @bank.spend(MINOR_STARTING_CASH, minor)
      end

      def init_starting_cash(players, bank)
        cash = self.class::STARTING_CASH
        cash = cash[players.size] if cash.is_a?(Hash)

        players.each do |player|
          bank.spend(cash, player, check_positive: false)
        end
      end

      def new_auction_round
        Round::Draft.new(self, [Step::G18Mag::SimpleDraft],
                         rotating_order: (players.size <= 4),
                         snake_order: (players.size > 4))
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Exchange,
          Step::HomeToken,
          Step::G18Mag::Track,
          Step::G18Mag::Token,
          Step::G18Mag::DiscardTrain,
          Step::G18Mag::Route,
          Step::G18Mag::Dividend,
          Step::G18Mag::BuyTrain,
        ], round_num: round_num)
      end

      def next_round!
        @round =
          case @round
          when Round::Stock
            @operating_rounds = @phase.operating_rounds
            reorder_players
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
            @operating_rounds = @phase.operating_rounds
            init_round_finished
            reorder_players
            new_operating_round
          end
      end

      def upgrades_to?(from, to, special = false)
        # correct color progression?
        return false unless Engine::Tile::COLORS.index(to.color) == (Engine::Tile::COLORS.index(from.color) + 1)

        # honors pre-existing track?
        return false unless from.paths_are_subset_of?(to.paths)

        # If special ability then remaining checks is not applicable
        return true if special

        # correct label?
        return false if from.label != to.label && !(from.label.to_s == 'K' && to.color == 'yellow')

        # honors existing town/city counts?
        # - allow labelled cities to upgrade regardless of count; they're probably
        #   fine (e.g., 18Chesapeake's OO cities merge to one city in brown)
        # - TODO: account for games that allow double dits to upgrade to one town
        return false if from.towns.size != to.towns.size
        return false if (!from.label || from.label.to_s == 'K') && from.cities.size != to.cities.size

        # handle case where we are laying a yellow OO tile and want to exclude single-city tiles
        return false if (from.color == :white) && from.label.to_s == 'OO' && from.cities.size != to.cities.size

        true
      end

      # price is nil, :free, or a positive int
      def buy_train(operator, train, price = nil)
        cost = price || train.price
        if price != :free && train.owner == @depot
          corp = %w[2 4].include?(train.name) ? @ldsteg : @mavag
          operator.spend(cost / 2, @bank)
          operator.spend(cost / 2, corp)
          @log << "#{corp.name} earns #{format_currency(cost / 2)}"
        elsif price != :free
          operator.spend(cost, train.owner)
        end
        remove_train(train)
        train.owner = operator
        operator.trains << train
        operator.rusted_self = false
        @crowded_corps = nil
      end

      def place_home_token(_corp); end

      def event_first_three!
        @trains_left.delete('3')
        @phase.current[:on] = nil
        @phase.upcoming[:on] = @trains_left if @phase.upcoming
        @phase.next_on = @trains_left
      end

      def event_first_four!
        @trains_left.delete('4')
        @phase.current[:on] = nil
        @phase.upcoming[:on] = @trains_left if @phase.upcoming
        @phase.next_on = @trains_left
      end

      def event_first_six!
        @trains_left.delete('6')
        @phase.current[:on] = nil
        @phase.upcoming[:on] = @trains_left if @phase.upcoming
        @phase.next_on = @trains_left
      end

      def info_on_trains(phase)
        Array(phase[:on]).join(', ')
      end
    end
  end
end
