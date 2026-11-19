# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18OE
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            minor = action.entity.type == :minor
            hex = action.city.hex
            if minor
              region = @game.region_for_hex(hex)

              raise GameError, "Region #{region} is not available" unless @game.region_available?(region)

              token.price = @game.track_rights_cost(region)
              @game.claim_region!(action.entity, region)
            end

            super

            return if !minor || !@game.remove_patronage!(hex)

            @game.log << "The #{hex.location_name} patronage tile is removed"
          end
        end
      end
    end
  end
end
