# frozen_string_literal: true

require_relative '../config/game/g_18_carolinas'
require_relative 'base'

module Engine
  module Game
    class G18Carolinas < Base
      load_from_json(Config::Game::G18Carolinas::JSON)

      def init_companies(players)
        super.take(players.size).each do |company|
        end
      end

      def setup
        counter = 0
        @companies.each do |company|
          price = company.value
          company.owner = @players[counter]
          @players[counter].companies << company
          @players[counter].spend(price, @bank)
          @log << "#{@players[counter].name} buys #{company.name} for #{format_currency(price)}"
          counter += 1
          @players.rotate!
          puts 'rotated'
        end

        @corporations[0, 1, 2, 3].sort_by! { @game.rand }
        @corporations[4, 5, 6, 7].sort_by! { @game.rand }

        car_pars = 3

        @corporations.each do |corporation|
          @stock_market.set_par(corporation, @stock_market.par_prices[car_pars])

          @log << "#{corporation.name} is set to par #{@stock_market.par_prices[car_pars].price}"
          corporation.tokens.pop(1) if car_pars == 1 || car_pars == 2
          corporation.tokens.pop(2) if car_pars == 0

          car_pars -= 1
          car_pars = 3 if car_pars == -1
        end

        @corporations.sort_by! { |corporation| -corporation.par_price.price }
        puts 'a'
        #        process_action(Engine::Action::BuyShare.new(@players[0], @corporations[0].shares.first)) if players.size >= 5
        puts 'b'
        #     @players.rotate! if players.size == 6

        #    process_action(Engine::Action::BuyShare.new(@players[0], @corporations[4].shares.first)) if players.size == 6
        #       rotate_players(@players[5]) if players.size == 6
        #        @players.rotate!

        next_round!
      end

      def finished?
        @end_game || @companies.empty?
      end
    end
  end
end
