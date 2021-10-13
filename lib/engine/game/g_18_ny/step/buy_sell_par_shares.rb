# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares_via_bid'

module Engine
  module Game
    module G18NY
      module Step
        class BuySellParShares < Engine::Step::BuySellParSharesViaBid
          MIN_BID = 100
          MAX_MINOR_PAR = 80

          def actions(entity)
            return corporate_actions(entity) if !entity.player? && entity.owned_by?(current_entity)

            super
          end

          def corporate_actions(entity)
            actions = []
            if @round.current_actions.none?
              actions << 'sell_shares' unless @game.issuable_shares(entity).empty?
              actions << 'buy_shares' unless @game.redeemable_shares(entity).empty?
            end
            actions
          end

          def issuable_shares(entity)
            return [] unless @round.current_actions.empty?
            return [] unless @game.check_sale_timing(entity, entity)

            # Done via Sell Shares
            @game.issuable_shares(entity)
          end

          def redeemable_shares(entity)
            return [] unless @round.current_actions.empty?
            return [] if did_sell?(entity, entity)

            # Done via Buy Shares
            @game.redeemable_shares(entity)
          end

          def process_buy_shares(action)
            super
            pass! if action.entity.corporation?
          end

          def process_sell_shares(action)
            super
            pass! if action.entity.corporation?
          end

          def can_bid?(entity)
            return false if max_bid(entity) < MIN_BID || bought?

            @game.corporations.any? { |c| c.type == :minor && @game.can_par?(c, entity) }
          end

          def win_bid(winner, _company)
            entity = winner.entity
            corporation = winner.corporation
            bid = winner.price

            @log << "#{entity.name} wins bid on #{corporation.name} for #{@game.format_currency(bid)}"

            max_share_price = [bid / 2, MAX_MINOR_PAR].min
            share_price = get_all_par_prices(corporation).find { |par| par.price <= max_share_price }
            process_par(Action::Par.new(entity, corporation: corporation, share_price: share_price))

            additional_cash = bid - share_price.price * 2
            entity.spend(additional_cash, corporation) if additional_cash.positive?

            @auctioning = nil
          end

          def can_gain?(entity, bundle, exchange: false)
            # Can buy above the share limit if from the share pool
            return true if bundle.owner == @game.share_pool && @game.num_certs(entity) < @game.cert_limit

            super
          end

          def get_all_par_prices(corp)
            types = corp.type == :major ? %i[par] : %i[par_1]
            @game.stock_market.share_prices_with_types(types)
          end

          def get_par_prices(entity, corp)
            get_all_par_prices(corp).select { |sp| sp.price * 2 <= entity.cash }
          end

          def ipo_type(entity)
            # Major's are par, minors are bid
            entity.type == :major ? :par : :bid
          end
        end
      end
    end
  end
end
