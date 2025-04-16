# frozen_string_literal: true

require_relative '../../g_1867/step/buy_sell_par_shares'

module Engine
  module Game
    module G1807
      module Step
        class BuySellParShares < G1867::Step::BuySellParShares
          def bank_first?
            # Show the private companies before minors/public companies/systems.
            true
          end

          def can_bid_any?(player)
            super || auctionable_companies.any? { |c| can_bid_company?(player, c) }
          end

          def can_bid_company?(player, company)
            (!@auctioning || @auctioning == company) &&
              auctionable_companies.include?(company) &&
              (min_bid(company) <= player.cash)
          end

          def can_buy_company?(_player, _company)
            false
          end

          def max_bid(player, _entity)
            return 0 unless @game.num_certs(player) < @game.cert_limit

            player.cash
          end

          def min_bid(entity)
            return highest_bid(entity).price + min_increment if @auctioning

            entity.company? ? entity.min_bid : MIN_BID
          end

          def win_bid(bid, _company)
            return super if bid.corporation

            player = bid.entity
            company = bid.company
            price = bid.price

            @log << "#{player.name} wins the auction for #{company.name} "\
                    "with a bid of #{@game.format_currency(price)}"

            player.spend(price, @game.bank)
            company.owner = player
            player.companies << company
          end

          private

          def auctionable_companies
            @game.buyable_bank_owned_companies
          end
        end
      end
    end
  end
end
