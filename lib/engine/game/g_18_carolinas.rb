# frozen_string_literal: true

require_relative '../config/game/g_18_carolinas'
require_relative 'base'

module Engine
  module Game
    class G18Carolinas < Base
      load_from_json(Config::Game::G18Carolinas::JSON)

      def init_round
        new_stock_round
      end

      def init_companies(players)
        super.take(players.size)
      end

      def setup
        @companies.each_with_index do |company, index|
          price = company.value
          player = @players[index]
          company.owner = player
          player.companies << company
          player.spend(price, @bank)
          @log << "#{player.name} buys #{company.name} for #{format_currency(price)}"
        end

        @corporations[0..3].sort_by! { @game.rand }
        @corporations[4..7].sort_by! { @game.rand }

        @corporations.each_with_index do |corporation, index|
          index -= 4 if index > 3
          @stock_market.set_par(corporation, @stock_market.par_prices[3 - index])

          @log << "#{corporation.name} is set to par #{@stock_market.par_prices[3 - index].price}"

          case index
          when 1, 2
            corporation.tokens.pop(1)
          when 3
            corporation.tokens.pop(2)
          end
        end

        if @players.size >= 5
          @players[4].spend(180, @bank)
          @log << "#{@players[4].name} buys #{@corporations[0].name} for $180"
          #          buy_shares(@players[4], @corporations[0].shares.first)
        end
        if @players.size == 6
          @players[5].spend(180, @bank)
          #          buy_shares(@players[5], @corporations[4].shares.first)
          @log << "#{@players[5].name} buys #{@corporations[4].name} for $180"
        end

        @corporations.sort_by! { |corporation| -corporation.par_price.price }
      end
    end
  end
end
