# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18USA
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def actions(entity)
            return [] if entity&.id == 'P16' && !@game.phase.tiles.include?(:brown)

            super
          end

          def hex_neighbors(entity, hex)
            # See 1817 and reinsert pittsburgh check for handling metros
            return false unless (ability = abilities(entity))

            hexes = ability.hexes
            return hex.neighbors.keys if hexes.include?(hex.id) && !ability.reachable
            return if hexes&.any? && !hexes&.include?(hex.id)

            # When actually laying track entity will be the corp.
            owner = entity.corporation? ? entity : entity.owner

            @game.graph.connected_hexes(owner)[hex]
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            tile = action.tile
            hex = action.hex
            entity = action.entity
            corp = entity.corporation? ? entity : entity.owner
         
            check_rural_junction(tile, hex) if @game.class::RURAL_TILES.include?(tile.name)
            super
            @game.consume_abilities_to_lay_resource_tile(hex, tile, corp.companies) if @game.resource_tile?(tile)
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

          def potential_future_tiles(_entity, hex)
            @game.tiles
              .uniq(&:name)
              .select { |t| @game.upgrades_to?(hex.tile, t) }
          end

          # The oil/coal/ore tiles falsely pass as offboards, so we need to be more careful
          def real_offboard?(tile)
            tile.offboards&.any? && !tile.labels&.any?
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
            %i[green brown].include?(hex.tile.color) && !@game.active_metropolitan_hexes.include?(hex)
          end

          def p26_available_hex(_entity, hex)
            hex.tile.color == :white
          end

          def p27_available_hex(_entity, hex)
            hex.tile.color == :white &&
              (hex.tile.cities.empty? || hex.tile.cities.all? { |c| !c.tokens.empty? }) &&
              (hex.neighbors.values & @game.active_metropolitan_hexes).empty?
          end

          def legal_tile_rotation?(entity, hex, tile)
            # See 1817 and reinsert pittsburgh check for handling metros
            return true if tile.name == 'X23'
            return super unless @game.resource_tile?(tile)

            super &&
            tile.exits.any? do |exit|
              neighbor = hex.neighbors[exit]
              ntile = neighbor&.tile
              next false unless ntile

              # The neighbouring tile must have a city or offboard or town
              # That neighbouring tile must either connect to an edge on the tile or
              # potentially be updated in future.
              # 1817 doesn't have any coal next to towns but 1817NA does and
              #  Marc Voyer confirmed that coal should be able to connect to the gray pre-printed town
              (ntile.cities&.any? || real_offboard?(ntile) || ntile.towns&.any?) &&
              (ntile.exits.any? { |e| e == Hex.invert(exit) } || potential_future_tiles(entity, neighbor).any?)
            end
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
            return nil if ability&.type == :tile_lay && !(@game.class::RESOURCE_LABELS.values & ability.tiles).empty?
            
            ability
          end
        end
      end
    end
  end
end
