# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares_via_bid'

module Engine
  module Game
    module G1867
      module Step
        class BuySellParShares < Engine::Step::BuySellParSharesViaBid
          MIN_BID = 100
          MAX_MINOR_PAR = 135
          MAJOR_PHASE = 4

          def win_bid(winner, _company)
            entity = winner.entity
            corporation = winner.corporation
            price = winner.price

            @log << "#{entity.name} wins bid on #{corporation.name} for #{@game.format_currency(price)}"
            par_price = [price / 2, MAX_MINOR_PAR].min

            share_price = get_all_par_prices(corporation).find { |sp| sp.price <= par_price }

            # Temporarily give the entity cash to buy the corporation PAR shares
            @game.bank.spend(share_price.price * 2, entity)

            action = Action::Par.new(entity, corporation: corporation, share_price: share_price)
            process_par(action)

            # Clear the corporation of 'share' cash grabbed earlier.
            corporation.spend(corporation.cash, @game.bank)

            # Then move the full amount.
            entity.spend(price, corporation)

            @auctioning = nil

            # Player to the right of the winner is the new player
            @round.goto_entity!(winner.entity)
            pass!
          end

          def can_bid?(entity)
            max_bid(entity) >= MIN_BID && !bought? &&
            @game.corporations.any? do |c|
              @game.can_par?(c, entity) && c.type == :minor && can_buy?(entity, c.shares.first&.to_bundle)
            end
          end

          def can_ipo_any?(entity)
            @game.phase.name.to_i >= MAJOR_PHASE && !bought? &&
            @game.corporations.any? do |c|
              @game.can_par?(c, entity) && c.type == :major && can_buy?(entity, c.shares.first&.to_bundle)
            end
          end

          def get_all_par_prices(corp)
            types = corp.type == :major ? %i[par_2 par] : %i[par_1 par]
            @game.stock_market.share_prices_with_types(types)
          end

          def get_par_prices(entity, corp)
            get_all_par_prices(corp).select { |sp| sp.price * 2 <= entity.cash }
          end

          def ipo_type(entity)
            # Major's are par, minors are bid
            phase = @game.phase.name.to_i
            if entity.type == :major
              if phase >= MAJOR_PHASE
                if @game.home_token_locations(entity).empty?
                  'No home token locations are available'
                else
                  :par
                end
              else
                "Cannot start till phase #{MAJOR_PHASE}"
              end
            else
              :bid
            end
          end
        end
      end
    end
  end
end
