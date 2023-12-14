# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G18ESP
      module Tracker
        include Engine::Step::Tracker

        def setup
          super
          @round.extra_mine_lay = false
          @round.mine_tile_laid = false
        end

        def lay_tile_action(action)
          hex = action.hex
          super

          if @game.mine_hex?(action.hex) && old_tile.color == :white
            @round.num_laid_track -= 1
            @round.mine_tile_laid = true
          end

          tokens = hex.tile.cities.first.tokens if hex.id == 'F24'
          if hex.id == 'F24' && tokens.find { |t| t&.corporation&.name == 'MZ' } && tokens.find do |t|
               t&.corporation&.name == 'MZA'
             end && (action.tile.color == :brown || action.tile.color == :gray)
            mz_token = tokens.find { |t| t&.corporation&.name == 'MZ' }
            hex.tile.cities.first.delete_token!(mz_token)
            hex.tile.cities.first.exchange_token(mz_token, extra_slot: true)
          end
          # clear graphs
          @game.graph.clear

          action.entity.goal_reached!(:destination) if @game.check_for_destination_connection(action.entity)
        end

        def extra_cost(tile, tile_lay, hex)
          @game.mine_hex?(hex) ? 0 : super
        end

        def round_state
          super.merge(
            {
              extra_mine_lay: false,
              mine_tile_laid: false,
            }
          )
        end

        def tracker_available_hex(entity, hex)
          get_tile_lay(entity)
          return super && @game.mine_hex?(hex) if @round.extra_mine_lay

          @round.mine_tile_laid ? super && !@game.mine_hex?(hex) : super
        end

        def get_tile_lay(entity)
          action = super
          # if action is nil, and mine wasn't laid, grant a lay action buy only for mine
          if action.nil? && !@round.mine_tile_laid
            @round.extra_mine_lay = true
            return { lay: true, upgrade: false, cost: 0 }
          end
          action
        end

        def potential_tiles(entity, hex)
          tiles = super

          if @game.north_hex?(hex)
            tiles.reject! { |tile| tile.paths.any? { |path| path.track == :broad } }
          else
            tiles.reject! { |tile| tile.paths.any? { |path| path.track == :narrow } }
          end
          tiles
        end

        def legal_tile_rotation?(entity, hex, tile)
          hex.tile.towns.none?(&:halt?) ? super : halt_upgrade_legal_rotation?(entity, hex, tile)
        end

        def halt_upgrade_legal_rotation?(entity_or_entities, hex, tile)
          # entity_or_entities is an array when combining private company abilities
          entities = Array(entity_or_entities)
          entity, *_combo_entities = entities

          return false unless @game.legal_tile_rotation?(entity, hex, tile)

          old_ctedges = hex.tile.city_town_edges

          new_paths = tile.paths
          new_exits = tile.exits
          new_ctedges = tile.city_town_edges
          extra_cities = [0, new_ctedges.size - old_ctedges.size].max
          multi_city_upgrade = tile.cities.size > 1 && hex.tile.cities.size > 1
          new_exits.all? { |edge| hex.neighbors[edge] } &&
            !(new_exits & hex_neighbors(entity, hex)).empty? &&
            new_paths.any? { |p| old_ctedges.flatten.empty? || (p.exits - old_ctedges.flatten).empty? } &&
            (old_ctedges.flatten - new_exits.flatten).empty? &&
            # Count how many cities on the new tile that aren't included by any of the old tile.
            # Make sure this isn't more than the number of new cities added.
            # 1836jr30 D6 -> 54 adds more cities
            extra_cities >= new_ctedges.count { |newct| old_ctedges.all? { |oldct| (newct & oldct).none? } } &&
            # 1867: Does every old city correspond to exactly one new city?
            (!multi_city_upgrade || old_ctedges.all? { |oldct| new_ctedges.one? { |newct| (oldct & newct) == oldct } })
        end
      end
    end
  end
end
