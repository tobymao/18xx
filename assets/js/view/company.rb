# frozen_string_literal: true

require 'component'

module View
  class Company < Component
    def initialize(company:, bids: [])
      @company = company
      @bids = bids
    end

    def selected?
      @company == state(:selected_company, :scope_company)
    end

    def render_bidders
      names = @bids.map { |bid| "#{bid.player.name} (#{bid.price})" }
      h(:div, "Bidders: #{names}")
    end

    def render
      onclick = lambda do
        selected_company = selected? ? nil : @company
        set_state(:selected_company, selected_company, :scope_company)
      end

      style = {
        cursor: 'pointer',
        border: 'solid 1px rgba(0,0,0,0.2)',
        display: 'inline-block',
      }

      style['background-color'] = 'lightblue' if selected?

      h(:div, { style: style, on: { click: onclick } }, [
        h(:div, "Company: #{@company.name}"),
        h(:div, "Desc: #{@company.desc}"),
        h(:div, "Value: #{@company.value}"),
        h(:div, "Income: #{@company.income}"),
        render_bidders,
      ])
    end
  end
end
