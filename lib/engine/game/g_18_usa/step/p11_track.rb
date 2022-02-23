# frozen_string_literal: true

module Engine
  module Game
    module G18USA
      module P11Track
        def owns_p11?(entity)
          @p11 ||= @game.company_by_id('P11')
          @p11&.owner == entity
        end

        def get_tile_lay(entity)
          action = super
          return unless action

          action[:upgrade] = true if owns_p11?(get_tile_lay_corporation(entity)) && @round.num_upgraded_track < 2
          action
        end

        def available_hex(_entity, hex)
          return nil if hex.tile.color != :white && !hex.tile.cities.empty? && @round.city_upgraded

          super
        end

        def potential_tile_colors(entity, hex)
          colors = super
          return colors if !hex.tile.cities.empty? || !owns_p11?(get_tile_lay_corporation(entity))

          colors << if colors.include?(:brown)
                      :gray
                    elsif colors.include?(:green)
                      :brown
                    else
                      :green
                    end
          colors
        end

        def lay_tile_action(action, entity: nil, spender: nil)
          hex = action.hex
          @round.city_upgraded = true if track_upgrade?(hex.tile, action.tile, hex) && !hex.tile.cities.empty?

          super
        end

        def round_state
          super.merge(
            {
              city_upgraded: false,
            }
          )
        end

        def setup
          super
          @round.city_upgraded = false
        end
      end
    end
  end
end
