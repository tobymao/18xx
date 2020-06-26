# frozen_string_literal: true

module View
  module Game
    class Company < Snabberb::Component
      needs :company
      needs :bids, default: nil
      needs :selected_company, default: nil, store: true
      needs :game, store: true
      needs :tile_selector, default: nil, store: true
      needs :display, default: 'inline-block'
      needs :table, default: false

      def selected?
        @company == @selected_company
      end

      def purchasable?
        !@company.owner || @game.round.operating? && @company.owner.player?
      end

      def ability_usable?
        return if (@company.all_abilities.map(&:type) & Round::Operating::ABILITIES).empty?

        @game.round.can_act?(@company.owner) || @company.owner.player?
      end

      def select_company(event)
        event.JS.stopPropagation
        selected_company = (ability_usable? || purchasable?) && !selected? ? @company : nil
        store(:tile_selector, nil, skip: true)
        store(:selected_company, selected_company)
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
        if @table
          @hidden_divs = {}
          render_company_on_card(@company)
        else
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
              cursor: purchasable? || ability_usable? ? 'pointer' : 'default',
              boxSizing: 'border-box',
              padding: '0.5rem',
              margin: '0.5rem 0.5rem 0 0',
              'text-align': 'center',
              'font-weight': 'bold',
            },
            on: { click: ->(event) { select_company(event) } },
          }
          if selected?
            props[:style]['background-color'] = 'lightblue'
            props[:style]['color'] = 'black'
          end
          props[:style][:display] = @display

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

      def render_company_on_card(company)
        toggle_desc = lambda do
          display = Native(@hidden_divs[company.sym]).elm.style.display
          Native(@hidden_divs[company.sym]).elm.style.display = display == 'none' ? 'grid' : 'none'
        end

        row_props = {
          style: {
            grid: @company.owner.player? ? 'auto 1fr / 4fr 1fr 1fr [last]' : 'auto 1fr / 5fr 1fr [last]',
            cursor: 'pointer',
          },
        }
        row_props[:on] = { click: ->(event) { select_company(event) } } unless @company.owner.player?

        income_props = {
          style: {
            paddingRight: '0.3rem',
          },
        }

        hidden_props = {
          style: {
            display: 'none',
            gridColumnEnd: 'span 3',
            marginBottom: '0.5rem',
            padding: '0.1rem 0.2rem',
            fontSize: '80%',
            cursor: ability_usable? ? 'pointer' : 'default',
          },
        }
        if selected?
          hidden_props[:style]['background-color'] = 'lightblue'
          hidden_props[:style]['color'] = 'black'
          hidden_props[:style][:borderRadius] = '0.2rem'
        end

        @hidden_divs[company.sym] = h('div#hidden', hidden_props, company.desc)

        h(:div, row_props, [
          h('span.name.nowrap', { on: { click: toggle_desc } }, company.name),
          @company.owner.player? ? h('span.right', income_props, @game.format_currency(company.value)) : '',
          h('span.right', income_props, @game.format_currency(company.revenue)),
          @hidden_divs[company.sym],
        ])
      end
    end
  end
end
