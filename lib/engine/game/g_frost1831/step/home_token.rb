# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module GFrost1831
      module Step
        class HomeToken < Engine::Step::HomeToken
          def ipo_type(_entity)
            nil
          end

          def process_place_token(action)
            super
            action.city.hex.tile.icons.reject! { |icon| icon.name == 'faction_base' }
          end
        end
      end
    end
  end
end
