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
        action = @game.tile_lays(corporation)[tile_lay_index]&.clone
        return unless action

        action[:lay] = !@round.upgraded_track if action[:lay] == :not_if_upgraded
        action[:upgrade] = !@round.upgraded_track if action[:upgrade] == :not_if_upgraded
        action[:cost] = action[:cost] || 0
        action[:upgrade_cost] = action[:upgrade_cost] || action[:cost]
        action[:cannot_reuse_same_hex] = action[:cannot_reuse_same_hex] || false
        action
      end

      def tile_lay_index
        @round.num_laid_track
      end

      def get_tile_lay_corporation(entity)
        entity.company? ? entity.owner : entity
      end

      def lay_tile_action(action, entity: nil, spender: nil)
        tile = action.tile
        hex = action.hex

        old_tile = action.hex.tile
        tile_lay = get_tile_lay(action.entity)
        raise GameError, 'Cannot lay an upgrade now' if track_upgrade?(old_tile, tile,
                                                                       action.hex) && !(tile_lay && tile_lay[:upgrade])
        raise GameError, 'Cannot lay a yellow now' if tile.color == :yellow && !(tile_lay && tile_lay[:lay])
        if tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(action.hex)
          raise GameError, "#{action.hex.id} cannot be laid as this hex was already laid on this turn"
        end

        extra_cost = extra_cost(tile, tile_lay, hex)

        lay_tile(action, extra_cost: extra_cost, entity: entity, spender: spender)
        if track_upgrade?(old_tile, tile, action.hex)
          @round.upgraded_track = true
          @round.num_upgraded_track += 1
        end
        @round.num_laid_track += 1
        @round.laid_hexes << action.hex
      end

      def extra_cost(tile, tile_lay, _hex)
        tile.color == :yellow ? tile_lay[:cost] : tile_lay[:upgrade_cost]
      end

      def track_upgrade?(from, _to, _hex)
        from.color != :white
      end

      def tile_lay_abilities_should_block?(entity)
        abilities = [type, 'owning_player_track'].flat_map do |time|
          Array(abilities(entity, time: time, passive_ok: false))
        end
        abilities.any? { |a| !a.consume_tile_lay }
      end

      def abilities(entity, **kwargs, &block)
        kwargs[:time] = [type] unless kwargs[:time]
        @game.abilities(entity, :tile_lay, **kwargs, &block)
      end

      def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
        entity ||= action.entity
        entities = [entity, *action.combo_entities]

        # games that support combining private company abilities will expect an
        # array of entities, all others a single entity
        entity_or_entities = action.combo_entities.empty? ? entity : entities

        spender ||= entity
        tile = action.tile
        hex = action.hex
        rotation = action.rotation
        old_tile = hex.tile
        graph = @game.graph_for_entity(spender)

        if !@game.loading && (blocking_ability = ability_blocking_hex(entity, hex))
          raise GameError, "#{hex.id} is blocked by #{blocking_ability.owner.name}"
        end

        tile.rotate!(rotation)

        unless @game.upgrades_to?(old_tile, tile, entity.company?, selected_company: (entity.company? && entity) || nil)
          raise GameError, "#{old_tile.name} is not upgradeable to #{tile.name}"
        end
        if !@game.loading && !legal_tile_rotation?(entity_or_entities, hex, tile)
          raise GameError, "#{old_tile.name} is not legally rotated for #{tile.name}"
        end

        update_tile_lists(tile, old_tile)

        hex.lay(tile)

        # Impassable hex is no longer impassable, update neighbors
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
        discount_abilities = []

        entities.each do |entity_|
          abilities(entity_) do |ability|
            next if ability.owner != entity_
            next if !ability.hexes.empty? && !ability.hexes.include?(hex.id)
            next if !ability.tiles.empty? && !ability.tiles.include?(tile.name)

            ability_found = true
            if ability.type == :teleport
              teleport ||= true
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

              free ||= ability.free
              discount += ability.discount
              discount_abilities << ability if discount&.positive?
              extra_cost += ability.cost
            end
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
            remove_border_calculate_cost!(tile, entity_or_entities, spender)

            extra_cost
          else
            border, border_types = remove_border_calculate_cost!(tile, entity_or_entities, spender)
            terrain += border_types if border.positive?

            base_cost = @game.upgrade_cost(old_tile, hex, entity, spender) + border + extra_cost

            unless discount_abilities.empty?
              discount = [base_cost, discount].min
              @game.log_cost_discount(spender, discount_abilities, discount)
            end

            @game.tile_cost_with_discount(tile, hex, entity, spender, base_cost - discount)
          end

        pay_tile_cost!(entity_or_entities, tile, rotation, hex, spender, cost, extra_cost)

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

      def pay_tile_cost!(entity_or_entities, tile, rotation, hex, spender, cost, _extra_cost)
        # entity_or_entities is an array when combining private company abilities
        entities = Array(entity_or_entities)
        entity, *_combo_entities = entities

        try_take_loan(spender, cost)
        spender.spend(cost, @game.bank) if cost.positive?

        @log << "#{spender.name}"\
                "#{spender == entity || !entity.company? ? '' : " (#{entities.map(&:sym).join('+')})"}"\
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
            actor = case @game.class::TOKEN_PLACEMENT_ON_TILE_LAY_ENTITY
                    when :current_operator
                      entity.company? ? entity.owner : entity
                    when :owner
                      token.corporation
                    end
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

      def remove_border_calculate_cost!(tile, entity_or_entities, spender)
        # entity_or_entities is an array when combining private company abilities
        entities = Array(entity_or_entities)
        entity, *_combo_entities = entities

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

      def potential_tiles(entity_or_entities, hex)
        # entity_or_entities is an array when combining private company abilities
        entities = Array(entity_or_entities)
        entity, *_combo_entities = entities

        colors = potential_tile_colors(entity, hex)
        @game.tiles
          .select { |tile| @game.tile_valid_for_phase?(tile, hex: hex, phase_color_cache: colors) }
          .uniq(&:name)
          .select { |t| @game.upgrades_to?(hex.tile, t) }
          .reject(&:blocks_lay)
      end

      def upgradeable_tiles(entity_or_entities, ui_hex)
        hex = @game.hex_by_id(ui_hex.id) # hex instance from UI can go stale
        tiles = potential_tiles(entity_or_entities, hex).map do |tile|
          tile.rotate!(0) # reset tile to no rotation since calculations are absolute
          tile.legal_rotations = legal_tile_rotations(entity_or_entities, hex, tile)
          next if tile.legal_rotations.empty?

          tile.rotate! # rotate it to the first legal rotation
          tile
        end.compact

        if (!hex.tile.cities.empty? && @game.class::TILE_UPGRADES_MUST_USE_MAX_EXITS.include?(:cities)) ||
           (!hex.tile.cities.empty? &&
            hex.tile.labels.empty? &&
            @game.class::TILE_UPGRADES_MUST_USE_MAX_EXITS.include?(:unlabeled_cities)) ||
           (hex.tile.cities.empty? && hex.tile.towns.empty? && @game.class::TILE_UPGRADES_MUST_USE_MAX_EXITS.include?(:track))
          max_exits(tiles)
        else
          tiles
        end
      end

      def max_exits(tiles)
        tiles.group_by(&:color).flat_map do |_, group|
          max_edges = group.map { |t| t.edges.size }.max
          group.select { |t| t.edges.size == max_edges }
        end
      end

      def legal_tile_rotation?(entity_or_entities, hex, tile)
        # entity_or_entities is an array when combining private company abilities
        entities = Array(entity_or_entities)
        entity, *_combo_entities = entities

        return false unless @game.legal_tile_rotation?(entity, hex, tile)

        old_ctedges = hex.tile.city_town_edges

        new_exits = tile.exits
        new_ctedges = tile.city_town_edges
        added_cities = [0, new_ctedges.size - old_ctedges.size].max
        multi_city_upgrade = tile.cities.size > 1 && hex.tile.cities.size > 1

        all_new_exits_valid = new_exits.all? { |edge| hex.neighbors[edge] }
        return false unless all_new_exits_valid

        neighbors = hex_neighbors(entity, hex) || []
        entity_reaches_a_new_exit = !(new_exits & neighbors).empty?
        return false unless entity_reaches_a_new_exit

        return false unless old_paths_maintained?(hex, tile)

        # Count how many cities on the new tile that aren't included by any of the old tile.
        # Make sure this isn't more than the number of new cities added.
        # 1836jr30 D6 -> 54 adds more cities
        valid_added_city_count = added_cities >= new_ctedges.count { |newct| old_ctedges.all? { |oldct| (newct & oldct).none? } }
        return false unless valid_added_city_count

        # 1867: Does every old city correspond to exactly one new city?
        old_cities_map_to_new =
          !multi_city_upgrade ||
          old_ctedges.all? { |oldct| new_ctedges.one? { |newct| (oldct & newct) == oldct } }
        return false unless old_cities_map_to_new

        return false unless city_sizes_maintained(hex, tile)

        true
      end

      def old_paths_maintained?(hex, tile)
        old_paths = hex.tile.paths
        new_paths = tile.paths
        old_paths.all? { |path| new_paths.any? { |p| path <= p } }
      end

      # 1822CA: some big cities have a mix of 2-slot and 1-slot cities; don't
      # reduce slots in a city
      def city_sizes_maintained(hex, tile)
        return true unless hex.tile.cities.map(&:normal_slots).uniq.size > 1

        hex.city_map_for(tile).all? { |old_c, new_c| new_c.normal_slots >= old_c.normal_slots }
      end

      def legal_tile_rotations(entity_or_entities, hex, tile)
        Engine::Tile::ALL_EDGES.select do |rotation|
          tile.rotate!(rotation)
          legal_tile_rotation?(entity_or_entities, hex, tile)
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
