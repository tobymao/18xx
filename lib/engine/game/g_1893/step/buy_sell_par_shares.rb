# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative 'buy_minor'
require_relative 'par_and_buy_actions'

module Engine
  module Game
    module G1893
      FIRST_SR_ACTIONS = %w[buy_company pass].freeze

      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          include ParAndBuy
          include BuyMinor

          def actions(entity)
            return [] unless entity&.player?

            result = super
            result.concat(FIRST_SR_ACTIONS) if can_buy_company?(entity)
            result
          end

          def can_buy_company?(player, _company = nil)
            @game.buyable_companies.any? { |c| player.cash >= c.value } && !sold? && !bought?
          end

          def can_buy?(_entity, bundle)
            super && @game.buyable?(bundle.corporation)
          end

          def can_sell?(_entity, bundle)
            return false if @game.turn == 1
            return !bought? if bundle.corporation == @game.adsk

            super && @game.buyable?(bundle.corporation)
          end

          def can_gain?(_entity, bundle, exchange: false)
            return false if exchange

            super && @game.buyable?(bundle.corporation)
          end

          def can_exchange?(_entity)
            false
          end

          def process_buy_company(action)
            entity = action.entity
            company = action.company
            price = action.price

            super

            if @game.buyable_companies.one?
              @game.corporations.each do |c|
                next if @game.merged_corporation?(c)

                @game.remove_ability(c, :no_buy)
              end
            end

            @round.last_to_act = entity

            handle_connected_minor(company, entity, price)
          end

          def process_sell_shares(action)
            if action.bundle.corporation == @game.adsk
              sell_adsk(action.bundle)
            else
              # In case president's share is reserved, do not change presidency
              allow_president_change = action.bundle.corporation.presidents_share.buyable
              sell_shares(action.entity, action.bundle, swap: action.swap,
                                                        allow_president_change: allow_president_change)
            end

            track_action(action, action.bundle.corporation)
          end

          private

          def sell_adsk(bundle)
            entity = bundle.owner
            price = bundle.price
            @log << "#{entity.name} sell #{bundle.percent}% " \
              "of #{bundle.corporation.name} and receives #{@game.format_currency(price)}"
            @game.share_pool.transfer_shares(bundle,
                                             @game.share_pool,
                                             spender: @bank,
                                             receiver: entity,
                                             price: price,
                                             allow_president_change: false)
          end
        end
      end
    end
  end
end
