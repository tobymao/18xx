# frozen_string_literal: true

require 'snabberb/component'

require 'engine/action/place_token'
require 'view/actionable'
require 'view/token'

module View
  module Part
    # a "slot" is a space in a city for a token
    class CitySlot < Snabberb::Component
      include Actionable

      needs :token
      needs :slot_index, default: 0
      needs :city
      needs :radius
      needs :tile_selector, default: nil, store: true
      needs :reservation, default: nil

      def render
        h(:g, { on: { click: ->(e) { on_click(e) } }, attrs: { class: 'city_slot' } }, [
            h(:circle, attrs: { r: @radius, fill: 'white' }),
            reservation,
            (h(Token, corporation: @token.corporation, radius: @radius) unless @token.nil?)
          ])
      end

      def reservation
        return nil if @reservation.nil?

        h(
          :text,
          { attrs: { 'text-anchor': 'middle', fill: 'black', transform: 'translate(0 9) scale(1.75)' } },
          @reservation,
        )
      end

      def on_selected_hex?
        @tile_selector.hex.tile.cities.include?(@city)
      end

      def on_white_tile?
        @tile_selector.hex.tile.color == :white
      end

      def on_click(event)
        return unless @tile_selector

        # when clicking on a city slot in an unselected hex, do nothing
        return unless on_selected_hex?

        return if on_white_tile?

        # don't propagate to the hex view's click handler
        event.JS.stopPropagation

        return unless @token.nil?

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
