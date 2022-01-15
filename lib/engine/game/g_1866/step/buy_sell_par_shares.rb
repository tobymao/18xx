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
            return (share_price.corporations.empty? || share_price.price == @game.class::MAX_PAR_VALUE) unless corp

            share_price.corporations.none? { |c| c.type != :stock_turn_corporation } ||
              share_price.price == @game.class::MAX_PAR_VALUE
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
            return get_minor_national_par_prices(entity, corp) if @game.minor_national_corporation?(corp)

            par_type = @game.phase_par_type(corp)
            par_prices = @game.stock_market.par_prices.select do |p|
              multiplier = !corp ? 1 : 2
              p.types.include?(par_type) && p.price * multiplier <= entity.cash && can_par_share_price?(p, corp)
            end
            par_prices.reject! { |p| p.price == @game.class::MAX_PAR_VALUE } if par_prices.size > 1
            par_prices
          end

          def get_minor_national_par_prices(entity, corp)
            par_rows = @game.class::MINOR_NATIONAL_PAR_ROWS[corp.name]
            share_price = @game.stock_market.share_price(par_rows[0], par_rows[1])
            return [] unless share_price.price <= entity.cash

            [share_price]
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

              # Remove the money from the national and put it into the bank
              corporation.spend(corporation.cash, @game.bank)

              # Close the concession company
              corporation.par_via_exchange.close!

              @game.after_par(corporation)
              track_action(action, corporation)

            elsif @game.minor_national_corporation?(corporation)
              @game.stock_market.set_par(corporation, share_price)
              share = corporation.ipo_shares.first
              bundle = share.to_bundle
              @game.share_pool.buy_shares(action.entity,
                                          bundle,
                                          exchange: :free,
                                          exchange_price: share.price_per_share)

              # Remove the money from the minor national and put it into the bank
              corporation.spend(corporation.cash, @game.bank)

              @game.after_par(corporation)
              track_action(action, action.corporation)
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
