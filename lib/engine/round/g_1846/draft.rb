# frozen_string_literal: true

require_relative '../base'

module Engine
  module Round
    module G1846
      class Draft < Base
        def name
          'Draft Round'
        end

        def select_entities
          @game.players.reverse
        end
      end
    end
  end
end
