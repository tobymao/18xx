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
        'text-align': 'center'
      }
      sortedBids = @bids.sort_by { |bid| -bid.price }
      names = sortedBids.map { |bid| h(:div, "#{bid.entity.name} (#{bid.price})" )}
      h(:div, { style: bidders_style }, names )

    end 

    def render
      onclick = lambda do
        selected_company = selected? ? nil : @company
        store(:selected_company, selected_company)
        #TODO: Move Bid Input into Private  
      end

      style = {
        cursor: 'pointer',
        border: 'solid 1px rgba(0,0,0,0.2)',
        display: 'block',
        margin: '5px 0px'
      }

      header_style = {
        background: 'yellow',
        border: '1px solid',
        'text-align': 'center',
        'font-size': '90%'
      }

      title_style = {
        'font-weight': 'bold',
        'text-align': 'center'
      }

      description_style = {
        'font-size': '80%'
      }

      value_style = {
        'font-weight': 'bold',
        'float': 'left'
      }

      revenue_style = {
        'font-weight': 'bold',
        'float': 'right'
      }

      bidders_style = {
        'font-weight': 'bold',
        'text-align': 'center'
      }

      style['background-color'] = 'lightblue' if selected?

      h(:div, { style: style, on: { click: onclick } }, [
        h(:div, { style: header_style }, "PRIVATE COMPANY"),
        h(:div, { style: title_style }, "#{@company.name}"),
        h(:div, { style: description_style }, "#{@company.desc}"),
        h(:div, { style: value_style }, "Value: #{@company.value}"),
        h(:div, { style: revenue_style }, "Revenue: #{@company.revenue}"),
        h(:br),
        h(:div, { style: bidders_style }, "Bidders:"),
        render_bidders
      ].compact)
    end
  end
end
