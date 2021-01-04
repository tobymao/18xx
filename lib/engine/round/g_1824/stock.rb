# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G1824
      class Stock < Stock
        attr_reader :reverse

        def description
          'First Stock Round'
        end

        def self.title
          'Hepp'
        end

        def setup
          @reverse = true

          super

          @entities.reverse!
        end

        def select_entities
          @game.players.reverse
        end

        def next_entity_index!
          if @entity_index == @game.players.size - 1
            @reverse = false
            @entities = @game.players
          end
          return super unless @reverse

          @entity_index = (@entity_index - 1) % @entities.size
        end
      end
    end
  end
end
