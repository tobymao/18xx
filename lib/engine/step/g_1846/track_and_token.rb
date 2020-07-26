# frozen_string_literal: true

require_relative '../track_and_token'
require_relative 'receivership_skip'

module Engine
  module Step
    module G1846
      class TrackAndToken < TrackAndToken
        include ReceivershipSkip
      end
    end
  end
end
