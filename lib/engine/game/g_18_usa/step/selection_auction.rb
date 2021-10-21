# frozen_string_literal: true

require_relative '../../g_1817/step/selection_auction'
module Engine
  module Game
    module G18USA
      module Step
        class SelectionAuction < G1817::Step::SelectionAuction
          def starting_bid(company)
            return super unless company.id == 'P14'

            [5, company.value - @seed_money].max
          end
        end
      end
    end
  end
end
