# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G1894
      module Step
        class RedeemShares < Engine::Step::IssueShares
          def actions(entity)
            return [] if @game.starting_corporation_ids.include?(entity.id)

            super
          end

          def round_state
            super.merge(redeem_cash: Hash.new { |h, c| h[c] = c.cash })
          end

          def pass_description
            'Skip (Redeem/Reissue)'
          end

          def process_buy_shares(action)
            super

            action.bundle.shares.each do |share|
              share.buyable = false
            end
            @round.redeem_cash[action.entity] = 0
          end

          def process_sell_shares(action)
            corporation = action.entity

            @game.bank.spend(action.bundle.share_price * action.bundle.num_shares, corporation)

            @log << "#{corporation.name} reissues #{@game.share_pool.num_presentation(action.bundle)} "\
                    "for #{@game.format_currency(action.bundle.share_price)}"

            new_par = @game.stock_market.par_prices.find { |p| p.price == 100 }
            if new_par.price > corporation.par_price.price
              @log << "#{corporation.name}'s par price is now #{@game.format_currency(new_par.price)}"
            end
            corporation.par_price = new_par

            action.bundle.shares.each { |s| s.buyable = true }

            pass!
          end
        end
      end
    end
  end
end
