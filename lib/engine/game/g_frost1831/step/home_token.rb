# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module GFrost1831
      module Step
        class HomeToken < Engine::Step::HomeToken
          # The Stock Round view asks the active step how to show unstarted corporations
          def ipo_type(_entity)
            nil
          end

          # The reserved-city marker leaves the map once a Faction takes the city
          def process_place_token(action)
            super
            action.city.hex.tile.icons.reject! { |icon| icon.name == 'faction_base' }
          end
        end
      end
    end
  end
end
