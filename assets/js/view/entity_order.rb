# frozen_string_literal: true

require 'engine/player'

class EntityOrder < Snabberb::Component
  needs :round

  def render
    divs = @round.entities.map.with_index do |entity, index|
      style = {
        display: 'inline-block',
        'margin-right': '1rem',
      }
      style['text-decoration'] = 'underline' if @round.can_act?(entity)

      if index.positive?
        style['border-left'] = 'black solid thin'
        style['padding-left'] = '1rem'
      end

      owner = " (#{entity.owner.name})" if !entity.player? && entity.owner

      h(:div, { style: style }, "#{entity.name}#{owner}")
    end

    props = {
      style: {
        margin: '1rem 0 1rem 0',
        'font-size': 'large',
      }
    }

    h(:div, props, divs)
  end
end
