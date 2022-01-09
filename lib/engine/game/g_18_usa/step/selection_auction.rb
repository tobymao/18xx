# frozen_string_literal: true

require_relative '../../g_1817/step/selection_auction'
module Engine
  module Game
    module G18USA
      module Step
        class SelectionAuction < G1817::Step::SelectionAuction
          def starting_bid(company)
            return 5 if company.id == 'P14'

            company.value / 2
          end
        end
      end
    end
  end
end
