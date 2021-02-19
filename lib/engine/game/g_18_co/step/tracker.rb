# frozen_string_literal: true

module Engine
  module Game
    module G18CO
      module Tracker
        # Remove the upgrade icon when the town is converted to a city
        def clear_upgrade_icon(tile)
          return if tile.cities.empty?
          return if tile.icons.empty? { |icon| icon.name == 'upgrade' }

          tile.icons.reject! { |icon| icon.name == 'upgrade' }
        end

        def collect_mines(corporation, hex)
          # Mine Token Collection
          return unless hex.tile.icons.any? { |icon| icon.name == 'mine' }

          # Remove mine symbol from hex
          hex.tile.icons.reject! { |icon| icon.name == 'mine' }

          # Add mine to corporation data
          @game.mine_add(corporation)

          @log << "#{corporation.name} collects a mine token from #{hex.name}"
        end

        def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
          entity ||= action.entity
          @previous_connections = prior_connected_paths(entity, action.hex.tile)

          super

          @previous_connections = []
        end

        def check_track_restrictions!(entity, old_tile, new_tile)
          return if @game.loading || !entity.operator?
          return true if pending_token(entity)

          super(entity, old_tile, new_tile)

          return if new_tile.color == :yellow # not an upgrade
          return if old_tile.city_towns.any? # not plain track
          return if new_tile.color == :green && new_tile.exits.size == 4 # no new junctions, cheap short circuit

          brand_new_exit_junctions = new_exit_junctions(old_tile, new_tile)
          return if brand_new_exit_junctions.empty?
          return if all_prior_paths_accessible?(old_tile.paths, @previous_connections)

          raise GameError, 'Must have route to access existing track' if @previous_connections.empty?

          return if accessible_new_path_creates_new_exit?(brand_new_exit_junctions)
          return if all_new_paths_have_new_exits?(brand_new_exit_junctions)

          raise GameError, 'Must have route to access both ends of at least one path of new track'
        end

        def new_exit_junctions(old_tile, new_tile)
          brand_new_paths = new_tile.paths.reject { |path| old_tile.paths.find { |p| path <= p } }

          brand_new_paths.map do |bnp|
            new_exit_junctions = bnp.exits & old_tile.exits
            next if new_exit_junctions.empty?

            [bnp, new_exit_junctions]
          end.compact
        end

        def prior_connected_paths(entity, old_tile)
          return [] if @game.loading

          @game.graph.connected_paths(entity).map do |connected_path, _b|
            next unless connected_path.hex == old_tile.hex

            old_tile.paths.find { |op| op <= connected_path }
          end.compact
        end

        def all_prior_paths_accessible?(old_paths, old_connected_paths)
          old_connected_paths.size == old_paths.size
        end

        def accessible_new_path_creates_new_exit?(brand_new_exit_junctions)
          brand_new_exit_junctions.flat_map { |_bnp, new_exit_junctions| new_exit_junctions }.one?
        end

        def all_new_paths_have_new_exits?(brand_new_exit_junctions)
          brand_new_exit_junctions.size >=
            brand_new_exit_junctions.sum { |_bnp, new_exit_junctions| new_exit_junctions.size }
        end

        def pending_token(entity)
          @round.pending_tokens.find { |pt| pt[:entity] == entity }
        end

        def migrate_reservations(tile)
          return unless @game.phase.status.include?('closable_corporations')
          return unless tile.cities.one?

          tile.reservations.dup.each do |corp|
            city = tile.cities.first
            slot = city.get_slot(corp)

            break unless slot

            tile.reservations.delete(corp)
            city.add_reservation!(corp, slot)
          end
        end
      end
    end
  end
end
