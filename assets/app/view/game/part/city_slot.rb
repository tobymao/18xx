# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/part/base'
require 'view/game/token'
require 'lib/token_selector'

module View
  module Game
    module Part
      # a "slot" is a space in a city for a token
      class CitySlot < Base
        include Actionable

        needs :token
        needs :slot_index, default: 0
        needs :city
        needs :num_cities
        needs :radius
        needs :tile_selector, default: nil, store: true
        needs :reservation, default: nil
        needs :game, default: nil, store: true

        def render_part
          children = []
          children << h(:circle, attrs: { r: @radius, fill: 'white' })
          children << reservation if @reservation
          children << h(Token, token: @token, radius: @radius) if @token

          props = { on: { click: -> { on_click } } }

          props[:attrs] = { transform: rotation_for_layout } if @num_cities > 1

          h(:g, props, children)
        end

        def reservation
          h(
            :text,
            { attrs: { 'text-anchor': 'middle', fill: 'black', transform: 'translate(0 9) scale(1.75)' } },
            @reservation,
          )
        end

        def on_click
          return if @token
          return unless @game.round.can_place_token?

          # If there's a choice of tokens from different corps show the selector, otherwise just place
          token_types = @game.current_entity.tokens.reject{|t| t.used?}.group_by(&:corporation)
          if token_types.size == 1
            action = Engine::Action::PlaceToken.new(
              @game.current_entity,
              @city,
              @slot_index
            )

            process_action(action)
          else
            store(:tile_selector,
                  Lib::TokenSelector.new(@tile.hex, Hex.coordinates(@tile.hex), @city, @slot_index, token_types))
          end
        end
      end
    end
  end
end
