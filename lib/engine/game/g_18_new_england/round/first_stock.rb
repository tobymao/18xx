# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18NewEngland
      module Round
        class FirstStock < Engine::Round::Stock
          def initialize(game, steps, **opts)
            @snake_order = opts[:snake_order] || false
            @snaking_up = true

            super
          end

          def next_entity_index!
            return super unless @snake_order

            if (@snaking_up && @entity_index == (@entities.size - 1)) ||
                (!@snaking_up && @entity_index.zero?)
              @snaking_up = !@snaking_up
            else
              plus_or_minus = @snaking_up ? :+ : :-
              @game.next_turn!
              @entity_index = @entity_index.send(plus_or_minus, 1) % @entities.size
            end
          end

          # only exit first stock round on consecutive passes
          def finished?
            @game.finished || @pass_order.size == @game.players.size
          end
        end
      end
    end
  end
end
