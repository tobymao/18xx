# frozen_string_literal: true

require_relative '../special_track'

module Engine
  module Step
    module G18CZ
      class SellCompanyAndSpecialTrack < SpecialTrack
        def actions(entity)
          actions = []
          abilities = tile_lay_abilities(entity)
          actions << 'lay_tile' if abilities
          actions << 'sell_company' if entity.company? && entity.owner == current_entity || entity == current_entity

          actions
        end

        def process_sell_company(action)
          corporation = action.entity
          company = action.company
          price = action.price

          @game.bank.spend(price, corporation)

          @log << "#{corporation.name} sells #{company.name} for #{@game.format_currency(price)} to the bank"

          company.close!

          @log << "#{company.name} closes"
        end

        def process_lay_tile(action)
          spender = if !action.entity.owner
                      nil
                    elsif action.entity.owner.corporation?
                      action.entity.owner
                    else
                      @game.current_entity
                    end
          lay_tile(action, spender: spender)

          @game.skip_default_track unless @game.purple_tile?(action.tile)

          abilities = @game.abilities(action.entity, :tile_lay, time: 'any')
          abilities.each(&:use!)
        end

        def hex_neighbors(entity, hex)
          return unless (abilities = tile_lay_abilities(entity))
          return if abilities.all? { |ability| !ability.hexes&.none? && !ability.hexes&.include?(hex.id) }

          operator = entity.owner.corporation? ? entity.owner : @game.current_entity
          return if abilities.all? { |ability| ability.reachable && !@game.graph.connected_hexes(operator)[hex] }

          @game.hex_by_id(hex.id).neighbors.keys
        end

        def potential_tiles(entity, hex)
          return [] unless (abilities = tile_lay_abilities(entity))

          abilities_for_hex = abilities.select do |ability|
            ability.hexes&.empty? || ability.hexes&.include?(hex.coordinates)
          end

          all_possible_tiles = abilities_for_hex.flat_map(&:tiles)

          all_possible_tiles.map { |name| @game.tiles.find { |t| t.name == name } }
            .compact
            .select { |t| @game.phase.tiles.include?(t.color) && @game.upgrades_to?(hex.tile, t, false) }
        end

        def tile_lay_abilities(entity, **kwargs, &block)
          abilities = super

          return nil if abilities.nil?
          return abilities if abilities.is_a?(Array)

          [abilities]
        end
      end
    end
  end
end
