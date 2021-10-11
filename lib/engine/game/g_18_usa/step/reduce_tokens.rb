# frozen_string_literal: true

require_relative '../../../step/reduce_tokens'

module Engine
  module Game
    module G18USA
      module Step
        class ReduceTokens < Engine::Step::ReduceTokens
          def move_tokens_to_surviving(surviving, others, price_for_new_token: 0, check_tokenable: true)
            super
            @game.jump_graph.clear_graph_for(surviving)
          end
        end
      end
    end
  end
end
