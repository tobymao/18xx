# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Track < Base
      ACTIONS = %w[lay_tile pass].freeze

      def actions(entity)
        entity == current_entity ? ACTIONS : []
      end

      def description
        'Lay Track'
      end

      def pass_description
        'Skip (Track)'
      end

      def sequential?
        true
      end

      def process_lay_tile(action)
        #   previous_tile = action.hex.tile

        #   hex_id = action.hex.id

        #   # companies with block_hexes should block hexes


        #   lay_tile(action)
        #   @current_entity.abilities(:teleport) do |ability, _|
        #     @teleported = ability.hexes.include?(hex_id) &&
        #     ability.tiles.include?(action.tile.name)
        #   end

        #   new_tile = action.hex.tile
        #   cities = new_tile.cities
        #   if previous_tile.paths.empty? &&
        #     new_tile.paths.any? &&
        #     cities.size > 1 &&
        #     cities.flat_map(&:tokens).any?
        #     token = cities.flat_map(&:tokens).find(&:itself)
        #     @ambiguous_hex_token = [action.hex, token]
        #     token.remove!
        #   end
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

        raise GameError, "#{old_tile.name} is not upgradeable to #{tile.name}" unless old_tile.upgrades_to?(tile)

        @game.tiles.delete(tile)
        @game.tiles << old_tile unless old_tile.preprinted

        hex.lay(tile)

        check_track_restrictions!(entity, old_tile, tile) unless @game.loading
        @game.graph.clear
        free = false

        entity.abilities(:tile_lay) do |ability|
          next if !ability.hexes.include?(hex.id) || !ability.tiles.include?(tile.name)

          free = ability.free
        end

        terrain = old_tile.terrain
        cost =
          if free
            0
          else
            border, border_types = border_cost(tile)
            terrain += border_types if border.positive?
            tile_cost(old_tile, entity) + border
          end

        entity.spend(cost, @game.bank) if cost.positive?

        @log << "#{action.entity.name}"\
          "#{cost.zero? ? '' : " spends #{@game.format_currency(cost)} and"}"\
          " lays tile ##{tile.name}"\
          " with rotation #{rotation} on #{hex.name}"

        pass!
        return unless terrain.any?

        @game.all_companies_with_ability(:tile_income) do |company, ability|
          if terrain.include?(ability.terrain)
            # If multiple borders are connected bonus counts each individually
            income = ability.income * terrain.find_all { |t| t == ability.terrain }.size
            @bank.spend(income, company.owner)
            @log << "#{company.owner.name} earns #{@game.format_currency(income)}"\
              " for #{ability.terrain} tile with #{company.name}"
          end
        end
      end

      def border_cost(tile)
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

      def tile_cost(tile, entity)
        ability = entity.all_abilities.find { |a| a.type == :tile_discount }

        tile.upgrades.sum do |upgrade|
          discount = ability && upgrade.terrains.uniq == [ability.terrain] ? ability.discount : 0

          if discount.positive?
            @log << "#{entity.name} receives a discount of "\
                    "#{@game.format_currency(discount)} from "\
                    "#{ability.owner.name}"
          end

          total_cost = upgrade.cost - discount
          total_cost
        end
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

      def available_hex(hex)
        @game.graph.connected_hexes(current_entity)[hex]
      end
    end
  end
end
