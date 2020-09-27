# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    module Tracker
      def setup
        @upgraded = false
        @laid_track = 0
      end

      def can_lay_tile?(entity)
        action = get_tile_lay(entity)
        return false unless action

        entity.tokens.any? && (@game.buying_power(entity) >= action[:cost]) && (action[:lay] || action[:upgrade])
      end

      def get_tile_lay(entity)
        action = @game.tile_lays(entity)[@laid_track]&.clone
        return unless action

        action[:lay] = !@upgraded if action[:lay] == :not_if_upgraded
        action[:upgrade] = !@upgraded if action[:upgrade] == :not_if_upgraded
        action[:cost] = action[:cost] || 0
        action
      end

      def lay_tile_action(action)
        tile = action.tile
        tile_lay = get_tile_lay(action.entity)
        @game.game_error('Cannot lay an upgrade now') if tile.color != :yellow && !tile_lay[:upgrade]
        @game.game_error('Cannot lay an yellow now') if tile.color == :yellow && !tile_lay[:lay]

        lay_tile(action, extra_cost: tile_lay[:cost])
        @upgraded = true if action.tile.color != :yellow
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

        @game.game_error("#{old_tile.name} is not upgradeable to #{tile.name}")\
          unless @game.upgrades_to?(old_tile, tile, entity.company?)
        if !@game.loading && !legal_tile_rotation?(entity, hex, tile)
          @game.game_error("#{old_tile.name} is not legally rotated for #{tile.name}")
        end

        @game.tiles.delete(tile)
        @game.tiles << old_tile unless old_tile.preprinted

        hex.lay(tile)

        @game.graph.clear
        check_track_restrictions!(entity, old_tile, tile)
        free = false
        discount = 0

        entity.abilities(:tile_lay) do |ability|
          next if ability.hexes.any? && (!ability.hexes.include?(hex.id) || !ability.tiles.include?(tile.name))

          @game.game_error("Track laid must be connected to one of #{spender.id}'s stations") if ability.reachable &&
            hex.name != spender.coordinates &&
            !@game.loading &&
            !@game.graph.reachable_hexes(spender)[hex]

          free = ability.free
          discount = ability.discount
        end

        entity.abilities(:teleport) do |ability, _|
          ability.use! if ability.hexes.include?(hex.id) && ability.tiles.include?(tile.name)
        end

        terrain = old_tile.terrain
        cost =
          if free
            extra_cost
          else
            border, border_types = border_cost(tile, entity)
            terrain += border_types if border.positive?
            @game.tile_cost(old_tile, entity) + border + extra_cost - discount
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
          if terrain.include?(ability.terrain) && (!ability.owner_only || company.owner == action.entity)
            # If multiple borders are connected bonus counts each individually
            income = ability.income * terrain.find_all { |t| t == ability.terrain }.size
            @game.bank.spend(income, company.owner)
            @log << "#{company.owner.name} earns #{@game.format_currency(income)}"\
              " for the #{ability.terrain} tile built by #{company.name}"
          end
        end
      end

      def border_cost(tile, entity)
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

          ability = entity.all_abilities.find do |a|
            (a.type == :tile_discount) && (border.type == a.terrain)
          end
          discount = ability&.discount || 0

          if discount.positive?
            @log << "#{entity.name} receives a discount of "\
            "#{@game.format_currency(discount)} from "\
            "#{ability.owner.name}"
          end

          cost - discount
        end
        [total_cost, types]
      end

      def check_track_restrictions!(entity, old_tile, new_tile)
        return if @game.loading || !entity.operator?

        old_paths = old_tile.paths
        changed_city = false
        used_new_track = old_paths.empty?

        new_tile.paths.each do |np|
          next unless @game.graph.connected_paths(entity)[np]

          op = old_paths.find { |path| path <= np }
          used_new_track = true unless op
          old_revenues = op&.nodes && op.nodes.map(&:max_revenue).sort
          new_revenues = np&.nodes && np.nodes.map(&:max_revenue).sort
          changed_city = old_revenues != new_revenues
        end

        case @game.class::TRACK_RESTRICTION
        when :permissive
          true
        when :restrictive
          @game.game_error('Must use new track') unless used_new_track
        when :semi_restrictive
          @game.game_error('Must use new track or change city value') if !used_new_track && !changed_city
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
        old_paths = hex.tile.paths
        old_ctedges = hex.tile.city_town_edges

        new_paths = tile.paths
        new_exits = tile.exits
        new_ctedges = tile.city_town_edges
        extra_cities = [0, new_ctedges.size - old_ctedges.size].max

        new_exits.all? { |edge| hex.neighbors[edge] } &&
          (new_exits & available_hex(entity, hex)).any? &&
          old_paths.all? { |path| new_paths.any? { |p| path <= p } } &&
          # Count how many cities on the new tile that aren't included by any of the old tile.
          # Make sure this isn't more than the number of new cities added.
          # 1836jr30 D6 -> 54 adds more cities
          extra_cities >= new_ctedges.count { |newct| old_ctedges.all? { |oldct| (newct & oldct).none? } }
      end

      def legal_tile_rotations(entity, hex, tile)
        Engine::Tile::ALL_EDGES.select do |rotation|
          tile.rotate!(rotation)
          legal_tile_rotation?(entity, hex, tile)
        end
      end
    end
  end
end
