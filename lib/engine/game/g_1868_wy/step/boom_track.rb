# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/tracker'

module Engine
  module Game
    module G1868WY
      module Step
        class BoomTrack < Engine::Step::Base
          include Engine::Step::Tracker

          def description
            'Boom Track'
          end

          def help
            'Players who laid original track must resolve pending Boom City upgrades'
          end

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless entity.minor?
            return [] unless blocks?

            ['lay_tile']
          end

          def process_lay_tile(action)
            lay_tile(action, spender: @game.tile_layers[action.hex])
            @game.postprocess_boom_lay_tile(action)
          end

          def blocks?
            !@game.pending_boom_tile_lays.empty?
          end

          def can_lay_tile?(_entity)
            blocks?
          end

          def available_hex(_entity, hex)
            @game.pending_boom_tile_lays.key?(hex)
          end

          def potential_tiles(_entity, hex)
            @game.pending_boom_tile_lays[hex] || []
          end

          def legal_tile_rotation?(_entity, hex, tile)
            if @game.pending_boom_tile_lays[hex].include?(tile)
              hex.tile.exits.sort == tile.exits.sort
            else
              false
            end
          end

          def check_track_restrictions!(entity, old_tile, new_tile); end
        end
      end
    end
  end
end
