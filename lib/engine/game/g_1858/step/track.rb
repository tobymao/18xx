# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1858
      module Step
        class Track < Engine::Step::Track
          def round_state
            # An extra field to track whether each tile lay only adds narrow gauge track.
            super.merge( { gauges_added: [] } )
          end

          def setup
            super
            @round.gauges_added = []
          end

          def new_track_gauge(old_tile, new_tile)
            old_track = old_tile.paths.map(&:track)
            new_track = new_tile.paths.map(&:track)
            old_track.each { |t| new_track.slice!(new_track.index(t) || new_track.size) }
            new_track.uniq
          end

          def lay_tile_action(action, entity: nil, spender: nil)
            # FIXME. This is ugly. The lay_tile_action has been cut'n'pasted from
            # Engine::Step::Tracker, with just a couple of lines added. This should
            # be refactored to add a hook into the base class.
            tile = action.tile
            old_tile = action.hex.tile
            tile_lay = get_tile_lay(action.entity)
            raise GameError, 'Cannot lay an upgrade now' if track_upgrade?(old_tile, tile,
                                                                           action.hex) && !(tile_lay && tile_lay[:upgrade])
            raise GameError, 'Cannot lay a yellow now' if tile.color == :yellow && !(tile_lay && tile_lay[:lay])
            if tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(action.hex)
              raise GameError, "#{action.hex.id} cannot be layed as this hex was already layed on this turn"
            end

            discount_second_tile!(tile_lay, old_tile, tile, action.entity)
            extra_cost = tile.color == :yellow ? tile_lay[:cost] : tile_lay[:upgrade_cost]

            lay_tile(action, extra_cost: extra_cost, entity: entity, spender: spender)
            if track_upgrade?(old_tile, tile, action.hex)
              @round.upgraded_track = true
              @round.num_upgraded_track += 1
            end
            @round.num_laid_track += 1
            @round.laid_hexes << action.hex
            @round.gauges_added << new_track_gauge(old_tile, tile)
          end

          def discount_second_tile!(tile_lay, old_tile, new_tile, entity)
            return if tile_lay[:cost].zero? # first tile

            gauges_added = @round.gauges_added + [ new_track_gauge(old_tile, new_tile) ]
            if gauges_added.include?([:narrow])
              @log << "#{entity.name} receives a #{@game.format_currency(10)} " \
                      'discount on its second tile for metre gauge track'
              tile_lay[:cost] = tile_lay[:upgrade_cost] = 10
            end
          end
        end
      end
    end
  end
end
