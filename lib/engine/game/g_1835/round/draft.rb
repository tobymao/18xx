# frozen_string_literal: true

require_relative '../../../round/draft'

module Engine
  module Game
    module G1835
      module Round
        class Draft < Engine::Round::Draft
          def select_entities
            @reverse_order ? @game.players.reverse : @game.players
          end

          def finished?
            # Finished when all drafted OR all players passed
            @game.all_entities_drafted? || entities.all?(&:passed?)
          end
        end
      end
    end
  end
end
