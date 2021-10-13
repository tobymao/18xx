# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G18Rhl
      module Round
        class Operating < Engine::Round::Operating
          attr_accessor :teleport_ability
        end
      end
    end
  end
end
