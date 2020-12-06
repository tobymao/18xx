# frozen_string_literal: true

module Engine
  module Step
    module G18CO
      module Tracker
        # Remove the upgrade icon when the town is converted to a city
        def clear_upgrade_icon(tile)
          return if tile.cities.empty?
          return if tile.icons.empty? { |icon| icon.name == 'upgrade' }

          tile.icons.reject! { |icon| icon.name == 'upgrade' }
        end

        def collect_mines(corporation, hex)
          # Mine Token Collection
          return unless hex.tile.icons.map(&:name).include?('mine')

          # Remove mine symbol from hex
          hex.tile.icons.reject! { |icon| icon.name == 'mine' }

          # Add mine to corporation data
          @game.mine_add(corporation)

          @log << "#{corporation.name} collects a mine token from #{hex.name}"
        end
      end
    end
  end
end
