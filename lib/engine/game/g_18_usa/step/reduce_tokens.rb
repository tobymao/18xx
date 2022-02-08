# frozen_string_literal: true

require_relative '../../../step/reduce_tokens'

module Engine
  module Game
    module G18USA
      module Step
        class ReduceTokens < Engine::Step::ReduceTokens
          def actions(entity)
            actions = super.dup
            actions << 'choose' if !actions.empty? && owns_p8?(entity)
            actions
          end

          def choice_available?(entity)
            owns_p8?(entity)
          end

          def choice_name
            "#{p8.name} token"
          end

          def choices
            %w[Remove]
          end

          def move_tokens_to_surviving(surviving, others, price_for_new_token: 0, check_tokenable: true)
            super
            @game.jump_graph.clear_graph_for(surviving)
          end

          def process_choose(action)
            entity = action.entity
            raise GameError, "#{entity.name} does not own #{p8.name}" unless owns_p8?(entity)

            token = (entity.tokens + others_tokens(acquired_corps)).find { |t| @game.p8_hexes.include?(t.hex) }
            token.remove!
            @game.log << "#{entity.name} removes #{p8.name} token"

            @game.log << "#{p8.name} closes"
            p8.close!

            return if tokens_above_limits?(entity, acquired_corps)

            move_tokens_to_surviving(entity, acquired_corps)
            @round.corporations_removing_tokens = nil
          end

          def owns_p8?(entity)
            p8.owner == entity
          end

          def p8
            @game.company_by_id('P8')
          end
        end
      end
    end
  end
end
