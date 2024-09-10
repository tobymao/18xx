# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative 'lay_tile_check'

module Engine
  module Game
    module G18ESP
      module Tracker
        include Engine::Step::Tracker
        include LayTileCheck

        def setup
          super
          @round.extra_mine_lay = false
          @round.mine_tile_laid = false
        end

        def lay_tile_action(action)
          hex = action.hex
          old_tile = hex.tile
          super

          if @game.mine_hex?(action.hex) && old_tile.color == :white
            @round.num_laid_track -= 1
            @round.mine_tile_laid = true
          end

          tokens = hex.tile.cities.first.tokens if hex == @game.madrid_hex
          if hex == @game.madrid_hex && tokens.find { |t| t&.corporation&.name == 'MZ' } && tokens.find do |t|
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
          return super && mine_tile?(hex) if @round.extra_mine_lay

          @round.mine_tile_laid ? super && !mine_tile?(hex) : super
        end

        def mine_tile?(hex)
          @game.mine_hex?(hex) && hex.tile.color == :white
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
      end
    end
  end
end
