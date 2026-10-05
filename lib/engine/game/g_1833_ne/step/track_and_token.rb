# frozen_string_literal: true

require_relative '../../../step/track_and_token'
require_relative 'receivership_skip'

module Engine
  module Game
    module G1833NE
      module Step
        class TrackAndToken < Engine::Step::TrackAndToken
          include ReceivershipSkip
        end
      end
    end
  end
end
