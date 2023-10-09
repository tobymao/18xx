# frozen_string_literal: true

require_relative '../../g_1822/step/pending_token'

module Engine
  module Game
    module G1822CA
      module Step
        class PendingToken < G1822::Step::PendingToken
          def setup_m14_track_rights(_m14); end
        end
      end
    end
  end
end
