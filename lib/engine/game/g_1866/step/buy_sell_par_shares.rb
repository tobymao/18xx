# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1866
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            return ['choose_ability'] unless choices_ability(entity).empty?

            super
          end

          def can_par_share_price?(share_price, corp)
            return (share_price.corporations.empty? || share_price.price == 200) unless corp

            share_price.corporations.none? { |c| c.type != :stock_turn_corporation } || share_price.price == 200
          end

          def choices_ability(entity)
            return {} if !entity.company? || (entity.company? && !@game.stock_turn_token_company?(entity))

            choices = {}
            get_par_prices(entity.owner, nil).reverse_each do |p|
              par_str = @game.par_price_str(p)
              choices[par_str] = par_str
            end
            choices
          end

          def description
            'Initial Stock Round'
          end

          def get_par_prices(entity, corp)
            par_type = @game.phase_par_type
            @game.stock_market.par_prices.select do |p|
              multiplier = if !corp || corp.type == :shipping
                             1
                           else
                             2
                           end
              p.types.include?(par_type) && p.price * multiplier <= entity.cash && can_par_share_price?(p, corp)
            end
          end

          def process_choose_ability(action)
            entity = action.entity
            choice = action.choice
            share_price = nil
            get_par_prices(entity.owner, nil).each do |p|
              next unless choice == @game.par_price_str(p)

              share_price = p
            end
            return unless share_price

            @game.purchase_stock_turn_token(entity.owner, share_price)
            track_action(action, entity.owner)
            log_pass(entity.owner)
            pass!
          end

          def process_par(action)
            share_price = action.share_price
            corporation = action.corporation
            entity = action.entity
            raise GameError, "#{corporation} can't be parred" unless @game.can_par?(corporation, entity)

            if corporation.par_via_exchange
              @game.stock_market.set_par(corporation, share_price)
              share = corporation.ipo_shares.first
              bundle = share.to_bundle
              @game.share_pool.buy_shares(action.entity,
                                          bundle,
                                          exchange: corporation.par_via_exchange,
                                          exchange_price: bundle.price)

              # Close the concession company
              corporation.par_via_exchange.close!

              @game.after_par(corporation)
              track_action(action, corporation)
            else
              super
            end

            log_pass(action.entity)
            pass!
          end
        end
      end
    end
  end
end
