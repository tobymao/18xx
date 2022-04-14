# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module GRollingStock
      module Round
        class Investment < Engine::Round::Stock
          def name
            'Investment'
          end

          def self.short_name
            'INV'
          end

          def finish_round; end

          def show_auto?
            false
          end
        end
      end
    end
  end
end
