# frozen_string_literal: true

require_relative '../config/game/g_18_te'
require_relative 'base'
require_relative 'terminus_check'

module Engine
  module Game
    class G18TE < Base
      load_from_json(Config::Game::G18TE::JSON)

      GAME_LOCATION = 'Tecklenburg, Germany'
      GAME_DESIGNER = 'Herbert Harangel'

      def init_round
        new_stock_round
      end

      def setup
        @corporations.each do |corporation|
          corporation.abilities(:assign_hexes) do |ability|
            ability.description = "Historical objective: #{get_location_name(ability.hexes.first)}"
          end
        end
      end

      def get_location_name(hex_name)
        @hexes.find { |h| h.name == hex_name }.location_name
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::HomeToken,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::BuyTrain,
        ], round_num: round_num)
      end

      SELL_BUY_ORDER = :sell_buy
    end
  end
end
