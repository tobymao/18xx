# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares_companies'
require_relative 'minor_exchange'

module Engine
  module Game
    module G18Ardennes
      module Step
        class BuySellParSharesCompanies < Engine::Step::BuySellParSharesCompanies
          include MinorExchange

          def actions(entity)
            return super unless under_obligation?(entity)

            if @game.bankrupt?(entity)
              %w[bankrupt]
            elsif can_sell_any?(entity)
              %w[sell_shares par]
            else
              %w[par]
            end
          end

          def bankruptcy_description(player)
            concession = player.companies
                               .select { |c| c.type == :concession }
                               .min { |c| @game.min_concession_cost(c) }

            "#{player.name} needs at least " \
              "#{@game.format_currency(@game.min_concession_cost(concession))} " \
              "to start #{concession.name} but can only raise " \
              "#{@game.format_currency(@game.liquidity(player))}."
          end

          def sellable_companies(entity)
            # Only the GL is sellable. Make sure concessions aren't visible.
            super.select { |company| company.type == :minor }
          end

          # Corporations whose cards are visible in the stock round.
          # Hide those whose concessions have not yet been auctioned.
          def visible_corporations
            @game.major_corporations.select do |corporation|
              corporation.floated || !corporation.par_via_exchange.owner.nil?
            end
          end

          # Valid par prices for public companies.
          def get_par_prices(_player, _corporation)
            @game.stock_market.par_prices.select { |pp| pp.types.include?(:par_2) }
          end

          # This function is called from View::Game::Par to calculate how many
          # shares can be bought at each possible par price. In 18Ardennes you
          # get an extra share when floating a public company, part paid for by
          # exchanging the pledged minor, so pretend that the player has extra
          # cash to pay for this extra share.
          def available_par_cash(player, corporation, share_price: nil)
            minor = @game.pledged_minors[corporation]
            available_cash(player) + @game.minor_sale_value(minor, share_price)
          end

          def process_par(action)
            super

            major = action.corporation
            minor = @game.pledged_minors[major]
            concession = major.par_via_exchange

            concession.close!
            exchange_minor(minor, major)
          end

          def process_bankrupt(action)
            player = action.entity

            # All shares and the GL go to the bank pool.
            # Concessions can be purchased by another player in a future auction.
            sell_bankrupt_shares(player)
            player.companies.each do |company|
              company.owner = company.type == :minor ? @game.bank : nil
            end
            player.companies.clear

            player.spend(player.cash, @game.bank) if player.cash.positive?
            @game.declare_bankrupt(player)
          end

          private

          # Has the player won any auctions for public companies in the
          # preceding auction round? If they have then they must start these
          # majors before they can buy any other shares or pass.
          def under_obligation?(player)
            return false unless player == current_entity
            return false if bought? # Already started a corporation this turn.

            player.companies.any? { |company| company.type == :concession }
          end

          def sell_bankrupt_shares(player)
            @log << "-- #{player.name} goes bankrupt and sells remaining shares --"

            player.shares_by_corporation.each do |corporation, shares|
              next if shares.empty?

              bundles = @game.bundles_for_corporation(player, corporation)
              @game.share_pool.sell_shares(bundles.last)
            end
          end
        end
      end
    end
  end
end
