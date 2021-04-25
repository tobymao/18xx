# frozen_string_literal: true

require_relative '../../../step/track_and_token'

module Engine
  module Game
    module G1840
      module Step
        class TrackAndToken < Engine::Step::TrackAndToken
          def process_place_token(action)
            entity = action.entity

            spender = @game.owning_major_corporation(entity)
            place_token(entity, action.city, action.token, spender: spender)
            @tokened = true
            pass! unless can_lay_tile?(entity)
          end
        end
      end
    end
  end
end
