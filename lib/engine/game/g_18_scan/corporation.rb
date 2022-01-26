# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G18Scan
      class Corporation < Engine::Corporation
        def initialize(game, sym:, name:, **opts)
          @game = game

          super(sym: sym, name: name, **opts)
        end

        def floated?
          return false unless @floatable

          @floated ||= @ipo_owner.percent_of(self) <= 100 - @game.float_percent
        end

        def percent_to_float
          return 0 if @floated

          @ipo_owner.percent_of(self) - (100 - @game.float_percent)
        end
      end
    end
  end
end
