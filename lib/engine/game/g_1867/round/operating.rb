# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1867
      module Round
        class Operating < Engine::Round::Operating
          def skip_entity?(entity)
            !entity.floated? || !@game.corporations.include?(entity)
          end
        end
      end
    end
  end
end
