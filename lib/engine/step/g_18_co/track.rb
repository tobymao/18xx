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

          # TODO: Implement Mine Collection
          @log << 'TODO: implement mine token collection'

          pass! unless can_lay_tile?(action.entity)
        end
      end
    end
  end
end
