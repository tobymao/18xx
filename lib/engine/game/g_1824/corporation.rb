# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G1824
      class Corporation < Engine::Corporation
        attr_accessor :floatable, :removed

        def initialize(sym:, name:, **opts)
          @floatable = true
          @removed = false
          super
        end

        def floated?
          @floatable && super
        end
      end
    end
  end
end
