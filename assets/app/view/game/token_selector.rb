# frozen_string_literal: true

require 'lib/radial_selector'
require 'lib/settings'
require 'view/game/hex'

module View
  module Game
    class TokenSelector < Snabberb::Component
      include Actionable
      include Lib::RadialSelector
      include Lib::Settings

      needs :user, default: nil, store: true
      needs :tile_selector, store: true
      needs :zoom, default: 1

      TOKEN_SIZE = 40

      def render
        @token_size = TOKEN_SIZE * @zoom
        @size = @token_size / 2
        @distance = @token_size

        tokener = @game.token_owner(@game.current_entity)
        tokens = tokener.tokens_by_type
        tokens = list_coordinates(tokens, @distance, @size).map do |token, left, bottom|
          click = lambda do
            action = Engine::Action::PlaceToken.new(
              @game.current_entity,
              city: @tile_selector.city,
              slot: @tile_selector.slot_index,
              token_type: token.type,
              tokener: tokener,
            )
            process_action(action)
          end

          props = {
            attrs: {
              src: setting_for(:simple_logos, @game) ? token.simple_logo : token.logo,
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
