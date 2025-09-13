# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1862Solo
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          ACTIONS = %w[buy_company pass].freeze
          UNCHARTERED_TOKEN_COST = 40

          def actions(entity)
            return [] unless entity == current_entity

            actions = ACTIONS.dup
            actions << 'sell_shares' if can_sell_any?(entity)
            actions
          end

          # Shares only bought as companies
          def visible_corporations
            []
          end

          # Shares should not appear in market
          def can_buy?(entity, bundle)
            true
          end

          # Shares only bought as companies
          def can_buy_any?(entity)
            true
          end

          # Shares only bought as companies
          def can_ipo_any?(entity)
            false
          end

          def pool_shares(_)
            []
          end

          def purchasable_companies(_)
            []
          end

          def can_buy_company?(player, company)
            result = @game.ipo_rows.flatten.include?(company) && available_cash(player) >= company.value
            puts "Can #{player.name} buy #{company.name}? #{result}, included? #{@game.buyable_bank_owned_companies.include?(company)}, available cash? #{available_cash(player) >= company.value}, company value? #{company.value}"
            result
          end

          def process_par(action)
            corporation = action.corporation
            @game.convert_to_incremental!(corporation)
            corporation.tokens.pop # 3 -> 2
            raise GameError, 'Wrong number of tokens for Unchartered Company' if corporation.tokens.size != 2

            super
          end

          def get_par_prices(entity, _corp)
            @game.repar_prices.select { |p| p.price * 3 <= entity.cash }
          end
        end
      end
    end
  end
end
