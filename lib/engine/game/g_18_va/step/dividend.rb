# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'

module Engine
  module Game
    module G18VA
      module Step
        class Dividend < Engine::Step::Dividend
          def withhold(_entity, revenue, subsidy)
            { corporation: revenue + subsidy, per_share: 0 }
          end

          def payout(entity, revenue, subsidy)
            { corporation: subsidy, per_share: payout_per_share(entity, revenue) }
          end

          def dividend_options(entity)
            revenue = @game.routes_revenue(routes)
            subsidy = @game.routes_subsidy(routes)
            dividend_types.to_h do |type|
              payout = send(type, entity, revenue, subsidy)
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
              [type, payout.merge(share_price_change(entity, revenue + subsidy - payout[:corporation]))]
            end
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

            adjusted_revenue = subsidy ? revenue + subsidy : revenue
            payout_shares(entity, adjusted_revenue - payout[:corporation]) if payout[:per_share].positive?

            change_share_price(entity, payout)

            pass!
          end

          def log_run_payout(entity, kind, revenue, subsidy, action, payout)
            unless Dividend::DIVIDEND_TYPES.include?(kind)
              @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays #{action.kind}"
            end

            withheld_amount =  payout[:corporation] - subsidy
            if withheld_amount.positive?
              @log << "#{entity.name} withholds #{@game.format_currency(withheld_amount)}"
            elsif payout[:per_share].zero?
              @log << "#{entity.name} does not run"
            end

            @log << "#{entity.name} earns subsidy of #{@game.format_currency(subsidy)}" if subsidy.positive?
          end

          def share_price_change(entity, revenue = 0)
            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } if revenue.zero?
            return { share_direction: :right, share_times: 1 } if revenue >= price

            {}
          end

          def holder_for_corporation(_entity)
            # Incremental corps DON'T get paid from IPO shares.
            @game.share_pool
          end
        end
      end
    end
  end
end
