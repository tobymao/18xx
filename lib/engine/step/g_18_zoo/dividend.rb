# frozen_string_literal: true

require_relative '../dividend'

module Engine
  module Step
    module G18ZOO
      class Dividend < Engine::Step::Dividend

        def dividend_options(entity)
          revenue = @game.routes_revenue(routes)

          dividend_types.map do |type|
            [type, send(type, entity, revenue)]
          end.to_h
        end

        def withhold(_entity, revenue)
          {corporation: (revenue / 25).ceil, per_share: 0, share_direction: :left, share_times: 1, divs_to_corporation: 0}
        end

        def payout(entity, revenue)
          {corporation: 0, per_share: payout_per_share(entity, revenue), share_direction: share_price_change(entity, revenue), share_times: 1, divs_to_corporation: 0}
        end

        def payout_per_share(entity, revenue)
          if revenue >= threshold(entity)
            share_price = @game.stock_market.find_share_price(entity, :left).price #TODO check how to get the next on right / top
            payout_per_share = bonus_payout_for_share(entity) #TODO should be the following
          else
            payout_per_share = bonus_payout_for_share(entity)
          end
          payout_per_share
        end

        def share_price_change(entity, revenue)
          share_direction = nil
          if revenue >= threshold(entity)
            share_direction = :right
          end
          share_direction
        end

        def dividends_for_entity(entity, holder, per_share)
          holder.player? ? super : 0
        end

        def payout_shares(entity, revenue)
          super

          bonus = bonus_payout_for_president(entity)
          if bonus > 0
            @game.bank.spend(bonus, entity.player, check_positive: false)
            @log << "#{entity.name} pays out #{@game.format_currency(bonus)} as bonus to family owner #{entity.player.name}"
          end
        end

        def process_dividend(action)
          water_gain = routes.sum { |r| r.stops.sum { |s| s.tile.towns.any? ? 1 : 0 } }
          @game.bank.spend(water_gain, action.entity, check_positive: false) unless water_gain.zero?
          @log << "Company withholds #{@game.format_currency(water_gain)} running into water tiles" unless water_gain.zero?

          super
        end

        private

        def market_info(entity)
          @game.market_infos[entity.share_price.coordinates[0]][entity.share_price.coordinates[1]]
        end

        def bonus_payout_for_share(entity)
          market_info(entity)[:share_value][0] || 0
        end

        def bonus_payout_for_president(entity)
          market_info(entity)[:share_value][1] || 0
        end

        def threshold(entity)
          market_info(entity)[:threshold]
        end

      end
    end
  end
end
