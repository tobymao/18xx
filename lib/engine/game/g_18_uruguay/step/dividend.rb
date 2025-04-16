# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'
module Engine
  module Game
    module G18Uruguay
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout withhold].freeze

          ACTIONS = %w[dividend].freeze

          def actions(entity)
            return [] if !entity.corporation? || missing_revenue(entity)

            ACTIONS
          end

          def total_revenue
            revenue = @game.routes_revenue(routes)
            revenue += @game.rptla_revenue if current_entity == @game.rptla
            revenue
          end

          def total_subsidy
            revenue = @game.routes_subsidy(routes)
            revenue += @game.rptla_subsidy if current_entity == @game.rptla
            revenue
          end

          def missing_revenue(_entity)
            (total_revenue.zero? && total_subsidy.zero?)
          end

          def auto_actions(entity)
            return [] unless entity.corporation?
            return [] unless @game.nationalized?
            return [] if entity.loans.empty?

            [Engine::Action::Dividend.new(current_entity, kind: 'withhold')]
          end

          def payoff_loans(entity)
            loans_to_pay_off = [(entity.cash / 100).floor, entity.loans.size].min
            @game.payoff_loan(entity, loans_to_pay_off, entity) if loans_to_pay_off.positive?
          end

          def payout_corporation(amount, entity)
            super
            payoff_loans(entity) if @game.nationalized? && entity.loans.size.positive?
          end

          def corporation_dividends(entity, per_share)
            return 0 if entity.minor?
            return 0 if entity == @game.rptla

            dividends_for_entity(entity, holder_for_corporation(entity), per_share)
          end

          def log_run_payout(entity, kind, revenue, subisdy, action, payout)
            super unless entity.minor?
          end

          def rptla_share_price_change(entity, revenue)
            return {} if entity == @game.rptla && @game.phase.current[:name] == '2'

            price = entity.share_price.price
            times = 0
            times = 1 if revenue >= price
            times = 2 if revenue >= price * 2

            if revenue.positive?
              { share_direction: :right, share_times: times }
            else
              { share_direction: :left, share_times: 1 }
            end
          end

          def share_price_change(entity, revenue)
            return rptla_share_price_change(entity, revenue) if entity == @game.rptla

            super
          end
        end
      end
    end
  end
end
