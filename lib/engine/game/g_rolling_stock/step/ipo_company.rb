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
              shares = corporation.ipo_shares.take(2)

              # player gets first share
              diff = share_price.price - company.value
              raise GameError, "#{player.name} does not have #{@game.format_currency(diff)} to spend on IPO" if player.cash < diff

              @log << "#{player.name} pays difference of #{@game.format_currency(diff)} to #{corporation.name} "\
                      'and receives one share'
              player.spend(diff, corporation) if diff.positive?
              @game.share_pool.buy_shares(player, shares[0].to_bundle, exchange: :free, silent: true)

              # issue next share
              @log << "#{corporation.name} issues one share and receives #{@game.format_currency(share_price.price)}"
              @game.share_pool.sell_shares(shares[1].to_bundle, silent: true)
            else
              shares = corporation.ipo_shares.take(4)

              # player gets first two shares
              diff = (share_price.price * 2) - company.value
              raise GameError, "#{player.name} does not have #{@game.format_currency(diff)} to spend on IPO" if player.cash < diff

              @log << "#{player.name} pays difference of #{@game.format_currency(diff)} to #{corporation.name} "\
                      'and receives two shares'
              player.spend(diff, corporation) if diff.positive?
              @game.share_pool.buy_shares(player, shares[0].to_bundle, exchange: :free, silent: true)
              @game.share_pool.buy_shares(player, shares[1].to_bundle, exchange: :free, silent: true)

              # issue next two shares
              @game.share_pool.sell_shares(shares[2].to_bundle, silent: true)
              @game.share_pool.sell_shares(shares[3].to_bundle, silent: true)
              @log << "#{corporation.name} issues two shares and receives "\
                      "#{@game.format_currency(share_price.price * 2)}"
            end

            corporation.companies << company
            company.owner = corporation
            player.companies.delete(company)
            @game.clear_synergy_income(corporation)

            pass!
          end

          def get_par_prices(company, _corporation)
            @game.available_par_prices(company).select { |p| cost_to_ipo(p.price, company) <= company.owner&.cash }
          end

          def cost_to_ipo(par_price, company)
            if par_price >= company.value
              par_price - company.value
            else
              (par_price * 2) - company.value
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
