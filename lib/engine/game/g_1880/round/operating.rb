# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1880
      module Round
        class Operating < Engine::Round::Operating
          def setup
            return super unless self == @game.saved_or_round

            @entities.each { |c| @game.place_home_token(c) } if @home_token_timing == :operating_round
            @game.round_history << @game.current_action_id
          end

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
