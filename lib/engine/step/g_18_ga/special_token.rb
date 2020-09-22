# frozen_string_literal: true

require_relative '../special_token'

module Engine
  module Step
    module G18GA
      class SpecialToken < SpecialToken
        def ability(entity)
          ability = super

          ability if ability &&
            entity.owner == @game.round.current_entity &&
            @game.round.active_step.respond_to?(:process_place_token)
        end
      end
    end
  end
end
