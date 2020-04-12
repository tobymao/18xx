# frozen_string_literal: true

module View
  class Company < Snabberb::Component
    needs :company
    needs :bids, default: nil
    needs :selected_company, default: nil, store: true

    def selected?
      @company == @selected_company
    end

    def render_bidders
      return unless @bids

      bidders_style = {
        'font-weight': 'normal'
      }
      names = @bids.sort_by(&:price).reverse.map { |bid| h(:div, "#{bid.entity.name} (#{bid.price})") }
      h(:div, { style: bidders_style }, names)
    end

    def render
      onclick = lambda do
        selected_company = selected? ? nil : @company
        store(:selected_company, selected_company)
        # TODO: Move Bid Input into Private
      end

      style = {
        cursor: 'pointer',
        border: 'solid 1px rgba(0,0,0,0.2)',
        display: 'block',
        margin: '5px 0px',
        'text-align': 'center',
        'font-weight': 'bold'
      }

      header_style = {
        background: 'yellow',
        border: '1px solid',
        'font-size': '90%'
      }

      description_style = {
        'font-size': '80%',
        'text-align': 'left',
        'font-weight': 'normal'
      }

      value_style = {
        'float': 'left'
      }

      revenue_style = {
        'float': 'right'
      }

      bidders_style = {
        'margin': '20px 0px 0px 0px'
      }

      style['background-color'] = 'lightblue' if selected?

      h(:div, { style: style, on: { click: onclick } }, [
        h(:div, { style: header_style }, 'PRIVATE COMPANY'),
        h(:div, @company.name),
        h(:div, { style: description_style }, @company.desc),
        h(:div, { style: value_style }, "Value: #{@company.value}"),
        h(:div, { style: revenue_style }, "Revenue: #{@company.revenue}"),
        h(:div, { style: bidders_style }, 'Bidders:'),
        render_bidders
      ].compact)
    end
  end
end
