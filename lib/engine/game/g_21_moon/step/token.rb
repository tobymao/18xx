# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G21Moon
      module Step
        class Token < Engine::Step::Token
          def process_place_token(action)
            super

            @game.graph.clear
            @game.sp_graph.clear
            @game.hb_graph.clear
          end
        end
      end
    end
  end
end
