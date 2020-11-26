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
        needs :edge
        needs :radius
        needs :selected_company, default: nil, store: true
        needs :tile_selector, default: nil, store: true
        needs :reservation, default: nil
        needs :game, default: nil, store: true
        needs :city_render_location, default: nil

        RESERVATION_FONT_SIZE = {
          1 => 22,
          2 => 22,
          3 => 22,
          4 => 17,
          5 => 13,
          6 => 13,
        }.freeze

        RESERVATION_VERT_SCALING = {
          1 => 1,
          2 => 1,
          3 => 1,
          4 => 1.4,
          5 => 2.0,
          6 => 2.0,
        }.freeze

        def render_part
          children = []
          children << h(:circle, attrs: { r: @radius, fill: 'white' })
          children << reservation if @reservation && !@token
          children << h(Token, token: @token, radius: @radius) if @token

          props = { on: { click: ->(event) { on_click(event) } } }

          props[:attrs] = { transform: rotation_for_layout } if @edge

          h(:g, props, children)
        end

        def reservation
          text = @reservation.id

          non_home = @reservation.corporation? && (@reservation.coordinates != @city.hex.coordinates)
          color = non_home ? '#808080' : 'black'

          attrs = {
            fill: 'black',
            'font-size': "#{RESERVATION_FONT_SIZE[text.size]}px",
            transform: "scale(1.0,#{RESERVATION_VERT_SCALING[text.size]})",
            'dominant-baseline': 'central',
          }

          if non_home
            attrs[:stroke] = color
            attrs[:fill] = color
          end

          h(:text, { attrs: attrs }, text)
        end

        def cheater_token(entity)
          token_abilities = entity.abilities(:token)
          return nil if token_abilities.empty?

          token_abilities&.cheater
        end

        def on_click(event)
          return if @tile_selector&.is_a?(Lib::TileSelector)

          step = @game.round.active_step(@selected_company)
          entity = @selected_company || step.current_entity
          actions = step.actions(entity)

          return if (%w[remove_token place_token] & actions).empty?

          return if @token && !step.can_replace_token?(entity, @token) && !(cheater = cheater_token(entity))

          event.JS.stopPropagation

          if actions.include?('remove_token')
            return unless @token

            action = Engine::Action::RemoveToken.new(
              @selected_company || @game.current_entity,
              city: @city,
              slot: @slot_index
            )
            process_action(action)
          else
            # If there's a choice of tokens of different types show the selector, otherwise just place
            next_tokens = step.available_tokens(entity)
            if next_tokens.size == 1 && actions.include?('place_token')
              action = Engine::Action::PlaceToken.new(
                @selected_company || @game.current_entity,
                city: @city,
                slot: cheater || @slot_index,
                token_type: next_tokens[0].type
              )
              store(:selected_company, nil, skip: true)
              process_action(action)
            else
              coords = Hex.coordinates(@tile.hex)
              coords[0] += @city_render_location[:x] if @city_render_location
              coords[1] += @city_render_location[:y] if @city_render_location

              store(:tile_selector,
                    Lib::TokenSelector.new(@tile.hex, coords, @city, @slot_index))
            end
          end
        end
      end
    end
  end
end
