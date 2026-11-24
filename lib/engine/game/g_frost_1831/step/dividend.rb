# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module GFrost1831
      module Step
        class Dividend < Engine::Step::Dividend
          def share_price_change(entity, revenue)
            return { share_direction: :left, share_times: 1 } if revenue.zero?
            return { share_direction: :right, share_times: 1 } if revenue >= entity.share_price.price

            {}
          end
        end
      end
    end
  end
end
