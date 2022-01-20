# frozen_string_literal: true

require_relative '../../../step/track'
require_relative '../../../step/upgrade_track_max_exits'

module Engine
  module Game
    module G1866
      module Step
        class Track < Engine::Step::Track
          include Engine::Step::UpgradeTrackMaxExits

          def available_hex(entity, hex)
            return nil if @game.national_corporation?(entity) && !@game.hex_within_national_region?(entity, hex)
            return nil if @game.public_corporation?(entity) && !@game.hex_operating_rights?(entity, hex)

            super
          end

          def can_lay_tile?(entity)
            action = get_tile_lay(entity)
            return false unless action
            return true if @game.national_corporation?(entity)

            !entity.tokens.empty? && (buying_power(entity) >= action[:cost]) && (action[:lay] || action[:upgrade])
          end

          def get_tile_lay(entity)
            action = super
            return unless action

            action[:upgrade] = @round.num_upgraded_track < @game.class::TILE_LAYS_UPGRADE[@game.phase.name]
            action
          end

          def lay_tile_action(action, entity: nil, spender: nil)
            tile = action.tile
            old_tile = action.hex.tile
            super

            @round.num_upgraded_track += 1 if track_upgrade?(old_tile, tile, action.hex)
          end

          def legal_tile_rotation?(entity, hex, tile)
            return true if hex.name == @game.class::PARIS_HEX || hex.name == @game.class::LONDON_HEX

            super
          end

          def process_lay_tile(action)
            entity = action.entity
            hex = action.hex
            if @game.national_corporation?(entity) && !@game.hex_within_national_region?(entity, hex)
              raise GameError, 'Cannot lay or upgrade tiles outside the nationals region'
            end
            if @game.public_corporation?(entity) && !@game.hex_operating_rights?(entity, hex)
              raise GameError, 'Cannot lay or upgrade tiles without operating rights in the selected region'
            end

            super
          end

          def round_state
            super.merge(
              {
                num_upgraded_track: 0,
              }
            )
          end

          def setup
            super

            @round.num_upgraded_track = 0
          end

          def upgradeable_tiles(entity, ui_hex)
            hex = @game.hex_by_id(ui_hex.id)
            potential_tiles(entity, hex).map do |tile|
              tile.rotate!(0)
              tile.legal_rotations = legal_tile_rotations(entity, hex, tile)
              next if tile.legal_rotations.empty?

              tile.rotate!
              tile
            end.compact
          end
        end
      end
    end
  end
end
