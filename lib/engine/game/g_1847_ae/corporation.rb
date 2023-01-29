# frozen_string_literal: true

module Engine
  module Game
    module G1847AE
      class Corporation < Engine::Corporation
        attr_reader :hex_color, :second_share_double, :last_share_double

        def initialize(sym:, name:, **opts)
          super

          @second_share_double = opts[:second_share_double]
          @last_share_double = opts[:last_share_double]
          shares[2].double_cert = @second_share_double
          shares.last.double_cert = @last_share_double
          @par_price = opts[:par_price]
          @hex_color = opts[:hex_color]
        end
      end
    end
  end
end
