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

          def actions(entity)
            actions = super.dup
            actions << 'payoff_player_debt' if can_payoff_debt?(entity)
            actions
          end

          def help
            return super unless indebted?(current_entity)

            "#{current_entity.name} cannot buy until they payoff their #{@game.format_currency(current_entity.debt)} loan. "\
              "#{current_entity.name} has #{@game.format_currency(current_entity.cash)} in cash."
          end

          def can_gain?(entity, bundle, exchange: false)
            # Can buy above the share limit if from the share pool
            return true if bundle.owner == @game.share_pool && @game.num_certs(entity) < @game.cert_limit

            super
          end

          def get_par_prices(entity, _corp)
            @game.stock_market.share_prices_with_types([:par]).select { |p| p.price * 2 <= available_cash(entity) }
          end

          def can_buy_any?(entity)
            !indebted?(entity) && super
          end

          def can_buy_company?(player, company)
            return false if indebted?(player) || !super

            companies_of_type = []
            if @game.mountain_railways.include?(company)
              companies_of_type = @game.mountain_railways
            elsif @game.tunnel_companies.include?(company)
              companies_of_type = @game.tunnel_companies
            end
            @round.players_purchased_companies[player].none? { |c| companies_of_type.include?(c) }
          end

          def can_payoff_debt?(entity)
            indebted?(entity) && entity.cash.positive?
          end

          def process_buy_company(action)
            super
            @round.players_purchased_companies[action.entity] << action.company
          end

          def process_payoff_player_debt(action)
            @game.payoff_player_loan(action.entity)
          end

          def indebted?(entity)
            entity.player? && entity.debt.positive?
          end
        end
      end
    end
  end
end
