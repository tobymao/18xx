# frozen_string_literal: true

require_relative '../../g_1846/round/operating'

module Engine
  module Game
    module G1833NE
      module Round
        class Operating < G1846::Round::Operating
          def after_setup
            start_operating if any_to_act?
          end
        end
      end
    end
  end
end
