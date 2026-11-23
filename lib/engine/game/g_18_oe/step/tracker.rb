# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G18OE
      module Tracker
        include Engine::Step::Tracker

        def round_state
          super.merge(tile_points_used: 0)
        end

        def setup
          super
          @round.tile_points_used = 0
        end

        def lay_tile_action(action, entity: nil, spender: nil)
          operator = spender || action.entity
          tile = action.tile
          old_tile = action.hex.tile
          points_cost = tile_points_cost(operator, action)
          points_available = remaining_tile_points(operator)
          raise GameError, 'Cannot lay an upgrade now' if tile.color != :yellow && points_cost > points_available
          raise GameError, 'Cannot lay a yellow now' if tile.color == :yellow && points_cost > points_available

          tile.rotate!(action.rotation)
          action.extra_cost = cross_water_fee(action, operator) unless @game.loading
          lay_tile(action, extra_cost: action.extra_cost || 0, entity: entity, spender: spender)
          @game.after_lay_tile(operator, old_tile, tile)
          @game.fulfill_patronage!(operator, action.hex)
          if track_upgrade?(old_tile, tile, action.hex)
            @round.upgraded_track = true
            @round.num_upgraded_track += 1
          end
          @round.num_laid_track += 1
          @round.laid_hexes << action.hex
          @round.tile_points_used += points_cost
        end

        def pay_tile_cost!(entity_or_entities, tile, rotation, hex, spender, cost, extra_cost)
          @game.check_reserved_train_funds!(spender, cost)
          super
        end

        def tile_points_cost(operator, action)
          @game.tile_point_cost(operator, old_tile: action.hex.tile)
        end

        def potential_tile_colors(entity, hex)
          entity = tile_lay_operator(entity)
          colors = super(entity, hex)
          colors << :green if right_of_way?(entity, hex)
          colors
        end

        def legal_tile_rotation?(entity_or_entities, hex, tile)
          entity_or_entities = tile_lay_operator(entity_or_entities)
          return false unless super(entity_or_entities, hex, tile)
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

        def get_tile_lay(entity)
          @game.tile_point_budget(entity)
        end

        def tracker_available_hex(entity, hex)
          return nil unless @game.hex_within_national_region?(entity, hex)
          return nil if @game.brandt_blocked?(entity, hex)

          connected = hex_neighbors(entity, hex)
          return nil unless connected

          return nil if hex.tile.color == :blue

          points_available = remaining_tile_points(entity)
          cost = @game.tile_point_cost(entity, old_tile: hex.tile)
          return nil if cost > points_available && !right_of_way?(entity, hex)

          connected
        end

        private

        def tile_lay_operator(entity_or_entities)
          entity = Array(entity_or_entities).first
          entity.company? ? @round.current_operator : entity_or_entities
        end

        def right_of_way?(entity, hex)
          points = remaining_tile_points(entity)
          !@game.aggressive_game? &&
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
          get_tile_lay(entity) - @round.tile_points_used
        end

        def cross_water_fee(action, entity = action.entity)
          fee = @game.cross_water_tile_fee(entity, action.hex, action.tile)
          return fee if !action.extra_cost || action.extra_cost == fee

          raise GameError, "Cross-water fee is #{@game.format_currency(fee)}, not #{@game.format_currency(action.extra_cost)}"
        end
      end
    end
  end
end
