# frozen_string_literal: true

require_relative '../../player'

module Engine
  module Game
    module G1844
      class Player < Engine::Player
        attr_accessor :debt

        def initialize(id, name)
          super
          @debt = 0
        end

        def value
          super - @debt
        end
      end
    end
  end
end
