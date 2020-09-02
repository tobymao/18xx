# frozen_string_literal: true

require_relative '../base'

module Engine
  module Round
    module G1817
      class Merger < Base
        def name
          'Merger Round'
        end

        def select_entities
          @game.players.reverse
        end
      end
    end
  end
end
