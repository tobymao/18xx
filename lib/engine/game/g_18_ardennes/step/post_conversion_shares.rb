# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Ardennes
      module Step
        class PostConversionShares < Engine::Step::Base
          include Engine::Step::ShareBuying
          ACTIONS = %w[buy_shares pass]

          def actions(entity)
            return [] unless @round.converted
            return [] unless entity == current_entity
            return [] unless can_buy?(entity)

            ACTIONS
          end

          def description
            'Buy shares'
          end

          def log_skip(_entity); end

          def active_entities
            [president]
          end

          def visible_corporations
            [corporation]
          end

          def process_buy_shares(action)
            buy_shares(action.entity, action.bundle)
          end

          def process_pass(_action)
            @round.converted = nil
          end

          private

          def can_buy?(player)
            return false if corporation.num_treasury_shares.zero? &&
                            corporation.num_market_shares.zero?

            player.cash >= corporation.share_price.price
          end

          def corporation
            @round.converted
          end

          def president
            corporation&.owner
          end
        end
      end
    end
  end
end
