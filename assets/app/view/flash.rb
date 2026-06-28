# frozen_string_literal: true

# backtick_javascript: true

module View
  class Flash < Snabberb::Component
    # flash_opts can be passed as a string which will default to salmon
    # if calling with a dictionary, you need to specify the skip or else
    # the opal compiler will remove the value
    # store(:flash_opts, value = { message: 'test' }, skip: false)
    needs :flash_opts, default: {}, store: true

    def render
      @flash_opts = { message: @flash_opts } if @flash_opts.is_a?(String)
      return h(:div) unless @flash_opts&.any?

      # flash_opts may be set client-side (symbol keys) or seeded by the server
      # through needs (string keys), so read both forms.
      message = @flash_opts[:message] || @flash_opts['message']
      color = @flash_opts[:color] || @flash_opts['color']

      `setTimeout(function() { self['$store']('flash_opts', Opal.hash()) }, 3000)`

      props = {
        style: {
          boxSizing: 'border-box',
          padding: '1em',
          position: 'fixed',
          cursor: 'pointer',
          top: '0',
          left: '0',
          width: '100%',
          zIndex: '10000',
          textAlign: 'center',
          backgroundColor: color || 'salmon',
          color: 'black',
        },
        on: { click: -> { store(:flash_opts, {}) } },
      }

      h(:div, props, message)
    end
  end
end
