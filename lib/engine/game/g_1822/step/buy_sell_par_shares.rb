# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative 'bidbox_auction'

module Engine
  module Game
    module G1822
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          include BidboxAuction

          attr_accessor :bidders, :bid_actions

          def actions(entity)
            return [] unless entity == current_entity
            return ['sell_shares'] if must_sell?(entity)

            # You can either buy shares or you can use your bidding tokens, you can always sell shares
            player_debt = @game.player_debt(entity)
            actions = []
            actions << 'buy_shares' if @bid_actions.zero? && can_buy_any?(entity) && player_debt.zero?
            actions << 'par' if @bid_actions.zero? && can_ipo_any?(entity) && player_debt.zero?
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'bid' if player_debt.zero?
            actions << 'payoff_player_debt' if player_debt.positive? && entity.cash >= player_debt
            actions << 'pass' unless actions.empty?
            actions
          end

          def available_cash(entity)
            entity.cash - committed_cash(entity)
          end

          def available_par_cash(entity, corporation)
            available = available_cash(entity)
            available += corporation.par_via_exchange.value if corporation.par_via_exchange
            available
          end

          def can_buy?(entity, bundle, available_cash: nil)
            return unless bundle&.buyable

            corporation = bundle.corporation
            return unless corporation.type == :major

            cash = available_cash || available_cash(entity)
            cash >= bundle.price &&
              !@round.players_sold[entity][corporation] &&
              (can_buy_multiple?(entity, corporation) || !bought?) &&
              can_gain?(entity, bundle)
          end

          def can_buy_any_from_ipo?(entity)
            @game.corporations.select { |c| c.type == :major }.each do |corporation|
              next unless corporation.ipoed
              return true if can_buy_shares?(entity, corporation.shares)
            end

            false
          end

          def can_ipo_any?(entity)
            !bought? && @game.corporations.select { |c| c.type == :major }.any? do |corporation|
              @game.can_par?(corporation, entity) &&
                can_buy?(entity, corporation.shares.first&.to_bundle,
                         available_cash: available_par_cash(entity, corporation))
            end
          end

          def description
            'Bid, convert concession or buy/sell shares'
          end

          def get_par_prices(entity, corporation)
            share_multiplier = corporation.shares.first.percent / 10
            available_cash = available_par_cash(entity, corporation)

            # Only get the par price for the majors
            @game.stock_market.share_prices_with_types(%i[par_1])
              .select { |p| p.price * share_multiplier <= available_cash }
          end

          def log_pass(entity)
            @log << "#{entity.name} passes"
          end

          def pass!
            @round.bidders = @bidders
            @round.bids = @bids
            super
          end

          def pass_description
            return 'Pass (Bids)' if @bid_actions.positive?

            'Pass'
          end

          def process_bid(action)
            action.entity.unpass!
            add_bid(action)
          end

          def process_buy_shares(action)
            super
            log_pass(action.entity)
            pass!
          end

          def process_par(action)
            share_price = action.share_price
            corporation = action.corporation
            entity = action.entity
            raise GameError, "#{corporation} can't be parred" unless @game.can_par?(corporation, entity)

            if corporation.par_via_exchange
              share = corporation.shares.first
              bundle = share.to_bundle
              unless can_buy?(entity, bundle, available_cash: available_par_cash(entity, corporation))
                raise GameError, "Can't buy a share of #{bundle&.corporation&.name}"
              end

              # Calculate the correct price of the exchange
              share_multiplier = bundle.percent / 10
              exchange_price = (share_price.price * share_multiplier) - corporation.par_via_exchange.value
              exchange_price = nil if exchange_price.negative?

              @game.stock_market.set_par(corporation, share_price)
              @game.share_pool.buy_shares(action.entity,
                                          bundle,
                                          exchange: corporation.par_via_exchange,
                                          exchange_price: exchange_price)

              # Add the missing money for the concession into the corporation from the bank
              concession_money = (exchange_price ? corporation.par_via_exchange.value : share_price.price)
              @game.bank.spend(concession_money, corporation)

              # Close the concession company
              corporation.par_via_exchange.close!

              @game.after_par(corporation)
              @round.last_to_act = entity
              @current_actions << action
            else
              super
            end

            log_pass(action.entity)
            pass!
          end

          def process_payoff_player_debt(action)
            entity = action.entity

            player_debt = @game.player_debt(entity)
            entity.check_cash(player_debt)
            @log << "#{entity.name} pays off its loan of #{@game.format_currency(player_debt)}"

            @game.payoff_player_loan(entity)
          end

          def setup
            setup_auction
            super

            @bid_actions = 0
            @bidders = @round.bidders || Hash.new { |h, k| h[k] = [] }
            @bids = @round.bids if @round.bids
          end

          def bidding_tokens(player)
            @game.bidding_token_per_player - (bids_for_player(player)&.size || 0)
          end

          def can_bid?(entity, company)
            return false if max_bid(entity, company) < min_bid(company) || highest_player_bid?(entity, company)

            !(!find_bid(entity, company) && bidding_tokens(entity).zero?)
          end

          protected

          def add_bid(action)
            super

            company = action.company
            price = action.price
            entity = action.entity

            @bidders[company] |= [entity]

            @current_actions << action
            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{company.name}"
            @round.last_to_act = action.entity
            @bid_actions += 1

            return if @bid_actions < @game.class::BIDDING_TOKENS_PER_ACTION

            log_pass(entity)
            pass!
          end
        end
      end
    end
  end
end
