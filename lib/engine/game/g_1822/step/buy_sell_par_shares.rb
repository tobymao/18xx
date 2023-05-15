# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative 'bidbox_auction'

module Engine
  module Game
    module G1822
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          include BidboxAuction

          def actions(entity)
            return ['choose_ability'] unless choices_ability(entity).empty?
            return [] unless entity == current_entity
            return ['sell_shares'] if must_sell?(entity)

            # You can either buy shares or you can use your bidding tokens, you can always sell shares
            player_debt = @game.player_debt(entity)
            actions = []
            actions << 'buy_shares' if @bid_actions.zero? && can_buy_any?(entity) && player_debt.zero?
            actions << 'par' if @bid_actions.zero? && can_ipo_any?(entity) && player_debt.zero?
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'bid' if player_debt.zero?
            actions << 'payoff_player_debt' if player_debt.positive? && entity.cash.positive?
            actions << 'pass' unless actions.empty?
            actions
          end

          def choices_ability(entity)
            return {} unless entity.company?

            choices = @game.company_choices(entity, :stock_round)
            if !choices.empty? && entity.id == @game.class::COMPANY_OSTH &&
                (@bid_actions.positive? || @game.player_debt(entity.owner).positive?)
              return {}
            end

            choices
          end

          def available_cash(entity)
            entity.cash - committed_cash(entity)
          end

          def available_par_cash(entity, corporation, share_price: nil)
            available = available_cash(entity)
            if corporation.par_via_exchange
              available += if share_price && corporation.id == 'LNWR'
                             share_price.price
                           else
                             corporation.par_via_exchange.value
                           end
            end
            available
          end

          def can_buy?(entity, bundle, available_cash: nil)
            return unless bundle&.buyable

            corporation = bundle.corporation
            return unless corporation.type == :major

            exchange_bundle = bundle.is_a?(ShareBundle) ? bundle : ShareBundle.new(bundle)
            exchange = exchange_bundle.presidents_share && @game.phase.status.include?('can_convert_concessions')
            cash = available_cash || available_cash(entity)
            cash >= bundle.price &&
              !@round.players_sold[entity][corporation] &&
              (can_buy_multiple?(entity, corporation, bundle.owner) || !bought?) &&
              can_gain?(entity, bundle, exchange: exchange)
          end

          def can_buy_any_from_ipo?(entity)
            @game.corporations.select { |c| c.type == :major }.each do |corporation|
              next unless corporation.ipoed
              return true if can_buy_shares?(entity, corporation.shares)
            end

            false
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity

            corporation = bundle.corporation
            corporation.holding_ok?(entity, bundle.percent) &&
              (!corporation.counts_for_limit || exchange || num_certs_with_bids(entity) < @game.cert_limit)
          end

          def can_ipo_any?(entity)
            !bought? && @game.corporations.select { |c| c.type == :major }.any? do |corporation|
              @game.can_par?(corporation, entity) &&
                can_buy?(entity, corporation.shares.first&.to_bundle,
                         available_cash: available_par_cash(entity, corporation))
            end
          end

          def num_certs_with_bids(entity)
            @game.num_certs(entity) + bids_for_player(entity, only_committed_bids: true).size
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

          def must_sell?(entity)
            return false unless can_sell_any?(entity)

            @game.num_certs(entity) > @game.cert_limit
          end

          def pass!
            # This should only be updated at the end of the round, not after each bid.
            @round.update_stored_winning_bids(current_entity)
            store_bids!
            super
          end

          def pass_description
            return 'Pass (Bids)' if @bid_actions.positive?

            'Pass'
          end

          def process_bid(action)
            @game.something_sold_in_sr! if @game.nothing_sold_in_sr?
            action.entity.unpass!
            add_bid(action)
            store_bids!
          end

          def process_buy_shares(action)
            super
            log_pass(action.entity)
            pass!
          end

          def process_choose_ability(action)
            unless action.entity.id == @game.class::COMPANY_OSTH
              return @game.company_made_choice(action.entity, action.choice, :stock_round)
            end

            bundle = @game.company_tax_haven_bundle(action.choice)
            entity = action.entity.owner
            if available_cash(entity) < bundle.price || @round.players_sold[entity][bundle.corporation]
              raise GameError, "Can't buy a share of #{bundle&.corporation&.name}"
            end

            @game.company_made_choice(action.entity, action.choice, :stock_round)
            track_action(action, action.entity)
            log_pass(entity)
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
              track_action(action, corporation)
            else
              super
            end

            log_pass(action.entity)
            pass!
          end

          def process_payoff_player_debt(action)
            player = action.entity
            @game.payoff_player_loan(player)
            @round.last_to_act = player
            @round.current_actions << action
          end

          def setup
            # This sets the initial value of @bids
            setup_auction
            super

            @bid_actions = 0
            @bids = @round.bids if @round.bids
            # Set initial value of @bids on the round if there's none.
            @round.bids = @bids unless @round.bids
          end

          def bidding_tokens(player)
            @game.bidding_token_per_player - (bids_for_player(player)&.size || 0)
          end

          def can_bid_company?(entity, company)
            return false unless num_certs_with_bids(entity) < @game.cert_limit
            return false if max_bid(entity, company) < min_bid(company) || highest_player_bid?(entity, company)

            !(!find_bid(entity, company) && bidding_tokens(entity).zero?)
          end

          def store_bids!
            @round.bids = @bids
          end

          def action_is_shenanigan?(entity, other_entity, action, corporation, share_to_buy)
            if action.is_a?(Action::Bid)
              stored_winning_bids = @round.stored_winning_bids(entity)
              # The parameter is named corporation, but it can be a minor or company as well.
              return "No longer winning bid on #{corporation.id}" if stored_winning_bids.include?(corporation)

              # Any other bid is fine (probably).
              return
            end

            # Off shore cannot cause presidency shift, ignore
            return if action.is_a?(Action::Choose) && action.entity.id == @game.class::COMPANY_OSTH

            super
          end

          protected

          def add_bid(action)
            super

            company = action.company
            price = action.price
            entity = action.entity

            track_action(action, bid_target(action))

            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{company.name}"
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
