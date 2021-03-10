# frozen_string_literal: true

require 'lib/color'
require 'lib/settings'
require 'view/game/actionable'

module View
  module Game
    class Company < Snabberb::Component
      include Actionable
      include Lib::Color
      include Lib::Settings

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

        if selected_company && @game.round.actions_for(entity).include?('assign') &&
          (@game.class::ALL_COMPANIES_ASSIGNABLE || entity.respond_to?(:assign!))
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
            background: @company.color,
            color: @company.text_color,
            border: '1px solid',
            borderRadius: '5px',
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
            props[:style][:border] = '1px solid'
          end
          props[:style][:display] = @display

          header_text = @game.respond_to?(:company_header) ? @game.company_header(@company) : 'PRIVATE COMPANY'

          children = [
            h(:div, { style: header_style }, header_text),
            h(:div, @company.name),
            h(:div, { style: description_style }, @company.desc),
            h(:div, { style: value_style }, "Value: #{@game.format_currency(@company.value)}"),
            h(:div, { style: revenue_style }, "Revenue: #{@game.format_currency(@company.revenue)}"),
          ]

          if @bids&.any?
            children << h(:div, { style: bidders_style }, 'Bidders:')
            children << render_bidders
          end

          unless @company.discount.zero?
            children << h(
            :div,
            { style: { float: 'center' } },
            "Price: #{@game.format_currency(@company.value - @company.discount)}"
          )
          end

          children << h('div.nowrap', { style: bidders_style }, "Owner: #{@company.owner.name}") if @company.owner
          if @game.company_status_str(@company)
            status_style = {
              marginTop: '0.5rem',
              clear: 'both',
              display: 'inline-block',
              justifyContent: 'center',
              width: '100%',
              backgroundColor: color_for(:bg2),
              color: color_for(:font2),
            }
            children << h(:div, { style: status_style }, @game.company_status_str(@company))
          end

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
            gridColumnEnd: "span #{@company.owner&.player? ? '3' : '2'}",
            marginBottom: '0.5rem',
            padding: '0.1rem 0.2rem',
            fontSize: '80%',
          },
        }

        @hidden_divs[company.sym] = h('div#hidden', hidden_props, company.desc)

        extra = []
        if (uses = company.ability_uses)
          extra << " (#{uses[0]}/#{uses[1]})"
        end
        extra << " #{@game.company_status_str(@company)}" if @game.company_status_str(@company)
        [h('div.nowrap', name_props, company.name + extra.join(',')),
         @game.show_value_of_companies?(company.owner) ? h('div.right', @game.format_currency(company.value)) : '',
         h('div.padded_number', @game.format_currency(company.revenue)),
         @hidden_divs[company.sym]]
      end
    end
  end
end
