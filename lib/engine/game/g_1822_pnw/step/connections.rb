# frozen_string_literal: true

module Engine
  module Game
    module G1822PNW
      module Connections
        def connected_to_port?(entity)
          @port_hexes ||= %w[E8 D9].map { |id| @game.hex_by_id(id) }
          !(@game.graph.reachable_hexes(entity).keys & @port_hexes).empty?
        end

        def entity_connects?(entity, minor)
          minor_city = if !minor.owner || minor.owner == @bank
                         # Trying to acquire a bidbox minor. Trace route to its hometokenplace
                         @game.hex_by_id(minor.coordinates).tile.cities.find { |c| c.reserved_by?(minor) }
                       else
                         # Minors only have one token, check if its connected
                         minor.tokens.first.city
                       end
          @game.graph.connected_nodes(entity)[minor_city] || (connected_to_port?(minor) && connected_to_port?(entity))
        end
      end
    end
  end
end
