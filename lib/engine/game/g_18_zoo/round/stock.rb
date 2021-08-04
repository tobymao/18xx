# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18ZOO
      module Round
        class Stock < Engine::Round::Stock
          def next_entity_index!
            # If overriding, make sure to call @game.next_turn!
            @game.next_turn!

            if @game.greek_to_me_active?
              @log << "#{@game.it_is_all_greek_to_me.owner.name} plays again. \"It’s all greek to me\" is closed."
              @game.it_is_all_greek_to_me.close!
            else
              @entity_index = (@entity_index + 1) % @entities.size
            end
          end

          def sold_out?(corporation)
            corporation.player_share_holders.values.sum == (@game.turn == 3 ? 120 : 100)
          end

          def name
            'SR-day'
          end
        end
      end
    end
  end
end
