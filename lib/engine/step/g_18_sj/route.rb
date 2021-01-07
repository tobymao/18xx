# frozen_string_literal: true

require_relative '../route'

module Engine
  module Step
    module G18SJ
      class Route < Route
        def setup
          @game.make_sj_tokens_passable_for_electric_trains(current_entity)

          super
        end
      end
    end
  end
end
