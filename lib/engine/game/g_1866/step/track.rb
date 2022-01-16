# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1866
      module Step
        class Track < Engine::Step::Track
          def can_lay_tile?(entity)
            action = get_tile_lay(entity)
            return false unless action
            return true if @game.national_corporation?(entity)

            !entity.tokens.empty? && (buying_power(entity) >= action[:cost]) && (action[:lay] || action[:upgrade])
          end
        end
      end
    end
  end
end
