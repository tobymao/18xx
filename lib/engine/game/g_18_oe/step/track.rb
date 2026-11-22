# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'skip_abbreviated_round'

module Engine
  module Game
    module G18OE
      module Step
        class Track < Engine::Step::Track
          include SkipAbbreviatedRound

          def setup
            super
            @points_used = 0
          end

          def potential_tile_colors(entity, hex)
            colors = super
            colors << :green if right_of_way?(entity, hex)
            colors
          end

          def legal_tile_rotation?(entity_or_entities, hex, tile)
            return false unless super
            return true if @game.phase.tiles.include?(tile.color)

            home_connectable?(Array(entity_or_entities).first, 0, hex => tile)
          end

          def home_connectable?(entity, points, laid = {})
            return false unless (home = entity.tokens.first&.city)

            cheapest = {}
            queue = home.exits.map { |exit| [home.hex, exit, 0] } + yellow_lay_ends(entity, home.hex, home.tile, 0, points)
            until queue.empty?
              hex, exit, cost = queue.shift
              next if cheapest[[hex.id, exit]] && cheapest[[hex.id, exit]] <= cost

              cheapest[[hex.id, exit]] = cost
              crossings(hex, exit).each do |neighbor, edge|
                tile = laid[neighbor] || neighbor.tile
                paths = tile.paths.select { |path| path.exits.include?(edge) }.flat_map { |path| path.junction&.paths || [path] }
                return true if paths.any? { |path| path.nodes.any? { |node| node != home } }

                lay_ends = yellow_lay_ends(entity, neighbor, tile, cost, points)
                return true if !lay_ends.empty? && !tile.city_towns.empty?

                queue.concat(paths.flat_map(&:exits).map { |track_exit| [neighbor, track_exit, cost] }, lay_ends)
              end
            end
            false
          end

          def can_lay_tile?(entity)
            return true if @game.track_token_placeable?(entity)

            points_available = remaining_tile_points(entity)
            return false if !points_available.positive? && !@game.zero_point_tile_lays_available?(entity)

            !entity.tokens.empty? || @game.national?(entity)
          end

          def auto_actions(entity)
            return unless actions(entity).include?('lay_tile')
            return if remaining_tile_points(entity).positive?
            return if @game.track_token_placeable?(entity)

            hexes = @game.graph_for_entity(entity).connected_hexes(entity).keys
            return if hexes.any? { |hex| available_hex(entity, hex) }

            [Engine::Action::Pass.new(entity)]
          end

          def get_tile_lay(entity)
            @game.tile_point_budget(entity)
          end

          def description
            'Lay Track'
          end

          def help
            entity = current_entity
            tile_lay = remaining_tile_points(entity)
            text = "#{tile_lay} track points"
            abilities = @game.terrain_point_abilities(entity)
            return text if abilities.empty?

            points = abilities.keys.map { |color| "1 #{color}-terrain point" }.join(' + ')
            "#{text} + #{points} (yellow lays only)"
          end

          def lay_tile_action(action)
            tile = action.tile
            old_tile = action.hex.tile
            points_available = remaining_tile_points(action.entity)
            right_of_way = !@game.phase.tiles.include?(tile.color)
            raise GameError, 'Right-of-Way is not available' if right_of_way && !right_of_way?(action.entity, action.hex)

            points_cost = right_of_way ? points_available : @game.tile_point_cost(action.entity, old_tile: old_tile)
            raise GameError, 'Cannot lay an upgrade now' if tile.color != :yellow && points_cost > points_available
            raise GameError, 'Cannot lay a yellow now' if tile.color == :yellow && points_cost > points_available

            tile.rotate!(action.rotation)
            action.extra_cost = cross_water_fee(action) unless @game.loading
            lay_tile(action, extra_cost: action.extra_cost || 0)
            @game.after_lay_tile(action.entity, old_tile, tile)
            @game.fulfill_patronage!(action.entity, action.hex)
            if track_upgrade?(old_tile, tile, action.hex)
              @round.upgraded_track = true
              @round.num_upgraded_track += 1
            end
            @round.num_laid_track += 1
            @round.laid_hexes << action.hex
            @points_used += points_cost
          end

          def tracker_available_hex(entity, hex)
            return nil unless @game.hex_within_national_region?(entity, hex)

            connected = hex_neighbors(entity, hex)
            return nil unless connected

            return nil if hex.tile.color == :blue

            points_available = remaining_tile_points(entity)
            cost = @game.tile_point_cost(entity, old_tile: hex.tile)
            return nil if cost > points_available && !right_of_way?(entity, hex)

            connected
          end

          private

          def right_of_way?(entity, hex)
            points = remaining_tile_points(entity)
            @game.players.size > 2 &&
              !@game.phase.tiles.include?(:green) &&
              !entity.operated? &&
              hex.tile.color == :yellow &&
              hex.tile.cities.empty? &&
              points.positive? &&
              (@game.loading || !home_connectable?(entity, points))
          end

          def yellow_lay_ends(entity, hex, tile, cost, points)
            return [] if tile.color != :white || !@game.hex_within_national_region?(entity, hex)

            cost += @game.tile_point_cost(entity, old_tile: tile)
            return [] if cost > points
            return [] unless @game.tiles.any? { |yellow| yellow.color == :yellow && @game.upgrades_to?(tile, yellow) }

            (0..5).map { |exit| [hex, exit, cost] }
          end

          def crossings(hex, exit)
            ferries = @game.ferry_links(hex.id, exit).map { |(hex_id, edge), _distance| [@game.hex_by_id(hex_id), edge] }
            neighbor = hex.neighbors[exit]
            return ferries if !neighbor || @game.sea_exit?(hex.id, exit)

            ferries << [neighbor, Engine::Hex.invert(exit)]
          end

          def remaining_tile_points(entity)
            get_tile_lay(entity) - @points_used
          end

          def cross_water_fee(action)
            fee = @game.cross_water_tile_fee(action.entity, action.hex, action.tile)
            return fee if !action.extra_cost || action.extra_cost == fee

            raise GameError, "Cross-water fee is #{@game.format_currency(fee)}, not #{@game.format_currency(action.extra_cost)}"
          end
        end
      end
    end
  end
end
