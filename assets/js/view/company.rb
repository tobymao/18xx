# frozen_string_literal: true

require 'view/actionable'

module View
  class Company < Snabberb::Component
    include Actionable

    needs :company
    needs :bids, default: nil
    needs :selected_company, default: nil, store: true
    needs :game, store: true

    def selected?
      @company == @selected_company
    end

    def render
      props = {
        style: {
          display: 'inline-block',
          'vertical-align': 'top',
        },
      }
      children = [render_company]
      children << render_actions if selected? && @game.round.auction?

      h(:div, props, children)
    end

    def render_company
      onclick = lambda do
        selected_company = selected? ? nil : @company
        store(:selected_company, selected_company)
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

    def render_bidders
      bidders_style = {
        'font-weight': 'normal',
      }
      names = @bids
        .sort_by(&:price)
        .reverse.map { |bid| "#{bid.entity.name} (#{@game.format_currency(bid.price)})" }
        .join(', ')
      h(:div, { style: bidders_style }, names)
    end

    def render_actions
      @round = @game.round
      @current_entity = @round.current_entity
      step = @round.min_increment

      input = h(:input, style: { 'margin-right': '1rem' }, props: {
        value: @round.min_bid(@company),
        step: step,
        min: @company.min_bid + step,
        max: @current_entity.cash,
        type: 'number',
      })

      create_bid = lambda do
        price = input.JS['elm'].JS['value'].to_i
        process_action(Engine::Action::Bid.new(@current_entity, @selected_company, price))
        store(:selected_company, nil, skip: true)
      end

      buy = lambda do
        process_action(Engine::Action::Bid.new(@current_entity, @selected_company, @round.min_bid(@selected_company)))
        store(:selected_company, nil, skip: true)
      end

      company_actions =
        if @round.may_purchase?(@company)
          [h(:button, { on: { click: buy } }, 'Buy')]
        elsif @company && @round.may_bid?(@company)
          [
            input,
            h(:button, { on: { click: create_bid } }, 'Place Bid'),
          ]
        end

      action_style = {
        margin: '0.5rem 0 1rem 0',
        width: '300px',
        'text-align': 'center'
      }

      h(:div, { style: action_style }, company_actions)
    end
  end
end
