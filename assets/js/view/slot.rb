# frozen_string_literal: true

require 'snabberb/component'

require 'engine/action/place_token'
require 'view/actionable'

module View
  class Slot < Snabberb::Component
    include Actionable

    needs :token
    needs :slot_index, default: 0
    needs :city

    def render
      h(:g, {}, [
          h(
            :circle,
            attrs: { r: 25, fill: 'white' },
            on: { click: ->(e) { on_slot_click(e, @slot_index) } }
          ),
          render_token
        ].compact)
    end

    def render_token
      return nil if @token.nil?

      h(
        :text,
        { attrs: { 'text-anchor': 'middle' } },
        @token.corporation.sym
      )
    end

    def on_slot_click(event, slot)
      return unless @token.nil?

      action = Engine::Action::PlaceToken.new(
        @game.current_entity,
        @city,
        slot
      )
      process_action(action)

      # don't propagate to a click on the hex (ie don't trigger a tile laying
      # action from the same click)
      event.JS.stopPropagation
    end
  end
end
