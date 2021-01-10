# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G1849
      class Stock < Stock
        def setup
          afg = @game.afg
          @game.place_home_token(afg) if afg&.floated? && afg.unplaced_tokens.size == 3

          super
        end
      end
    end
  end
end
