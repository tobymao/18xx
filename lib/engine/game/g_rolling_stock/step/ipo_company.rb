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

            # player gets first share
            diff = share_price.price - company.value
            @log << "#{player.name} pays difference of #{@game.format_currency(diff)} to #{corporation.name} "\
                    'and receives one share'
            player.spend(diff, corporation)
            first_share = corporation.ipo_shares[0]
            @game.share_pool.buy_shares(player, first_share.to_bundle, exchange: :free, silent: true)

            # issue next share
            second_share = corporation.ipo_shares[1]
            @game.share_pool.sell_shares(second_share.to_bundle, silent: true)
            @log << "#{corporation.name} issues one share and receives #{@game.format_currency(share_price.price)}"

            corporation.companies << company
            company.owner = corporation
            player.companies.delete(company)

            pass!
          end

          def get_par_prices(company, _corporation)
            @game.available_par_prices(company).select { |p| (p.price - company.value) <= company.owner&.cash }
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
        end
      end
    end
  end
end
