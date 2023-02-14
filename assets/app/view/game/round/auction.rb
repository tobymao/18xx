# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/company'
require 'view/game/par'
require 'view/game/par_chart'
require 'view/game/players'
require 'view/game/stock_market'

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
        needs :before_process_pass, default: -> {}, store: true

        def render
          @round = @game.round
          @current_entity = @round.current_entity
          @step = @round.active_step
          @current_actions = @step.current_actions

          user_name = @user&.dig('name')
          user_is_player = !hotseat? && user_name && @game.players.map(&:name).include?(user_name)
          @user_is_current_player = user_is_player && @current_entity.name == user_name
          @block_show = user_is_player && !@user_is_current_player && !Lib::Storage[@game.id]&.dig('master_mode')

          store(:before_process_pass, -> { hide! }, skip: true) if @current_actions.include?('pass')

          if @current_actions.include?('par') && @step.respond_to?(:companies_pending_par) && @step.companies_pending_par
            h(:div, render_company_pending_par)
          elsif @current_actions.include?('choose')
            h(Choose)
          else
            h(:div, [
              render_turn_bid,
              render_show_button,
              *render_companies,
              *render_minors,
              *render_corporations,
              render_par_corporations,
              render_players,
              render_map,
              render_stock_market,
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

          company = @step.companies_pending_par.first
          @game.abilities(company, :shares).shares.each do |share|
            next unless share.president

            children << h(Corporation, corporation: share.corporation)
            children << if @game.respond_to?(:par_chart)
                          h(ParChart, corporation_to_par: share.corporation)
                        else
                          h(Par, corporation: share.corporation)
                        end
          end

          children
        end

        def render_show_button
          return nil if @user_is_current_player
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
          return [] if !@current_actions.include?('bid') &&
                       !(@step.respond_to?(:show_companies) && @step.show_companies)

          @selected_company = @step.auctioning if @step.auctioning

          if @step.respond_to?(:tiered_auction_companies)
            @step.tiered_auction_companies.map do |tier|
              h(:div, { style: { display: 'table' } }, tier.map { |company| render_company(company) })
            end
          else
            companies = @step.available.select(&:company?)
            companies.map { |company| render_company(company) }
          end
        end

        def render_company(company)
          props = {
            style: {
              display: 'inline-block',
              verticalAlign: 'top',
            },
          }

          children = [h(Company, company: company, bids: @step.bids[company])]
          children << render_input(company) if @selected_company == company
          h(:div, props, children)
        end

        def render_input(company)
          actions = render_company_actions(company)

          if @step.respond_to?(:may_reduce?) && @step.may_reduce?(company)
            actions << h(:button, { on: { click: -> { assign(company) } } }, 'Reduce Price')
          end

          h(:div, { style: { textAlign: 'center', margin: '1rem' } }, actions)
        end

        def render_company_actions(company)
          if @step.respond_to?(:may_offer?) && @step.may_offer?(company)
            return [h(:button, {
                        on: {
                          click: lambda {
                            offer
                          },
                        },
                      }, 'Offer')]
          end

          return [] if @step.auctioneer? && @step.max_bid(@current_entity, company) < @step.min_bid(company)

          buy_str = @step.respond_to?(:buy_str) ? @step.buy_str(company) : 'Buy'
          return [h(:button, { on: { click: -> { buy(company) } } }, buy_str)] if @step.may_purchase?(company)
          return [h(:button, { on: { click: -> { choose } } }, 'Choose')] if @step.may_choose?(company)

          input = h(:input, style: { marginRight: '1rem' }, props: {
                      value: @step.min_bid(company),
                      step: @step.min_increment,
                      min: @step.min_bid(company),
                      max: @step.max_bid(@current_entity, company),
                      type: 'number',
                      size: @current_entity.cash.to_s.size + 2,
                    })

          buttons = []
          if @step.may_bid?(company) && @step.min_bid(company) <= @step.max_place_bid(@current_entity, company)
            bid_str = @step.respond_to?(:bid_str) ? @step.bid_str(company) : 'Place Bid'
            buttons << h(:button, { on: { click: -> { create_bid(company, input) } } }, bid_str)
          end
          buttons.concat(render_move_bid_buttons(company, input))

          return [] if buttons.empty?

          [input, *buttons]
        end

        def render_move_bid_buttons(company, input)
          return [] unless @current_actions.include?('move_bid')

          moveable_bids = @step.moveable_bids(@current_entity, company)
          return [] if moveable_bids.empty?

          moveable_bids.flat_map do |from_company, from_bids|
            from_bids.map do |from_bid|
              bid_max = @step.max_move_bid(@current_entity, company, from_bid.price)
              bid_min = @step.min_move_bid(company, from_bid.price)
              next if bid_max < bid_min

              h(:button, { on: { click: -> { move_bid(company, input, from_company, from_bid.price) } } },
                "Move #{from_company.sym} #{@game.format_currency(from_bid.price)} Bid")
            end
          end.compact
        end

        def render_turn_bid
          return if !@current_actions.include?('bid') || @step.auctioning != :turn

          if @step.respond_to?(:bid_choices)
            choice_bid_input(@step, @current_entity)
          else
            number_bid_input(@step, @current_entity)
          end
        end

        def number_bid_input(_step, _current_entity)
          input =
            h(:input, style: { margin: '1rem 0px', marginRight: '1rem' }, props: {
                value: @step.min_player_bid,
                step: @step.min_increment,
                min: @step.min_player_bid,
                max: @step.max_player_bid(@current_entity),
                type: 'number',
                size: @current_entity.cash.to_s.size + 2,
              })
          h(:div, [
            input,
            h(:button, { on: { click: -> { create_turn_bid(input) } } }, 'Place Bid'),
          ])
        end

        def choice_bid_input(step, _current_entity)
          choice_buttons = step.bid_choices.map do |price|
            click = lambda do
              hide!
              process_action(Engine::Action::Bid.new(
                @current_entity,
                price: price,
              ))
            end

            props = {
              style: {
                padding: '0.2rem 0.2rem',
              },
              on: { click: click },
            }
            h('button', props, @game.format_currency(price))
          end

          div_class = choice_buttons.size < 5 ? '.inline' : ''
          h(:div, [
            h("div#{div_class}", { style: { marginTop: '0.5rem' } }, 'Bid: '),
            *choice_buttons,
          ])
        end

        def render_minors
          return [] unless @current_actions.include?('bid')

          props = {
            style: {
              display: 'inline-block',
              verticalAlign: 'top',
            },
          }

          @step.available.select(&:minor?).map do |minor|
            children = [h(Corporation, corporation: minor)]
            children << render_minor_input(minor) if @selected_corporation == minor
            h(:div, props, children)
          end
        end

        def render_minor_input(minor)
          minor_actions = []

          minor_actions.concat(render_minor_choose(minor))
          minor_actions.concat(render_minor_place_bid(minor))

          h(:div, { style: { textAlign: 'center', margin: '1rem' } }, minor_actions)
        end

        def render_minor_choose(minor)
          return [] unless @step.may_choose?(minor)

          [h(:button, { on: { click: -> { choose_minor(minor) } } }, 'Choose')]
        end

        def render_minor_place_bid(minor)
          return [] unless @step.auctioneer?
          return [] unless @step.min_bid(minor) <= @step.max_place_bid(@current_entity, minor)

          input = h(:input, style: { marginRight: '1rem' }, props: {
                      value: @step.min_bid(minor),
                      step: @step.min_increment,
                      min: @step.min_bid(minor),
                      max: @step.max_bid(@current_entity, minor),
                      type: 'number',
                      size: @current_entity.cash.to_s.size + 2,
                    })

          bid_str = @step.respond_to?(:bid_str) ? @step.bid_str(minor) : 'Place Bid'

          [
            input,
            h(:button,
              { on: { click: -> { create_minor_bid(minor, input) } } },
              bid_str),
          ]
        end

        def render_corporations
          return [] if !@current_actions.include?('bid') && !@current_actions.include?('par')

          props = {
            style: {
              display: 'inline-block',
              verticalAlign: 'top',
            },
          }

          @selected_corporation = @step.auctioning if @step.auctioning.is_a?(Engine::Corporation)

          @step.available.select(&:corporation?).map do |corporation|
            children = []
            children << h(Corporation, corporation: corporation)
            children << render_ipo_input if @selected_corporation == corporation && !corporation.ipoed
            children << render_corp_choose_input if @selected_corporation == corporation && corporation.ipoed
            h(:div, props, children)
          end.compact
        end

        def render_par_corporations
          return nil if !@current_actions.include?('par') || !@step.respond_to?(:par_corporations)

          props = {
            style: {
              display: 'inline-block',
              verticalAlign: 'top',
            },
          }

          corporations = []
          @step.par_corporations(@current_entity).each do |corporation|
            children = []
            children << h(Corporation, corporation: corporation)
            children << render_ipo_input if @selected_corporation == corporation
            corporations << h(:div, props, children)
          end
          h(:div, props, corporations)
        end

        def render_ipo_input
          h('div.margined_bottom', { style: { width: '20rem' } }, [h(Par, corporation: @selected_corporation)])
        end

        def render_corp_choose_input
          choose = lambda do
            hide!
            process_action(Engine::Action::Bid.new(@current_entity,
                                                   corporation: @selected_corporation,
                                                   price: 0))
            store(:selected_corporation, nil, skip: true)
          end

          corp_actions = [h(:button, { on: { click: choose } }, 'Choose')]

          h(:div, { style: { textAlign: 'center', margin: '1rem' } }, corp_actions)
        end

        def hide!
          store(:hidden, true, skip: true)
        end

        def hidden?
          return false if @user_is_current_player

          @block_show || @hidden
        end

        def choose_minor(minor)
          hide!
          process_action(Engine::Action::Bid.new(
            @current_entity,
            minor: minor,
            price: 0
          ))
          store(:selected_corporation, nil, skip: true)
        end

        def create_minor_bid(target, input)
          hide!
          price = input.JS['elm'].JS['value'].to_i
          process_action(Engine::Action::Bid.new(
            @current_entity,
            minor: target,
            price: price,
          ))
          store(:selected_corporation, nil, skip: true)
        end

        def create_bid(target, input)
          hide!
          price = input.JS['elm'].JS['value'].to_i
          process_action(Engine::Action::Bid.new(
            @current_entity,
            company: target,
            price: price,
          ))
          store(:selected_company, nil, skip: true)
        end

        def create_turn_bid(input)
          hide!
          price = input.JS['elm'].JS['value'].to_i
          process_action(Engine::Action::Bid.new(
            @current_entity,
            price: price,
          ))
        end

        def assign(company)
          process_action(Engine::Action::Assign.new(@current_entity, target: company))
        end

        def offer
          hide!
          process_action(Engine::Action::Offer.new(
            @current_entity,
            company: @selected_company
          ))
          store(:selected_company, @selected_company, skip: true)
        end

        def choose
          hide!
          process_action(Engine::Action::Bid.new(
            @current_entity,
            company: @selected_company,
            price: @selected_company.value
          ))
          store(:selected_company, nil, skip: true)
        end

        def buy(company)
          hide!
          process_action(Engine::Action::Bid.new(
            @current_entity,
            company: company,
            price: @step.min_bid(company),
          ))
          store(:selected_company, nil, skip: true)
        end

        def move_bid(company, input, from_company, from_price)
          hide!
          price = input.JS['elm'].JS['value'].to_i
          process_action(Engine::Action::MoveBid.new(
            @current_entity,
            company: company,
            from_company: from_company,
            price: price,
            from_price: from_price,
          ))
          store(:selected_company, nil, skip: true)
        end

        # show the map if there are minors to pick from
        def render_map
          show = @step.available.any?(&:minor?) || (@step.respond_to?(:show_map) && @step.show_map)
          return nil unless show

          h(Game::Map, game: @game, opacity: 1.0)
        end

        def render_stock_market
          show = (@step.respond_to?(:show_stock_market?) && @step.show_stock_market?)
          return nil unless show

          h(StockMarket, game: @game, show_bank: false)
        end
      end
    end
  end
end
