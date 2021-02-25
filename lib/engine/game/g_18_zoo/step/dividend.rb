# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        class Dividend < Engine::Step::Dividend
          def dividend_options(entity)
            revenue = @game.routes_revenue(routes)

            dividend_types.map do |type|
              [type, send(type, entity, revenue)]
            end.to_h
          end

          def log_run_payout(entity, kind, revenue, action, payout)
            unless Dividend::DIVIDEND_TYPES.include?(kind)
              @log << "#{entity.name} runs for #{revenue} and pays #{action.kind}"
            end

            if payout[:corporation].positive?
              @log << "#{entity.name} withholds #{@game.format_currency(payout[:corporation])}"
            elsif payout[:per_share].zero?
              @log << "#{entity.name} does not run"
            end
          end

          def share_price_change(entity, revenue)
            :right if revenue >= threshold(entity)
          end

          def withhold(_entity, revenue)
            {
              corporation: (revenue / 25).ceil,
              per_share: 0,
              share_direction: :left,
              share_times: 1,
              divs_to_corporation: 0,
            }
          end

          def payout(entity, revenue)
            {
              corporation: 0,
              per_share: payout_per_share(entity, revenue),
              share_direction: share_price_change(entity, revenue),
              share_times: 1,
              divs_to_corporation: 0,
            }
          end

          def dividends_for_entity(entity, holder, per_share)
            holder.player? ? super : 0
          end

          def payout_per_share(entity, revenue)
            bonus_payout_for_share(share_price_updated(entity, revenue))
          end

          def payout_shares(entity, revenue)
            super

            bonus = bonus_payout_for_president(share_price_updated(entity, revenue))
            return unless bonus.positive?

            @game.bank.spend(bonus, entity.player, check_positive: false)
            @log << "Family owner #{entity.player.name} earns #{@game.format_currency(bonus)}"\
              " as bonus from #{entity.name} run"
          end

          private

          def share_price_updated(entity, revenue)
            return @game.stock_market.find_share_price(entity, :right) if revenue >= threshold(entity)

            @game.stock_market.find_share_price(entity, :stay)
          end

          def bonus_payout_for_share(share_price)
            G18ZOO::Game::STOCKMARKET_GAIN[share_price.coordinates[0]][share_price.coordinates[1]]
          end

          def bonus_payout_for_president(share_price)
            return 0 if share_price.coordinates[0] > 0

            G18ZOO::Game::STOCKMARKET_OWNER_GAIN[share_price.coordinates[1]] || 0
          end

          def threshold(entity)
            G18ZOO::Game::STOCKMARKET_THRESHOLD[entity.share_price.coordinates[0]][entity.share_price.coordinates[1]]
          end
        end
      end
    end
  end
end
