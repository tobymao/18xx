# frozen_string_literal: true

require_relative '../../../round/draft'

module Engine
  module Game
    module G18MO
      module Round
        class Draft < Engine::Round::Draft
          def finished?
            @game.companies.reject(&:owned_by_player?).empty?
          end
        end
      end
    end
  end
end
