# frozen_string_literal: true

require_relative '../../../round/draft'

module Engine
  module Game
    module G1847AE
      module Round
        class Draft < Engine::Round::Draft
          def initialize(game, steps, **opts)
            super

            return unless @game.draft_first_round_finished

            @entity_index = @game.draft_last_acting_index
            @game.draft_last_acting_index = nil
          end

          def next_entity_index!
            if @entity_index == @entities.size - 1 && !@game.draft_first_round_finished
              @entities.reverse!
              @game.draft_first_round_finished = true
            end

            super
          end
        end
      end
    end
  end
end
