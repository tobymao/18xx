# frozen_string_literal: true

require_relative '../auction'

module Engine
  module Round
    module G1846
      class Draft < Auction
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
