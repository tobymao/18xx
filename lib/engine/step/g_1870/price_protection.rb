# frozen_string_literal: true

require_relative '../base'
require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1870
      class PriceProtection < Base
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

        def round_state
          { sell_queue: [] }
        end

        def purchasable_companies(_entity = nil)
          []
        end

        def price_protection
          @round.sell_queue[0]
        end

        def can_sell?
          false
        end

        def can_buy?(entity, bundle)
          return unless bundle&.buyable
          return unless bundle == price_protection

          entity.cash >= bundle.price &&
            !@round.players_sold[entity][bundle.corporation] &&
            @game.num_certs(entity) + bundle.num_shares <= @game.cert_limit
        end

        def process_buy_shares(action)
          bundle = @round.sell_queue.shift

          player = action.entity
          price = bundle.price

          @game.share_pool.transfer_shares(
            bundle,
            player,
            spender: player,
            receiver: @bank,
            price: price
          )

          @round.goto_entity!(player)

          num_presentation = @game.share_pool.num_presentation(bundle)
          @log << "#{player.name} price protects #{num_presentation} "\
                  "#{bundle.corporation.name} for #{@game.format_currency(price)}"
        end

        def skip!(action)
          return process_pass(action, true) if price_protection

          super
        end

        def process_pass(_action, forced = false)
          bundle = @round.sell_queue.shift

          corporation = bundle.corporation
          player = bundle.president
          price = corporation.share_price.price

          previous_ignore = corporation.share_price.type == :ignore_one_sale
          bundle.num_shares.times do
            previous_ignore = corporation.share_price.type == :ignore_one_sale
            @game.stock_market.move_down(corporation)
          end
          current_ignore = corporation.share_price.type == :ignore_one_sale

          verb = forced ? 'can\'t' : 'doesn\'t'
          num_presentation = @game.share_pool.num_presentation(bundle)
          @log << "#{player.name} #{verb} price protect #{num_presentation} #{corporation.name}"

          if current_ignore && !previous_ignore
            @log << "#{corporation.name} hits the ledge"
            @game.stock_market.move_up(corporation) if current_ignore && !previous_ignore
          end

          @game.log_share_price(corporation, price)
        end

        def active_entities
          return [] unless @round.sell_queue.any?

          @round.sell_queue.map(&:president)
        end
      end
    end
  end
end
