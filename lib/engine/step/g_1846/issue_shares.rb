# frozen_string_literal: true

require_relative '../issue_shares'
require_relative 'receivership_skip'

module Engine
  module Step
    module G1846
      class IssueShares < IssueShares
        include ReceivershipSkip

        def actions(entity)
          unless @round.steps.find { |step| step.class == Step::G1846::Dividend }.active?
            pass!
            return []
          end

          super
        end

        def blocks?
          false
        end
      end
    end
  end
end
