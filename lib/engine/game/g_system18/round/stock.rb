# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module GSystem18
      module Round
        class Stock < Engine::Round::Stock
          def finish_round
            super
            if @game.respond_to?("map_#{@game.cmap_name}_stock_finish_round")
              return @game.send("map_#{@game.cmap_name}_stock_finish_round")
            end
            return unless @game.corporations.none?(&:floated)

            @log << '-- Round ended with no floated corporations. Ending game. --'
            @game.end_game!(:dnf)
          end
        end
      end
    end
  end
end
