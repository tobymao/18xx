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

      h('form.pure-form.pure-form-stacked', { on: { keyup: enter } }, [
        h(:legend, name),
        h('div.pure-g', inputs),
        h(:input, attrs: { type: :text }, style: { display: 'none' }),
      ])
    end

    def render_input(label, id:, el: 'input', type: 'text', attrs: {}, children: [])
      props = { attrs: { type: type, **attrs } }
      input = h("#{el}.pure-u-23-24", props, children)
      @inputs[id] = input
      h('div.pure-u-1.pure-u-md-1-2', [label, input])
    end

    def render_button(text, &block)
      h('div.pure-u-1-3', { style: { margin: '1rem 0 1rem 0' } }, [
        h(
          'button.pure-button.pure-button-primary.pure-u-23-24',
          { attrs: { type: :button }, on: { click: block } },
          text,
        )
      ])
    end
  end
end
