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
            dividend_types.to_h do |type|
              payout = send(type, entity, revenue)
              payout[:divs_to_corporation] = 0
              [type, payout.merge(share_price_change(entity, payout[:per_share].positive? ? revenue : 0))]
            end
          end

          def process_dividend(action)
            super
            @game.check_bank_broken!
            @game.check_bankruptcy!(action.entity)
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

          def withhold(_entity, revenue)
            { corporation: revenue, per_share: 0 }
          end

          def payout(entity, revenue)
            { corporation: 0, per_share: payout_per_share(entity, revenue) }
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
