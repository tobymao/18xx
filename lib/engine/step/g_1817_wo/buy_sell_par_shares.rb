# frozen_string_literal: true

require_relative '../g_1817/buy_sell_par_shares'

module Engine
  module Step
    module G1817WO
      class BuySellParShares < G1817::BuySellParShares
        def process_choose(action)
          size = action.choice
          entity = action.entity
          @game.game_error('Corporation size is invalid') unless choices.include?(size)
          corporation = @winning_bid.corporation
          @game.game_error('Corporation in Nieuw Zeeland must be 5 or 10 share corporation') if
            @game.corp_has_new_zealand?(corporation) && size == 2

          size_corporation(size)
          par_corporation if available_subsidiaries(entity).empty?
        end

        def corporate_actions(entity)
          return [] if @winning_bid

          return [] if @corporation_action && @corporation_action.entity != entity

          actions = []
          if @current_actions.none?
            actions << 'take_loan' if @game.can_take_loan?(entity) && !@corporate_action.is_a?(Action::BuyShares)
            actions << 'buy_shares' if @game.redeemable_shares(entity).any?
          end
          if can_buy_tokens?(entity)
            actions << 'buy_tokens'
            actions << 'buy_and_place_tokens' if @game.corp_has_new_zealand?(entity)
          end
          actions
        end

        def process_buy_and_place_tokens(action)
          process_buy_tokens(action)
          entity = action.entity
          @game.place_second_token(entity)
        end

        def choices
          corporation = @winning_bid.corporation
          return super unless @game.corp_has_new_zealand?(corporation)

          super.reject { |size| size == 2 }
        end
      end
    end
  end
end
