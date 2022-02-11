# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G1866
      module Step
        class IssueShares < Engine::Step::IssueShares
          def actions(entity)
            return [] if entity != current_entity || !entity.corporation? || @game.game_end_corporation_operated?(entity)

            super
          end

          def process_sell_shares(action)
            bundle = action.bundle
            corporation = bundle.corporation
            price = corporation.share_price.price
            @game.share_pool.sell_shares(action.bundle)
            @game.player_sold_shares[corporation.owner][corporation] = true

            bundle.num_shares.times { @game.stock_market.move_left(corporation) }
            @game.log_share_price(corporation, price)
            pass!
          end

          def skip!
            entity = current_entity
            log_skip(entity) if !@acted && entity.corporation? && @game.corporation?(entity)
            pass!
          end
        end
      end
    end
  end
end
