# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1849
      module Round
        class Stock < Engine::Round::Stock
          def setup
            @game.corporations
              .select { |c| c.floated? && c.unplaced_tokens.size == 3 }
              .each { |c| @game.place_home_token(c) }
            super
          end

          def start_entity
            @game.moved_this_turn = []
            super
          end
        end
      end
    end
  end
end
