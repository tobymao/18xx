# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18CZ
      module Round
        class Stock < Engine::Round::Stock
          def select_entities
            @game.players_without_vaclav
          end
        end
      end
    end
  end
end
