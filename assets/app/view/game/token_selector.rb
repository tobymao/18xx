# frozen_string_literal: true

require 'lib/radial_selector'
require 'lib/settings'
require 'view/game/hex'

module View
  module Game
    class TokenSelector < Snabberb::Component
      include Actionable
      include Lib::RadialSelector
      include Lib::Settings

      needs :user, default: nil, store: true
      needs :tile_selector, store: true
      needs :zoom, default: 1

      TOKEN_SIZE = 40

      def render
        @token_size = TOKEN_SIZE * @zoom
        @size = @token_size / 2
        @distance = @token_size

        entity = @game.current_entity
        step = @game.round.step_for(@selected_company || entity, 'place_token')
        return render_token_choices(step, entity) if step.respond_to?(:selectable_token_choices)

        tokener = @game.token_owner(entity)
        tokens = tokener.tokens_by_type
        tokens = list_coordinates(tokens, @distance, @size).map do |token, left, bottom|
          click = lambda do
            action = Engine::Action::PlaceToken.new(
              @game.current_entity,
              city: @tile_selector.city,
              slot: @tile_selector.slot_index,
              token_type: token.type,
              tokener: tokener,
            )
            process_action(action)
          end

          props = {
            attrs: {
              src: setting_for(:simple_logos, @game) ? token.simple_logo : token.logo,
            },
            on: {
              click: click,
            },
            style: style(left, bottom, @token_size),
          }

          h(:img, props)
        end

        h(:div, tokens)
      end

      private

      def render_token_choices(step, entity)
        options = step.selectable_token_choices(entity, @tile_selector.city)
        tokens = list_coordinates(options, @distance, @size).map do |option, left, bottom|
          token = option[:token]
          cost = option[:cost]
          disabled = cost > entity.cash
          click = lambda do
            process_action(Engine::Action::PlaceToken.new(
              entity,
              city: @tile_selector.city,
              slot: @tile_selector.slot_index,
              token_index: option[:index],
              cost: cost,
            ))
          end
          attrs = { type: 'button' }
          attrs[:disabled] = true if disabled
          props = {
            attrs: attrs,
            on: disabled ? {} : { click: click },
            style: style(left, bottom, @token_size).merge(
              padding: '0',
              fontSize: "#{12 * @zoom}px",
              opacity: disabled ? 0.6 : 1,
            ),
          }
          logo = setting_for(:simple_logos, @game) ? token.simple_logo : token.logo
          image = h(:img, attrs: { src: logo, alt: '' }, style: { display: 'block', width: '50%', margin: 'auto' })
          h(:button, props, [image, @game.format_currency(cost)])
        end

        h(:div, tokens)
      end
    end
  end
end
