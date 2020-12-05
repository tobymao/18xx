# frozen_string_literal: true

require_relative '../bankrupt'

module Engine
  module Step
    module G1856
      class Bankrupt < Bankrupt
        def active?
          active_entities.any?
        end

        def active_entities
          return [] unless @round.cash_crisis_player

          [@round.cash_crisis_player]
        end

        def process_bankrupt(action)
          player = action.entity

          @log << "-- #{player.name} goes bankrupt --"
          # TODO: Implement
        end
      end
    end
  end
end
