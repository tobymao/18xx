# frozen_string_literal: true

require_relative 'dividend'
require_relative 'connection'
require_relative 'connection_token'
require_relative 'connection_route'

module Engine
  module Game
    module G1870
      module Step
        class ConnectionDividend < G1870::Step::Dividend
          include Connection

          DIVIDEND_TYPES = %i[payout withhold].freeze

          def description
            'Pay or withhold connection dividends'
          end

          def share_price_change(_entity, revenue)
            return { share_direction: :right, share_times: 1 } if revenue.positive?

            {}
          end

          def process_dividend(action)
            entity = action.entity
            revenue = @game.routes_revenue(routes)
            kind = action.kind.to_sym
            payout = dividend_options(entity)[kind]

            @game.connection_run[entity] = [
              @game.turn,
              @round.round_num,
              OperatingInfo.new(routes, action, revenue, nil), # no tiles are laid in connection runs
            ]

            @round.routes = []

            log_run_payout(entity, kind, revenue, action, payout)

            @game.bank.spend(payout[:corporation], entity) if payout[:corporation].positive?

            payout_shares(entity, revenue - payout[:corporation]) if payout[:per_share].positive?

            change_share_price(entity, payout)

            @round.connection_runs.shift
            @round.steps.each do |step|
              step.unpass! if step.class < Connection
            end
          end
        end
      end
    end
  end
end
