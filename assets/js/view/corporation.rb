# frozen_string_literal: true

module View
  class Corporation < Snabberb::Component
    needs :corporation
    needs :selected_corporation, default: nil, store: true

    def selected?
      @corporation == @selected_corporation
    end

    def render
      onclick = lambda do
        selected_corporation = selected? ? nil : @corporation
        store(:selected_corporation, selected_corporation)
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
