# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module GRollingStock
      module Step
        class IPOCompany < Engine::Step::Base
          def actions(entity)
            return [] if !entity.company? || entity != current_entity || !entity.owner
            return [] unless can_ipo?(entity)

            %w[par pass]
          end

          def can_ipo?(entity)
            return unless entity.company?
            return if @game.corporations.all?(&:ipoed)
            return if (par_prices = @game.available_par_prices(entity)).empty?

            par_prices.any? { |p| (p.price - entity.value) <= entity.owner.cash }
          end

          def description
            'Choose a Corporation to IPO'
          end

          def process_par(action)
            share_price = action.share_price
            corporation = action.corporation
            company = action.entity
            player = company.owner

            @log << "#{company.sym} converts to a corporation: #{corporation.full_name}"
            @log << "#{corporation.name} share price is set to #{@game.format_currency(share_price.price)}"
            @game.stock_market.set_par(corporation, share_price)

            if share_price.price >= company.value
              buy_and_issue(player, company, share_price, corporation, 1)
            elsif share_price.price * 2 >= company.value
              buy_and_issue(player, company, share_price, corporation, 2)
            else
              # we should only get here in RS not RSS
              buy_and_issue(player, company, share_price, corporation, 3)
            end

            corporation.companies << company
            company.owner = corporation
            player.companies.delete(company)
            @game.clear_synergy_income(corporation)

            pass!
          end

          def buy_and_issue(player, company, share_price, corporation, num_to_buy)
            total = num_to_buy * 2
            if corporation.ipo_shares.size < total
              raise GameError, "#{corporation.name} does not have #{total} shares of stock for IPO"
            end

            shares = corporation.ipo_shares.take(total)

            # player gets first num_to_buy shares
            diff = (share_price.price * num_to_buy) - company.value
            raise GameError, "#{player.name} does not have #{@game.format_currency(diff)} to spend on IPO" if player.cash < diff

            @log << "#{player.name} pays difference of #{@game.format_currency(diff)} to #{corporation.name} "\
                    "and receives #{num_to_buy} share#{num_to_buy > 1 ? 's' : ''}"
            player.spend(diff, corporation) if diff.positive?
            num_to_buy.times do |i|
              @game.share_pool.buy_shares(player, shares[i].to_bundle, exchange: :free, silent: true)
            end

            # issue next num_to_buy shares
            num_to_buy.times do |i|
              @game.share_pool.sell_shares(shares[num_to_buy + i].to_bundle, silent: true)
            end
            @log << "#{corporation.name} issues #{num_to_buy} share#{num_to_buy > 1 ? 's' : ''} and receives "\
                    "#{@game.format_currency(share_price.price * num_to_buy)}"
          end

          def get_par_prices(company, _corporation)
            @game.available_par_prices(company).select { |p| cost_to_ipo(p.price, company) <= company.owner&.cash }
          end

          def cost_to_ipo(par_price, company)
            if par_price >= company.value
              par_price - company.value
            elsif par_price * 2 >= company.value
              (par_price * 2) - company.value
            else
              (par_price * 3) - company.value
            end
          end

          def ipo_type(_entity)
            :par
          end

          def visible_corporations
            @game.corporations.reject(&:ipoed)
          end

          def available_par_cash(company, _corporation, _share_price)
            company.owner.cash
          end

          def par_price_only(_corporation, _price)
            true
          end
        end
      end
    end
  end
end
