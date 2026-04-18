# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Round
    module G18OE
      class Consolidation < Engine::Round::Stock
        def self.short_name
          'C'
        end

        def name
          'Consolidation Round'
        end

        def select_entities
          @game.players.select do |p|
            @game.corporations.any? do |c|
              c.president?(p) &&
                (%i[minor regional].include?(c.type) ||
                  (c.type == :major && !c.floated?))
            end
          end
        end
      end
    end
  end
end
