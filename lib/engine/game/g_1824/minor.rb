# frozen_string_literal: true

require_relative '../../minor'

module Engine
  module Game
    module G1824
      class Minor < Engine::Minor
        attr_accessor :type, :removed

        def initialize(sym:, name:, **opts)
          @type = opts[:type]&.to_sym
          @removed = false
          super
        end
      end
    end
  end
end
