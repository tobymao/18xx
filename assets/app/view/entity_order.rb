# frozen_string_literal: true

class EntityOrder < Snabberb::Component
  needs :round

  def render
    divs = @round.entities.map.with_index do |entity, index|
      entity_props = {
        key: "entity_#{index}",
        style: {
          display: 'inline-block',
          height: '1.5rem',
          'vertical-align': 'top',
          'margin-right': '1rem',
          'white-space': 'nowrap',
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
        style['text-decoration'] = 'underline'
        style['font-weight'] = 'bold'
      end

      if index.positive?
        style['border-left'] = 'black solid thin'
        style['padding-left'] = '1rem'
      end

      children = []
      if entity.corporation?
        logo_props = {
          attrs: {
            src: entity.logo,
            width: '25px',
          },
          style: {
            'max-height': '1.2rem',
            padding: '0 .4rem 0 0',
          },
        }
        logo_container_props = {
          style: {
            height: '100%',
            display: 'inline-block',
            'vertical-align': 'top',
          },
        }
        children << h(:span, logo_container_props, [h(:img, logo_props)])
      end

      owner = " (#{entity.owner.name})" if !entity.player? && entity.owner
      children << h(:span, "#{entity.name}#{owner}")

      h(:div, entity_props, children)
    end

    props = {
      key: 'entity_order',
      style: {
        margin: '1rem 0 1rem 0',
        'font-size': '1.1rem',
        overflow: 'auto',
      },
    }

    container_props = {
      style: {
        width: 'max-content',
        'margin-bottom': '0.5rem',
      },
      key: 'entity_order_container',
    }

    h(:div, props, [
      h(:div, container_props, divs),
    ])
  end
end
