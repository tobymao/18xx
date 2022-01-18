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

          def half(entity, revenue, _subsidy)
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

          def log_run_payout(entity, kind, revenue, _action, payout)
            @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays half" if kind == 'half'

            withhold = payout[:corporation]
            if withhold.positive? && !@game.minor_national_corporation?(entity)
              @log << "#{entity.name} withholds #{@game.format_currency(withhold)}"
            elsif payout[:per_share].zero?
              @log << "#{entity.name} does not run"
            end
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
            times = 2 if revenue >= price * 2 && @game.public_corporation?(entity)
            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end
        end
      end
    end
  end
end
