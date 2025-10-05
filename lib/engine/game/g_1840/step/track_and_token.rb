# frozen_string_literal: true

require_relative '../../../step/track_and_token'

module Engine
  module Game
    module G1840
      module Step
        class TrackAndToken < Engine::Step::TrackAndToken
          def actions(entity)
            actions = []
            return actions if entity != current_entity

            actions << 'lay_tile' if can_lay_tile?(entity)
            actions << 'place_token' if can_place_token?(entity)
            actions << 'remove_token'
            actions << 'pass'
            actions
          end

          def process_remove_token(action)
            city = action.city
            entity = action.entity
            token = city.tokens[action.slot]
            hex = city.hex

            raise GameError, "Token in #{hex.name} cannot be removed" if
             token&.corporation&.type != :city || @game.class::NO_TOKEN_REMOVE_HEX.include?(hex.coordinates)

            spender = @game.owning_major_corporation(entity)
            spender.spend(40, @game.bank)
            @log << "#{entity.name} removes token from #{hex.name} (#{hex.location_name}) "\
                    "for #{@game.format_currency(40)}"
            token.destroy!

            @game.graph_for_entity(entity).clear
          end

          def process_place_token(action)
            entity = action.entity
            city = action.city

            spender = @game.owning_major_corporation(entity)
            place_token(entity, city, action.token, spender: spender)

            @game.city_graph.clear
            @tokened = true
          end

          def process_lay_tile(action)
            entity = action.entity
            spender = @game.owning_major_corporation(entity)
            tile = action.tile

            lay_tile_action(action, spender: spender)

            if @game.orange_framed?(tile) && tile.color == :yellow
              @orange_placed = true
              type = read_type_from_icon(action.hex)

              if type == :token
                @round.pending_special_tokens << {
                  entity: entity,
                  token: entity.find_token_by_type,
                }
              else
                @round.pending_tile_lays << {
                  entity: entity,
                  color: type,
                }
              end

              entry = @game.city_tracks.find do |_k, v|
                v.include?(tile.hex.coordinates)
              end
              entry[1].delete(tile.hex.coordinates) if entry
            else
              @normal_placed = true
            end
            @game.city_graph.clear
          end

          def available_hex(entity, hex)
            return @game.graph.reachable_hexes(entity)[hex] unless can_lay_tile?(entity)

            return orange_tile_available?(hex) if @game.orange_framed?(hex.tile) && hex.tile == hex.original_tile

            return @game.graph.connected_nodes(entity)[hex] if @normal_placed

            return true if super
            return false if @game.class::NO_TOKEN_REMOVE_HEX.include?(hex.coordinates)

            hex.tile.cities.any? { |c| c.tokens.any? { |t| t&.corporation&.type == :city } }
          end

          def orange_tile_available?(hex)
            return false if @orange_placed

            entry = @game.city_tracks.find do |_k, v|
              v.include?(hex.coordinates)
            end

            # Already placed, and could be upgraded
            return false unless entry

            hexes = entry[1]
            index = hexes.index(hex.coordinates)

            index.zero? || (index == hexes.size - 1)
          end

          def setup
            super
            @orange_placed = false
            @normal_placed = false
          end

          def potential_tiles(_entity, hex)
            tiles = super

            return tiles.select { |tile| @game.orange_framed?(tile) } if @game.orange_framed?(hex.tile)

            tiles.reject { |tile| @game.orange_framed?(tile) }
          end

          def legal_tile_rotation?(_entity, hex, tile)
            if @game.orange_framed?(hex.tile) && tile.color == :yellow
              needed_exits = @game.needed_exits_for_hex(hex)
              return (tile.exits & needed_exits).size == needed_exits.size
            end

            super
          end

          def read_type_from_icon(hex)
            name = hex.original_tile.icons.first.name
            name.split('_').first.to_sym
          end

          def show_other
            @game.owning_major_corporation(current_entity)
          end

          def can_replace_token?(_entity, _token)
            true
          end

          def can_place_token?(entity)
            current_entity == entity &&
              !@round.tokened &&
              !(tokens = available_tokens(entity)).empty? &&
              min_token_price(tokens) <= buying_power(entity)
          end

          def hex_neighbors(_entity, hex)
            return @game.hex_by_id(hex.id).neighbors.keys if @game.orange_framed?(hex.tile) && hex.tile == hex.original_tile

            super
          end
        end
      end
    end
  end
end
