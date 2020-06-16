# frozen_string_literal: true

require_relative '../config/game/g_1836_jr30'
require_relative 'base'

module Engine
  module Game
    class G1836Jr30 < Base
      load_from_json(Config::Game::G1836Jr30::JSON)

      DEV_STAGE = :alpha
      GAME_LOCATION = 'Netherlands'
      GAME_RULES_URL = 'https://boardgamegeek.com/filepage/114572/1836jr-30-rules'
      GAME_DESIGNER = 'David G. D. Hecht'

      def action_processed(action)
        case action
        when Action::BuyTrain
          if !chemins.closed? && action.entity.name == 'Nord'
            chemins.close!
            @log << "#{chemins.name} closes"
          end
        end
      end

      def chemins
        @chemins ||= @companies.find { |company| company.name == 'Chemin de Fer de Lille à Valenciennes' }
      end

      def stock_round
        Round::Stock.new(@players, game: self, sell_buy_order: :sell_buy_sell)
      end
    end
  end
end
