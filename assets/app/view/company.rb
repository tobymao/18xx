# frozen_string_literal: true

module View
  class Company < Snabberb::Component
    needs :company
    needs :bids, default: nil
    needs :selected_company, default: nil, store: true
    needs :game, store: true

    def selected?
      @company == @selected_company
    end

    def render_bidders
      bidders_style = {
        'font-weight': 'normal'
      }
      names = @bids
        .sort_by(&:price)
        .reverse.map { |bid| "#{bid.entity.name} (#{@game.format_currency(bid.price)})" }
        .join(', ')
      h(:div, { style: bidders_style }, names)
    end

    def render
      onclick = lambda do
        selected_company = selected? ? nil : @company
        store(:selected_company, selected_company)
      end

      header_style = {
        background: 'yellow',
        border: '1px solid',
        'border-radius': '5px',
        color: 'black',
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
          'border-radius': '10px',
          overflow: 'hidden',
          padding: '0.5rem',
          margin: '0.5rem 0.5rem 0 0',
          width: '300px',
          'text-align': 'center',
          'font-weight': 'bold',
          'vertical-align': 'top',
        },
        on: { click: onclick },
      }
      if selected?
        props[:style]['background-color'] = 'lightblue'
        props[:style]['color'] = 'black'
      end

      children = [
        h(:div, { style: header_style }, 'PRIVATE COMPANY'),
        h(:div, @company.name),
        h(:div, { style: description_style }, @company.desc),
        h(:div, [
          h(:div, { style: value_style }, "Value: #{@game.format_currency(@company.value)}"),
          h(:div, { style: revenue_style }, "Revenue: #{@game.format_currency(@company.revenue)}"),
        ]),
      ]

      if @bids&.any?
        children << h(:div, { style: bidders_style }, 'Bidders:')
        children << render_bidders
      end

      children << h(:div, { style: bidders_style }, "Owner: #{@company.owner.name}") if @company.owner

      h(:div, props, children)
    end
  end
end
