# frozen_string_literal: true

require_relative '../../../step/track'
require_relative '../../../step/upgrade_track_max_exits'

module Engine
  module Game
    module G18USA
      module Step
        class Track < Engine::Step::Track
          include Engine::Step::UpgradeTrackMaxExits

          def can_lay_tile?(entity)
            super || can_place_token_with_p20?(entity) || can_assign_p6?(entity)
          end

          def can_place_token_with_p20?(entity)
            entity.companies.include?(@game.company_by_id('P20')) &&
            !entity.tokens.all?(&:used) &&
            @game.graph.connected_nodes(entity).keys.any? do |node|
              node.city? && node.available_slots.zero? && !node.tokened_by?(entity)
            end
          end

          def can_assign_p6?(entity)
            entity.companies.include?(@game.company_by_id('P6')) &&
            @game.graph.connected_hexes(entity).keys.any? { |hex| hex.tile.color == :red }
          end

          def owns_p11?(entity)
            @p11 ||= @game.company_by_id('P11')
            entity.companies.include?(@p11)
          end

          def get_tile_lay(entity)
            action = super
            return unless action

            action[:upgrade] = true if owns_p11?(entity) && @num_upgraded < 2
            action
          end

          def available_hex(_entity, hex)
            return nil if hex.tile.color != :white && !hex.tile.cities.empty? && @city_upgraded

            super
          end

          def potential_tile_colors(entity, hex)
            colors = super
            return colors if !hex.tile.cities.empty? || !owns_p11?(entity)

            colors << if colors.include?(:brown)
                        :gray
                      elsif colors.include?(:green)
                        :brown
                      else
                        :green
                      end
            colors
          end

          def process_lay_tile(action)
            return super unless free_brown_city_upgrade?(action.entity, action.hex, action.tile)

            lay_tile(action)
            @round.laid_hexes << action.hex
          end

          def free_brown_city_upgrade?(entity, hex, tile)
            !entity.operated? && @game.home_hex_for(entity) == hex && tile.color == :brown
          end

          def lay_tile_action(action, entity: nil, spender: nil)
            tile = action.tile
            previous_tile = action.hex.tile
            if previous_tile.color != :white
              @num_upgraded += 1
              @city_upgraded = true unless tile.cities.empty?
            end

            super
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            tile = action.tile
            hex = action.hex
            previous_tile = hex.tile

            check_company_town(tile, hex) if @game.class::COMPANY_TOWN_TILES.include?(tile.name)

            if previous_tile.cities.empty? && tile.color != previous_tile.color
              extra_cost += 10 * (Engine::Tile::COLORS.index(tile.color) - Engine::Tile::COLORS.index(previous_tile.color) - 1)
            end

            super(action, extra_cost: extra_cost, entity: entity, spender: spender)

            @game.company_by_id('P16').close! if tile.name == 'X23'
            process_company_town(tile) if @game.class::COMPANY_TOWN_TILES.include?(tile.name)
            if @game.metro_denver && @game.hex_by_id('E11').tile.color == :white &&
                hex.neighbors.any? { |exit, h| hex.tile.exits.include?(exit) && h.name == 'E11' }
              @round.pending_tracks << { entity: action.entity, hexes: [@game.hex_by_id('E11')] }
            end
            @game.jump_graph.clear
          end

          def check_company_town(_tile, hex)
            raise GameError, 'Cannot use Company Town in a tokened hex' if hex.tile.cities&.first&.tokens&.first
            return if (hex.neighbors.values & @game.active_metropolitan_hexes).empty?

            raise GameError, 'Cannot use Company Town next to a metropolis'
          end

          def process_company_town(tile)
            corporation = @game.company_by_id('P27').owner
            if corporation.tokens.size < 8
              @game.log << "#{corporation.name} gets a free token to place on the Company Town"
              bonus_token = Engine::Token.new(corporation)
              corporation.tokens << bonus_token
              tile.cities.first.place_token(corporation, bonus_token, free: true, check_tokenable: false, extra_slot: true)
            else
              @game.log << "#{corporation.name} forfeits the Company Town token as they are at token limit of 8"
            end
            @game.graph.clear
            @game.company_by_id('P27').close!
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            old_tile.name.include?('ore') && new_tile.name.include?('ore') ? true : super
          end

          def setup
            super
            @city_upgraded = false
            @num_upgraded = 0
          end
        end
      end
    end
  end
end
