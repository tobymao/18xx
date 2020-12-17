# frozen_string_literal: true

require_relative '../track_and_token'
require_relative 'receivership_skip'

module Engine
  module Step
    module G1846
      class TrackAndToken < TrackAndToken
        include ReceivershipSkip

        def buying_power(entity)
          @game.track_buying_power(entity)
        end
      end
    end
  end
end
