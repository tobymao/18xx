# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../skip_coal_and_oil'

module Engine
  module Game
    module G1868WY
      module Step
        class Dividend < Engine::Step::Dividend
          include G1868WY::SkipCoalAndOil

          def share_price_change(entity, revenue = 0)
            return {} if entity.minor?
            return { share_direction: :left, share_times: 1 } if revenue.zero?

            if (times = [revenue.div(entity.share_price.price), 3].min).positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end

          def log_run_payout(entity, kind, revenue, action, payout)
            super unless entity.minor?
          end

          def rust_obsolete_trains!(entity, log: false)
            super(entity, log: false)
          end

          def process_dividend(action)
            super
            @game.double_headed_trains = []
          end

          # Teapot Dome: force a float in both JS and Ruby
          def payout_per_share(entity, revenue)
            revenue % 10 == 5 ? revenue / 10.0 : super
          end

          # Teapot Dome: log the fractional amount that will be rounded after
          # multiplying by share count, i.e., in
          # Engine::Step::Dividend#dividends_for_entity()
          def log_payout_shares(entity, revenue, per_share, receivers)
            return super unless revenue % 10 == 5

            @log << "#{entity.name} pays out #{@game.format_currency(revenue)} = "\
                    "$#{revenue / 10.0} per share, rounded up (#{receivers})"
          end
        end
      end
    end
  end
end
