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
        needs :selected_corporation, default: nil, store: true
        needs :hidden, default: true, store: true
        needs :flash_opts, default: {}, store: true
        needs :user
        needs :before_process_pass, store: true

        def render
          @round = @game.round
          @current_entity = @round.current_entity
          @step = @round.active_step
          @current_actions = @step.current_actions

          user_name = @user&.dig('name')
          @block_show = user_name &&
            @game.players.map(&:name).include?(user_name) &&
            @current_entity.name != user_name &&
            !Lib::Storage[@game.id]&.dig('master_mode')

          store(:before_process_pass, -> { hide! }, skip: true) if @current_actions.include?('pass')

          if @current_actions.include?('par') && @step.companies_pending_par
            h(:div, render_company_pending_par)
          else
            h(:div, [
              render_turn_bid,
              render_show_button,
              *render_companies,
              *render_corporations,
              render_players,
            ].compact)
          end
        end

        def render_players
          return nil if !@step.players_visible? && hidden?

          if @step.players_visible?
            h(Players, game: @game)
          else
            h(:div, [
              h(Player, player: @current_entity, game: @game, show_hidden: true),
            ])
          end
        end

        def render_company_pending_par
          children = []

          @step.companies_pending_par.first.abilities(:shares).shares.each do |share|
            next unless share.president

            children << h(Corporation, corporation: share.corporation)
            children << h(Par, corporation: share.corporation)
          end

          children
        end

        def render_show_button
          return nil if @step.visible? && @step.players_visible?

          toggle = lambda do
            if @block_show
              store(:flash_opts, 'Enter master mode to reveal other hand. Use this feature fairly.')
            else
              store(:hidden, !@hidden)
            end
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

          h(:button, props, "#{hidden? ? 'Show' : 'Hide'} #{@step.visible? ? 'Player' : 'Companies'}")
        end

        def render_companies
          return [] if hidden? && !@step.visible?
          return [] unless @current_actions.include?('bid')

          @selected_company = @step.auctioning if @step.auctioning

          props = {
            style: {
              display: 'inline-block',
              verticalAlign: 'top',
            },
          }

          @step.available.select(&:company?).map do |company|
            children = [h(Company, company: company, bids: @step.bids[company])]
            children << render_input(company) if @selected_company == company
            h(:div, props, children)
          end
        end

        def render_input(company)
          buy = lambda do
            hide!
            process_action(Engine::Action::Bid.new(
              @current_entity,
              company: company,
              price: @step.min_bid(company),
            ))
            store(:selected_company, nil, skip: true)
          end

          choose = lambda do
            hide!
            process_action(Engine::Action::Bid.new(@current_entity,
                                                   company: @selected_company,
                                                   price: @selected_company.value))
            store(:selected_company, nil, skip: true)
          end

          company_actions =
            if @step.auctioneer? && @step.max_bid(@current_entity, company) < @step.min_bid(company)
              []
            elsif @step.may_purchase?(company)
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
                hide!
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

          if @step.respond_to?(:may_reduce?) && @step.may_reduce?(company)
            company_actions << h(:button, {
               on: { click: -> { process_action(Engine::Action::Assign.new(@current_entity, target: company)) } },
 }, 'Reduce Price')
          end

          h(:div, { style: { textAlign: 'center', margin: '1rem' } }, company_actions)
        end

        def render_turn_bid
          return if !@current_actions.include?('bid') || @step.auctioning != :turn

          input = h(:input, style: { margin: '1rem 0px', marginRight: '1rem' }, props: {
            value: @step.min_player_bid,
            step: @step.min_increment,
            min: @step.min_player_bid,
            max: @step.max_player_bid(@current_entity),
            type: 'number',
            size: @current_entity.cash.to_s.size,
          })

          create_bid = lambda do
            hide!
            price = input.JS['elm'].JS['value'].to_i
            process_action(Engine::Action::Bid.new(
              @current_entity,
              price: price,
            ))
          end
          h(:div,
            [
              input,
              h(:button, { on: { click: create_bid } }, 'Place Bid'),
            ])
        end

        def render_corporations
          return [] if !@current_actions.include?('bid') && !@current_actions.include?('par')

          props = {
            style: {
              display: 'inline-block',
              verticalAlign: 'top',
            },
          }

          @selected_corporation = @step.auctioning if @step.auctioning

          @step.available.select(&:corporation?).map do |corporation|
            children = []
            children << h(Corporation, corporation: corporation)
            children << render_ipo_input if @selected_corporation == corporation
            h(:div, props, children)
          end.compact
        end

        def render_ipo_input
          h('div.margined_bottom', { style: { width: '20rem' } }, [h(Par, corporation: @selected_corporation)])
        end

        def hide!
          store(:hidden, true, skip: true)
        end

        def hidden?
          @block_show || @hidden
        end
      end
    end
  end
end
