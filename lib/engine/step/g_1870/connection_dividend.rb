# frozen_string_literal: true

require_relative 'dividend'

module Engine
  module Step
    module G1870
      class ConnectionDividend < Dividend
        DIVIDEND_TYPES = %i[payout withhold].freeze

        def share_price_change(_entity, revenue)
          return { share_direction: :right, share_times: 1 } if revenue.positive?

          {}
        end

        def active?
          @round.connection_runs.any?
        end

        def override_entities
          @round.connection_runs.keys
        end

        def current_entity
          @round.connection_runs.keys.first
        end

        def context_entities
          @round.entities
        end

        def active_context_entity
          @round.entities[@round.entity_index]
        end

        def process_dividend(action)
          entity = action.entity
          revenue = @game.routes_revenue(routes)
          kind = action.kind.to_sym
          payout = dividend_options(entity)[kind]

          @game.connection_runs[entity] = {
            turn: @game.turn,
            round: @round.round_num,
            info: OperatingInfo.new(routes, action, revenue),
          }

          @round.routes = []

          log_run_payout(entity, kind, revenue, action, payout)

          @game.bank.spend(payout[:corporation], entity) if payout[:corporation].positive?

          payout_shares(entity, revenue - payout[:corporation]) if payout[:per_share].positive?

          change_share_price(entity, payout)

          @round.connection_runs.shift
          @round.connection_steps.each(&:unpass!)
          @round.connection_steps = []
        end
      end
    end
  end
end
