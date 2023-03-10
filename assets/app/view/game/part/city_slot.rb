# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/part/base'
require 'view/game/token'
require 'lib/settings'
require 'lib/tile_selector'
require 'lib/token_selector'

module View
  module Game
    module Part
      # a "slot" is a space in a city for a token
      class CitySlot < Base
        include Actionable
        include Lib::Settings

        needs :token
        needs :slot_index, default: 0
        needs :city
        needs :edge
        needs :extra_token, default: false
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
          color = ((@reservation&.corporation? || @reservation&.minor?) &&
                    @reservation&.reservation_color) ||
                    'white'

          radius = @radius
          show_player_colors = setting_for(:show_player_colors, @game)
          if show_player_colors && (owner = @token&.corporation&.owner) && @game&.players&.include?(owner)
            color = player_colors(@game.players)[owner]
            radius -= 4
          end

          token_attrs = {
            r: @radius,
            fill: color,
          }

          if (highlight = @game&.highlight_token?(@token))
            radius -= 3
            token_attrs[:stroke] = 'white'
            token_attrs[:'stroke-width'] = '3px'
          elsif @extra_token
            radius -= 3
            token_attrs[:stroke] = 'black'
            token_attrs[:'stroke-width'] = '3px'
            token_attrs[:'stroke-dasharray'] = '4'
          end

          children = [h(:circle, attrs: token_attrs)]
          children << reservation if @reservation && !@token
          children << render_boom if @city&.boom
          children << h(Token, token: @token, radius: radius, game: @game) if @token

          props = {
            on: { click: ->(event) { on_click(event) } },
            attrs: { transform: '' },
          }
          props[:attrs][:transform] = rotation_for_layout if @edge
          if highlight
            # make it look like an extra tall token
            props[:attrs][:filter] = 'drop-shadow(8px 8px 2px #444)'
          elsif @extra_token
            props[:attrs][:transform] += ' scale(0.95)'
            props[:attrs][:filter] = 'drop-shadow(0 0 6px #000)'
          end

          h(:g, props, children)
        end

        def reservation
          text = @reservation.id

          non_home = @reservation.corporation? && !Array(@reservation.coordinates).include?(@city.hex.coordinates)
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

        def on_click(event)
          return if @tile_selector.is_a?(Lib::TileSelector)

          step = @game.round.active_step(@selected_company)
          entity = @selected_company || step.current_entity
          remove_token_step = @game.round.step_for(entity, 'remove_token')
          place_token_step = @game.round.step_for(entity, 'place_token')
          return if !remove_token_step && !place_token_step
          return if @token &&
                    (!remove_token_step&.can_replace_token?(entity, @token) &&
                     !place_token_step&.can_replace_token?(entity, @token)) &&
                    !(cheater = @game.abilities(entity, :token)&.cheater) &&
                    !@game.abilities(entity, :token)&.extra_slot

          event.JS.stopPropagation

          # if remove_token and place_token is possible, remove should only be called when a token is available
          if remove_token_step && (@token || !place_token_step)
            return unless @token

            action = Engine::Action::RemoveToken.new(
              entity,
              city: @city,
              slot: @slot_index
            )
            process_action(action)
          else
            # If there's a choice of tokens of different types show the selector, otherwise just place
            next_tokens = place_token_step.available_tokens(entity)
            if next_tokens.size == 1 && place_token_step
              token_owner = @game.token_owner(entity)
              action = Engine::Action::PlaceToken.new(
                entity,
                city: @city,
                tokener: @selected_company&.owned_by_player? ? @game.current_entity : token_owner,
                slot: cheater || @slot_index,
                token_type: next_tokens[0].type,
              )
              action.cost = place_token_step.token_cost_override(
                action.entity,
                action.city,
                action.slot,
                action.token,
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

        def render_boom
          radius_addend = @reservation || @token ? 3.2 : 0.8
          h(:circle, attrs: {
              transform: translate.to_s,
              stroke: @color,
              r: @boom_radius ||= 10 * (radius_addend + (route_prop(0, :width).to_i / 40)),
              'stroke-width': 2,
              'stroke-dasharray': 6,
            })
        end
      end
    end
  end
end
