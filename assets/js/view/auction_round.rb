# frozen_string_literal: true

require 'view/actionable'
require 'view/company'
require 'view/undo_and_pass'

require 'engine/action/bid'

module View
  class AuctionRound < Snabberb::Component
    include Actionable

    needs :round
    needs :selected_company, default: nil, store: true

    def render
      @current_entity = @round.current_entity

      h(:div, [
        h(UndoAndPass, undo: @game.actions.size.positive?),
        *render_companies,
        render_input,
      ].compact)
    end

    def render_companies
      @round.companies.map do |company|
        h(Company, company: company, bids: @round.bids[company])
      end
    end

    def render_input
      return unless @selected_company

      step = @round.min_increment

      input = h(:input, props: {
        value: @round.min_bid(@selected_company),
        step: step,
        min: @selected_company.min_bid + step,
        max: @current_entity.cash,
        type: 'number',
      })

      buy = lambda do
        process_action(Engine::Action::Bid.new(@current_entity, @selected_company, @round.min_bid(@selected_company)))
        store(:selected_company, nil, skip: true)
      end

      create_bid = lambda do
        price = input.JS['elm'].JS['value'].to_i
        process_action(Engine::Action::Bid.new(@current_entity, @selected_company, price))
        store(:selected_company, nil, skip: true)
      end

      company_actions =
        if @round.may_purchase?(@selected_company)
          [h(:button, { on: { click: buy } }, 'Buy')]
        elsif @selected_company && @round.may_bid?(@selected_company)
          [
            input,
            h(:button, { on: { click: create_bid } }, 'Place Bid'),
          ]
        end

      h(:div, company_actions)
    end
  end
end
