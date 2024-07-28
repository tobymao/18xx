# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Ardennes
      module Step
        class Convert < Engine::Step::Base
          ACTIONS = %w[convert pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if entity.receivership?
            return [] unless can_convert?(entity)

            ACTIONS
          end

          def description
            'Convert to a 10-share company'
          end

          def round_state
            super.merge({ converted: nil })
          end

          def can_convert?(corporation)
            corporation.type == :'5-share' && corporation.operated?
          end

          def process_convert(action)
            corporation = action.entity
            @log << "#{corporation.id} converts to a 10-share company"
            @round.converted = corporation
            @game.convert!(corporation)
          end

          def log_skip(_entity); end
        end
      end
    end
  end
end
