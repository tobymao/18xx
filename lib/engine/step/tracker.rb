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

        (entity.cash >= action[:cost]) && (action[:lay] || action[:upgrade])
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
        raise GameError, 'Cannot lay an upgrade now' if tile.color != :yellow && !tile_lay[:upgrade]
        raise GameError, 'Cannot lay an yellow now' if tile.color == :yellow && !tile_lay[:lay]

        lay_tile(action, tile_lay[:cost])
        @upgraded = true if action.tile.color != :yellow
        @laid_track += 1
      end

      def lay_tile(action, extra_cost = 0)
        entity = action.entity
        tile = action.tile
        hex = action.hex
        rotation = action.rotation
        old_tile = hex.tile

        @game.companies.each do |company|
          next if company.closed?
          next unless (ability = company.abilities(:blocks_hexes))

          raise GameError, "#{hex.id} is blocked by #{company.name}" if ability.hexes.include?(hex.id)
        end

        tile.rotate!(rotation)

        raise GameError, "#{old_tile.name} is not upgradeable to #{tile.name}"\
          unless old_tile.upgrades_to?(tile, entity.company?)

        @game.tiles.delete(tile)
        @game.tiles << old_tile unless old_tile.preprinted

        hex.lay(tile)

        @game.graph.clear
        check_track_restrictions!(entity, old_tile, tile) unless @game.loading
        free = false

        entity.abilities(:tile_lay) do |ability|
          next if !ability.hexes.include?(hex.id) || !ability.tiles.include?(tile.name)

          free = ability.free
        end

        entity.abilities(:teleport) do |ability, _|
          ability.use! if ability.hexes.include?(hex.id) && ability.tiles.include?(tile.name)
        end

        terrain = old_tile.terrain
        cost =
          if free
            0
          else
            border, border_types = border_cost(tile, entity)
            terrain += border_types if border.positive?
            @game.tile_cost(old_tile, entity) + border + extra_cost
          end

        entity.spend(cost, @game.bank) if cost.positive?

        cities = tile.cities
        if old_tile.paths.empty? &&
             tile.paths.any? &&
             cities.size > 1 &&
             cities.flat_map(&:tokens).any?
          token = cities.flat_map(&:tokens).find(&:itself)
          @round.pending_tokens << {
            entity: entity,
            hex: action.hex,
            token: token,
          }

          token.remove!
        end
        @log << "#{action.entity.name}"\
          "#{cost.zero? ? '' : " spends #{@game.format_currency(cost)} and"}"\
          " lays tile ##{tile.name}"\
          " with rotation #{rotation} on #{hex.name}"

        return unless terrain.any?

        @game.all_companies_with_ability(:tile_income) do |company, ability|
          if terrain.include?(ability.terrain)
            # If multiple borders are connected bonus counts each individually
            income = ability.income * terrain.find_all { |t| t == ability.terrain }.size
            @game.bank.spend(income, company.owner)
            @log << "#{company.owner.name} earns #{@game.format_currency(income)}"\
              " for #{ability.terrain} tile with #{company.name}"
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
        old_paths = old_tile.paths
        changed_city = false
        used_new_track = old_paths.empty?

        new_tile.paths.each do |np|
          next unless @game.graph.connected_paths(entity)[np]

          op = old_paths.find { |path| path <= np }
          used_new_track = true unless op
          changed_city = true if op&.node && op.node.max_revenue != np.node.max_revenue
        end

        case @game.class::TRACK_RESTRICTION
        when :permissive
          true
        when :restrictive
          raise GameError, 'Must use new track' unless used_new_track
        when :semi_restrictive
          raise GameError, 'Must use new track or change city value' if !used_new_track && !changed_city
        else
          raise
        end
      end

      def potential_tiles(hex)
        colors = @game.phase.tiles
        @game.tiles
          .select { |tile| colors.include?(tile.color) }
          .uniq(&:name)
          .select { |t| hex.tile.upgrades_to?(t) }
          .reject(&:blocks_lay)
      end

      def upgradeable_tiles(entity, hex)
        potential_tiles(hex).map do |tile|
          tile.rotate!(0) # reset tile to no rotation since calculations are absolute
          tile.legal_rotations = legal_tile_rotations(entity, hex, tile)
          next if tile.legal_rotations.empty?

          tile.rotate! # rotate it to the first legal rotation
          tile
        end.compact
      end

      def legal_tile_rotations(_entity, hex, tile)
        old_paths = hex.tile.paths

        Engine::Tile::ALL_EDGES.select do |rotation|
          tile.rotate!(rotation)
          new_paths = tile.paths
          new_exits = tile.exits

          new_exits.all? { |edge| hex.neighbors[edge] } &&
            (new_exits & available_hex(hex)).any? &&
            old_paths.all? { |path| new_paths.any? { |p| path <= p } }
        end
      end
    end
  end
end
