# frozen_string_literal: true

require_relative '../../../step/track_and_token'

module Engine
  module Game
    module G18GB
      module Step
        class TrackAndToken < Engine::Step::TrackAndToken
          def setup
            @laid_city = false
            super
          end

          def actions(entity)
            actions = []
            return actions if entity != current_entity

            actions << 'lay_tile' if can_lay_tile?(entity)
            actions << 'place_token' if can_place_token?(entity)
            actions << 'pass' if can_use_company_abilities?(entity) || actions.any?
            actions
          end

          def can_use_company_abilities?(entity)
            return false unless entity == current_entity

            @game.companies.select { |c| entity.owner == c.owner }.map { |c| @game.abilities(c, :tile_lay) }.any?
          end

          def lay_tile_action(action)
            tile = action.tile
            tile_lay = get_tile_lay(action.entity)
            raise GameError, 'Cannot lay a city tile now' if tile.cities.any? && @laid_city

            lay_tile(action, extra_cost: tile_lay[:cost])
            @laid_city = true if action.tile.cities.any?
            @round.num_laid_track += 1
            @round.laid_hexes << action.hex
          end

          def update_token!(_action, entity, tile, old_tile)
            cities = tile.cities
            if old_tile.paths.empty? &&
              !tile.paths.empty? &&
              cities.size > 1 &&
              !(tokens = cities.flat_map(&:tokens).compact).empty?
              # OO or XX tile newly connected to the network - we need to handle its tokens
              tokens.each do |token|
                token.remove!
                if token.corporation == entity
                  # if the token is for the corporation laying the tile, it will be connected to track
                  place_token(
                    token.corporation,
                    tile.cities[0],
                    token,
                    connected: false,
                    extra_action: true
                  )
                else
                  # if the token is from another corporation, it will be unconnected
                  place_token(
                    token.corporation,
                    tile.cities[1],
                    token,
                    connected: false,
                    extra_action: true
                  )
                end
              end
            end
          end

          def remove_border_calculate_cost!(tile, entity, spender)
            hex = tile.hex
            types = []
            total_cost = tile.borders.dup.sum do |border|
              next 0 unless (cost = border.cost)

              edge = border.edge
              neighbor = hex.neighbors[edge]
              next 0 unless hex.targeting?(neighbor)

              tile.borders.delete(border)
              types << border.type
              cost - border_cost_discount(entity, spender, cost, hex)
            end

            [total_cost, types]
          end

          def process_place_token(action)
            entity = action.entity
            place_token(entity, action.city, action.token)
            @tokened = true
          end

          def process_tile_lay(action)
            lay_tile_action(action)
          end
        end
      end
    end
  end
end
