# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Junta
      module Step
        # Rules summary 6.2: after laying the first tile in a paramilitary hex, the president chooses the
        # side the company supports.
        class ParamilitaryChoice < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def description
            'Paramilitary Token'
          end

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless @game.pending_paramilitary_choice_for?(entity)

            ACTIONS
          end

          def log_skip(_entity); end

          def blocks?
            @game.pending_paramilitary_choice_for?(current_entity)
          end

          def choice_name
            hex = @game.pending_paramilitary_hex
            "A paramilitary group was identified at #{hex&.name}: which side will the company support now?"
          end

          def choices
            {
              'civilian' => 'Support the Civilian side',
              'military' => 'Support the Military side',
            }
          end

          def process_choose(action)
            @game.resolve_paramilitary_choice!(action.entity, action.choice)
          end
        end
      end
    end
  end
end
