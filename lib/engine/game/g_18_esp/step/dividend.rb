# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G18ESP
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::MinorHalfPay
          ACTIONS = %w[dividend].freeze

          def actions(entity)
            return [] if entity.company? || @game.routes_revenue(routes).zero?

            ACTIONS
          end

          def dividend_options(entity)
            revenue = @game.routes_revenue(routes)
            subsidy = @game.routes_subsidy(routes)
            total_revenue = revenue + subsidy
            dividend_types.to_h do |type|
              payout = send(type, entity, revenue, subsidy)
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
              [type, payout.merge(share_price_change(entity, total_revenue - payout[:corporation]))]
            end
          end

          def share_price_change(entity, revenue = 0)
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            times = 1 if revenue.positive?
            times = 2 if @game.final_ors? && @round.round_num == @game.phase.operating_rounds && @game.north_corp?(entity)
            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end

          def movement_str(times, dir)
            "#{times} #{dir}"
          end

          def process_dividend(action)
            entity = action.entity
            revenue = @game.routes_revenue(routes)
            subsidy = @game.routes_subsidy(routes)
            kind = action.kind.to_sym
            payout = dividend_options(entity)[kind]

            rust_obsolete_trains!(entity)

            entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
              routes,
              action,
              revenue,
              @round.laid_hexes
            )

            entity.trains.each { |train| train.operated = true }

            @round.routes = []

            log_run_payout(entity, kind, revenue, subsidy, action, payout)

            payout_corporation(payout[:corporation], entity)

            payout_shares(entity, revenue - payout[:corporation] + subsidy) if payout[:per_share].positive?

            change_share_price(entity, payout)

            pass!
          end

          def log_run_payout(entity, kind, revenue, subsidy, action, payout)
            unless Dividend::DIVIDEND_TYPES.include?(kind)
              @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays #{action.kind}"
            end

            if (payout[:corporation] - subsidy).positive?
              @log << "#{entity.name} withholds #{@game.format_currency(payout[:corporation])}"
            elsif subsidy.positive?
              @log << "#{entity.name} retains a subsidy of #{@game.format_currency(subsidy)}"
            elsif payout[:per_share].zero?
              @log << "#{entity.name} does not run"
            end
          end

          def payout_per_share(entity, revenue)
            revenue * 1.0 / entity.total_shares
          end

          def payout(entity, revenue, subsidy)
            if entity.corporation? && entity.type != :minor
              { corporation: subsidy, per_share: payout_per_share(entity, revenue) }
            else
              amount = revenue / 2
              { corporation: amount + subsidy, per_share: amount }
            end
          end

          def withhold(_entity, revenue, subsidy)
            { corporation: revenue + subsidy, per_share: 0 }
          end
        end
      end
    end
  end
end
