# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1844
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def round_state
            super.merge(
              {
                players_purchased_companies: Hash.new { |h, k| h[k] = [] },
              }
            )
          end

          def can_buy_company?(player, company)
            return false unless super

            companies_of_type = []
            if @game.mountain_railways.include?(company)
              companies_of_type = @game.mountain_railways
            elsif @game.tunnel_companies.include?(company)
              companies_of_type = @game.tunnel_companies
            end
            @round.players_purchased_companies[player].none? { |c| companies_of_type.include?(c) }
          end

          def process_buy_company(action)
            super
            @round.players_purchased_companies[action.entity] << action.company
          end
        end
      end
    end
  end
end
