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

          def routes_revenue(routes, entity)
            revenue = @game.routes_revenue(routes)
            revenue += @game.rptla_revenue(entity) if entity == @game.rptla
            revenue
          end

          def routes_subsidy(routes, entity)
            revenue = @game.routes_subsidy(routes)
            revenue += @game.rptla_subsidy(entity) if entity == @game.rptla
            revenue
          end

          def missing_revenue(entity)
            (routes_revenue(routes, entity).zero? && routes_subsidy(routes, entity).zero?)
          end

          def description
            'Pay or Withhold Dividends'
          end

          def auto_actions(entity)
            return [] unless @game.nationalized?
            return [] if entity.loans.empty?

            [Engine::Action::Dividend.new(current_entity, kind: 'withhold')]
          end

          def dividend_options(entity)
            total_revenue = routes_revenue(routes, entity)
            revenue = total_revenue

            subsidy = routes_subsidy(routes, entity)
            total_revenue += subsidy
            dividend_types.to_h do |type|
              payout = send(type, entity, revenue, subsidy)
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
              [type, payout.merge(share_price_change(entity, total_revenue - payout[:corporation]))]
            end
          end

          def holder_for_corporation(_entity)
            @game.share_pool
          end

          def payout(entity, revenue, subsidy)
            if @game.nationalized? && entity.loans.size.positive?
              return {
                corporation: subsidy + (payout_per_share(entity, revenue) * 10),
                per_share: 0,
              }
            end

            { corporation: subsidy, per_share: payout_per_share(entity, revenue) }
          end

          def withhold(_entity, revenue, subsidy)
            { corporation: revenue + subsidy, per_share: 0 }
          end

          def process_dividend_rptla(action)
            entity = action.entity
            revenue = routes_revenue(routes, entity)
            subsidy = routes_subsidy(routes, entity)
            kind = action.kind.to_sym
            payout = dividend_options(entity)[kind]
            entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
              routes,
              action,
              revenue,
              @round.laid_hexes
            )

            entity.trains.each { |train| train.operated = true }

            @round.routes = []
            log_run_payout_sub(entity, kind, revenue, subsidy, action, payout)
            @game.bank.spend(payout[:corporation], entity) if payout[:corporation].positive?
            payout_shares(entity, revenue + subsidy - payout[:corporation]) if payout[:per_share].positive?
            change_share_price(entity, payout)

            pass!
          end

          def process_dividend(action)
            return process_dividend_rptla(action) if action.entity == @game.rptla

            super
            loans_to_pay_off = [(current_entity.cash / 100).floor, current_entity&.loans&.size].min
            return if !loans_to_pay_off.positive? || !@game.nationalized?

            @game.payoff_loan(current_entity, loans_to_pay_off, current_entity)
          end

          def log_run_payout(entity, kind, revenue, action, payout)
            super unless entity.minor?
          end

          def log_run_payout_sub(entity, kind, revenue, _subsidy, _action, payout)
            unless Dividend::DIVIDEND_TYPES.include?(kind)
              @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays #{action.kind}"
            end

            if payout[:corporation].positive?
              @log << "#{entity.name} withholds #{@game.format_currency(payout[:corporation])}"
            elsif payout[:per_share].zero?
              @log << "#{entity.name} does not run" unless entity.minor?
            end
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
