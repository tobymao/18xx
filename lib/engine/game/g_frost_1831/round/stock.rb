# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module GFrost1831
      module Round
        class Stock < Engine::Round::Stock
          def finished?
            !@game.pending_influence_choice && super
          end

          def next_entity!
            super unless @prices_moved
          end

          def finish_round
            @prices_moved = true
            super
          end

          def corporations_to_move_price
            super.reject { |c| c.type == :faction }
          end
        end
      end
    end
  end
end
