# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G1849
      class Stock < Stock
        def setup
          @game.corporations
            .select { |c| c.floated? && c.unplaced_tokens.size == 3 }
            .each { |c| @game.place_home_token(c) }
          super
        end
      end
    end
  end
end
