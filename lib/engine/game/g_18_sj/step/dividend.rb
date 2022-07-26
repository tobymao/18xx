# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G18SJ
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::MinorHalfPay

          ONLY_PAYOUT = %i[payout].freeze

          def share_price_change(entity, revenue = 0)
            return {} if entity.minor? || @game.bot_corporation?(entity)

            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } if revenue.zero? && entity.player != @game.edelsward

            times = 0
            times = 1 if revenue >= price
            times = 2 if revenue >= price * 2 && price > 82
            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end

          def process_dividend(action)
            super

            # Do some clean up for the entity in the OR
            @game.clean_up_after_dividend(action.entity)
          end

          def dividend_types
            if @game.two_player_variant && @game.bot_corporation?(current_entity) &&
              !current_entity.trains.empty? && @game.routes_revenue(routes).positive?
              return ONLY_PAYOUT
            end

            super
          end

          def change_share_price(entity, payout)
            return if @game.two_player_variant && @game.bot_corporation?(entity)

            super
          end
        end
      end
    end
  end
end
