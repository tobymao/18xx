# frozen_string_literal: true

require_relative '../../../round/draft'

module Engine
  module Game
    module G18CZ
      module Round
        class Draft < Engine::Round::Draft
          def select_entities
            @game.players_without_vaclav
          end
        end
      end
    end
  end
end
