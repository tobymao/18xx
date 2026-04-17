# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1835
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          # Nationalization: Check if player can buy shares from another player
          # Requires owning at least 55% of the corporation.
          # Also enforces share group availability for IPO purchases.
          def can_buy?(entity, bundle)
            if bundle&.owner&.player?
              return false unless can_nationalize?(entity, bundle.corporation)

              return entity.cash >= nationalization_price(bundle.price) &&
                !@round.players_sold[entity][bundle.corporation] &&
                can_gain?(entity, bundle)
            end

            # Block IPO purchases for corporations not yet available per share group rules
            if bundle&.owner&.corporation? && bundle.owner == bundle.corporation
              return false unless @game.corporation_ipo_available?(bundle.corporation)

              corp = bundle.corporation

              # The president's share must be the first purchase; block all non-president
              # shares until the corp is on the stock market (president's share sold).
              return false if !corp.share_price.corporations.include?(corp) && !bundle.presidents_share

              ipo = corp.ipo_shares

              # BA/HE/WT: the trailing 20% share (last_cert) may only be bought once
              # all other non-presidential IPO shares are gone.
              if bundle.shares.any?(&:last_cert) &&
                 ipo.any? { |s| !s.president && !s.last_cert }
                return false
              end

              # MS/OL: the 10% shares may only be bought after both 20% IPO shares
              # (non-presidential) are sold.
              if %w[MS OL].include?(corp.id) &&
                 bundle.shares.any? { |s| s.percent == 10 } &&
                 ipo.any? { |s| !s.president && s.percent == 20 }
                return false
              end
            end

            super
          end

          # Override to use G1835 progressive availability rules instead of corporation.ipoed,
          # since BA/WT/HE/MS/OL/PR have pre-set par prices but ipoed=false until first purchase.
          def can_buy_any_from_ipo?(entity)
            @game.corporations.each do |corporation|
              next if !corporation.ipoed && !@game.corporation_ipo_available?(corporation)

              return true if can_buy_shares?(entity, corporation.shares)
            end
            false
          end

          # Check if entity can buy any shares from other players
          def can_buy_any_from_player?(entity)
            return false if bought?

            @game.corporations.select(&:floated?).any? do |corporation|
              can_nationalize?(entity, corporation) &&
                entity.cash >= nationalization_price(corporation.share_price.price)
            end
          end

          # Check if player owns >= 55% of the corporation (required for nationalization)
          def can_nationalize?(player, corporation)
            player.percent_of(corporation) >= @game.class::NATIONALIZATION_THRESHOLD
          end

          # Calculate nationalization price (150% of market value)
          def nationalization_price(price)
            (price * 1.5).ceil
          end

          # Prevent the normal presidency auto-transfer for PR before it forms.
          # PR's president's share (10%) is reserved for the M2 owner and must not
          # be handed out just because a player owns >= 10% during the SR.
          # After PR forms, normal presidency changes are allowed.
          def allow_president_change?(corporation)
            return false if corporation.id == 'PR' && !@game.pr_formed

            super
          end

          # In 1835, a player may sell shares of the same corporation in multiple separate
          # actions within one turn, but the share price only drops once per corporation
          # per player per turn.
          def sell_shares(entity, shares, swap: nil)
            raise GameError, "Cannot sell shares of #{shares.corporation.name}" if !can_sell?(entity, shares) && !swap

            already_dropped = @round.players_sold[shares.owner][shares.corporation] == :now
            @round.players_sold[shares.owner][shares.corporation] = :now
            @game.sell_shares_and_change_price(shares, swap: swap, movement: already_dropped ? :none : nil)
          end

          def process_buy_shares(action)
            bundle = action.bundle
            corporation = bundle.corporation

            # When the president's share of a corporation is first bought from IPO,
            # place the corporation's token on the stock market.
            if !bundle.owner.player? && bundle.presidents_share &&
               !corporation.share_price.corporations.include?(corporation)
              @game.stock_market.set_par(corporation, corporation.par_price)
              corporation.ipoed = true
            end

            if bundle.owner.player?
              # Nationalization: buying shares from another player
              player = action.entity
              price = nationalization_price(bundle.price)
              owner = bundle.owner

              raise GameError, 'Cannot nationalize this corporation' unless can_nationalize?(player, corporation)
              raise GameError, 'Not enough cash for nationalization' unless player.cash >= price

              @log << "-- Nationalization: #{player.name} buys a #{bundle.percent}% share " \
                      "of #{corporation.name} from #{owner.name} for #{@game.format_currency(price)} --"

              @game.share_pool.transfer_shares(bundle,
                                               player,
                                               spender: player,
                                               receiver: owner,
                                               price: price)

              track_action(action, corporation)
            else
              super
            end

            @game.check_new_corp_availabilities
          end
        end
      end
    end
  end
end
