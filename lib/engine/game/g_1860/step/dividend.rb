# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../operating_info'
require_relative '../../../action/dividend'

module Engine
  module Game
    module G1860
      module Step
        class Dividend < Engine::Step::Dividend
          def dividend_options(entity)
            revenue = @game.routes_revenue(routes)
            subsidy = @game.routes_subsidy(routes)
            dividend_types.to_h do |type|
              payout = send(type, entity, revenue, subsidy)
              payout[:divs_to_corporation] = 0
              [type, payout.merge(share_price_change(entity, payout[:per_share].positive? ? revenue : 0))]
            end
          end

          def process_dividend(action)
            entity = action.entity
            revenue = @game.routes_revenue(routes)
            subsidy = @game.routes_subsidy(routes)
            kind = action.kind.to_sym
            payout = dividend_options(entity)[kind]

            entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
              routes,
              (@game.insolvent?(entity) ? @game.actions.last : action),
              revenue,
              @round.laid_hexes
            )

            entity.trains.each { |train| train.operated = true } unless @game.insolvent?(entity)

            @round.routes = []

            log_run_payout(entity, kind, revenue, subsidy, action, payout)
            @game.bank.spend(payout[:corporation], entity) if payout[:corporation].positive?
            payout_shares(entity, revenue) if payout[:per_share].positive?
            change_share_price(entity, payout)
            @game.check_bank_broken!
            pass!
            @game.check_bankruptcy!(entity)
          end

          def log_run_payout(entity, kind, revenue, subsidy, action, payout)
            unless Dividend::DIVIDEND_TYPES.include?(kind)
              @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays #{action.kind}"
            end

            if payout[:per_share].zero? && payout[:corporation].zero?
              @log << "#{entity.name} does not run"
            elsif payout[:per_share].zero?
              @log << "#{entity.name} withholds #{@game.format_currency(revenue)}"
            end
            @log << "#{entity.name} earns subsidy of #{@game.format_currency(subsidy)}" if subsidy.positive?
          end

          def share_price_change(entity, revenue)
            if revenue.positive?
              curr_price = entity.share_price.price
              if revenue >= curr_price && revenue < 2 * curr_price
                { share_direction: :right, share_times: 1 }
              elsif revenue >= 2 * curr_price && revenue < 3 * curr_price
                { share_direction: :right, share_times: 2 }
              elsif revenue >= 3 * curr_price && revenue < 4 * curr_price
                { share_direction: :right, share_times: 3 }
              elsif revenue >= 4 * curr_price
                { share_direction: :right, share_times: 4 }
              else
                {}
              end
            else
              { share_direction: :left, share_times: 1 }
            end
          end

          def withhold(_entity, revenue, subsidy)
            { corporation: revenue + subsidy, per_share: 0 }
          end

          def payout(entity, revenue, subsidy)
            { corporation: subsidy, per_share: payout_per_share(entity, revenue) }
          end

          def payout_shares(entity, revenue)
            per_share = payout_per_share(entity, revenue)

            payouts = {}
            @game.players.each do |player|
              payout_entity(entity, player, per_share, payouts)
            end

            receivers = payouts
              .sort_by { |_r, c| -c }
              .map { |receiver, cash| "#{@game.format_currency(cash)} to #{receiver.name}" }.join(', ')

            @log << "#{entity.name} pays out #{@game.format_currency(revenue)} = "\
                    "#{@game.format_currency(per_share)} (#{receivers})"
          end
        end
      end
    end
  end
end
