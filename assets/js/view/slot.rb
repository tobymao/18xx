# frozen_string_literal: true

require 'snabberb/component'

require 'engine/action/place_token'
require 'view/actionable'
require 'view/token'

module View
  # a "slot" is a space in a city for a token
  class Slot < Snabberb::Component
    include Actionable

    needs :token
    needs :slot_index, default: 0
    needs :city
    needs :radius
    needs :tile_selector, default: nil, store: true

    def render
      h(:g, { on: { click: on_click } }, [
          h(:circle, attrs: { r: @radius, fill: 'white' }),
          (h(Token, token: @token, radius: @radius) unless @token.nil?)
        ].compact)
    end

    def on_selected_hex?
      @tile_selector&.hex&.tile&.cities&.include?(@city)
    end

    def on_click
      lambda do |event|
        # when clicking on a city slot in an unselected hex, do nothing
        next unless on_selected_hex?

        # don't propagate to the hex view's click handler
        event.JS.stopPropagation

        next unless @token.nil?

        action = Engine::Action::PlaceToken.new(
          @game.current_entity,
          @city,
          @slot_index
        )
        process_action(action)
      end
    end
  end
end
