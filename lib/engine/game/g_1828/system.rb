# frozen_string_literal: true

require_relative '../../corporation'
require_relative 'shell'

module Engine
  module Game
    module G1828
      class System < Engine::Corporation
        attr_reader :shells, :corporations

        def initialize(sym:, name:, **opts)
          opts[:always_market_price] = true
          super(sym: sym, name: name, **opts)

          @corporations = opts[:corporations]
          @name = @corporations.first.name

          @shells = []
        end

        def system?
          true
        end

        def floated?
          @floated ||= (num_ipo_shares - num_ipo_reserved_shares) <= 4
        end

        def percent_to_float
          super - (num_ipo_reserved_shares * 10)
        end

        def remove_train(train)
          @shells.each { |shell| shell.trains.delete(train) }
        end
      end
    end
  end
end
