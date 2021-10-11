# frozen_string_literal: true

require_relative '../../../round/choices'

module Engine
  module Game
    module G1822
      module Round
        class Choices < Engine::Round::Choices
          def name
            'Choose'
          end

          def select_entities
            @game.choices_entities
          end
        end
      end
    end
  end
end
