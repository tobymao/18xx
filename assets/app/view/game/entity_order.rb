# frozen_string_literal: true

require 'lib/truncate'
require 'lib/settings'

module View
  module Game
    class EntityOrder < Snabberb::Component
      needs :round

      include Lib::Settings

      def render
        items = @round.entities.map.with_index do |entity, index|
          entity_props = {
            key: "entity_#{index}",
            style: {
              float: 'left',
              listStyle: 'none',
              paddingRight: '1rem',
            },
          }

          if @round.current_entity == entity
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

          if @round.can_act?(entity)
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
            logo_props = {
              attrs: { src: entity.logo },
              style: {
                padding: '0 0.4rem 0 0',
                height: '1.2rem',
              },
            }
            children << h(:img, logo_props)
          end

          owner = " (#{entity.owner.name.truncate})" if !entity.player? && entity.owner
          children << h(:span, "#{entity.name}#{owner}")

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
