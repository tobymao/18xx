# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18FL
      module Step
        class Convert < Engine::Step::Base
          def actions(entity)
            return %w[convert pass] if can_convert?(entity)

            []
          end

          def description
            'Convert to 10 Share'
          end

          def pass_description
            'Do not convert'
          end

          def can_convert?(entity)
            entity.corporation? &&
              entity.operated? &&
              @game.phase.status.include?('may_convert') &&
              entity.total_shares == 5
          end

          def process_convert(action)
            @game.convert(action.entity)
            pass!
          end
        end
      end
    end
  end
end
