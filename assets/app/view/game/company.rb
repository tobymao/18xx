# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class Company < Snabberb::Component
      include Actionable

      needs :company
      needs :bids, default: nil
      needs :selected_company, default: nil, store: true
      needs :tile_selector, default: nil, store: true
      needs :display, default: 'inline-block'
      needs :layout, default: nil

      def selected?
        @company == @selected_company
      end

      def select_company(event)
        event.JS.stopPropagation
        entity = @game.current_entity
        selected_company = selected? ? nil : @company

        if selected_company && @game.round.actions_for(entity).include?('assign')
          return process_action(Engine::Action::Assign.new(entity, target: selected_company))
        end

        store(:tile_selector, nil, skip: true)
        store(:selected_company, selected_company)
      end

      def render_bidders
        bidders_style = {
          fontWeight: 'normal',
          margin: '0 0.5rem',
        }
        names = @bids
          .sort_by(&:price)
          .reverse.map { |bid| "#{bid.entity.name} (#{@game.format_currency(bid.price)})" }
          .join(', ')
        h(:div, { style: bidders_style }, names)
      end

      def render
        if @layout == :table
          @hidden_divs = {}
          render_company_on_card(@company)
        else
          header_style = {
            background: 'yellow',
            border: '1px solid',
            borderRadius: '5px',
            color: 'black',
            marginBottom: '0.5rem',
            fontSize: '90%',
          }

          description_style = {
            margin: '0.5rem 0',
            fontSize: '80%',
            textAlign: 'left',
            fontWeight: 'normal',
          }

          value_style = {
            float: 'left',
          }

          revenue_style = {
            float: 'right',
          }

          bidders_style = {
            marginTop: '0.5rem',
            display: 'inline-block',
            clear: 'both',
            width: '100%',
          }

          props = {
            style: {
              cursor: 'pointer',
              boxSizing: 'border-box',
              padding: '0.5rem',
              margin: '0.5rem 5px 0 0',
              textAlign: 'center',
              fontWeight: 'bold',
            },
            on: { click: ->(event) { select_company(event) } },
          }
          if selected?
            props[:style][:backgroundColor] = 'lightblue'
            props[:style][:color] = 'black'
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

      def toggle_desc(event, company)
        event.JS.stopPropagation
        display = Native(@hidden_divs[company.sym]).elm.style.display
        Native(@hidden_divs[company.sym]).elm.style.display = display == 'none' ? 'grid' : 'none'
      end

      def render_company_on_card(company)
        name_props = {
          style: {
            display: 'inline-block',
            cursor: 'pointer',
          },
          on: { click: ->(event) { toggle_desc(event, company) } },
        }

        hidden_props = {
          style: {
            display: 'none',
            gridColumnEnd: "span #{@company.owner.player? ? '3' : '2'}",
            marginBottom: '0.5rem',
            padding: '0.1rem 0.2rem',
            fontSize: '80%',
          },
        }

        @hidden_divs[company.sym] = h('div#hidden', hidden_props, company.desc)

        [h('div.nowrap', name_props, company.name),
         @company.owner.player? ? h('div.right', @game.format_currency(company.value)) : '',
         h('div.padded_number', @game.format_currency(company.revenue)),
         @hidden_divs[company.sym]]
      end
    end
  end
end
