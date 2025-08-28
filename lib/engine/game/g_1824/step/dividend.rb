# frozen_string_literal: true

require_relative '../../g_1837/step/dividend'

module Engine
  module Game
    module G1824
      module Step
        class Dividend < G1837::Step::Dividend
          def dividend_types_per_entity(entity)
            return [:payout] if @game.bond_railway?(entity)
            return DIVIDEND_TYPES if entity.type == :minor

            DIVIDEND_TYPES - [:half]
          end

          def dividend_options(entity)
            revenue = total_revenue
            dividend_types_per_entity(entity).to_h do |type|
              payout = send(type, entity, revenue)
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
              [type, payout.merge(share_price_change(entity, revenue - payout[:corporation]))]
            end
          end

          def process_dividend(action)
            entity = action.entity

            # Rule X.4: Construction regional should not get any payout - does not use cash
            return payout_for_bond_railway(entity) if @game.bond_railway?(entity)

            super
          end

          def payout_entity(entity, holder, per_share, payouts)
            return if holder.corporation? && @game.bond_railway?(holder)

            super
          end

          private

          def payout_for_bond_railway(entity)
            kind = :payout
            action = Engine::Action::Dividend.new(entity, kind: kind)
            revenue = entity.share_price.price
            payout = { share_direction: :right, share_times: 1 }
            routes = []
            routes << Engine::Route.new(
              @game,
              @game.phase,
              nil,
              connection_hexes: [],
              hexes: [entity.placed_tokens.first.hex.id],
              revenue: revenue,
              revenue_str: '',
              routes: routes
            )
            entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
              routes,
              action,
              revenue,
              @round.laid_hexes
            )
            @round.routes = []
            @round.extra_revenue = 0
            payout_shares(entity, revenue)
            change_share_price(entity, payout)
            pass!
          end
        end
      end
    end
  end
end
