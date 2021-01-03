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

      def setup
        # start with first minor tokens placed (as opposed to just reserved)
        @mine = @minors.find { |m| m.name == 'mine' }
        @minors.reject! { |m| m.name == 'mine' }.each do |minor|
          train = @depot.upcoming[0]
          minor.buy_train(train, :free)
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
      end

      def init_starting_cash(players, bank)
        cash = self.class::STARTING_CASH
        cash = cash[players.size] if cash.is_a?(Hash)

        players.each do |player|
          bank.spend(cash, player, check_positive: false)
        end
      end
    end
  end
end
