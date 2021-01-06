# frozen_string_literal: true

require_relative '../operating'

module Engine
  module Round
    module G1849
      class Operating < Operating
        def next_entity!
          return @game.end_game! if @entities[@entity_index].reached_max_value

          super
        end
      end
    end
  end
end
