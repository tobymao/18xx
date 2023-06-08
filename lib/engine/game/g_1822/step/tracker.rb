# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G1822
      module Tracker
        include Engine::Step::Tracker

        def can_lay_tile?(entity)
          # Special case for minor 14, the first OR its hometoken placement counts as tile lay
          return false if entity.corporation? && @game.home_token_counts_as_tile_lay?(entity) && !entity.operated?

          super
        end

        def check_track_restrictions!(entity, old_tile, new_tile)
          return if @game.loading || !entity.operator?
          return if new_tile.hex.name == @game.class::ENGLISH_CHANNEL_HEX
          return if new_tile.hex.name == @game.class::CARDIFF_HEX

          super
        end

        def get_tile_lay_corporation(entity)
          return entity if entity.id == @game.class::COMPANY_HSBC

          super
        end

        def legal_tile_rotation?(entity_or_entities, hex, tile)
          # entity_or_entities is an array when combining private company abilities
          entities = Array(entity_or_entities)
          entity, *_combo_entities = entities

          # We will remove a town from the white S tile, this meaning we will not follow the normal path upgrade rules
          if hex.name == @game.class::UPGRADABLE_S_HEX_NAME &&
            tile.name == @game.class::UPGRADABLE_S_YELLOW_CITY_TILE &&
            @game.class::UPGRADABLE_S_YELLOW_ROTATIONS.include?(tile.rotation)
            return true
          end

          operator = entity.company? ? entity.owner : entity
          super(operator, hex, tile)
        end

        def potential_tiles(entity_or_entities, hex)
          # entity_or_entities is an array when combining private company abilities
          entities = Array(entity_or_entities)
          entity, *_combo_entities = entities

          colors = if entity.corporation? && entity.type == :minor &&
            @game.phase.status.include?('minors_green_upgrade')
                     @game.class::MINOR_GREEN_UPGRADE
                   else
                     @game.phase.tiles
                   end
          @game.tiles
               .select { |tile| colors.include?(tile.color) }
               .uniq(&:name)
               .select { |t| @game.upgrades_to?(hex.tile, t) }
               .reject(&:blocks_lay)
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
            next 0 unless hex.targeting?(neighbor)

            tile.borders.delete(border)
            types << border.type
            cost - border_cost_discount(entity, spender, border, cost, hex)
          end

          # P10 Glasgow and South-Western Railway private removes the border
          # cost of one estuary crossing
          if entities.any? { |e| e.id == @game.class::COMPANY_GSWR }
            raise GameError, 'Must lay tile with one path over an estuary crossing' if total_cost.zero?

            total_cost -= @game.class::COMPANY_GSWR_DISCOUNT
          end

          # P21 Humber Suspension Bridge Company private must point into a estuary crossing
          if entity.id == @game.class::COMPANY_HSBC && total_cost.zero?
            raise GameError, 'Must lay tile with one path over the Hull / Grimsby estuary'
          end

          [total_cost, types]
        end

        def upgraded_track?(from, _to, _hex)
          from.color != :white
        end
      end
    end
  end
end
