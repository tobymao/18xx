# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module GRollingStock
      module Round
        class Investment < Engine::Round::Stock
          def name
            'Phase 1 - Investment'
          end

          def self.short_name
            'IR'
          end
        end
      end
    end
  end
end
