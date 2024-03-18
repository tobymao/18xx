# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18NewEngland
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def visible_corporations
            @game.stock_round_corporations
          end

          def get_par_prices(entity, _corp)
            @game.available_minor_par_prices.select { |p| p.price * 2 <= entity.cash }
          end

          def can_buy_any?(entity)
            (can_buy_any_from_market?(entity) ||
             can_buy_any_from_ipo?(entity) ||
             can_buy_any_from_treasury?(entity))
          end

          def can_buy_any_from_treasury?(entity)
            @game.corporations.each do |corporation|
              next unless corporation.ipoed
              next unless corporation.type == :major
              return true if can_buy_shares?(entity, corporation.shares)
            end

            false
          end

          def can_buy_any_from_ipo?(entity)
            @game.corporations.each do |corporation|
              next unless corporation.ipoed
              next unless corporation.type == :major
              return true if can_buy_shares?(entity, corporation.ipo_shares)
            end

            false
          end

          def can_ipo_any?(entity)
            !bought? && @game.corporations.any? do |c|
              if c.type == :minor
                @game.can_par?(c, entity) && can_par_minor?(entity, c.shares.first&.to_bundle)
              else
                @game.can_par?(c, entity) && can_buy?(entity, c.shares.first&.to_bundle)
              end
            end
          end

          def can_par_minor?(entity, bundle)
            @game.available_minor_prices.any? { |p| 2 * p.price <= entity.cash } &&
              can_gain?(entity, bundle)
          end

          # Overrides method in share_buying
          def buy_shares(entity, shares, exchange: nil, swap: nil, allow_president_change: true, borrow_from: nil,
                         discounter: nil)
            corp = shares.corporation
            if corp.type == :major && shares.owner == corp.ipo_owner
              @game.share_pool.buy_shares(entity,
                                          shares,
                                          exchange: exchange,
                                          swap: swap,
                                          allow_president_change: allow_president_change)
              # bank compensates company always at par price
              price = corp.original_par_price.price
              @game.bank.spend(price, corp)
              @log << "The Bank pays #{corp.name} #{@game.format_currency(price)} for the IPO share" if price != shares.price
            else
              super
            end
          end
        end
      end
    end
  end
end
