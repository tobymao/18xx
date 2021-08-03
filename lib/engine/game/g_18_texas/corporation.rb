# frozen_string_literal: true

require_relative 'corporation'

module Engine
  module Game
    module G18Texas
      class Corporation < Engine::Corporation
        attr_reader :token_fee

        def initialize(sym:, name:, **opts)
          super
          @token_fee = opts[:token_fee]
        end
      end
    end
  end
end
