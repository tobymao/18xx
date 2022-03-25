# frozen_string_literal: true

require_relative '../../../ability/base'

module Engine
  module Game
    module GRollingStock
      module Ability
        class StockMasters < Engine::Ability::Base
          def description
            'No Decrease on Issue'
          end

          def desc_detail
            'When issuing a share, its share price does not change'
          end
        end
      end
    end
  end
end
