# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1880
      module Round
        class Operating < Engine::Round::Operating
          def finished?
            finished = !active_step || !any_to_act?
            @game.end_game! if finished && trigger_game_end?
            @current_operator = nil if finished
            finished
          end

          def trigger_game_end?
            round_num == @game.final_operating_rounds &&
            @current_operator == @game.train_marker
          end
        end
      end
    end
  end
end
