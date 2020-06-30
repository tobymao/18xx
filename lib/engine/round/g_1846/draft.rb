# frozen_string_literal: true

require_relative '../auction'

module Engine
  module Round
    module G1846
      class Draft < Auction
        def initialize(game, steps)
          super
          @index = @entities.size - 1
        end

        def name
          'Draft Round'
        end

        def next_index!
          @index = (@index - 1) % @entities.size
        end
      end
    end
  end
end
