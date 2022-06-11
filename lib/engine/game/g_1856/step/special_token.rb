# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G1856
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def actions(entity)
            # WSRC must be owned by player
            # WSRC token must be at token time.
            # Order is:
            # Track <--
            # Token
            # Route
            # Interest <--
            # Dividend/Withold

            # Doing the token during route is fine, we can use paid interest as a way to gate this
            # We also need to check that track has been done
            return [] if (entity.company? && entity.owner.player?) ||
              @round.paid_interest[entity&.owner] || !@round.after_track[entity&.owner]

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
