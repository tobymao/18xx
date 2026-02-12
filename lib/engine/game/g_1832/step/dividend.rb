# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'

module Engine
  module Game
    module G1870
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          include Engine::Step::HalfPay

          def holder_for_corporation(entity)
            entity
          end

          def share_price_change(_entity, revenue)
            return { share_direction: :left, share_times: 1 } if revenue.zero?

            return { share_direction: :right, share_times: 1 } if revenue == @game.routes_revenue(routes)

            {}
          end
            def payout_shares(entity, revenue)
                per_share = payout_per_share(entity, revenue)

                payouts = {}
                (@game.players + @game.corporations).each do |payee|
                payout_entity(entity, payee, per_share, payouts)
                end

                receivers = payouts
                            .sort_by { |_r, c| -c }
                            .map { |receiver, cash| "#{@game.format_currency(cash)} to #{receiver.name}" }.join(', ')

                if entity == @game.london_company
                    @log << "London Investment closes"
                    li =  @game.companies.find { |c| c.sym == 'P4' }
                    li.close! if li
                end
                log_payout_shares(entity, revenue, per_share, receivers)
            end           
        end
      end
    end
  end
end
