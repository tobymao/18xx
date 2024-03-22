# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18RoyalGorge
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def round_state
            super.merge(
              {
                metals_investor_bought: [],
              }
            )
          end

          def setup
            super
            @_modify_purchase_price = {}
          end

          def get_par_prices(entity, _corp)
            @game.par_prices.select { |p| p.price * 2 <= entity.cash }
          end

          def can_dump?(_entity, bundle)
            @game.president_sales_to_market?(bundle.corporation) || super
          end

          def visible_corporations
            # * hide debt company
            # * put metal companies always first
            @game.sorted_corporations.reject { |c| c.type == :debt }.sort_by { |c| c.type == :metal ? 0 : 1 }
          end

          def process_buy_shares(action)
            super
            return unless action.discounter

            case action.discounter
            when @game.mint_worker
              @log << "#{@game.mint_worker.name} closes"
              @game.mint_worker.close!
            when @game.metals_investor
              @round.metals_investor_bought << action.bundle.corporation
            end
          end

          def modify_purchase_price(bundle)
            @_modify_purchase_price[bundle] || bundle.price
          end

          def mint_worker_discounted_bundles(corporation)
            return [] unless current_entity == @game.mint_worker&.owner
            return [] unless corporation == @game.gold_corp

            (1..2).map do |num_shares|
              shares = @game.share_pool.shares_by_corporation[corporation].take(num_shares)
              bundle = ShareBundle.new(shares)
              @_modify_purchase_price[bundle] = (bundle.price / 2.0).ceil
              [@game.mint_worker, bundle]
            end
          end

          def metal_investor_discounted_bundles(corporation)
            return [] if @round.metals_investor_bought.include?(corporation)
            return [] unless current_entity == @game.metals_investor&.owner
            return [] unless [@game.gold_corp, @game.steel_corp].include?(corporation)

            share = @game.share_pool.shares_by_corporation[corporation][0]
            bundle = ShareBundle.new(share)
            @_modify_purchase_price[bundle] = @game.stock_market.find_share_price(corporation, :left).price
            [[@game.metals_investor, bundle]]
          end

          def company_discounted_bundles(corporation)
            case corporation
            when @game.gold_corp
              bundles = []
              bundles.concat(metal_investor_discounted_bundles(corporation))
              bundles.concat(mint_worker_discounted_bundles(corporation))
              bundles
            when @game.steel_corp
              metal_investor_discounted_bundles(corporation)
            else
              []
            end
          end

          def can_sell?(entity, bundle)
            corporation = bundle.corporation

            # must hold the shares bought with the metal investor discount
            if entity == @game.metals_investor&.owner &&
               [@game.gold_corp, @game.steel_corp].include?(corporation) &&
               @round.metals_investor_bought.include?(corporation) &&
               bundle.num_shares == entity.num_shares_of(corporation)
              return false
            end

            super
          end
        end
      end
    end
  end
end
