# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1866
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze

          def actions(entity)
            return [] if !entity.corporation? || (entity.corporation? && @game.national_corporation?(entity))

            super
          end

          def dividend_options(entity)
            revenue = @game.routes_revenue(routes)
            dividend_types.to_h do |type|
              payout = send(type, entity, revenue)
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
              [type, payout.merge(share_price_change(entity, total_revenue - payout[:corporation]))]
            end
          end

          def half(entity, revenue)
            withheld = half_pay_withhold_amount(entity, revenue)
            { corporation: withheld, per_share: payout_per_share(entity, revenue - withheld) }
          end

          def half_pay_withhold_amount(entity, revenue)
            return revenue / 2.0 if @game.minor_national_corporation?(entity)

            (revenue / 2 / entity.total_shares).to_i * entity.total_shares
          end

          def log_payout_shares(entity, revenue, per_share, receivers)
            return @log << "#{entity.name} pays out #{receivers}" if @game.minor_national_corporation?(entity)

            @log << "#{entity.name} pays out #{@game.format_currency(revenue)} = "\
                    "#{@game.format_currency(per_share)} per share (#{receivers})"
          end

          def payout(entity, revenue)
            { corporation: 0, per_share: payout_per_share(entity, revenue) }
          end

          def payout_shares(entity, revenue)
            per_share = payout_per_share(entity, revenue)

            payouts = {}
            (@game.players + @game.corporations).each do |payee|
              payout_entity(entity, payee, per_share, payouts) if !payee.corporation? || !@game.national_corporation?(payee)
            end

            receivers = payouts
                          .sort_by { |_r, c| -c }
                          .map { |receiver, cash| "#{@game.format_currency(cash)} to #{receiver.name}" }.join(', ')

            log_payout_shares(entity, revenue, per_share, receivers)
          end

          def skip!
            entity = current_entity
            return super unless @game.national_corporation?(entity)

            process_dividend(Action::Dividend.new(
              entity,
              kind: 'payout',
            ))
          end

          def share_price_change(entity, revenue = 0)
            return {} if @game.minor_national_corporation?(entity)
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            price = entity.share_price.price
            times = 0
            times = 1 if revenue >= price || @game.major_national_corporation?(entity)
            times = 2 if revenue >= price * 2 && @game.corporation?(entity)
            times = 3 if revenue >= price * 3 && @game.corporation?(entity)
            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end

          def withhold(_entity, revenue)
            { corporation: revenue, per_share: 0 }
          end
        end
      end
    end
  end
end
