# frozen_string_literal: true

require 'view/game/hex'
require 'lib/radial_selector'

module View
  module Game
    class TokenSelector < Snabberb::Component
      include Lib::RadialSelector
      include Actionable
      needs :tile_selector, store: true
      TOKEN_SIZE = 40
      SIZE = TOKEN_SIZE / 2
      DISTANCE = TOKEN_SIZE

      def render
        corp_tokens = @game.current_entity.available_tokens_by_corporation
        tokens = list_coordinates(corp_tokens.keys, DISTANCE, SIZE).map do |corporation, left, bottom|
          layable = corp_tokens[corporation].first

          click = lambda do
            action = Engine::Action::PlaceToken.new(
              @game.current_entity,
              @tile_selector.city,
              @tile_selector.slot_index,
              @game.current_entity.tokens.find_index(layable)
            )
            process_action(action)
          end

          props = {
            attrs: {
              src: layable.logo,
            },
            on: {
              click: click,
            },
            style: style(left, bottom, TOKEN_SIZE),
          }

          h(:img, props)
        end

        h(:div, tokens)
      end
    end
  end
end
