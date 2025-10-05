# frozen_string_literal: true

module Engine
  module Game
    module G1868WY
      class DevelopmentCompany < Engine::Minor
        def initialize(player:, **opts)
          @owner = player

          super(tokens: [], color: :black, **opts)
        end

        def spender
          @owner
        end
      end
    end
  end
end
