# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18Dixie
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            super
            entity = action.entity
            return unless entity.minor?

            Array.new(entity.coordinates).each { |c| @game.hex_by_id(c).tile.cities.first.remove_reservation!(entity) }
          end
        end
      end
    end
  end
end
