# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/emergency_money'

module Engine
  module Game
    module G18Dixie
      module Step
        # Mostly actionless unless bad things happen
        class PresidencyShareExchange < Engine::Step::Base
          include Engine::Step::EmergencyMoney
          # In the case that a president of an ICG/SCL merger company needing to raise funds
          # this is used to do that. Bankruptcy can happen.
          def actions(entity)
            return [] unless entity == current_entity

            unless @active_entity
              @active_entity = entity
              @game.log << "#{@active_entity.name} enters Emergency Fundraising and owes"\
                           " the bank #{@game.format_currency(needed_cash(@active_entity))}"
            end

            ['sell_shares']
          end

          def description
            'Presidency Exchange'
          end

          def cash_crisis?
            true
          end

          def active?
            active_entities.any?
          end

          def active_entities
            if @round&.merge_presidency_cash_crisis_player&.cash&.negative?
              [@round.merge_presidency_cash_crisis_player]
            else
              []
            end
          end

          def needed_cash(entity)
            -entity.cash
          end

          def available_cash(_player)
            0
          end

          def process_sell_shares(action)
            super
            player = action.entity
            return if player.cash.negative?

            @active_entity = nil
            # Player has resolved cash obligations
            if @round.merge_presidency_cash_crisis_corp == @round.merge_presidency_exchange_corps[0]
              unless player == @round.merge_presidency_cash_crisis_player
                raise Engine::GameError, 'Only the player in cash crisis can sell shares right now'
              end

              @round.merge_presidency_cash_crisis_player = nil
              @round.merge_presidency_cash_crisis_corp = nil
              @game.try_exchange_for_merger_20_share(
                @round.merge_presidency_exchange_corps[0],
                @round.merge_presidency_exchange_corps[1],
                @round.merge_presidency_exchange_merging_corp
              )
            elsif @round.merge_presidency_cash_crisis_corp == @round.merge_presidency_exchange_corps[1]
              unless player == @round.merge_presidency_cash_crisis_player
                raise Engine::GameError, 'Only the player in cash crisis can sell shares right now'
              end

              @round.merge_presidency_cash_crisis_player = nil
              @round.merge_presidency_cash_crisis_corp = nil
              @game.finish_exchanges(
                @round.merge_presidency_exchange_corps[0],
                @round.merge_presidency_exchange_corps[1],
                @round.merge_presidency_exchange_merging_corp
              )
            else
              # This shouldn't happen, provided for defensive coding
              raise Engine::GameError, 'Selling shares in presidency exchange with no cash crisis player is not allowed'
            end
          end

          # In the double share exchanges, the primary is resolved before the secondary.
          # If a player is president of both, and is in serious financial trouble, could they dump
          # the presidency of the secondary company to raise funds for the first one to duck out of that responsibility?
          # RAW is not explicit so I'll let what happens here happen and make sure that the president of the secondary
          # corporation is determined only when its needed for the secondary 20 percent exchange
          def sellable_bundle?(bundle)
            player = bundle.owner
            # Can't sell president's share
            return false unless bundle.can_dump?(player)

            # Can't oversaturate the market
            return false unless @game.share_pool.fit_in_bank?(bundle)

            # Can't swap presidency
            corporation = bundle.corporation
            if corporation.president?(player) && @round.merge_presidency_cash_crisis_corp == corporation
              share_holders = corporation.player_share_holders
              remaining = share_holders[player] - bundle.percent
              next_highest = share_holders.reject { |k, _| k == player }.values.max || 0
              return false if remaining < next_highest
            end

            # Otherwise we're good
            true
          end
          # Use EmergencyMoney can_sell?

          def swap_sell(_player, _corporation, _bundle, _pool_share); end
        end
      end
    end
  end
end
