# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G1856
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def actions(entity)
            return [] if entity.company? && entity.owner.player?

            super
          end

          def process_place_token(action)
            # This is WSRC because no other private can use the special token step
            @game.log << "#{@game.wsrc.name} is used and will close at the end of the operating round"
            @round.wsrc_activated = true
            super
          end
        end
      end
    end
  end
end
