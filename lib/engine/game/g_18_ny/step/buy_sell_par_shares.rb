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
            return corporate_actions(entity) if entity.corporation? && entity.owned_by?(current_entity)
            return %w[buy_shares sell_shares] if entity.player? && mandatory_nyc_buy?(entity)

            actions = super
            actions << 'pass' if entity.player? && actions.empty? && players_corporations_have_actions?(entity)
            actions
          end

          def corporate_actions(entity)
            return [] unless @round.current_actions.empty?
            return [] if entity.type == :minor
            return [] if !entity.operated? && (entity != @game.nyc_corporation || !@game.nyc_formed?)

            actions = []
            actions << 'sell_shares' unless @game.issuable_shares(entity).empty?
            actions << 'buy_shares' unless @game.redeemable_shares(entity).empty?
            actions
          end

          def players_corporations_have_actions?(player)
            @game.corporations.any? { |c| c.owner == player && !corporate_actions(c).empty? }
          end

          def visible_corporations
            @game.sorted_corporations.reject { |c| c.closed? || (c.type == :minor && c.ipoed) }
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
            share_corp = action.bundle.corporation
            super
            @game.fully_capitalize_corporation(share_corp) if @game.can_fully_capitalize?(share_corp)
            pass! if action.entity.corporation?
          end

          def process_sell_shares(action)
            super
            pass! if action.entity.corporation?
          end

          def mandatory_nyc_buy?(entity)
            @game.nyc_corporation.presidents_share.owner == @game.nyc_corporation &&
              @game.first_nyc_owner == entity
          end

          def can_buy?(entity, bundle)
            return false if mandatory_nyc_buy?(entity) && bundle.corporation != @game.nyc_corporation
            return false if bundle.presidents_share&.owner == @game.nyc_corporation

            super
          end

          def can_sell?(entity, bundle)
            return false if mandatory_nyc_buy?(entity) && bundle.corporation == @game.nyc_corporation

            super
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

            @log << "#{corporation.name} receives #{@game.format_currency(bid)} in its Treasury"
            additional_cash = bid - (share_price.price * 2)
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
