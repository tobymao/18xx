# frozen_string_literal: true

module View
  module Game
    class Company < Snabberb::Component
      needs :company
      needs :bids, default: nil
      needs :selected_company, default: nil, store: true
      needs :game, store: true
      needs :tile_selector, default: nil, store: true
      needs :inline, default: true

      def selected?
        @company == @selected_company
      end

      def render_bidders
        bidders_style = {
          'font-weight': 'normal',
          margin: '0 0.5rem',
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
          store(:tile_selector, nil)
          store(:selected_company, selected_company)
        end

        header_style = {
          background: 'yellow',
          border: '1px solid',
          'border-radius': '5px',
          color: 'black',
          'margin-bottom': '0.5rem',
          'font-size': '90%',
        }

        description_style = {
          margin: '0.5rem 0',
          'font-size': '80%',
          'text-align': 'left',
          'font-weight': 'normal',
        }

        value_style = {
          float: 'left',
        }

        revenue_style = {
          float: 'right',
        }

        bidders_style = {
          'margin-top': '0.5rem',
          display: 'inline-block',
          clear: 'both',
          width: '100%',
        }

        props = {
          style: {
            cursor: 'pointer',
            boxSizing: 'border-box',
            padding: '0.5rem',
            margin: '0.5rem 0.5rem 0 0',
            'text-align': 'center',
            'font-weight': 'bold',
          },
          on: { click: onclick },
        }
        if selected?
          props[:style]['background-color'] = 'lightblue'
          props[:style]['color'] = 'black'
        end
        props[:style][:display] = 'block' unless @inline

        children = [
          h(:div, { style: header_style }, 'PRIVATE COMPANY'),
          h(:div, @company.name),
          h(:div, { style: description_style }, @company.desc),
          h(:div, { style: value_style }, "Value: #{@game.format_currency(@company.value)}"),
          h(:div, { style: revenue_style }, "Revenue: #{@game.format_currency(@company.revenue)}"),
        ]

        if @bids&.any?
          children << h(:div, { style: bidders_style }, 'Bidders:')
          children << render_bidders
        end

        children << h('div.nowrap', { style: bidders_style }, "Owner: #{@company.owner.name}") if @company.owner

        h('div.company.card', props, children)
      end
    end
  end
end
