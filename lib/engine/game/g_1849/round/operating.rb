# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1849
      module Round
        class Operating < Engine::Round::Operating
          def next_entity!
            return @game.end_game! if @entities[@entity_index].reached_max_value

            super
          end
        end
      end
    end
  end
end
