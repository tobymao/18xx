# frozen_string_literal: true

module Engine
  module Game
    module G18FR
      class Train < Engine::Train
        attr_reader :base_price, :final_price

        def initialize(name:, distance:, price:, index: 0, **opts)
          super

          @base_price = price
          @final_price = opts[:final_price] || price
        end

        def new_price(price)
          @price = price
          variant[:price] = price
        end

        def min_price
          return 0 unless from_depot?

          super
        end
      end
    end
  end
end
