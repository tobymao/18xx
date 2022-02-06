# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1870
      module Step
        class PriceProtection < Engine::Step::BuySellParShares
          def actions(entity)
            return [] if !entity.player? || entity != current_entity

            actions = []
            actions << 'buy_shares' if can_buy?(entity, price_protection)
            actions << 'pass' if actions.any?
            actions
          end

          def description
            'Price protect shares'
          end

          def active_entities
            return [] if @game.sell_queue.empty?

            [price_protection_entity]
          end

          def purchasable_companies(_entity = nil)
            []
          end

          def price_protection
            @game.sell_queue.dig(0, 0)
          end

          def price_protection_entity
            @game.sell_queue.dig(0, 1)
          end

          def can_sell?
            false
          end

          def can_buy?(entity, bundle)
            return unless bundle&.buyable
            return unless bundle == price_protection

            have_cert_room = if bundle.corporation.counts_for_limit
                               @game.num_certs(entity, price_protecting: true) + bundle.num_shares <= @game.cert_limit
                             else
                               true # can price protect yellow/green/brown even if over cert limit
                             end
            entity.cash >= bundle.price &&
              !@round.players_sold[entity][bundle.corporation] &&
              have_cert_room
          end

          def process_buy_shares(action)
            bundle, = @game.sell_queue.shift

            player = action.entity
            price = bundle.price

            @game.share_pool.transfer_shares(
              bundle,
              player,
              spender: player,
              receiver: @game.bank,
              price: price
            )

            # Price protecting a share counts as an action, which changes what player
            # gets to act next. But not if done during an OR
            if @round.entities[@round.entity_index].player?
              player.unpass!
              @round.goto_entity!(player)
              track_action(action, action.bundle.corporation)
            end

            num_presentation = @game.share_pool.num_presentation(bundle)
            @log << "#{player.name} price protects #{num_presentation} "\
                    "of #{bundle.corporation.name} for #{@game.format_currency(price)}"
          end

          def skip!
            process_pass(nil, true) while price_protection && !can_buy?(price_protection_entity, price_protection)
          end

          def process_pass(_action, forced = false)
            bundle, corporation_owner = @game.sell_queue.shift

            corporation = bundle.corporation
            price = corporation.share_price.price

            hit_soft_ledge = false
            bundle.num_shares.times do
              if hit_soft_ledge
                @game.stock_market.move_down(corporation)
                hit_soft_ledge = false
              end

              r, c = corporation.share_price.coordinates
              if corporation.share_price.type != :ignore_one_sale &&
                  @game.stock_market.market.dig(r + 1, c)&.type == :ignore_one_sale
                hit_soft_ledge = true
              else
                @game.stock_market.move_down(corporation)
              end
            end

            verb = forced ? 'can\'t' : 'doesn\'t'
            num_presentation = @game.share_pool.num_presentation(bundle)
            @log << "#{corporation_owner.name} #{verb} price protect #{num_presentation} of #{corporation.name}"
            @log << "#{corporation.name} hits the ledge" if hit_soft_ledge

            @game.log_share_price(corporation, price)

            @round.recalculate_order if @round.respond_to?(:recalculate_order)
          end
        end
      end
    end
  end
end
