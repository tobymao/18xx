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
        needs :hidden, default: true, store: true
        needs :flash_opts, default: {}, store: true
        needs :user

        def render
          @round = @game.round
          @current_entity = @round.current_entity
          @step = @round.active_step
          @current_actions = @step.current_actions

          if @current_actions.include?('par')
            h(:div, render_company_pending_par)
          else
            h(:div, [
              render_show_button,
              *render_companies,
              render_players,
            ].compact)
          end
        end

        def render_players
          return nil if !@step.players_visible? && @hidden

          if @step.players_visible?
            h(Players, game: @game)
          else
            h(:div, [
              h(Player, player: @current_entity, game: @game),
            ])
          end
        end

        def render_company_pending_par
          corporation = @step.company_pending_par.abilities(:share).share.corporation

          [
            h(Corporation, corporation: corporation),
            h(Par, corporation: corporation),
          ]
        end

        def render_show_button
          return nil if @step.visible? && @step.players_visible?

          toggle = lambda do
            return store(:flash_opts, 'Enter master mode to reveal other hand. Use this feature fairly.') if @block_show

            store(:hidden, !@hidden)
          end

          props = {
            style: {
              display: 'block',
              width: '8.5rem',
              padding: '0.2rem 0',
              margin: '1rem 0',
            },
            on: { click: toggle },
          }

          h(:button, props, "#{@hidden ? 'Show' : 'Hide'} #{@step.visible? ? 'Player' : 'Companies'}")
        end

        def render_companies
          return [] if @hidden && !@step.visible?
          return [] unless @current_actions.include?('bid')

          @selected_company = @step.auctioning_company if @step.auctioning_company

          props = {
            style: {
              display: 'inline-block',
              verticalAlign: 'top',
            },
          }

          @step.available.map do |company|
            children = [h(Company, company: company, bids: @step.bids[company])]
            children << render_input(company) if @selected_company == company
            h(:div, props, children)
          end
        end

        def render_input(company)
          buy = lambda do
            store(:hidden, true, skip: true)
            process_action(Engine::Action::Bid.new(
              @current_entity,
              company: company,
              price: @step.min_bid(company),
            ))
            store(:selected_company, nil, skip: true)
          end

          choose = lambda do
            store(:hidden, true, skip: true)
            process_action(Engine::Action::Bid.new(@current_entity,
                                                   company: @selected_company,
                                                   price: @selected_company.value))
            store(:selected_company, nil, skip: true)
          end

          company_actions =
            if @step.may_purchase?(company)
              [h(:button, { on: { click: buy } }, 'Buy')]
            elsif @step.may_choose?(company)
              [h(:button, { on: { click: choose } }, 'Choose')]
            else

              step = @step.min_increment

              input = h(:input, style: { marginRight: '1rem' }, props: {
                value: @step.min_bid(company),
                step: step,
                min: @step.min_bid(company) + step,
                max: @step.max_bid(@current_entity, company),
                type: 'number',
                size: @current_entity.cash.to_s.size,
              })

              create_bid = lambda do
                store(:hidden, true, skip: true)
                price = input.JS['elm'].JS['value'].to_i
                process_action(Engine::Action::Bid.new(
                  @current_entity,
                  company: company,
                  price: price,
                ))
                store(:selected_company, nil, skip: true)
              end
              [
                input,
                h(:button, { on: { click: create_bid } }, 'Place Bid'),
              ]
            end

          h(:div, { style: { textAlign: 'center', margin: '1rem' } }, company_actions)
        end
      end
    end
  end
end
