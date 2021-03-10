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
            return false if first_sr_passed?(player)

            @game.buyable_companies.any? { |c| player.cash >= c.value } && !sold? && !bought?
          end

          def can_buy?(entity, bundle)
            !first_sr_passed?(entity) && super && @game.buyable?(bundle.corporation)
          end

          def can_sell?(_entity, bundle)
            return false if @game.turn == 1
            return !bought? if bundle.corporation == @game.adsk

            super && @game.buyable?(bundle.corporation)
          end

          def can_gain?(entity, bundle, exchange: false)
            return false if exchange

            !first_sr_passed?(entity) && super && @game.buyable?(bundle.corporation)
          end

          def can_exchange?(_entity)
            false
          end

          def first_sr_passed?(entity)
            @game.passers_first_stock_round.include?(entity)
          end

          def process_pass(action)
            @game.passers_first_stock_round << action.entity if @game.turn == 1
            super
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
            # In case president's share is reserved, do not change presidency
            allow_president_change = action.bundle.corporation.presidents_share.buyable
            sell_shares(action.entity, action.bundle, swap: action.swap,
                                                      allow_president_change: allow_president_change)

            track_action(action, action.bundle.corporation)
          end
        end
      end
    end
  end
end
