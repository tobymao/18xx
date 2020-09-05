# frozen_string_literal: true

require_relative '../special_token'

module Engine
  module Step
    module G18MS
      class SpecialToken < SpecialToken
        def ability(entity)
          ability = super

          return unless ability

          # If outside normal token lay do not allow special token
          @game.round.active_step.respond_to?(:process_place_token) ? ability : nil
        end
      end
    end
  end
end
