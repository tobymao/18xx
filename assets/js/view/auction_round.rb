# frozen_string_literal: true

require 'view/actionable'
require 'view/company'
require 'view/pass_button'

require 'engine/action/bid'

module View
  class AuctionRound < Snabberb::Component
    include Actionable

    needs :selected_company, default: nil, store: true

    def render
      @round = @game.round
      @current_entity = @round.current_entity

      h(:div, 'Private Company Auction', [
        *render_companies,
        render_input,
      ])
    end

    def render_companies
      @round.companies.map do |company|
        h(Company, company: company, bids: @round.bids[company])
      end
    end

    def render_input
      input = h(:input, props: { value: @round.min_bid(@selected_company) })

      buy = lambda do
        process_action(Engine::Action::Bid.new(@current_entity, @selected_company, @round.min_bid(@selected_company)))
      end

      create_bid = lambda do
        price = input.JS['elm'].JS['value'].to_i
        process_action(Engine::Action::Bid.new(@current_entity, @selected_company, price))
      end

      decrease_bid = lambda do
        price = input.JS['elm'].JS['value'].to_i
        input.JS['elm'].JS['value'] = price - @round.min_increment
      end

      increase_bid = lambda do
        price = input.JS['elm'].JS['value'].to_i
        input.JS['elm'].JS['value'] = price + @round.min_increment
      end

      company_actions =
        if @round.may_purchase?(@selected_company)
          [h(:button, { on: { click: buy } }, 'Buy')]
        elsif @selected_company
          [
            input,
            h(:button, { on: { click: decrease_bid } }, '-'),
            h(:button, { on: { click: increase_bid } }, '+'),
            h(:button, { on: { click: create_bid } }, 'Place Bid'),
          ]
        end

      h(:div, [
        *company_actions,
        h(PassButton),
      ])
    end
  end
end
