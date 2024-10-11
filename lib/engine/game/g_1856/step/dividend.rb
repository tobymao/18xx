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
            return [] if entity.company? || routes.empty?

            Engine::Step::Dividend::ACTIONS
          end

          def dividend_options(entity)
            revenue = total_revenue

            dividend_types.to_h do |type|
              payout = send(type, entity, revenue)
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])

              [type, payout.merge(share_price_change(entity, revenue - payout[:corporation]))]
            end
          end

          def payout_per_share(entity, revenue)
            (revenue / entity.total_shares.to_f)
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

          def total_revenue
            super - (@round.interest_penalty[@round.current_operator] || 0)
          end

          def log_run_payout(entity, kind, revenue, _subsidy, action, payout)
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
