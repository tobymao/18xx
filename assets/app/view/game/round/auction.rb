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
          @step = @round.active_step
          @current_actions = @step.current_actions

          h(:div, [
            h(UndoAndPass, pass: @current_actions.include?('pass')),
            *render_company_pending_par,
            *render_companies,
            h(Players, game: @game),
          ].compact)
        end

        def render_company_pending_par
          return [] unless @current_actions.include?('par')

          corporation = @step.company_pending_par.abilities(:share).share.corporation

          [
            h(Corporation, corporation: corporation),
            h(Par, corporation: corporation),
          ]
        end

        def render_companies
          return [] unless @current_actions.include?('bid')

          @selected_company = @step.auctioning_company if @step.auctioning_company

          props = {
            style: {
              display: 'inline-block',
              verticalAlign: 'top',
            },
          }

          @step.companies.map do |company|
            children = [h(Company, company: company, bids: @step.bids[company])]
            children << render_input(company) if @selected_company == company
            h(:div, props, children)
          end
        end

        def render_input(company)
          step = @step.min_increment

          input = h(:input, style: { marginRight: '1rem' }, props: {
            value: @step.min_bid(company),
            step: step,
            min: @step.min_bid(company) + step,
            max: @step.max_bid(@current_entity, company),
            type: 'number',
            size: @current_entity.cash.to_s.size,
          })

          buy = lambda do
            process_action(Engine::Action::Bid.new(
              @current_entity,
              company: company,
              price: @step.min_bid(company),
            ))
            store(:selected_company, nil, skip: true)
          end

          create_bid = lambda do
            price = input.JS['elm'].JS['value'].to_i
            process_action(Engine::Action::Bid.new(
              @current_entity,
              company: company,
              price: price,
            ))
            store(:selected_company, nil, skip: true)
          end

          company_actions =
            if @step.may_purchase?(company)
              [h('button.button', { on: { click: buy } }, 'Buy')]
            else
              [
                input,
                h('button.button', { on: { click: create_bid } }, 'Place Bid'),
              ]
            end

          h(:div, { style: { textAlign: 'center', margin: '1rem' } }, company_actions)
        end
      end
    end
  end
end
