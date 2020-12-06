# frozen_string_literal: true

require_relative '../tracker'

module Engine
  module Step
    module G1860
      module Tracker
        include Step::Tracker

        def setup
          @upgraded = false
          @laid_track = 0
          @laid_city = false
        end

        def get_tile_lay(entity)
          action = @game.tile_lays(entity)[@laid_track]&.clone
          return unless action

          action[:lay] = !@upgraded && !@laid_city if action[:lay] == :not_if_upgraded_or_city
          action[:upgrade] = !@upgraded if action[:upgrade] == :not_if_upgraded
          action[:cost] = action[:cost] || 0
          action
        end

        def lay_tile_action(action)
          tile = action.tile
          tile_lay = get_tile_lay(action.entity)
          @game.game_error('Cannot lay an upgrade now') if tile.color != :yellow && !tile_lay[:upgrade]
          @game.game_error('Cannot lay an yellow now') if tile.color == :yellow && !tile_lay[:lay]
          @game.game_error('Cannot lay a city tile now') if tile.cities.any? && @laid_track.positive?

          lay_tile(action, extra_cost: tile_lay[:cost])
          @upgraded = true if action.tile.color != :yellow
          @laid_city = true if action.tile.cities.any?
          @laid_track += 1
        end

        def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
          entity ||= action.entity
          spender ||= entity
          tile = action.tile
          hex = action.hex
          rotation = action.rotation
          old_tile = hex.tile

          @game.companies.each do |company|
            next if company.closed?
            next unless (ability = company.abilities(:blocks_hexes))

            @game.game_error("#{hex.id} is blocked by #{company.name}") if ability.hexes.include?(hex.id)
          end

          tile.rotate!(rotation)

          unless @game.upgrades_to?(old_tile, tile, entity.company?)
            @game.game_error("#{old_tile.name} is not upgradeable to #{tile.name}")
          end

          if !@game.loading && !legal_tile_rotation?(entity, hex, tile)
            @game.game_error("#{old_tile.name} is not legally rotated for #{tile.name}")
          end

          @game.add_extra_tile(tile) if tile.unlimited

          max_distance = @game.biggest_train(entity)
          old_revenues = if old_tile.color == :white
                           []
                         else
                           old_tile.nodes.select { |n| reachable_node?(entity, n, max_distance) }
                             .map(&:max_revenue).sort
                         end

          @game.tiles.delete(tile)
          @game.tiles << old_tile unless old_tile.preprinted

          hex.lay(tile)

          @game.graph.clear
          @game.clear_distances
          check_track_restrictions!(entity, old_tile, tile, old_revenues, max_distance)
          free = false
          discount = 0

          tile_lay_abilities(entity) do |ability|
            next if ability.hexes.any? && (!ability.hexes.include?(hex.id) || !ability.tiles.include?(tile.name))

            @game.game_error("Track laid must be connected to one of #{spender.id}'s stations") if ability.reachable &&
              hex.name != spender.coordinates &&
              !@game.loading &&
              !@game.graph.reachable_hexes(spender)[hex]

            free = ability.free
            discount = ability.discount
            extra_cost += ability.cost
          end

          entity.abilities(:teleport) do |ability, _|
            ability.use! if ability.hexes.include?(hex.id) && ability.tiles.include?(tile.name)
          end

          terrain = old_tile.terrain
          cost =
            if free
              # call for the side effect of deleting a completed border cost
              border_cost(tile, entity)

              extra_cost
            else
              border, border_types = border_cost(tile, entity)
              terrain += border_types if border.positive?
              @game.tile_cost(old_tile, hex, entity) + border + extra_cost - discount
            end

          if @game.insolvent?(spender) && cost.positive?
            @game.game_error("#{spender.id} cannot pay for a tile when insolvent")
          end

          spender.spend(cost, @game.bank) if cost.positive?

          cities = tile.cities
          if old_tile.paths.empty? &&
              tile.paths.any? &&
              cities.size > 1 &&
              cities.flat_map(&:tokens).any?
            token = cities.flat_map(&:tokens).find(&:itself)
            @round.pending_tokens << {
              entity: entity,
              hexes: [action.hex],
              token: token,
            }

            token.remove!
          end
          @log << "#{spender.name}"\
            "#{cost.zero? ? '' : " spends #{@game.format_currency(cost)} and"}"\
            " lays tile ##{tile.name}"\
            " with rotation #{rotation} on #{hex.name}"

          return unless terrain.any?

          @game.all_companies_with_ability(:tile_income) do |company, ability|
            if terrain.include?(ability.terrain) && (!ability.owner_only || company.owner == entity)
              # If multiple borders are connected bonus counts each individually
              income = ability.income * terrain.find_all { |t| t == ability.terrain }.size
              @game.bank.spend(income, company.owner)
              @log << "#{company.owner.name} earns #{@game.format_currency(income)}"\
                " for the #{ability.terrain} tile built by #{company.name}"
            end
          end
        end

        def check_track_restrictions!(entity, old_tile, new_tile, old_revenues, max_distance)
          return if @game.loading || !entity.operator?

          changed_city = false
          if old_tile.color != :white
            # add requirement that paths/nodes be reachable with train
            unless reachable_hex?(entity, new_tile.hex, max_distance)
              @game.game_error('Tile must be reachable with train')
            end
            new_revenues = new_tile.nodes.select { |n| reachable_node?(entity, n, max_distance) }
                             .map(&:max_revenue).sort
            changed_city = old_revenues != new_revenues
          end

          old_paths = old_tile.paths
          used_new_track = old_paths.empty?

          new_tile.paths.each do |np|
            next unless @game.graph.connected_paths(entity)[np]
            next if old_tile.color != :white && !reachable_path?(entity, np, max_distance)

            op = old_paths.find { |path| np <= path }
            used_new_track = true unless op

            next unless old_tile.color == :white

            old_revenues = op&.nodes && op.nodes.map(&:max_revenue).sort
            new_revenues = np&.nodes && np.nodes.map(&:max_revenue).sort
            changed_city = true unless old_revenues == new_revenues
          end

          case @game.class::TRACK_RESTRICTION
          when :permissive
            true
          when :city_permissive
            @game.game_error('Must be city tile or use new track') if new_tile.cities.none? && !used_new_track
          when :restrictive
            @game.game_error('Must use new track') unless used_new_track
          when :semi_restrictive
            @game.game_error('Must use new track or change city value') if !used_new_track && !changed_city
          else
            raise
          end
        end

        def legal_tile_rotation?(entity, hex, tile)
          return false unless @game.legal_tile_rotation?(entity, hex, tile)

          old_paths = hex.tile.paths
          old_ctedges = hex.tile.city_town_edges

          new_paths = tile.paths
          new_exits = tile.exits
          new_ctedges = tile.city_town_edges
          extra_cities = [0, new_ctedges.size - old_ctedges.size].max

          new_exits.all? { |edge| hex.neighbors[edge] } &&
            (new_exits & hex_neighbors(entity, hex)).any? &&
            old_paths.all? { |path| new_paths.any? { |p| path <= p } } &&
            # Count how many cities on the new tile that aren't included by any of the old tile.
            # Make sure this isn't more than the number of new cities added.
            # 1836jr30 D6 -> 54 adds more cities
            extra_cities >= new_ctedges.count { |newct| old_ctedges.all? { |oldct| (newct & oldct).none? } }
        end
      end
    end
  end
end
