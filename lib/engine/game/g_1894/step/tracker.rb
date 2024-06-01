# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G1894
      module Tracker
        include Engine::Step::Tracker

        def check_track_restrictions!(entity, old_tile, new_tile)
          return if @game.loading || !entity.operator?
          return if @game.class::BROWN_CITY_TILES.include?(new_tile.name)

          super
        end

        def legal_tile_rotation?(entity, hex, tile)
          return super unless @game.class::BROWN_CITY_TILES.include?(tile.name)

          old_paths = hex.tile.paths
          old_exits = hex.tile.exits
          new_paths = tile.paths
          new_exits = tile.exits

          new_exits.all? { |edge| hex.neighbors[edge] } &&
            old_paths.all? { |path| new_paths.any? { |p| path <= p } } &&
            new_exits.sort == old_exits.sort
        end

        def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
          hex = action.hex
          old_tile = hex.tile
          new_tile = action.tile

          if @game.class::BROWN_CITY_TILES.include?(new_tile.name)
            # The city splits into two cities, so the reservation has to be for the whole hex
            reservation = old_tile.cities.first.reservations.compact.first
            if reservation
              old_tile.cities.first.remove_all_reservations!
              old_tile.add_reservation!(reservation.corporation, nil, false)
            end

            tokens = old_tile.cities.flat_map(&:tokens).compact
            tokens_to_save = []
            tokens.each do |token|
              token.price = 0
              tokens_to_save << {
                entity: token.corporation,
                hexes: [hex],
                token: token,
              }
            end
            @game.save_tokens(tokens_to_save)
            @game.save_tokens_hex(hex)

            tokens.each(&:remove!)
          end

          super
        end
      end
    end
  end
end
