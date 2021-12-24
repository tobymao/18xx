# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../operating_info'
require_relative '../../../action/dividend'

module Engine
  module Game
    module G1856
      module Step
        class Dividend < Engine::Step::Dividend
          def actions(entity)
            # National must withhold if it never owned a permanent
            return [] if entity.corporation? && entity == @game.national && !@game.national_ever_owned_permanent

            super
          end

          def dividend_options(entity)
            penalty = @round.interest_penalty[entity] || 0
            revenue = @game.routes_revenue(routes) - penalty

            dividend_types.to_h do |type|
              payout = send(type, entity, revenue)
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])

              [type, payout.merge(share_price_change(entity, revenue - payout[:corporation]))]
            end
          end

          def payout_per_share(entity, revenue)
            (revenue / entity.total_shares.to_f)
          end

          def process_dividend(action)
            entity = action.entity
            penalty = @round.interest_penalty[entity] || 0
            revenue = @game.routes_revenue(routes) - penalty
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

            log_run_payout(entity, kind, revenue, action, payout)

            @game.bank.spend(payout[:corporation], entity) if payout[:corporation].positive?

            payout_shares(entity, revenue - payout[:corporation]) if payout[:per_share].positive?

            change_share_price(entity, payout)

            pass!
          end

          def share_price_change(entity, _revenue)
            # Share price of national does not change until it owns a permanent
            return {} if entity == @game.national && !@game.national_ever_owned_permanent

            super
          end

          def holder_for_corporation(_entity)
            # Incremental corps DON'T get paid from IPO shares.
            @game.share_pool
          end

          def log_run_payout(entity, kind, revenue, action, payout)
            if (@round.interest_penalty[entity] || 0).positive?
              @log << "#{entity.name} deducts #{@game.format_currency(@round.interest_penalty[entity])}"\
                      ' for unpaid interest'
            end
            if (@round.player_interest_penalty[entity] || 0).positive?
              @log << "#{entity.owner.name} must personally contribute "\
                      "#{@game.format_currency(@round.player_interest_penalty[entity])} for unpaid interest"
            end
            unless Dividend::DIVIDEND_TYPES.include?(kind)
              @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays #{action.kind}"
            end

            if payout[:corporation].positive?
              @log << "#{entity.name} withholds #{@game.format_currency(payout[:corporation])}"
            elsif payout[:per_share].zero?
              @log << "#{entity.name} does not run"
            end
          end
        end
      end
    end
  end
end
