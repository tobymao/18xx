# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18CO
      class Track < Track
        def process_lay_tile(action)
          lay_tile_action(action)

          # Remove the upgrade icon when the town is converted to a city
          if action.hex.tile.cities.any? &&
             action.hex.tile.icons.any? { |icon| icon.name == 'upgrade' }
            action.hex.tile.icons.reject! { |icon| icon.name == 'upgrade' }
          end

          # Mine Token Collection
          if action.hex.tile.icons.map(&:name).include?('mine')
            # Remove mine symbol from hex
            action.hex.tile.icons.reject! { |icon| icon.name == 'mine' }

            # Add mine to corporation data
            @game.mine_add(action.entity)

            @log << "#{action.entity.name} collects a mine token from
              #{action.hex.name} for a total of
              #{@game.format_currency(@game.mines_total(action.entity))} from mines"
          end

          pass! unless can_lay_tile?(action.entity)
        end
      end
    end
  end
end
