# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1848
      module Round
        class Operating < Engine::Round::Operating
          def skip_entity?(entity)
            return super if entity.name != :COM

            !@game.sydney_adelaide_connected
          end
        end
      end
    end
  end
end
