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

    def render
      h(:g, { on: { click: on_click } }, [
          h(:circle, attrs: { r: @radius, fill: 'white' }),
          (h(Token, token: @token, radius: @radius) unless @token.nil?)
        ].compact)
    end

    def on_click
      lambda do |event|
        # don't propagate to a click on the hex (i.e., don't trigger a tile laying
        # action from the same click)
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
