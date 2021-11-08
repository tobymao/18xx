# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G18NY
      module Round
        class Operating < Engine::Round::Operating
          def skip_entity?(entity)
            entity.closed? || entity.receivership?
          end

          def cash_crisis_entity
            @game.corporations.find { |corp| corp.cash.negative? }
          end
        end
      end
    end
  end
end
