# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1848
      module Round
        class Operating < Engine::Round::Operating
          def skip_entity?(entity)
            return super if entity.name != :COM

            @log << 'COM does not operate, Sydney and Addelaide are not connected' unless @game.sydney_adelaide_connected
            !@game.sydney_adelaide_connected
          end
        end
      end
    end
  end
end
