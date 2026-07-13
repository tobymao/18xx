# frozen_string_literal: true

# backtick_javascript: true

module View
  class Form < Snabberb::Component
    needs :app_route, default: nil, store: true
    needs :turnstile_sitekey, default: nil
    # The widget id must outlive component re-renders (snabberb rebuilds the
    # instance on every render pass), so it lives in the store, not an ivar --
    # otherwise the solved token stops being submitted after the first re-render.
    needs :turnstile_widget_id, default: nil, store: true

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

    def params(inputs = nil)
      param = (inputs || @inputs).to_h do |key, input|
        input = Native(input)
        elm = input['elm']
        [key, %w[checkbox radio].include?(elm['type']) ? elm['checked'] : elm['value']]
      end
      param['cf_turnstile_response'] = turnstile_response if @turnstile_sitekey
      param
    end

    # Cloudflare Turnstile (CAPTCHA) for the unauthenticated auth forms. Renders
    # nothing unless a site key was provided; the token rides along in #params and
    # the widget is reset after each submit so the next attempt gets a fresh one.
    def turnstile_widget
      return '' unless @turnstile_sitekey

      h(:div, {
          key: 'turnstile',
          style: { margin: '0.5rem 0' },
          hook: { insert: ->(vnode) { render_turnstile(vnode) } },
        })
    end

    def render_turnstile(vnode)
      sitekey = @turnstile_sitekey
      %x{
        var self = this;
        var elm = #{vnode}.elm;
        var doRender = function() {
          self.$remember_turnstile_id(window.turnstile.render(elm, { sitekey: #{sitekey} }));
        };
        if (window.turnstile && window.turnstile.render) {
          doRender();
        } else {
          var tries = 0;
          var iv = setInterval(function() {
            if (window.turnstile && window.turnstile.render) { clearInterval(iv); doRender(); }
            else if (++tries > 100) { clearInterval(iv); }
          }, 100);
        }
      }
    end

    def remember_turnstile_id(id)
      store(:turnstile_widget_id, id, skip: true)
    end

    # Both only run after the widget rendered (which sets the id and requires
    # window.turnstile to exist), so no window.turnstile guard is needed here --
    # unlike render_turnstile, which mounts before the async script may have loaded.
    def turnstile_response
      id = @turnstile_widget_id
      return '' unless id

      `window.turnstile.getResponse(#{id}) || ''`
    end

    def reset_turnstile
      id = @turnstile_widget_id
      `window.turnstile.reset(#{id})` if id
    end

    def render_form(name, inputs, description = nil, on_submit: nil)
      on_submit ||= -> { submit }
      props = {
        on: { keyup: ->(event) { on_submit.call if Native(event)['key'] == 'Enter' } },
      }
      h2_props = { style: { margin: '1rem 0 0.5rem 0' } }

      id = name.gsub(/\s/, '-').downcase
      h(:form, props, [
        h(:legend, [h(:h2, h2_props, name)]),
        description ? h(:p, description) : '',
        h("div##{id}", inputs),
        h(:input, attrs: { type: :text }, style: { display: 'none' }),
      ])
    end

    # rubocop:disable Layout/LineLength
    def render_input(label, id:, placeholder: '', el: 'input', type: 'text', attrs: {}, on: {}, container_style: {}, label_style: {}, input_style: {}, children: [], siblings: [], inputs: nil)
      # rubocop:enable Layout/LineLength
      label_props = {
        style: {
          cursor: 'pointer',
          **label_style,
        },
        attrs: { for: id },
      }
      input_props = {
        style: input_style,
        attrs: {
          id: id,
          type: type,
          **attrs,
        },
        on: { **on },
      }
      input_props[:attrs][:placeholder] = placeholder if placeholder != ''
      if (small_input_elm = %w[radio checkbox].include?(type))
        label_props[:style][:verticalAlign] = 'middle'
        input_props[:style][:verticalAlign] = 'middle'
      end
      input = h(el, input_props, children)
      inputs ||= @inputs
      inputs[id] = input
      children = small_input_elm ? [input, h(:label, label_props, label)] : [h(:label, label_props, label), input]

      h(
        'div.input-container',
        { style: { **container_style } },
        children + siblings,
      )
    end

    def render_button(text, style: {}, attrs: {}, &block)
      props = {
        attrs: {
          **attrs,
          type: :button,
        },
        style: {
          **style,
        },
        on: { click: block },
      }

      h(:button, props, text)
    end

    def render_checkbox(label, id, form, checked)
      render_input(
        label,
        id: id,
        type: 'checkbox',
        inputs: form,
        attrs: {
          checked: checked,
        }
      )
    end
  end
end
