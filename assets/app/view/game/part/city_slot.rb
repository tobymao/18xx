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

        RESERVATION_FONT_SIZE = {
          1 => 22,
          2 => 22,
          3 => 22,
          4 => 17,
          5 => 13,
          6 => 13,
        }.freeze

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
          text = @reservation.id

          attrs = {
            fill: 'black',
            'font-size': "#{RESERVATION_FONT_SIZE[text.size]}px",
            'dominant-baseline': 'central',
          }

          h(:text, { attrs: attrs }, text)
        end

        def on_click(event)
          return if @token
          return if @tile_selector&.is_a?(Lib::TileSelector)

          round = @selected_company ? @game.special : @game.round
          actions = round.active_step.current_actions
          return unless (%w[move_token place_token] & actions).empty?

          event.JS.stopPropagation

          # If there's a choice of tokens of different types show the selector, otherwise just place
          next_tokens = @game.current_entity.tokens_by_type

          if actions.include?('move_token')
            # There should only be one token in the city
            action = Engine::Action::MoveToken.new(
              @game.current_entity,
              city: @city,
              slot: @slot_index,
              token: token,
            )

            process_action(action)
          elsif next_tokens.size == 1
            # TODO: this needs to see if it's the home token action, in which case the user has no choice
            # Maybe the tokens should come from the step.
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
