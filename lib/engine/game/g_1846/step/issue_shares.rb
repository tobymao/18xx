# frozen_string_literal: true

require_relative '../../../step/issue_shares'
require_relative 'receivership_skip'

module Engine
  module Game
    module G1846
      module Step
        class IssueShares < Engine::Step::IssueShares
          include ReceivershipSkip

          def dividend_step_passes
            pass!
          end

          def blocks?
            false
          end
        end
      end
    end
  end
end
