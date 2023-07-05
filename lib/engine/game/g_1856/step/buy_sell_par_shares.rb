# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1856
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def round_state
            # The false national president situation can only happen once in the game so there's no need to reset this.
            super.merge({ false_national_president_warning_issued: false })
          end

          def actions(entity)
            return super if @game.false_national_president != entity || entity != current_entity

            # entity == current_entity == @game.false_national_president
            unless @round.false_national_president_warning_issued
              @game.log << "-- #{entity.name} must raise funds to buy a #{@game.national.name} share --"
              @round.false_national_president_warning_issued = true
            end

            actions = []
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'buy_shares' if can_buy_any?(entity)
            # Force player to sell shares
            failed_to_raise_money(entity) if actions.empty? && !national_buy_liquidity(entity)

            actions
          end

          def can_buy_shares?(entity, shares)
            return false if @game.false_national_president == entity &&
              entity == current_entity &&
              shares.first&.corporation != @game.national

            super
          end

          def failed_to_raise_money(player)
            @game.log << "-- #{player.name} is unable to raise funds and is bankrupt --"
            @game.end_game!
          end

          def national_buy_liquidity(player)
            national_price = @game.national.share_price.price

            # Can't buy from possibly cheaper IPO if market is above limit
            national_price = [national_price, @game.national.par_price.price].min if
                @game.national.holding_ok?(@game.share_pool, 10)
            value = player.cash
            value += player.shares_by_corporation.sum do |corporation, shares|
              next 0 if shares.empty? || corporation == @game.national

              value_for_sellable(player, corporation)
            end
            value >= national_price
          end

          def value_for_sellable(player, corporation)
            max_bundle = sellable_bundles(player, corporation).max_by(&:price)
            max_bundle&.price || 0
          end

          def sellable_bundles(player, corporation)
            bundles = @game.bundles_for_corporation(player, corporation)
            bundles.select { |bundle| can_sell?(player, bundle) }
          end

          # TODO: Make it possible to go bankrupt from not being able to afford
          # to buy up to a full CGR presidency in the case of a false presidency
          # Although .. Is that ever going to happen? Assuming remotely competent play?
          # Has it ever happened in the history of the game?
          def can_buy?(entity, bundle)
            # holding_ok uses 60% for limit as if it was a player. This isn't true for the market so we are getting
            # around this buy adding 10% so that if it's ok for the market to hold current + 10% = <=60% it's OK to
            # buy IPO (so it's OK to buy IPO if market is <= 50%)
            return false if bundle.owner == bundle.corporation && !bundle.corporation.holding_ok?(@game.share_pool, 10)

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
            return if bundle.owner&.player?

            corporation = bundle.corporation

            corporation.holding_ok?(entity, bundle.percent) &&
              !attempt_cgr_action_while_not_floated?(bundle) &&
              (!corporation.counts_for_limit || exchange ||
                @game.num_certs(entity) + bundle.shares.sum(&:cert_size) <= @game.cert_limit)
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
            raise GameError, "Cannot buy a share of #{shares&.corporation&.name}" if
                !can_buy?(entity, shares.to_bundle) && !swap

            bundle = shares.is_a?(ShareBundle) ? shares : ShareBundle.new(shares)
            price = bundle.price

            # Pay for the share.
            entity.spend(price, @game.bank)

            # grow up the share
            share_percent = @game.national.presidents_share.percent
            @game.national.presidents_share.percent += share_percent
            @game.national.share_holders[entity] += share_percent

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

          def train_to_operate
            return "2 and 2'" if @game.phase.status.include?('facing_2')
            return "3 and 3'" if @game.phase.status.include?('facing_3')
            return "4 and 4'" if @game.phase.status.include?('facing_4')
            return "5 and 5'" if @game.phase.status.include?('facing_5')
            return "6 and 6'" if @game.phase.status.include?('facing_6')

            # This shouldn't happen
            raise NotImplementedError
          end

          def activate_program_buy_shares(entity, program)
            corporation = program.corporation
            if actions(entity).include?('buy_shares') &&
                (program.until_condition == 'float' && !@game.phase.status.include?('facing_6')) && corporation.floatable?
              return [Action::ProgramDisable.new(
                entity, reason: "#{corporation.name} has enough shares sold to operate next OR"\
                                " unless all of the #{train_to_operate} trains are sold out"
              )]
            end
            super
          end
        end
      end
    end
  end
end
