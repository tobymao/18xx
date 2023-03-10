# frozen_string_literal: true

require_relative '../../company'

module Engine
  module Game
    module G1850
      class Company < Engine::Company
        def max_price(buyer)
          id == 'CM' && buyer&.id == 'UP' ? @value * 3 : @max_price
        end
      end
    end
  end
end
