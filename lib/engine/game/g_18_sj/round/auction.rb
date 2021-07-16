# frozen_string_literal: true

require_relative '../../../round/auction'

module Engine
  module Game
    module G18SJ
      module Round
        class Auction < Engine::Round::Auction
          def select_entities
            super.reject { |p| p == @game.edelsward }
          end
        end
      end
    end
  end
end
