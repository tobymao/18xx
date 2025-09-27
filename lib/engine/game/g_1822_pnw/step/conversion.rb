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
            shares = ((minors_value - minors_cash - 1) / par).floor + 1
            [2, shares].max
          end

          def max_exchange_shares(par, minors_value, player_cash)
            shares = ((minors_value + [player_cash, (par - 1)].min) / par).floor
            [6, shares].min
          end

          def possible_exchanged_shares(par, minors_cash, minors_value, player_cash)
            if (6 * par) < minors_value
              return (par == 100 ? [6] : [])
            end

            min_shares = min_exchange_shares(par, minors_value, minors_cash)
            max_shares = max_exchange_shares(par, minors_value, player_cash)
            (min_shares..max_shares).to_a
          end

          def can_par_at?(par, minors_cash, minors_value, player_cash)
            !possible_exchanged_shares(par, minors_cash, minors_value, player_cash).empty?
          end
        end
      end
    end
  end
end
