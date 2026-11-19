# frozen_string_literal: true

require_relative '../../player'

module Engine
  module Game
    module G18Junta
      # Rules summary 5: corruption tokens are always held by players, never by companies.
      class Player < Engine::Player
        attr_reader :corruption_tokens

        def initialize(id, name)
          @corruption_tokens = { white: 0, black: 0 }
          super
        end
      end
    end
  end
end
