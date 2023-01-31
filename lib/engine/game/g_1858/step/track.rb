# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1858
      module Step
        class Track < Engine::Step::Track
          def actions(entity)
            return [] unless entity == current_entity
            return [] if !entity.minor? && !entity.corporation?
            return [] unless can_lay_tile?(entity)

            ACTIONS
          end

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

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            old_tile = action.hex.tile
            new_tile = action.tile
            @round.gauges_added << new_track_gauge(old_tile, new_tile)

            super
            new_tile.icons = old_tile.icons
          end

          def process_lay_tile(action)
            entity = action.entity
            spender = entity.minor? ? entity.owner : nil
            lay_tile_action(action, spender: spender)
            pass! unless can_lay_tile?(entity)
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

            # Check whether there are any hexes where track can be laid. After a
            # couple of operating rounds many of the private railway companies
            # will not be able to lay track, so this step (and so their entire
            # operating turn) can be skipped if it not possible to add track.
            hexes = (@game.graph_broad.connected_hexes(entity).keys +
                     @game.graph_metre.connected_hexes(entity).keys).uniq
            hexes.any? { |hex| available_hex(entity, hex) }
          end

          # If a public company does not have enough money to pay its terrain or
          # extra tile costs then transfer money from the company's president to
          # pay for these.
          def subsidise_track(corporation, cost)
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

          # Override the default implementation to give a better log message.
          # This also allows a more intuitive name to be used for the method for
          # the player contributing money for the tile, instead of abusing
          # try_take_loan.
          def pay_tile_cost!(entity, tile, rotation, hex, spender, cost, _extra_cost)
            subsidise_track(spender, cost)
            spender.spend(cost, @game.bank) if cost.positive?

            message = ''
            message += "#{spender.name} spends #{@game.format_currency(cost)} and " if cost.positive?
            message += "#{entity.name} " if cost.zero? || (entity != spender)
            message += "lays tile ##{tile.name}"
            message += " with rotation #{rotation} on #{hex.name}"
            message += " (#{tile.location_name})" unless tile.location_name.to_s.empty?
            @log << message
          end

          def hex_neighbors(entity, hex)
            hexes_broad = @game.graph_broad.connected_hexes(entity)[hex]
            hexes_metre = @game.graph_metre.connected_hexes(entity)[hex]
            hexes = [*hexes_broad, *hexes_metre].uniq
            hexes unless hexes.empty?
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            return if @game.loading || !entity.operator?

            raise GameError, 'New track must override old one' if !@game.class::ALLOW_REMOVING_TOWNS &&
                old_tile.city_towns.any? do |old_city|
                  new_tile.city_towns.none? { |new_city| (old_city.exits - new_city.exits).empty? }
                end

            # Need to check twice whether this tile is OK, once using routes along
            # broad/dual gauge track, and once allow metre/dual gauge.
            if !valid_tile_lay?(entity, old_tile, new_tile, @game.graph_broad) &&
                !valid_tile_lay?(entity, old_tile, new_tile, @game.graph_metre)
              raise GameError, 'Must have a broad gauge or metre gauge route ' \
                               'to new track, or upgrade a city'
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

          # Finds whether track lays in a hex are blocked by a private company.
          # Some hexes are blocked by two private companies. In this case either
          # one can lay track in the hex.
          def ability_blocking_hex(operator, hex)
            return false unless hex.tile.color == :white # Upgrades are never blocked.

            privates = (@game.companies + @game.minors).reject(&:closed?)
            blocking_abilities = privates.map do |entity|
              ability = @game.abilities(entity, :blocks_hexes)
              next unless ability

              ability if @game.hex_blocked_by_ability?(operator, ability, hex)
            end.compact
            return false if blocking_abilities.empty?

            # This hex is blocked by something. Check if this can be ignored.
            blocking_abilities.none? do |ability|
              blocker = ability.owner
              (operator == blocker) || (operator == blocker.owner)
            end
          end
        end
      end
    end
  end
end
