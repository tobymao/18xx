# frozen_string_literal: true

module View
  class Form < Snabberb::Component
    needs :app_route, default: nil, store: true

    def render
      @inputs = {}

      render_content
    end

    def render_content
      raise NotImplementedError
    end

    def submit
      raise NotImplementedError
    end

    def params
      @inputs.map do |key, input|
        [key, input.JS['elm'].JS['value']]
      end.to_h
    end

    def render_form(name, inputs)
      enter = lambda do |event|
        code = event.JS['keyCode']
        submit if code && code == 13
      end

      props = {
        on: { keyup: enter },
      }

      h(:form, props, [
        h(:legend, name),
        h(:div, inputs),
        h(:input, attrs: { type: :text }, style: { display: 'none' }),
      ])
    end

    def render_input(label, id:, el: 'input', type: 'text', attrs: {}, children: [])
      props = {
        style: {
          margin: '1rem',
        },
        attrs: {
          placeholder: label,
          type: type,
          **attrs,
        },
      }
      input = h(el, props, children)
      @inputs[id] = input
      h(:div, { style: { display: 'inline-block' } }, [label, input])
    end

    def render_button(text, &block)
      props = {
        style: {
          margin: '0.5rem 0.5rem 0 0',
        },
        attrs: { type: :button },
        on: { click: block },
      }

      h(:button, props, text)
    end
  end
end
