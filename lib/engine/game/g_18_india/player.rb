# frozen_string_literal: true

require_relative '../../player'

module Engine
  module Game
    module G18India
      class Player < Engine::Player
        attr_accessor :hand

        def initialize(id, name)
          @hand = []
          super
        end
      end
    end
  end
end
