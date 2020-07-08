# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Track < Base
      ACTIONS = %w[lay_tile pass].freeze

      def actions(entity)
        entity == current_entity ? ACTIONS : []
      end

      def sequential?
        true
      end

      def process_lay_tile(action)
        #   previous_tile = action.hex.tile

        #   hex_id = action.hex.id

        #   # companies with block_hexes should block hexes
        #   @game.companies.each do |company|
        #     next if company.closed?
        #     next unless (ability = company.abilities(:blocks_hexes))

        #     raise GameError, "#{hex_id} is blocked by #{company.name}" if ability.hexes.include?(hex_id)
        #   end

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

        tile.rotate!(rotation)

        raise GameError, "#{old_tile.name} is not upgradeable to #{tile.name}" unless old_tile.upgrades_to?(tile)

        @game.tiles.delete(tile)
        @game.tiles << old_tile unless old_tile.preprinted

        hex.lay(tile)

        @game.graph.clear
        check_track_restrictions!(old_tile, tile) unless @game.loading

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
            tile_cost(old_tile, entity.all_abilities) + border
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

          cost
        end
        [total_cost, types]
      end

      def tile_cost(tile, abilities)
        tile.upgrade_cost(abilities)
      end
    end
  end
end
