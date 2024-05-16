# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G21Moon
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def teleport_complete
            @log << "#{@round.teleported.name} closes"
            @round.teleported.close!
            @game.lb_graph.clear
            @game.sp_graph.clear
            @game.graph.clear
            super
          end
        end
      end
    end
  end
end
