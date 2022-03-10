# frozen_string_literal: true

require_relative '../../../round/auction'

module Engine
  module Game
    module G1871
      module Round
        class Auction < Engine::Round::Auction
          def select_entities
            super.reject { |p| p == @game.union_bank }
          end
        end
      end
    end
  end
end
