# frozen_string_literal: true

require_relative '../../../step/track_and_token'

module Engine
  module Game
    module G1840
      module Step
        class TrackAndToken < Engine::Step::TrackAndToken
          def process_place_token(action)
            entity = action.entity

            spender = @game.owning_major_corporation(entity)
            place_token(entity, action.city, action.token, spender: spender)
            @tokened = true
            pass! unless can_lay_tile?(entity)
          end

          def process_lay_tile(action)
            entity = action.entity
            spender = @game.owning_major_corporation(entity)

            lay_tile_action(action, spender: spender)
            pass! if !can_lay_tile?(entity) && @tokened

            @orange_placed = true if @game.orange_framed?(action.tile)
            @normal_placed = true unless @game.orange_framed?(action.tile)
          end

          def available_hex(entity, hex)
            return @game.graph.reachable_hexes(entity)[hex] unless can_lay_tile?(entity, hex)
            return !@orange_placed if @game.orange_framed?(hex.tile)
            return false if @normal_placed

            super
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
            # this if of course not yet correct ;)
            return true if @game.orange_framed?(hex.tile)

            super
          end
        end
      end
    end
  end
end
