# frozen_string_literal: true

require_relative '../../../round/draft'

module Engine
  module Game
    module G1835
      module Round
        class Draft < Engine::Round::Draft
          def select_entities
            @game.players
          end
        end
      end
    end
  end
end
