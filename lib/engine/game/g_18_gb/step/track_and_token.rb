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
            return [] if entity.receivership? || @game.insolvent?(entity)

            actions << 'lay_tile' if can_lay_tile?(entity)
            actions << 'place_token' if can_place_token?(entity)
            actions << 'pass' if can_use_company_abilities?(entity) || !actions.empty?
            actions
          end

          def description
            @game.end_game_restrictions_active? ? 'Lay Track' : 'Place a Token or Lay Track'
          end

          def pass_description
            verb = @acted ? 'Done' : 'Skip'
            actions = @game.end_game_restrictions_active? ? 'Track' : 'Token/Track'
            "#{verb} (#{actions})"
          end

          def can_place_token?(entity)
            return false if @game.end_game_restrictions_active?

            super
          end

          def can_use_company_abilities?(entity)
            return false unless entity == current_entity

            @game.companies.select { |c| entity.owner == c.owner }.any? { |c| @game.abilities(c, :tile_lay) }
          end

          def potential_tile_colors(entity, hex)
            colors = super
            return colors if colors.include?(:green)

            colors << :green if @game.special_green_hexes(entity).include?(hex.coordinates)
            colors
          end

          def lay_tile_action(action)
            tile = action.tile
            tile_lay = get_tile_lay(action.entity)
            raise GameError, 'Cannot lay a city tile now' if !tile.cities.empty? && @laid_city

            lay_tile(action, extra_cost: tile_lay[:cost])
            @game.close_company_in_hex(action.hex)
            @laid_city = true unless action.tile.cities.empty?
            @round.num_laid_track += 1
            @round.laid_hexes << action.hex
          end

          def update_token!(_action, entity, tile, old_tile)
            cities = tile.cities
            if old_tile.paths.empty? &&
              !tile.paths.empty? &&
              cities.size > 1 &&
              !(tokens = cities.flat_map(&:tokens).compact).empty?
              # OO or XX tile newly connected to the network - we need to handle its tokens:
              # - if the token is for the corporation laying the tile, it will be connected to track
              # - if the token is from another corporation, it will be unconnected
              tokens.each do |token|
                token.remove!
                place_token(
                  token.corporation,
                  cities[token.corporation == entity ? 0 : 1],
                  token,
                  connected: false,
                  extra_action: true
                )
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
              cost - border_cost_discount(entity, spender, border, cost, hex)
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
