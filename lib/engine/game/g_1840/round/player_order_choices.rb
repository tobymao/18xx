# frozen_string_literal: true

require_relative '../../../round/choices'

module Engine
  module Game
    module G1840
      module Round
        class Choices < Engine::Round::Choices
          def name
            'Choose'
          end

          def select_entities
            current_order = @game.players.dup
            @game.players.sort_by { |p| [p.cash, current_order.index(p)] }
          end
        end
      end
    end
  end
end
