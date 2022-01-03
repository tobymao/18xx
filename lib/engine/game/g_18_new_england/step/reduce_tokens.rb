# frozen_string_literal: true

require_relative '../../../step/reduce_tokens'

module Engine
  module Game
    module G18NewEngland
      module Step
        class ReduceTokens < Engine::Step::ReduceTokens
          def description
            'Choose token to remove'
          end

          def help
            'Choose which duplicate token to remove.'
          end

          def available_hex(entity, hex)
            return false unless entity == surviving

            entity.tokens.count { |t| t.used && t.city.hex == hex } > 1
          end
        end
      end
    end
  end
end
