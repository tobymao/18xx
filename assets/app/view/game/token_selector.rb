# frozen_string_literal: true

require 'view/game/hex'
require 'lib/radial_selector'

module View
  module Game
    class TokenSelector < Snabberb::Component
      include Lib::RadialSelector
      include Actionable
      needs :tile_selector, store: true
      needs :tokens
      needs :city
      needs :slot_index
      TOKEN_SIZE = 40
      SIZE = TOKEN_SIZE / 2
      DISTANCE = TOKEN_SIZE

      def render
        tokens = list_coordinates(@tokens.keys, DISTANCE, SIZE).map do |corporation, left, bottom|
          layable = @tokens[corporation].first
          style = {
            position: 'absolute',
            left: "#{left}px",
            bottom: "#{bottom}px",
            width: "#{TOKEN_SIZE}px",
            height: "#{TOKEN_SIZE}px",
            filter: 'drop-shadow(5px 5px 2px #888)',
            'pointer-events' => 'auto',
          }

          click = lambda do
            action = Engine::Action::PlaceToken.new(
              @game.current_entity,
              @city,
              @slot_index,
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
            style: style,
          }

          h(:img, props)
        end

        h(:div, tokens)
      end
    end
  end
end
