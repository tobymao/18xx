# frozen_string_literal: true

module View
  class Company < Snabberb::Component
    needs :company
    needs :bids
    needs :selected_company, default: nil, store: true

    def selected?
      @company == @selected_company
    end

    def render_bidders
      names = @bids.map { |bid| "#{bid.entity.name} (#{bid.price})" }
      h(:div, "Bidders: #{names}")
    end

    def render
      onclick = lambda do
        selected_company = selected? ? nil : @company
        store(:selected_company, selected_company)
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
