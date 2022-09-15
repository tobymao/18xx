# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1858
      module Step
        class Track < Engine::Step::Track
          def round_state
            # An extra field to track whether each tile lay only adds narrow gauge track.
            super.merge({ gauges_added: [] })
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

            gauges_added = @round.gauges_added + [new_track_gauge(old_tile, new_tile)]
            return unless gauges_added.include?([:narrow])

            @log << "#{entity.name} receives a #{@game.format_currency(10)} " \
                    'discount on its second tile for metre gauge track'
            tile_lay[:cost] = tile_lay[:upgrade_cost] = 10
          end

          def potential_tiles(entity, hex)
            tiles = super
            return tiles unless @game.phase.name == '2'

            # Metre gauge track is not available until phase 3.
            tiles.reject { |tile| tile.paths.map(&:track).include?(:narrow) }
          end

          def can_lay_tile?(entity)
            # Don't check whether the company has enough cash to pay for the tile
            # lay as this can be paid by the company president.
            action = get_tile_lay(entity)
            return false unless action

            action[:lay] || action[:upgrade]
          end

          def try_take_loan(corporation, cost)
            # 1858 does not have any loans, but this method gets called at the
            # start of Engine::Step::Tracker.pay_tile_cost! and so can be used
            # to catch when a public company does not have enough money to pay
            # its terrain or extra tile costs, and have the company's president
            # contribute money to pay for these.
            return unless corporation.corporation?
            return unless cost.positive?
            return unless cost > corporation.cash

            president = corporation.owner
            shortfall = cost - corporation.cash
            if shortfall > corporation.owner.cash
              raise GameError, "The tile lay costs #{@game.format_currency(cost)} but " \
                               "#{corporation.name} has #{@game.format_currency(corporation.cash)} and " \
                               "#{president.name} has #{@game.format_currency(president.cash)}"
            end
            @game.log << "#{president.name} contributes #{@game.format_currency(shortfall)} " \
                         "towards the cost of #{corporation.name}'s tile lay"
            president.spend(shortfall, corporation)
          end

          def hex_neighbors(entity, hex)
            hexes_broad = @game.graph_broad.connected_hexes(entity)[hex]
            hexes_metre = @game.graph_metre.connected_hexes(entity)[hex]
            hexes = [hexes_broad, hexes_metre].compact.inject([], :|)
            hexes if hexes.any?
          end
        end
      end
    end
  end
end
