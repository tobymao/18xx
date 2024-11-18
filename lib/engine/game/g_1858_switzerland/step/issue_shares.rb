# frozen_string_literal: true

require_relative '../../g_1858/step/issue_shares'

module Engine
  module Game
    module G1858Switzerland
      module Step
        class IssueShares < G1858::Step::IssueShares
          def skip!
            super unless @game.robot_owner?(current_entity)
          end
        end
      end
    end
  end
end
