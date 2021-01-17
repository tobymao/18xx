# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1824
      class BuySellParShares < BuySellParShares
        def actions(_entity)
          result = super
          result << 'buy_company' unless result.empty?
          result
        end

        def can_buy?(_entity, bundle)
          super && @game.buyable?(bundle.corporation)
        end

        def can_sell?(_entity, bundle)
          super && @game.buyable?(bundle.corporation)
        end

        def can_gain?(_entity, bundle)
          super && @game.buyable?(bundle.corporation)
        end

        def purchasable_unsold_companies
          @game.companies.reject { |c| c.owner || c.closed? }
        end

        def process_buy_company(action)
          entity = action.entity
          company = action.company

          super

          return unless (pre_staatsbahn = @game.minor_by_id(company.id))

          treasury = action.price
          @game.log << "Pre-Staatsbahn #{pre_staatsbahn.full_name} floats and receives "\
            "#{@game.format_currency(treasury)} in treasury"
          pre_staatsbahn.owner = entity
          pre_staatsbahn.float!
          @game.bank.spend(treasury, pre_staatsbahn)
        end

        def process_par(action)
          corporation = action.corporation
          return super unless @game.coal_railway?(corporation)

          share_price = action.share_price
          coal_railway = corporation
          regional_railway = @game.associated_regional_railway(coal_railway)

          entity = action.entity
          raise GameError, "#{coal_railway.name} cannot be parred" unless @game.can_par?(corporation, entity)

          par_coal_railway(entity, share_price, coal_railway, regional_railway)
          @round.last_to_act = entity
          @current_actions << action
        end

        private

        def par_coal_railway(entity, share_price, coal_railway, regional_railway)
          share = coal_railway.shares.first
          bundle = share.to_bundle

          regional_railway.ipoed = true
          price = share_price.price
          @game.stock_market.set_par(regional_railway, share_price)
          coal_railway.par_price = share_price
          treasury = 2 * price

          @game.log << "#{entity.name} buys the presidency share of #{coal_railway.name} "\
            "for #{@game.format_currency(treasury)}"
          @game.log << "#{entity.name} pars #{regional_railway.name} at #{@game.format_currency(share_price.price)}"

          @game.share_pool.transfer_shares(
            bundle,
            entity,
            spender: entity,
            receiver: coal_railway,
            price: price
          )

          entity.spend(treasury - price, coal_railway)
          g_train = @game.depot.upcoming.select { |t| @game.g_train?(t) }.shift
          @game.log << "#{coal_railway.name} floats and buys a #{g_train.name} train from the depot "\
          "for #{@game.format_currency(g_train.price)}"
          @game.buy_train(coal_railway, g_train, g_train.price)
        end
      end
    end
  end
end
