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
      names = @bids
        .sort_by(&:price)
        .reverse.map { |bid| "#{bid.entity.name} ($#{bid.price})" }
        .join(', ')
      h(:div, { style: bidders_style }, names)
    end

    def render
      onclick = lambda do
        selected_company = selected? ? nil : @company
        store(:selected_company, selected_company)
        # TODO: Move Bid Input into Private
      end

      header_style = {
        background: 'yellow',
        border: '1px solid',
        'margin-bottom': '0.5rem',
        'font-size': '90%'
      }

      description_style = {
        margin: '0.5rem 0 0.5rem 0',
        'font-size': '80%',
        'text-align': 'left',
        'font-weight': 'normal',
      }

      value_style = {
        display: 'inline-block',
        width: '50%',
        'text-align': 'left'
      }

      revenue_style = {
        display: 'inline-block',
        width: '50%',
        'text-align': 'right'
      }

      bidders_style = {
        'margin-top': '1rem'
      }

      props = {
        style: {
          display: 'inline-block',
          cursor: 'pointer',
          border: 'solid 1px gainsboro',
          padding: '0.5rem',
          margin: '0.5rem 0.5rem 0 0',
          width: '300px',
          'text-align': 'center',
          'font-weight': 'bold',
        },
        on: { click: onclick },
      }

      props[:style]['background-color'] = 'lightblue' if selected?

      h(:div, props, [
        h(:div, { style: header_style }, 'PRIVATE COMPANY'),
        h(:div, @company.name),
        h(:div, { style: description_style }, @company.desc),
        h(:div, [
          h(:div, { style: value_style }, "Value: #{@company.value}"),
          h(:div, { style: revenue_style }, "Revenue: #{@company.revenue}"),
        ]),
        h(:div, { style: bidders_style }, 'Bidders:'),
        render_bidders,
      ].compact)
    end
  end
end
