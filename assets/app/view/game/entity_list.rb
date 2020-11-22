# frozen_string_literal: true

require 'lib/truncate'
require 'lib/settings'

module View
  module Game
    class EntityList < Snabberb::Component
      needs :round
      needs :entities
      needs :acting_entity, default: nil
      needs :game, store: true

      include Lib::Settings
      TOKEN_SIZES = { small: 1.2, medium: 1.4, large: 1.8 }.freeze

      def render
        items = @entities.map.with_index do |entity, index|
          entity_props = {
            key: "entity_#{index}",
            style: {
              float: 'left',
              listStyle: 'none',
              paddingRight: '1rem',
              display: 'flex',
            },
          }

          if @acting_entity == entity
            scroll_to = lambda do |vnode|
              elm = Native(vnode)['elm']
              elm['parentElement']['parentElement'].scrollLeft = elm['offsetLeft'] - 10
            end

            entity_props[:hook] = {
              insert: scroll_to,
              update: ->(_, vnode) { scroll_to.call(vnode) },
            }
          end

          style = entity_props[:style]

          if @acting_entity == entity || @round.can_act?(entity)
            style[:textDecoration] = 'underline'
            style[:fontSize] = '1.1rem'
            style[:fontWeight] = 'bold'
          end

          if index.positive?
            style[:borderLeft] = "#{setting_for(:font)} solid thin"
            style[:paddingLeft] = '1rem'
          end

          children = []
          if entity.corporation?
            size = TOKEN_SIZES[@game.corporation_size(entity)]
            vpadding = (TOKEN_SIZES[:large] - size)/2
            logo_props = {
              attrs: { src: entity.logo },
              style: {
                padding: "#{vpadding}rem 0.4rem #{vpadding}rem 0",
                height: "#{size}rem",
                margin: 'auto',
              },
            }
            children << h(:img, logo_props)
          end

          text_props = { style: { margin: 'auto' } }
          small_props = { style: { fontSize: 'smaller' } }
          owner = "#{entity.owner.name.truncate}" if !entity.player? && entity.owner
          owner = 'CLOSED' if entity.closed?

          text = [entity.name]
          text += [h(:br), h(:span, small_props, owner)] if owner
          children << h(:span, text_props, text)

          h(:li, entity_props, children)
        end

        div_props = {
          key: 'entity_order',
          attrs: { title: 'Order' },
          style: {
            margin: '1rem 0',
            overflow: 'auto',
          },
        }

        ul_props = {
          key: 'entity_order_container',
          style: {
            width: 'max-content',
            margin: '0',
            padding: '0',
          },
        }

        h(:div, div_props, [
          h(:ul, ul_props, items),
        ])
      end
    end
  end
end
