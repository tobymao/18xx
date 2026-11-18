# frozen_string_literal: true

require_relative '../../train'

module Engine
  module Game
    module G18OE
      class Train < Engine::Train
        attr_reader :level

        def initialize(name:, distance:, price:, index: 0, **opts)
          super

          @level = opts[:level]
        end
      end
    end
  end
end
