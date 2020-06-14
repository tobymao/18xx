# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/company'
require 'view/game/par'
require 'view/game/players'
require 'view/game/undo_and_pass'

module View
  module Game
    module Round
      class Auction < Snabberb::Component
        include Actionable

        needs :selected_company, default: nil, store: true

        def render
          @round = @game.round
          @current_entity = @round.current_entity
          @company_pending_par = @round.company_pending_par

          h(:div, [
            h(UndoAndPass, pass: !@company_pending_par),
            *render_company_pending_par,
            *render_companies,
            h(Players, game: @game),
          ].compact)
        end

        def render_company_pending_par
          return [] unless @company_pending_par

          corporation = @company_pending_par.abilities(:share)[:share].corporation
          [
            h(Corporation, corporation: corporation),
            h(Par, corporation: corporation),
          ]
        end

        def render_companies
          props = {
            style: {
              display: 'inline-block',
              'vertical-align': 'top',
            },
          }

          @round.companies.map do |company|
            children = [h(Company, company: company, bids: @round.bids[company])]
            children << render_input if @selected_company == company
            h(:div, props, children)
          end
        end

        def render_input
          step = @round.min_increment

          input = h(:input, style: { 'margin-right': '1rem' }, props: {
            value: @round.min_bid(@selected_company),
            step: step,
            min: @selected_company.min_bid + step,
            max: @round.max_bid(@current_entity, @selected_company),
            type: 'number',
            size: @current_entity.cash.to_s.size,
          })

          buy = lambda do
            process_action(Engine::Action::Bid.new(
              @current_entity,
              company: @selected_company,
              price: @round.min_bid(@selected_company),
            ))
            store(:selected_company, nil, skip: true)
          end

          create_bid = lambda do
            price = input.JS['elm'].JS['value'].to_i
            process_action(Engine::Action::Bid.new(
              @current_entity,
              company: @selected_company,
              price: price,
            ))
            store(:selected_company, nil, skip: true)
          end

          company_actions =
            if @round.may_purchase?(@selected_company)
              [h('button.button', { on: { click: buy } }, 'Buy')]
            elsif @selected_company && @round.may_bid?(@selected_company)
              [
                input,
                h('button.button', { on: { click: create_bid } }, 'Place Bid'),
              ]
            end

          h(:div, { style: { 'text-align': 'center', 'margin': '1rem' } }, company_actions)
        end
      end
    end
  end
end
