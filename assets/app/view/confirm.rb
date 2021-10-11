# frozen_string_literal: true

module View
  class Confirm < Snabberb::Component
    # confirm_opts can be passed as a string which will default to yellow
    # if calling with a dictionary, you need to specify the skip or else
    # the opal compiler will remove the value
    # store(:confirm_opts, value = { message: 'test' }, skip: false)

    # This is almost the same as flash_opts but changing flash opts
    # twice from within the view and then from a callback causes the second
    # not to show
    needs :confirm_opts, default: {}, store: true

    def render
      @confirm_opts = { message: @confirm_opts } if @confirm_opts.is_a?(String)
      return h(:div) unless @confirm_opts&.any?

      `setTimeout(function() { self['$store']('confirm_opts', Opal.hash()) }, 3000)`

      props = {
        style: {
          padding: '1em',
          position: 'fixed',
          cursor: 'pointer',
          top: '0',
          left: '0',
          width: '100%',
          zIndex: '10000',
          textAlign: 'center',
          backgroundColor: 'yellow',
          color: 'black',
        },
        on: { click: -> { store(:confirm_opts, {}) } },
      }

      complete = lambda do
        c = @confirm_opts[:click]
        store(:confirm_opts, {})
        c.call
      end

      h(:div, props, [
        @confirm_opts[:message],
        h(:button, { style: { marginLeft: '1rem' }, on: { click: complete } }, 'Confirm'),
      ])
    end
  end
end
