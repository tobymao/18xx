# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1835
      module Step
        class Track < Engine::Step::Track
          def check_connected(action)
            # Baden can lay its first tile on L6 without connectivity
            return if action.entity.id == 'BA' && action.hex.id == 'L6' && action.entity.tokens.first&.used == false

            super
          end

          def available_hex(entity, hex)
            # Ensure L6 is clickable for Baden before it has placed any tokens
            return true if entity.id == 'BA' && hex.id == 'L6' && entity.tokens.first&.used == false

            super
          end
        end
      end
    end
  end
end
