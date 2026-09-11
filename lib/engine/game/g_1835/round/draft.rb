# frozen_string_literal: true

require_relative '../../../round/draft'

module Engine
  module Game
    module G1835
      module Round
        class Draft < Engine::Round::Draft
          def setup
            @all_players_have_acted_at_least_once = false
          end

          def next_entity!
            next_entity_index!
            return if finished?

            @steps.each(&:unpass!)
            skip_steps
            next_entity! unless active_step
          end

          def finished?
            @game.all_drafted? || @entities.all?(&:passed?)
          end

          def next_entity_index!
            if @entity_index == @entities.size - 1 && very_first_round_with_clemens?
              # select_entities reversed the players, we now un-reverse them and let the first player have another turn
              @entities = @entities.reverse
              @entity_index = 0
              @all_players_have_acted_at_least_once = true
            else
              super
            end
          end

          def very_first_round_with_clemens?
            !@all_players_have_acted_at_least_once && @game.option_clemens? && @round_num == 1
          end
        end
      end
    end
  end
end
