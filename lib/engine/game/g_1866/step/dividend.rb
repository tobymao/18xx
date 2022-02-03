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
            subsidy = @game.routes_subsidy(routes)
            total_revenue = revenue + subsidy
            dividend_types.to_h do |type|
              payout = send(type, entity, revenue, subsidy)
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
              [type, payout.merge(share_price_change(entity, total_revenue - payout[:corporation]))]
            end
          end

          def half(entity, revenue, subsidy)
            withheld = half_pay_withhold_amount(entity, revenue)
            { corporation: withheld + subsidy, per_share: payout_per_share(entity, revenue - withheld) }
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

          def log_run_payout(entity, kind, revenue, subsidy, _action, payout)
            @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays half" if kind == 'half'

            withhold = payout[:corporation] - subsidy
            if withhold.positive? && !@game.minor_national_corporation?(entity)
              @log << "#{entity.name} withholds #{@game.format_currency(withhold)}"
            elsif payout[:per_share].zero?
              @log << "#{entity.name} does not run"
            end
            @log << "#{entity.name} earns subsidy of #{@game.format_currency(subsidy)}" if subsidy.positive?
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
            payout_shares(entity, revenue + subsidy - payout[:corporation]) if payout[:per_share].positive?
            change_share_price(entity, payout)

            pass!
          end

          def payout(entity, revenue, subsidy)
            { corporation: subsidy, per_share: payout_per_share(entity, revenue) }
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

          def withhold(_entity, revenue, subsidy)
            { corporation: revenue + subsidy, per_share: 0 }
          end
        end
      end
    end
  end
end
