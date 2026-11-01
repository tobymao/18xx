# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module GFrost1831
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            corp = pending_entity

            super

            # Remove faction_base icon from the hex after placing token
            hex = action.city.hex
            hex.tile.icons.reject! { |icon| icon.name == 'faction_base' }

            # Clear coordinates so the view uses token.hex.name as source of truth
            corp.coordinates = nil
          end
        end
      end
    end
  end
end
