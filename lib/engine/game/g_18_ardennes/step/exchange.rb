# frozen_string_literal: true

require_relative '../../../step/exchange'
require_relative 'minor_exchange'

module Engine
  module Game
    module G18Ardennes
      module Step
        class Exchange < Engine::Step::Exchange
          include MinorExchange

          def can_exchange?(entity, _bundle = nil)
            return false unless entity.corporation?

            entity.type == :minor
          end
        end
      end
    end
  end
end
