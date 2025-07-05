# frozen_string_literal: true

require_relative '../../../round/choices'

module Engine
  module Game
    module GSystem18
      module Round
        class DifficultySelection < Engine::Round::Choices
          def name
            'Difficulty Selection'
          end

          def self.short_name
            'DS'
          end

          def select_entities
            # Only the first player needs to make the choice
            [@game.players.first]
          end

          def show_in_history?
            false
          end
        end
      end
    end
  end
end
