# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1824
      module Step
        class BuySellParSharesFirstSr < Engine::Step::BuySellParShares
          def can_buy_company?(_player, _company)
            !bought?
          end

          def can_buy?(_entity, bundle)
            super && @game.buyable?(bundle.corporation)
          end

          def can_sell?(_entity, bundle)
            super && @game.buyable?(bundle.corporation)
          end

          def can_gain?(_entity, bundle, exchange: false)
            return false if exchange

            super && @game.buyable?(bundle.corporation)
          end

          def can_exchange?(_entity)
            false
          end

          def process_buy_company(action)
            entity = action.entity
            company = action.company
            price = action.price
            company.value = price

            super

            minor = @game.minor_by_id(company.id)
            return unless (minor = @game.minor_by_id(company.id))
            return buy_pre_staatsbahn(minor, entity, action) if @game.pre_staatsbahn?(minor)

            buy_coal_railway(minor, entity, price)
          end

          private

          def buy_pre_staatsbahn(pre_staatsbahn, buyer, action)
            treasury = action.price
            @game.log << "Pre-Staatsbahn #{pre_staatsbahn.full_name} floats and receives "\
                         "#{@game.format_currency(treasury)} in treasury"
            pre_staatsbahn.owner = buyer
            pre_staatsbahn.float!
            @game.bank.spend(treasury, pre_staatsbahn)
          end

          def buy_coal_railway(coal_railway, buyer, price)
            regional_railway = @game.associated_regional_railway(coal_railway)

            coal_railway.owner = buyer
            coal_railway.float!
            @game.bank.spend(price, coal_railway)
            g_train = @game.depot.upcoming.select { |t| @game.g_train?(t) }.shift
            treasury = price - g_train.price
            @game.log << "#{coal_railway.name} floats and buys a #{g_train.name} train from the depot "\
                         "for #{@game.format_currency(g_train.price)} and remaining #{@game.format_currency(treasury)} "\
                         'is put in treasury'
            @game.buy_train(coal_railway, g_train, g_train.price)

            share_price = @game.stock_market.par_prices.find { |s| s.price == price / 2 }
            regional_railway.ipoed = true
            @game.stock_market.set_par(regional_railway, share_price)
            @game.log << "#{buyer.name} pars #{regional_railway.name} at #{@game.format_currency(share_price.price)}"
          end
        end
      end
    end
  end
end
