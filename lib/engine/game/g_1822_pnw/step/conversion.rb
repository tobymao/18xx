# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../token'
require_relative '../../../step/token_merger'
require_relative '../../../step/programmer_merger_pass'

module Engine
  module Game
    module G1822PNW
      module Step
        module Conversion
          def min_exchange_shares(par, minors_value, minors_cash)
            ((minors_value - minors_cash - 1) / par).floor + 1
          end

          def max_exchange_shares(par, minors_value, player_cash)
            ((minors_value + [player_cash, (par - 1)].min) / par).floor
          end

          def possible_exchanged_shares(par, minors_cash, minors_value, player_cash)
            return [6] if (6 * par) < minors_value && par == 100 && minors_cash >= (minors_value - 600)
            return [] if (6 * par) < minors_value

            min_shares = min_exchange_shares(par, minors_value, minors_cash)
            max_shares = max_exchange_shares(par, minors_value, player_cash)
            (2..10).to_a.select { |n| n >= min_shares && n <= max_shares }
          end

          def can_par_at?(par, minors_cash, minors_value, player_cash)
            !possible_exchanged_shares(par, minors_cash, minors_value, player_cash).empty?
          end
        end
      end
    end
  end
end
