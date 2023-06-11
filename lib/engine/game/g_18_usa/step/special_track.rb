# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'resource_track'

module Engine
  module Game
    module G18USA
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include ResourceTrack
          include P11Track

          def actions(entity)
            return [] if entity&.id == 'P16' && !@game.phase.tiles.include?(:brown)

            super
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            tile = action.tile
            hex = action.hex
            entity ||= action.entity

            check_rural_junction(tile, hex) if @game.class::RURAL_TILES.include?(tile.name)
            super
            process_company_town(tile) if @game.class::COMPANY_TOWN_TILES.include?(tile.name)
          end

          def check_rural_junction(_tile, hex)
            return unless hex.neighbors.values.any? { |h| @game.class::RURAL_TILES.include?(h.tile.name) }

            raise GameError, 'Cannot place rural junctions adjacent to each other'
          end

          def potential_tile_colors(entity, _hex)
            colors = super
            colors << :green if %w[P9 S8].include?(entity.id)
            colors << :gray if %w[P16 P27].include?(entity.id)
            colors
          end

          def available_hex(entity, hex)
            return false unless super
            return p9_available_hex(entity, hex) if entity.id == 'P9'
            return p16_available_hex(entity, hex) if entity.id == 'P16'
            return p26_available_hex(entity, hex) if entity.id == 'P26'
            return p27_available_hex(entity, hex) if entity.id == 'P27'

            true
          end

          def p9_available_hex(_entity, hex)
            @game.plain_yellow_city_tiles.find { |t| t.name == hex.tile.name }
          end

          def p16_available_hex(_entity, hex)
            %i[green brown].include?(hex.tile.color) && !@game.active_metropolis_hexes.include?(hex)
          end

          def p26_available_hex(entity, hex)
            hex.tile.color == :white && @game.home_hex_for(entity.owner) != hex
          end

          def p27_available_hex(_entity, hex)
            hex.tile.color == :white &&
              (hex.tile.cities.empty? || hex.tile.cities.none?(&:tokened?)) &&
              (hex.neighbors.values & @game.active_metropolis_hexes).empty?
          end

          def legal_tile_rotation?(entity, hex, tile)
            return true if tile.name == 'X23'

            super
          end

          def process_company_town(tile)
            corporation = @game.company_by_id('P27').owner
            if corporation.tokens.size < 8
              @game.log << "#{corporation.name} gets a free token to place on the Company Town"
              bonus_token = Engine::Token.new(corporation)
              corporation.tokens << bonus_token
              tile.cities.first.place_token(corporation, bonus_token, free: true, check_tokenable: false)
            else
              @game.log << "#{corporation.name} forfeits the Company Town token as they are at token limit of 8"
            end
            @game.graph.clear
            @game.company_by_id('P27').close!
          end

          def abilities(entity, **kwargs, &block)
            ability = super
            return nil if ability&.type == :tile_lay && !(@game.class::RESOURCE_LABELS.values & ability&.tiles).empty?

            ability
          end
        end
      end
    end
  end
end
