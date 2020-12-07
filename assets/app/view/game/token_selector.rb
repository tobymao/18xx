# frozen_string_literal: true

require 'view/game/hex'
require 'lib/radial_selector'

module View
  module Game
    class TokenSelector < Snabberb::Component
      include Lib::RadialSelector
      include Actionable

      needs :tile_selector, store: true
      needs :zoom, default: 1

      TOKEN_SIZE = 40

      def render
        @token_size = TOKEN_SIZE * @zoom
        @size = @token_size / 2
        @distance = @token_size

        tokens = @game.current_entity.tokens_by_type
        tokens = list_coordinates(tokens, @distance, @size).map do |token, left, bottom|
          click = lambda do
            action = Engine::Action::PlaceToken.new(
              @game.current_entity,
              city: @tile_selector.city,
              slot: @tile_selector.slot_index,
              token_type: token.type
            )
            process_action(action)
          end

          props = {
            attrs: {
              src: token.logo,
            },
            on: {
              click: click,
            },
            style: style(left, bottom, @token_size),
          }

          h(:img, props)
        end

        h(:div, tokens)
      end
    end
  end
end
