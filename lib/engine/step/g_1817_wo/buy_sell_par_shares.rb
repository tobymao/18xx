# frozen_string_literal: true

require_relative '../g_1817/buy_sell_par_shares'

module Engine
  module Step
    module G1817WO
      class BuySellParShares < G1817::BuySellParShares
        def process_choose(action)
          size = action.choice
          entity = action.entity
          raise GameError, 'Corporation size is invalid' unless choices.include?(size)

          corporation = @winning_bid.corporation
          raise GameError, 'Corporation in Nieuw Zeeland must be 5 or 10 share corporation' if
            @game.corp_has_new_zealand?(corporation) && size == 2

          size_corporation(size)
          par_corporation if available_subsidiaries(entity).empty?
        end

        def choices
          corporation = @winning_bid.corporation
          return super unless @game.corp_has_new_zealand?(corporation)

          super.reject { |size| size == 2 }
        end

        def add_tokens(entity, tokens)
          super
          @game.place_second_token(entity) if @game.corp_has_new_zealand?(entity)
        end
      end
    end
  end
end
