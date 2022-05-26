# frozen_string_literal: true

require_relative '../../g_1822/step/route'

module Engine
  module Game
    module G1822MX
      module Step
        class Route < Engine::Game::G1822::Step::Route
          def ndem_acting_player
            @game.players.find { |p| @game.ndem.player_share_holders[p]&.positive? } || @game.players.first
          end

          def help
            return super unless current_entity == @game.ndem

            'NDEM has no president.  The shareholder in highest priority will run the '\
              'trains.  If there are no shareholders, the player with priority will do so.'
          end
        end
      end
    end
  end
end
