# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G21Moon
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            return ['sell_shares'] if entity&.corporation? && entity&.owner == current_entity && can_ipo_issue?(entity)
            return [] if @issued

            super
          end

          def can_ipo_any?(entity)
            !bought? && @game.corporations.any? do |c|
              @game.can_par?(c, entity) && can_buy?(entity, c.ipo_shares.first&.to_bundle)
            end
          end

          def can_buy_any?(entity)
            (can_buy_any_from_market?(entity) || can_buy_any_from_ipo?(entity))
          end

          def can_buy_any_from_ipo?(entity)
            @game.corporations.each do |corporation|
              next unless corporation.ipoed
              return true if can_buy_shares?(entity, corporation.ipo_shares)
            end

            false
          end

          def can_ipo_issue?(corp)
            corp&.corporation? && corp&.ipoed && @round.parred[corp] && !@round.issued[corp] && !bought? && !sold?
          end

          def parred_this_round?(corp)
            @round.players_history[corp.owner][corp].include?(Action::Par)
          end

          def process_par(action)
            super

            @round.parred[action.corporation] = true
          end

          def process_sell_shares(action)
            return issue_shares(action.entity, action.bundle) if action.entity.corporation?

            super
          end

          def buy_shares(entity, shares, exchange: nil, swap: nil, allow_president_change: true)
            corp = shares.corporation
            if shares.owner == corp.ipo_owner
              # IPO shares pay corporation
              @game.share_pool.buy_shares(entity,
                                          shares,
                                          exchange: exchange,
                                          swap: swap,
                                          allow_president_change: allow_president_change)
              price = corp.share_price.price * shares.num_shares
              @game.bank.spend(price, corp)
            else
              super
            end
          end

          def issue_shares(corp, bundle)
            floated = corp.floated?

            @log << "#{corp.name} issues #{share_str(bundle)} of #{corp.name} to the market"\
                    " and receives #{@game.format_currency(bundle.price)}"
            @game.share_pool.transfer_shares(bundle,
                                             @game.share_pool,
                                             spender: @game.bank,
                                             receiver: corp)

            @game.float_corporation(corp) if corp.floatable && floated != corp.floated?

            @issued = true
            @round.issued[corp] = true
            @round.current_actions << :issue
          end

          def share_str(bundle)
            num_shares = bundle.num_shares
            return "a #{bundle.percent}% IPO share" if num_shares == 1

            "#{num_shares} IPO shares"
          end

          # can only issue up to number of shares president has
          def issuable_shares(entity)
            return [] if bought? || sold?

            shares = @game.bundles_for_corporation(@game.bank, entity) # IPO shares are in bank
            shares.reject { |bundle| bundle.num_shares > entity.owner.num_shares_of(entity) }
          end

          def setup
            @issued = false
            super
          end

          def round_state
            super.merge(
              {
                parred: {},
                issued: {},
              }
            )
          end
        end
      end
    end
  end
end
