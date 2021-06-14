# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1856
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          # TODO: Make it possible to go bankrupt from not being able to afford
          # to buy up to a full CGR presidency in the case of a false presidency
          # Although .. Is that ever going to happen? Assuming remotely competent play?
          # Has it ever happened in the history of the game?
          def can_buy?(entity, bundle)
            if @game.false_national_president && entity == @game.false_national_president
              # The player is the false national president
              return super if bundle.corporation == @game.national

              false
            else
              super && !attempt_cgr_action_while_not_floated?(bundle)
            end
          end

          def can_sell?(entity, bundle)
            super && !attempt_cgr_action_while_not_floated?(bundle) && vested?(entity, bundle)
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity

            corporation = bundle.corporation

            corporation.holding_ok?(entity, bundle.percent) &&
              !attempt_cgr_action_while_not_floated?(bundle) &&
              (!corporation.counts_for_limit || exchange || @game.num_certs(entity) + 1 <= @game.cert_limit)
          end

          def attempt_cgr_action_while_not_floated?(bundle)
            bundle.corporation == @game.national && !bundle.corporation.floated?
          end

          def vested?(player, bundle)
            # If the player will be left with at least 1 share, or is fully vested, this is fair game
            return true unless @round.players_unvested_holdings[player] == bundle.corporation

            # The player has an unvested share, will they be left with at least 1 share?
            bundle.num_shares < player.num_shares_of(bundle.corporation)
          end

          def process_buy_shares(action)
            # This is weird and complicated because 1856 has the weird situation where a player
            # can have a 20% presidents cert, but only actually have 10% of it.
            # Refactoring the process_buy_shares would make it far more complicated to benefit only one game
            # so we are putting the weirdness here in 1856 where it can't affect anything else
            corporation = action.bundle.corporation
            false_president = @game.false_national_president
            if false_president && corporation == @game.national && action.entity == false_president
              buy_and_grow_presidency(action.entity, action.bundle, swap: action.swap)
              track_action(action, corporation)
            elsif false_president && corporation == @game.national && !action.entity.shares_of(@game.national).empty?
              # The player pays for the bundle but the shares in the bundle don't leave the IPO/market
              # instead they get the unpurchased half of the president's certificate
              # swap the player's cert for the president's cert

              @game.share_pool.change_president(@game.national.presidents_share, false_president, action.entity)
              @game.national.owner = action.entity
              buy_and_grow_presidency(action.entity, action.bundle, swap: action.swap)
              track_action(action, corporation)
            else
              super
            end
            @round.players_unvested_holdings[action.entity] = corporation
          end

          def buy_and_grow_presidency(entity, shares, exchange: nil, swap: nil, allow_president_change: true)
            raise GameError, "Cannot buy a share of #{shares&.corporation&.name}" if !can_buy?(entity, shares) && !swap

            bundle = shares.is_a?(ShareBundle) ? shares : ShareBundle.new(shares)
            price = bundle.price

            # Pay for the share.
            entity.spend(price, @game.bank)

            # grow up the share
            @game.national.presidents_share.percent *= 2
            @game.false_national_president = nil
            @game.national.remove_ability(@game.class::FALSE_PRESIDENCY_ABILITY)

            @game.log << "#{entity.name} spends #{@game.format_currency(price)} to buy up to the "\
            "presidency of the #{@game.national.name}"
          end

          def process_par(action)
            share_price = action.share_price
            corporation = action.corporation
            entity = action.entity
            raise GameError, "#{corporation} cannot be parred" unless @game.can_par?(corporation, entity)

            corporation.par!
            @log << "#{corporation.name} is parred as a #{corporation.capitalization_type_desc} cap corporation"
            @game.stock_market.set_par(corporation, share_price)
            share = corporation.shares.first
            buy_shares(entity, share.to_bundle)
            @game.after_par(corporation)
            track_action(action, corporation)
          end
        end
      end
    end
  end
end
