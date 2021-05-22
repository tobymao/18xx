# frozen_string_literal: true

require_relative '../../../step/special_token'
require_relative 'tokened_city_must_be_connected'

module Engine
  module Game
    module G18MS
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def ability(entity)
            ability = super

            return unless ability

            # If outside normal token lay do not allow special token
            @game.round.active_step.respond_to?(:process_place_token) ? ability : nil
          end

          include TokenedCityMustBeConnected
        end
      end
    end
  end
end
