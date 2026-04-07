# frozen_string_literal: true

require_relative '../../graph'

module Engine
  module Game
    module G1835
      class Graph < Engine::Graph
        # Hamburg (C11) has two cities with a total of 3 token slots.
        # Per 1835 rules, Hamburg is non-blocking as long as any slot is open.
        # The standard engine evaluates blocking per-city, so city 0 (2-slot)
        # can incorrectly block when it is full even if city 1 still has a slot.
        #
        # Fix: before computing routes, temporarily add a nil (open-slot marker)
        # to any full Hamburg city when the hex still has open slots elsewhere.
        # Restore the arrays immediately after compute completes.
        def compute(corporation, routes_only: false, one_token: nil, &block)
          snapshots = temporarily_unblock_hamburg
          super(corporation, routes_only: routes_only, one_token: one_token, &block)
        ensure
          restore_hamburg_cities(snapshots || {})
        end

        private

        def temporarily_unblock_hamburg
          hex = @game.hex_by_id(@game.class::HAMBURG_HEX)
          return {} unless hex&.tile

          cities = hex.tile.cities
          total_open = cities.sum { |c| c.tokens.count(&:nil?) }
          return {} if total_open.zero? # All slots filled — normal blocking applies

          snapshots = {}
          cities.each do |city|
            next if city.tokens.include?(nil) # Already has an open slot

            # City is full but the hex as a whole has open slots.
            # Save the token array and append nil so blocks? returns false.
            snapshots[city] = city.tokens.dup
            city.tokens << nil
          end
          snapshots
        end

        def restore_hamburg_cities(snapshots)
          snapshots.each { |city, original| city.tokens.replace(original) }
        end
      end
    end
  end
end
