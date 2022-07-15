# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1848
      module Step
        class Dividend < Engine::Step::Dividend
          BOE_BASE_PAYOUT = { '2' => 0, '3' => 100, '4' => 100, '5' => 200, '6' => 200, '8' => 300 }.freeze

          def actions(entity)
            return super unless entity == @game.boe

            # boe always pays if it has any revenue
            process_dividend(Action::Dividend.new(entity, kind: 'payout'))
            []
          end

          def corporation_dividends(_entity, _per_share)
            0
          end

          def change_share_price(entity, payout)
            return super unless entity == @game.boe
          end

          def dividend_options(entity)
            return super unless entity == @game.boe

            revenue = calculate_boe_revenue
            dividend_types.to_h do |type|
              payout = send(type, entity, revenue)
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
              [type, payout.merge(share_price_change(entity, revenue - payout[:corporation]))]
            end
          end

          def process_dividend(action)
            entity = action.entity
            return super unless entity == @game.boe

            kind = action.kind.to_sym
            payout = dividend_options(entity)[kind]

            payout_shares(entity, calculate_boe_revenue) if payout[:per_share].positive?
            pass!
          end

          def calculate_boe_revenue
            current_phase_name = @game.phase.current[:name]
            base_pay = BOE_BASE_PAYOUT[current_phase_name]
            cities_revenue = get_token_cities_total_revenue(@game.boe)
            base_pay + cities_revenue
          end

          def get_token_cities_total_revenue(corporation)
            @game.hexes.sum do |hex|
              hex.tile.cities.sum do |city|
                 city.tokened_by?(corporation) ? city.revenue[hex.tile.color] : 0  
              end
            end
          end
        end
      end
    end
  end
end
