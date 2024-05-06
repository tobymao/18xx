# frozen_string_literal: true

require_relative '../../../step/special_buy'
require_relative 'buy_e_token'

module Engine
  module Game
    module G1849
      module Step
        class SpecialBuy < Engine::Step::SpecialBuy
          attr_reader :e_token

          def buyable_items(entity)
            return [@e_token] if @game.loading || @game.can_buy_e_token?(entity)

            []
          end

          def short_description
            'E-Token'
          end

          def process_special_buy(action)
            raise GameError, "Cannot buy unknown item: #{item.description}" if action.item != @e_token
            raise GameError, 'Error' if !@game.loading && !@game.can_buy_e_token?(action.entity)

            @game.buy_e_token(action.entity)
          end

          def setup
            super
            @e_token ||= Item.new(description: 'E-token', cost: @game.e_token_cost)
          end
        end
      end
    end
  end
end
