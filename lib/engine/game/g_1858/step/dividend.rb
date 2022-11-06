# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1858
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze

          def actions(entity)
            return [] unless entity.corporation?
            return [] if total_revenue(entity).zero?

            ACTIONS
          end

          def total_revenue(entity)
            @game.routes_revenue(routes) + entity.companies.sum(&:revenue)
          end

          def dividend_adjustment(entity)
            entity.companies.sum(&:revenue)
          end

          def process_dividend(action)
            return if action.entity.minor?

            super
            @game.close_companies(action.entity)
          end

          def rust_obsolete_trains!(_entity)
            # Wounded trains are not discarded after running
          end

          def share_price_change(entity, revenue = 0)
            price = entity.share_price.price
            per_share = payout_per_share(entity, revenue)

            if revenue.zero?
              { share_direction: :left, share_times: 1 }
            elsif per_share * 10 >= price
              { share_direction: :right, share_times: 1 }
            else
              {}
            end
          end

          def payout_per_share(entity, revenue)
            (revenue / entity.total_shares.to_f).floor.to_i
          end

          def payout(entity, revenue)
            # 1858 can give revenues that do not neatly divide between the
            # shareholders. This means that even on a full payout there can be
            # some money left over after paying the shareholders. This goes to
            # the company treasury.
            per_share = payout_per_share(entity, revenue)
            withheld = revenue - (per_share * entity.total_shares)
            { corporation: withheld, per_share: per_share }
          end

          def half(entity, revenue)
            per_share = payout_per_share(entity, revenue / 2)
            withheld = revenue - (per_share * entity.total_shares)
            { corporation: withheld, per_share: per_share }
          end
        end
      end
    end
  end
end
