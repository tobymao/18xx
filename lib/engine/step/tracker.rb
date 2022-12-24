# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    module Tracker
      def round_state
        {
          num_laid_track: 0,
          upgraded_track: false,
          num_upgraded_track: 0,
          laid_hexes: [],
        }
      end

      def setup
        @round.num_laid_track = 0
        @round.num_upgraded_track = 0
        @round.upgraded_track = false
        @round.laid_hexes = []
      end

      def can_lay_tile?(entity)
        return true if tile_lay_abilities_should_block?(entity)
        return true if can_buy_tile_laying_company?(entity, time: type)

        action = get_tile_lay(entity)
        return false unless action

        !entity.tokens.empty? && (buying_power(entity) >= action[:cost]) && (action[:lay] || action[:upgrade])
      end

      def get_tile_lay(entity)
        corporation = get_tile_lay_corporation(entity)
        action = @game.tile_lays(corporation)[@round.num_laid_track]&.clone
        return unless action

        action[:lay] = !@round.upgraded_track if action[:lay] == :not_if_upgraded
        action[:upgrade] = !@round.upgraded_track if action[:upgrade] == :not_if_upgraded
        action[:cost] = action[:cost] || 0
        action[:upgrade_cost] = action[:upgrade_cost] || action[:cost]
        action[:cannot_reuse_same_hex] = action[:cannot_reuse_same_hex] || false
        action
      end

      def get_tile_lay_corporation(entity)
        entity.company? ? entity.owner : entity
      end

      def lay_tile_action(action, entity: nil, spender: nil)
        tile = action.tile

        old_tile = action.hex.tile
        tile_lay = get_tile_lay(action.entity)
        raise GameError, 'Cannot lay an upgrade now' if track_upgrade?(old_tile, tile,
                                                                       action.hex) && !(tile_lay && tile_lay[:upgrade])
        raise GameError, 'Cannot lay a yellow now' if tile.color == :yellow && !(tile_lay && tile_lay[:lay])
        if tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(action.hex)
          raise GameError, "#{action.hex.id} cannot be layed as this hex was already layed on this turn"
        end

        tile_lay_cost_override!(tile_lay, action, tile, old_tile)
        extra_cost = tile.color == :yellow ? tile_lay[:cost] : tile_lay[:upgrade_cost]

        lay_tile(action, extra_cost: extra_cost, entity: entity, spender: spender)
        if track_upgrade?(old_tile, tile, action.hex)
          @round.upgraded_track = true
          @round.num_upgraded_track += 1
        end
        @round.num_laid_track += 1
        @round.laid_hexes << action.hex
      end

      # This method can be implemented to adjust the cost of a tile lay
      def tile_lay_cost_override!(tile_lay, action, new_tile, old_tile); end

      def track_upgrade?(from, _to, _hex)
        from.color != :white
      end

      def tile_lay_abilities_should_block?(entity)
        Array(abilities(entity, time: type, passive_ok: false)).any? { |a| !a.consume_tile_lay }
      end

      def abilities(entity, **kwargs, &block)
        kwargs[:time] = [type] unless kwargs[:time]
        @game.abilities(entity, :tile_lay, **kwargs, &block)
      end

      def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
        entity ||= action.entity
        spender ||= entity
        tile = action.tile
        hex = action.hex
        rotation = action.rotation
        old_tile = hex.tile
        graph = @game.graph_for_entity(entity)

        if !@game.loading && (blocking_ability = ability_blocking_hex(entity, hex))
          raise GameError, "#{hex.id} is blocked by #{blocking_ability.owner.name}"
        end

        tile.rotate!(rotation)

        unless @game.upgrades_to?(old_tile, tile, entity.company?, selected_company: (entity.company? && entity) || nil)
          raise GameError, "#{old_tile.name} is not upgradeable to #{tile.name}"
        end
        if !@game.loading && !legal_tile_rotation?(entity, hex, tile)
          raise GameError, "#{old_tile.name} is not legally rotated for #{tile.name}"
        end

        update_tile_lists(tile, old_tile)

        hex.lay(tile)

        # Impassable hex is no longer impassible, update neighbors
        if @game.class::IMPASSABLE_HEX_COLORS.include?(old_tile.color)
          hex.all_neighbors.each do |direction, neighbor|
            next if hex.tile.borders.any? { |border| border.edge == direction && border.type == :impassable }
            next unless tile.exits.include?(direction)

            neighbor.neighbors[neighbor.neighbor_direction(hex)] = hex
            hex.neighbors[direction] = neighbor
          end
        end

        @game.clear_graph_for_entity(entity)
        free = false
        discount = 0
        teleport = false
        ability_found = false

        abilities(entity) do |ability|
          next if ability.owner != entity
          next if !ability.hexes.empty? && !ability.hexes.include?(hex.id)
          next if !ability.tiles.empty? && !ability.tiles.include?(tile.name)

          ability_found = true
          if ability.type == :teleport
            teleport = true
            free = true if ability.free_tile_lay
            if ability.cost&.positive?
              spender.spend(ability.cost, @game.bank)
              @log << "#{spender.name} (#{ability.owner.sym}) spends #{@game.format_currency(ability.cost)} "\
                      "and teleports to #{hex.name} (#{hex.location_name})"
            end
          else
            raise GameError, "Track laid must be connected to one of #{spender.id}'s stations" if ability.reachable &&
              hex.name != spender.coordinates &&
              !@game.loading &&
              !graph.reachable_hexes(spender)[hex]

            free = ability.free
            discount = ability.discount
            extra_cost += ability.cost
          end
        end

        if entity.company? && !ability_found
          raise GameError, "#{entity.name} does not have an ability that allows them to lay this tile"
        end

        check_track_restrictions!(entity, old_tile, tile) unless teleport

        terrain = old_tile.terrain
        cost =
          if free
            # call for the side effect of deleting a completed border cost
            remove_border_calculate_cost!(tile, entity, spender)

            extra_cost
          else
            border, border_types = remove_border_calculate_cost!(tile, entity, spender)
            terrain += border_types if border.positive?
            base_cost = @game.upgrade_cost(old_tile, hex, entity, spender) + border + extra_cost - discount
            @game.tile_cost_with_discount(tile, hex, entity, spender, base_cost)
          end

        pay_tile_cost!(entity, tile, rotation, hex, spender, cost, extra_cost)

        update_token!(action, entity, tile, old_tile)

        @game.all_companies_with_ability(:tile_income) do |company, ability|
          if !ability.terrain
            # company with tile income ability that pays for all tiles
            pay_all_tile_income(company, ability)
          else
            # company with tile income for specific terrain
            pay_terrain_tile_income(company, ability, terrain, entity, spender)
          end
        end
      end

      def pay_all_tile_income(company, ability)
        income = ability.income
        @game.bank.spend(income, company.owner)
        @log << "#{company.owner.name} earns #{@game.format_currency(income)}"\
                " for the tile built by #{company.name}"
      end

      def pay_terrain_tile_income(company, ability, terrain, entity, spender)
        return unless terrain.include?(ability.terrain)
        return if ability.owner_only && company.owner != entity && company.owner != spender

        # If multiple borders are connected bonus counts each individually
        income = ability.income * terrain.count { |t| t == ability.terrain }
        @game.bank.spend(income, company.owner)
        @log << "#{company.owner.name} earns #{@game.format_currency(income)}"\
                " for the #{ability.terrain} tile built by #{company.name}"
      end

      def update_tile_lists(tile, old_tile)
        @game.update_tile_lists(tile, old_tile)
      end

      def pay_tile_cost!(entity, tile, rotation, hex, spender, cost, _extra_cost)
        try_take_loan(spender, cost)
        spender.spend(cost, @game.bank) if cost.positive?

        @log << "#{spender.name}"\
                "#{spender == entity || !entity.company? ? '' : " (#{entity.sym})"}"\
                "#{cost.zero? ? '' : " spends #{@game.format_currency(cost)} and"}"\
                " lays tile ##{tile.name}"\
                " with rotation #{rotation} on #{hex.name}"\
                "#{tile.location_name.to_s.empty? ? '' : " (#{tile.location_name})"}"
      end

      def update_token!(action, entity, tile, old_tile)
        cities = tile.cities
        if old_tile.paths.empty? &&
            !tile.paths.empty? &&
            cities.size > 1 &&
            !(tokens = cities.flat_map(&:tokens).compact).empty?
          tokens.each do |token|
            actor = entity.company? ? entity.owner : entity
            @round.pending_tokens << {
              entity: actor,
              hexes: [action.hex],
              token: token,
            }
            @log << "#{actor.name} must choose city for token"

            token.remove!
          end
        end
      end

      def remove_border_calculate_cost!(tile, entity, spender)
        hex = tile.hex
        types = []

        total_cost = tile.borders.dup.sum do |border|
          next 0 unless (cost = border.cost)

          edge = border.edge
          neighbor = hex.neighbors[edge]
          next 0 if !hex.targeting?(neighbor) || !neighbor.targeting?(hex)

          types << border.type
          tile.borders.delete(border)
          neighbor.tile.borders.map! { |nb| nb.edge == hex.invert(edge) ? nil : nb }.compact!

          cost - border_cost_discount(entity, spender, border, cost, hex)
        end
        [total_cost, types]
      end

      def border_cost_discount(entity, spender, border, cost, hex)
        entity = entity.owner if !entity.corporation? && entity.owner&.corporation?
        entity.all_abilities.each do |a|
          next if (a.type != :tile_discount) ||
            !a.terrain ||
            (border.type != a.terrain) ||
            (a.hexes && !a.hexes.include?(hex.name))

          discount = [a.discount, cost].min
          if discount.positive?
            @log << "#{spender.name} receives a discount of #{@game.format_currency(discount)} from" \
                    " #{a.owner.name}"
          end
          return discount
        end

        0
      end

      def check_track_restrictions!(entity, old_tile, new_tile)
        return if @game.loading || !entity.operator?

        graph = @game.graph_for_entity(entity)

        raise GameError, 'New track must override old one' if !@game.class::ALLOW_REMOVING_TOWNS &&
            old_tile.city_towns.any? do |old_city|
              new_tile.city_towns.none? { |new_city| (old_city.exits - new_city.exits).empty? }
            end

        old_paths = old_tile.paths
        changed_city = false
        used_new_track = old_paths.empty?

        new_tile.paths.each do |np|
          next unless graph.connected_paths(entity)[np]

          op = old_paths.find { |path| np <= path }
          used_new_track = true unless op
          old_revenues = op&.nodes && op.nodes.map(&:max_revenue).sort
          new_revenues = np&.nodes && np.nodes.map(&:max_revenue).sort
          changed_city = true unless old_revenues == new_revenues
        end

        case @game.class::TRACK_RESTRICTION
        when :permissive
          true
        when :city_permissive
          raise GameError, 'Must be city tile or use new track' if new_tile.cities.none? && !used_new_track
        when :restrictive
          raise GameError, 'Must use new track' unless used_new_track
        when :semi_restrictive
          raise GameError, 'Must use new track or change city value' if !used_new_track && !changed_city
        when :station_restrictive
          raise GameError, 'Must use new track' if !used_new_track && new_tile.nodes.empty?
        else
          raise
        end
      end

      def potential_tile_colors(_entity, _hex)
        @game.phase.tiles.dup
      end

      def potential_tiles(entity, hex)
        colors = potential_tile_colors(entity, hex)
        @game.tiles
          .select { |tile| @game.tile_valid_for_phase?(tile, hex: hex, phase_color_cache: colors) }
          .uniq(&:name)
          .select { |t| @game.upgrades_to?(hex.tile, t) }
          .reject(&:blocks_lay)
      end

      def upgradeable_tiles(entity, ui_hex)
        hex = @game.hex_by_id(ui_hex.id) # hex instance from UI can go stale
        tiles = potential_tiles(entity, hex).map do |tile|
          tile.rotate!(0) # reset tile to no rotation since calculations are absolute
          tile.legal_rotations = legal_tile_rotations(entity, hex, tile)
          next if tile.legal_rotations.empty?

          tile.rotate! # rotate it to the first legal rotation
          tile
        end.compact

        if (!hex.tile.cities.empty? && @game.class::TILE_UPGRADES_MUST_USE_MAX_EXITS.include?(:cities)) ||
          (hex.tile.cities.empty? && @game.class::TILE_UPGRADES_MUST_USE_MAX_EXITS.include?(:track))
          tiles.group_by(&:color).flat_map do |_, group|
            max_edges = group.map { |t| t.edges.size }.max
            group.select { |t| t.edges.size == max_edges }
          end
        else
          tiles
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
        multi_city_upgrade = tile.cities.size > 1 && hex.tile.cities.size > 1

        new_exits.all? { |edge| hex.neighbors[edge] } &&
          !(new_exits & hex_neighbors(entity, hex)).empty? &&
          old_paths.all? { |path| new_paths.any? { |p| path <= p } } &&
          # Count how many cities on the new tile that aren't included by any of the old tile.
          # Make sure this isn't more than the number of new cities added.
          # 1836jr30 D6 -> 54 adds more cities
          extra_cities >= new_ctedges.count { |newct| old_ctedges.all? { |oldct| (newct & oldct).none? } } &&
          # 1867: Does every old city correspond to exactly one new city?
          (!multi_city_upgrade || old_ctedges.all? { |oldct| new_ctedges.one? { |newct| (oldct & newct) == oldct } })
      end

      def legal_tile_rotations(entity, hex, tile)
        Engine::Tile::ALL_EDGES.select do |rotation|
          tile.rotate!(rotation)
          legal_tile_rotation?(entity, hex, tile)
        end
      end

      def hex_neighbors(entity, hex)
        @game.graph_for_entity(entity).connected_hexes(entity)[hex]
      end

      def can_buy_tile_laying_company?(entity, time:)
        return false unless entity == current_entity
        return false unless @game.phase.status.include?('can_buy_companies')

        @game.purchasable_companies(entity).any? do |company|
          next false unless company.min_price <= buying_power(entity)

          company.all_abilities.any? { |a| a.type == :tile_lay && a.when?(time) }
        end
      end

      def ability_blocking_hex(entity, hex)
        (@game.companies + @game.minors + @game.corporations).each do |company|
          next if company.closed? || company == entity
          next unless (ability = @game.abilities(company, :blocks_hexes))

          return ability if @game.hex_blocked_by_ability?(entity, ability, hex)
        end

        nil
      end

      def tracker_available_hex(entity, hex)
        connected = hex_neighbors(entity, hex)
        return nil unless connected

        tile_lay = get_tile_lay(entity)
        return nil unless tile_lay

        color = hex.tile.color
        return nil if color == :white && !tile_lay[:lay]
        return nil if color != :white && !tile_lay[:upgrade]
        return nil if color != :white && tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(hex)
        return nil if ability_blocking_hex(entity, hex)

        connected
      end
    end
  end
end
