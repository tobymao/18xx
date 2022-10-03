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

          def process_lay_tile(action)
            entity = action.entity
            spender = entity.minor? ? entity.owner : nil
            lay_tile_action(action, spender: spender)
            pass! unless can_lay_tile?(entity)
          end

          def tile_lay_cost_override!(tile_lay, action, new_tile, old_tile)
            return if tile_lay[:cost].zero? # first tile

            gauges_added = @round.gauges_added + [new_track_gauge(old_tile, new_tile)]
            return unless gauges_added.include?([:narrow])

            @log << "#{action.entity.name} receives a #{@game.format_currency(10)} " \
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

          def check_track_restrictions!(entity, old_tile, new_tile)
            return if @game.loading || !entity.operator?

            raise GameError, 'New track must override old one' if !@game.class::ALLOW_REMOVING_TOWNS &&
                old_tile.city_towns.any? do |old_city|
                  new_tile.city_towns.none? { |new_city| (old_city.exits - new_city.exits).empty? }
                end

            # Need to check twice whether this tile is OK, once using routes along
            # broad/dual gauge track, and once allow metre/dual gauge.
            # The check for private railways home hexes is needed in case a private
            # builds plain track that's not connected to a revenue centre, it will
            # not be classed as a connected path.
            unless valid_tile_lay?(entity, old_tile, new_tile, @game.graph_broad) ||
                   valid_tile_lay?(entity, old_tile, new_tile, @game.graph_metre) ||
                   (entity.minor? && entity.home_hex?(new_tile.hex))
              raise GameError, 'Must use new track or change city value'
            end
          end

          def valid_tile_lay?(entity, old_tile, new_tile, graph)
            return false unless graph.connected_hexes(entity).include?(new_tile.hex)

            old_paths = old_tile.paths
            changed_city = false
            used_new_track = false

            new_tile.paths.each do |np|
              next unless graph.connected_paths(entity)[np]

              op = old_paths.find { |path| np <= path }
              used_new_track = true unless op
              old_revenues = op&.nodes && op.nodes.map(&:max_revenue).sort
              new_revenues = np&.nodes && np.nodes.map(&:max_revenue).sort
              changed_city = true unless old_revenues == new_revenues
            end

            used_new_track || changed_city
          end
        end
      end
    end
  end
end
