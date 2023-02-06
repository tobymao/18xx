# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1880
      module Round
        class Operating < Engine::Round::Operating
          def setup
            return super unless self == @game.saved_or_round

            current = @entities[@entity_index]
            @entities = select_entities
            @entity_index = @entities.find_index(current)

            @entities.each { |c| @game.place_home_token(c) } if @home_token_timing == :operating_round
            start_operating
          end

          def skip_steps
            return if @game.round.stock?

            super
          end

          def after_process(action)
            return if @game.round.stock?

            super
          end

          def after_end_of_turn(_action)
            @game.end_game! if trigger_game_end?
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
