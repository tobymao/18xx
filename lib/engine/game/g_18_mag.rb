# frozen_string_literal: true

require_relative '../config/game/g_18_mag.rb'
require_relative 'base'

module Engine
  module Game
    class G18Mag < Base
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

      START_PRICES = [60, 60, 65, 65, 70, 70, 75, 75, 80, 80].freeze
      MINOR_STARTING_CASH = 50

      def setup
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
        prices = START_PRICES.dup
        rand_prices = @corporations.size.times.map do |_|
          prices.rotate!(rand % prices.size)
          prices.pop
        end
        @corporations.each do |corp|
          share_price = @stock_market.par_prices.find { |p| p.price == rand_prices[0] }
          rand_prices.shift
          @stock_market.set_par(corp, share_price)
          corp.ipoed = true

          corp.ipo_shares.each do |share|
            bundle = ShareBundle.new([share])
            @share_pool.transfer_shares(
              bundle,
              share_pool,
              spender: share_pool,
              receiver: @bank,
              price: 0
            )
          end
          corp.owner = @share_pool
        end
      end

      def float_minor(minor)
        train = @depot.upcoming[0]
        minor.buy_train(train, :free)
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
          Step::DiscardTrain,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::BuyTrain,
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
    end
  end
end
