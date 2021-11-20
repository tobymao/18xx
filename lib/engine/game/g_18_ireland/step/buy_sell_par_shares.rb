# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares_via_bid'

module Engine
  module Game
    module G18Ireland
      module Step
        class BuySellParShares < Engine::Step::BuySellParSharesViaBid
          MIN_BID = 100
          MAX_MINOR_PAR = 135
          MAJOR_PHASE = 6

          def win_bid(winner, _company)
            entity = winner.entity
            corporation = winner.corporation
            price = winner.price

            @log << "#{entity.name} wins bid on #{corporation.name}
              and buys its director's share for #{@game.format_currency(price)}"
            @log << "#{corporation.name} receives bid amount of #{@game.format_currency(price)}"
            par_price = [price / 2, MAX_MINOR_PAR].min

            share_price = get_par_prices(entity, corporation).find { |sp| sp.price <= par_price }

            # Temporarily give the entity cash to buy the corporation PAR shares
            @game.bank.spend(share_price.price * 2, entity)

            action = Action::Par.new(entity, corporation: corporation, share_price: share_price)
            process_par(action)

            # Clear the corporation of 'share' cash grabbed earlier.
            corporation.spend(corporation.cash, @game.bank)

            # Then move the full amount.
            entity.spend(price, corporation)

            @auctioning = nil

            @round.minor_started = true
            pass!
          end

          def can_bid?(entity)
            max_bid(entity) >= MIN_BID && !bought? && !sold? &&
            @game.corporations.any? do |c|
              @game.can_par?(c, entity) && c.type == :minor && can_buy?(entity, c.shares.first&.to_bundle)
            end
          end

          def can_ipo_any?(entity)
            phase_allows_ipo? && !bought? && !sold? &&
            @game.corporations.any? do |c|
              @game.can_par?(c, entity) && c.type == :major && can_buy?(entity, c.shares.first&.to_bundle)
            end
          end

          def phase_allows_ipo?
            @game.phase.name == 'D' || @game.phase.name.to_i >= MAJOR_PHASE
          end

          def ipo_type(entity)
            # Major's are par, minors are bid
            if entity.type == :major
              if phase_allows_ipo?
                :par
              else
                "Cannot start till phase #{MAJOR_PHASE}"
              end
            elsif entity == @game.corporations.find { |c| c.ipoed == false }
              # First un-ipoed corporation
              :bid
            else
              'Minor is not the first available minor'
            end
          end

          def round_state
            super.merge(minor_started: false)
          end
        end
      end
    end
  end
end
