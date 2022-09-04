# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1858
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze

          def rust_obsolete_trains!(entity)
            # Wounded trains are not discarded after running
          end

          def payout_per_share(entity, revenue)
            (revenue / entity.total_shares.to_f).floor.to_i
          end

          def half(entity, revenue)
            dividend = payout_per_share(entity, revenue / 2)
            withheld = revenue - (dividend * entity.total_shares)
            puts "revenue: #{revenue}, shares: #{entity.total_shares}, dividend: #{dividend.to_f}, withheld: #{withheld}"
            { corporation: withheld, per_share: dividend }
          end
        end
      end
    end
  end
end
