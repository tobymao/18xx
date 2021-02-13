# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    module Tracker
      def round_state
        {
          num_laid_track: 0,
          upgraded_track: false,
          laid_hexes: [],
        }
      end

      def setup
        @round.num_laid_track = 0
        @round.upgraded_track = false
        @round.laid_hexes = []
      end

      def can_lay_tile?(entity)
        return true if abilities(entity, time: type, passive_ok: false)

        action = get_tile_lay(entity)
        return false unless action

        !entity.tokens.empty? && (buying_power(entity) >= action[:cost]) && (action[:lay] || action[:upgrade])
      end

      def get_tile_lay(entity)
        action = @game.tile_lays(entity)[@round.num_laid_track]&.clone
        return unless action

        action[:lay] = !@round.upgraded_track if action[:lay] == :not_if_upgraded
        action[:upgrade] = !@round.upgraded_track if action[:upgrade] == :not_if_upgraded
        action[:cost] = action[:cost] || 0
        action[:cannot_reuse_same_hex] = action[:cannot_reuse_same_hex] || false
        action
      end

      def lay_tile_action(action, entity: nil, spender: nil)
        tile = action.tile
        tile_lay = get_tile_lay(action.entity)
        raise GameError, 'Cannot lay an upgrade now' if tile.color != :yellow && !(tile_lay && tile_lay[:upgrade])
        raise GameError, 'Cannot lay a yellow now' if tile.color == :yellow && !(tile_lay && tile_lay[:lay])
        if tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(action.hex)
          raise GameError, "#{action.hex.id} cannot be layed as this hex was already layed on this turn"
        end

        lay_tile(action, extra_cost: tile_lay[:cost], entity: entity, spender: spender)
        @round.upgraded_track = true if action.tile.color != :yellow
        @round.num_laid_track += 1
        @round.laid_hexes << action.hex
      end

      def abilities(entity, **kwargs, &block)
        kwargs[:time] = [type, 'owning_corp_or_turn'] unless kwargs[:time]
        @game.abilities(entity, :tile_lay, **kwargs, &block)
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
          next unless (ability = @game.abilities(company, :blocks_hexes))

          if @game.hex_blocked_by_ability?(entity, ability, hex)
            raise GameError, "#{hex.id} is blocked by #{company.name}"
          end
        end

        tile.rotate!(rotation)

        unless @game.upgrades_to?(old_tile, tile, entity.company?)
          raise GameError, "#{old_tile.name} is not upgradeable to #{tile.name}"
        end
        if !@game.loading && !legal_tile_rotation?(entity, hex, tile)
          raise GameError, "#{old_tile.name} is not legally rotated for #{tile.name}"
        end

        update_tile_lists(tile, old_tile)

        hex.lay(tile)

        @game.graph.clear
        free = false
        discount = 0
        teleport = false

        abilities(entity) do |ability|
          next if ability.owner != entity
          next if !ability.hexes.empty? && (!ability.hexes.include?(hex.id) || !ability.tiles.include?(tile.name))

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
              !@game.graph.reachable_hexes(spender)[hex]

            free = ability.free
            discount = ability.discount
            extra_cost += ability.cost
          end
        end

        check_track_restrictions!(entity, old_tile, tile) unless teleport

        terrain = old_tile.terrain
        cost =
          if free
            # call for the side effect of deleting a completed border cost
            remove_border_calculate_cost!(tile, entity)

            extra_cost
          else
            border, border_types = remove_border_calculate_cost!(tile, entity)
            terrain += border_types if border.positive?
            base_cost = @game.upgrade_cost(old_tile, hex, entity) + border + extra_cost - discount
            @game.tile_cost_with_discount(tile, hex, entity, base_cost)
          end

        pay_tile_cost!(entity, tile, rotation, hex, spender, cost, extra_cost)

        update_token!(action, entity, tile, old_tile)

        return if terrain.empty?

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

      def update_tile_lists(tile, old_tile)
        @game.add_extra_tile(tile) if tile.unlimited

        @game.tiles.delete(tile)
        @game.tiles << old_tile unless old_tile.preprinted
      end

      def pay_tile_cost!(entity, tile, rotation, hex, spender, cost, _extra_cost)
        try_take_loan(spender, cost)
        spender.spend(cost, @game.bank) if cost.positive?

        @log << "#{spender.name}"\
          "#{spender == entity ? '' : " (#{entity.sym})"}"\
          "#{cost.zero? ? '' : " spends #{@game.format_currency(cost)} and"}"\
          " lays tile ##{tile.name}"\
          " with rotation #{rotation} on #{hex.name}"\
          "#{tile.location_name.to_s.empty? ? '' : " (#{tile.location_name})"}"
      end

      def update_token!(action, _entity, tile, old_tile)
        cities = tile.cities
        if old_tile.paths.empty? &&
            !tile.paths.empty? &&
            cities.size > 1 &&
            (token = cities.flat_map(&:tokens).find(&:itself))
          corporation = token.corporation
          @round.pending_tokens << {
            entity: corporation,
            hexes: [action.hex],
            token: token,
          }
          @log << "#{corporation.name} must choose city for token"

          token.remove!
        end
      end

      def remove_border_calculate_cost!(tile, entity)
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

          cost - border_cost_discount(entity, border, hex)
        end
        [total_cost, types]
      end

      def border_cost_discount(entity, border, hex)
        ability = entity.all_abilities.find do |a|
          (a.type == :tile_discount) &&
            a.terrain &&
            (border.type == a.terrain) &&
            (!a.hexes || a.hexes.include?(hex.name))
        end
        discount = ability&.discount || 0

        @log << "#{entity.name} receives a discount of #{@game.format_currency(discount)} from "\
          "#{ability.owner.name}" if discount.positive?

        discount
      end

      def check_track_restrictions!(entity, old_tile, new_tile)
        return if @game.loading || !entity.operator?

        old_paths = old_tile.paths
        changed_city = false
        used_new_track = old_paths.empty?

        new_tile.paths.each do |np|
          next unless @game.graph.connected_paths(entity)[np]

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
        else
          raise
        end
      end

      def potential_tiles(_entity, hex)
        colors = @game.phase.tiles
        @game.tiles
          .select { |tile| colors.include?(tile.color) }
          .uniq(&:name)
          .select { |t| @game.upgrades_to?(hex.tile, t) }
          .reject(&:blocks_lay)
      end

      def upgradeable_tiles(entity, hex)
        potential_tiles(entity, hex).map do |tile|
          tile.rotate!(0) # reset tile to no rotation since calculations are absolute
          tile.legal_rotations = legal_tile_rotations(entity, hex, tile)
          next if tile.legal_rotations.empty?

          tile.rotate! # rotate it to the first legal rotation
          tile
        end.compact
      end

      def legal_tile_rotation?(entity, hex, tile)
        return false unless @game.legal_tile_rotation?(entity, hex, tile)

        old_paths = hex.tile.paths
        old_ctedges = hex.tile.city_town_edges

        new_paths = tile.paths
        new_exits = tile.exits
        new_ctedges = tile.city_town_edges
        extra_cities = [0, new_ctedges.size - old_ctedges.size].max
        multi_city_upgrade = new_ctedges.size > 1 && old_ctedges.size > 1

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
        @game.graph.connected_hexes(entity)[hex]
      end
    end
  end
end
