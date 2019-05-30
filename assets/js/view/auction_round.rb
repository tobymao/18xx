# frozen_string_literal: true

require 'component'
require 'view/company'

require 'engine/action/bid'
require 'engine/action/pass'

module View
  class AuctionRound < Component
    def initialize(round:, handler:)
      @round = round
      @handler = handler
      @current_entity = @round.current_entity
    end

    def render_companies
      @round.companies.map do |company|
        c(Company, company: company, bids: @round.bids[company])
      end
    end

    def render_input
      selected_company = state(:selected_company, :scope_company)
      input = h(:input, props: { value: @round.min_bid(selected_company) })

      create_bid = lambda do
        price = input.JS['elm'].JS['value'].to_i
        @handler.process_action(Engine::Action::Bid.new(@current_entity, selected_company, price))
        update
      end

      decrease_bid = lambda do
        price = input.JS['elm'].JS['value'].to_i
        input.JS['elm'].JS['value'] = price - @round.min_increment
      end

      increase_bid = lambda do
        price = input.JS['elm'].JS['value'].to_i
        input.JS['elm'].JS['value'] = price + @round.min_increment
      end

      pass = lambda do
        @handler.process_action(Engine::Action::Pass.new(@current_entity))
        update
      end

      h(:div, [
        input,
        h(:button, { on: { click: decrease_bid } }, '-'),
        h(:button, { on: { click: increase_bid } }, '+'),
        h(:button, { on: { click: create_bid } }, 'Place Bid'),
        h(:button, { on: { click: pass } }, 'Pass'),
      ])
    end

    def render
      h(:div, 'Private Company Auction', [
        *render_companies,
        render_input,
      ])
    end
  end
end
