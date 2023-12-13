# frozen_string_literal: true

module Engine
  module Game
    module G18India
      class Corporation < Engine::Corporation

        def initialize(sym:, name:, **opts)
          super

          # @par_price = opts[:par_price]
        end
      end
    end
  end
end
