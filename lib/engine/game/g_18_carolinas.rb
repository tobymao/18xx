# frozen_string_literal: true

require_relative '../config/game/g_18_carolinas'
require_relative 'base'

module Engine
  module Game
    class G18Carolinas < Base
      load_from_json(Config::Game::G18Carolinas::JSON)

      def init_companies(players)
        super.take(players.size)
      end

      def setup
        @companies.each_with_index do |company, index|
          price = company.value
          player = @players[index]
          company.owner = player
          @players[index].companies << company
          @players[index].spend(price, @bank)
          @log << "#{player.name} buys #{company.name} for #{format_currency(price)}"
        end

        @corporations[0..3].sort_by! { @game.rand }
        @corporations[4..7].sort_by! { @game.rand }

        @corporations.each_with_index do |corporation, index|
          index -= 4 if index > 3

          @stock_market.set_par(corporation, @stock_market.par_prices[index - 3])

          @log << "#{corporation.name} is set to par #{@stock_market.par_prices[index - 3].price}"
          corporation.tokens.pop(1) if index - 3 == 1 || index - 3 == 2
          corporation.tokens.pop(2) if index - 3 == 0
        end

        @corporations.sort_by! { |corporation| -corporation.par_price.price }

        next_round!
      end
    end
  end
end
