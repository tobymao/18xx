# frozen_string_literal: true

require 'component'

module View
  class Corporation < Component
    def initialize(corporation:)
      @corporation = corporation
    end

    def selected?
      @corporation == state(:selected_corporation, :scope_corporation)
    end

    def render
      onclick = lambda do
        selected_corporation = selected? ? nil : @corporation
        set_state(:selected_corporation, selected_corporation, :scope_corporation)
      end

      style = {
        cursor: 'pointer',
        border: 'solid 1px rgba(0,0,0,0.2)',
        display: 'inline-block',
      }

      style['background-color'] = 'lightblue' if selected?

      h(:div, { style: style, on: { click: onclick } }, [
        h(:div, "Corporation: #{@corporation.name}"),
        h(:div, "Available Shares: #{@corporation.shares.size}"),
      ])
    end
  end
end
