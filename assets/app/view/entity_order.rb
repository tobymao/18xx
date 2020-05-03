# frozen_string_literal: true

class EntityOrder < Snabberb::Component
  needs :round

  def render
    divs = @round.entities.map.with_index do |entity, index|
      style = {
        display: 'inline-block',
        'margin-right': '1rem',
        'white-space': 'nowrap'
      }
      style['text-decoration'] = 'underline' if @round.can_act?(entity)

      if index.positive?
        style['border-left'] = 'black solid thin'
        style['padding-left'] = '1rem'
      end

      children = []
      if entity.corporation?
        logo_props = {
          attrs: {
            src: entity.logo,
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
            'vertical-align': 'middle',
          },
        }
        children << h(:span, logo_container_props, [h(:img, logo_props)])
      end

      owner = " (#{entity.owner.name})" if !entity.player? && entity.owner
      children << h(:span, "#{entity.name}#{owner}")

      h(:div, { style: style }, children)
    end

    props = {
      style: {
        margin: '1rem 0 1rem 0',
        'font-size': '1.rem',
        height: '1.5rem',
      }
    }

    h(:div, props, divs)
  end
end
