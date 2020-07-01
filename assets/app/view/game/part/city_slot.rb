# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/part/base'
require 'view/game/token'
require 'lib/tile_selector'
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
        needs :selected_company, default: nil, store: true
        needs :tile_selector, default: nil, store: true
        needs :reservation, default: nil
        needs :game, default: nil, store: true

        def render_part
          children = []
          children << h(:circle, attrs: { r: @radius, fill: 'white' })
          children << reservation if @reservation && !@token
          children << h(Token, token: @token, radius: @radius) if @token

          props = { on: { click: ->(event) { on_click(event) } } }

          props[:attrs] = { transform: rotation_for_layout } if @num_cities > 1

          h(:g, props, children)
        end

        def reservation
          h(
            :text,
            { attrs: { fill: 'black', transform: 'translate(0 9) scale(1.75)' } },
            @reservation.id,
          )
        end

        def on_click(event)
          return if @token
          return if @tile_selector&.is_a?(Lib::TileSelector)
          return unless @game.round.can_place_token?

          event.JS.stopPropagation


          # If there's a choice of tokens of different types show the selector, otherwise just place
          next_tokens = @game.current_entity.tokens_by_type
          if (token = @game.round.ambiguous_token)
            # There should only be one token in the city
            action = Engine::Action::MoveToken.new(
              @game.current_entity,
              city: @city,
              slot: @slot_index,
              token: token,
            )

            process_action(action)
          elsif next_tokens.size == 1 || @game.round.step == :home_token
            action = Engine::Action::PlaceToken.new(
              @selected_company || @game.current_entity,
              city: @city,
              slot: @slot_index,
            )
            store(:selected_company, nil, skip: true)
            process_action(action)
          else
            store(:tile_selector,
                  Lib::TokenSelector.new(@tile.hex, Hex.coordinates(@tile.hex), @city, @slot_index))
          end
        end
      end
    end
  end
end
