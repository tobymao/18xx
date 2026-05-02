# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18OE
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            if action.entity.type == :minor
              hex = action.city.hex
              region = @game.region_for_hex(hex)

              raise GameError, "Region #{region} is not available" unless @game.region_available?(region)

              token.price = @game.track_rights_cost(region)
              @game.claim_region!(region)
              @game.minor_floated_regions[action.entity.id] = region
            end

            super
          end
        end
      end
    end
  end
end
