# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/bank'
require 'view/game/buy_sell_shares'
require 'view/game/company'
require 'view/game/corporation'
require 'view/game/par'
require 'view/game/players'
require 'view/game/sell_shares'
require 'view/game/stock_market'
require 'view/game/undo_and_pass'

module View
  module Game
    module Round
      class Stock < Snabberb::Component
        include Actionable

        needs :selected_corporation, default: nil, store: true
        needs :last_player, default: nil, store: true

        def render
          @step = @game.round.active_step
          @current_actions = @step.current_actions
          @auctioning_corporation = @step.auctioning_corporation if @step.respond_to?(:auctioning_corporation)
          @selected_corporation ||= @auctioning_corporation

          @current_entity = @step.current_entity
          if @last_player != @current_entity && !@auctioning_corporation
            store(:selected_corporation, nil, skip: true)
            store(:last_player, @current_entity, skip: true)
          end

          children = []
          if @step.respond_to?(:must_sell?) && @step.must_sell?(@current_entity)
            children << if @current_entity.num_certs > @game.cert_limit
                          h('div.margined', 'Must sell stock: above certificate limit')
                        else
                          h('div.margined', 'Must sell stock: above 60% limit in corporation(s)')
                        end
          end

          children.concat(render_corporations)
          children << h(Players, game: @game)
          children << h(BuyCompanyFromOtherPlayer, game: @game) if @step.purchasable_companies(@current_entity).any?
          children << h(StockMarket, game: @game)

          h(:div, children)
        end

        def render_corporations
          props = {
            style: {
              display: 'inline-block',
              verticalAlign: 'top',
            },
          }

          @game.corporations.map do |corporation|
            next if @auctioning_corporation && @auctioning_corporation != corporation

            children = []
            children.concat(render_subsidiaries)
            children << h(Corporation, corporation: corporation)
            children << render_input if @selected_corporation == corporation
            h(:div, props, children)
          end.compact
        end

        def render_input
          h('div.margined_bottom', { style: { width: '20rem' } }, [
            @selected_corporation.ipoed ? h(BuySellShares, corporation: @selected_corporation) : render_pre_ipo,
            render_loan,
          ].compact)
        end

        def render_pre_ipo
          return h(Par, corporation: @selected_corporation) if @current_actions.include?('par')
          return render_bid(@selected_corporation) if @current_actions.include?('bid')

          nil
        end

        def render_bid(corporation)
          step = @step.min_increment

          price_input = h(:input, style: { marginRight: '1rem' }, props: {
            value: @step.min_bid(corporation),
            step: step,
            min: @step.min_bid(corporation) + step,
            max: @step.max_bid(@current_entity, corporation),
            type: 'number',
            size: @current_entity.cash.to_s.size,
          })

          place_bid = lambda do
            process_action(Engine::Action::Bid.new(
              @current_entity,
              corporation: corporation,
              price: Native(price_input)[:elm][:value].to_i,
            ))
          end

          bid_button = h(:button, { on: { click: place_bid } }, 'Place Bid')

          h('div.center', [price_input, bid_button])
        end

        def render_subsidiaries
          return [] unless @current_actions.include?('assign')

          @step.available_subsidiaries.map do |company|
            h(Company, company: company)
          end
        end

        def render_loan
          return unless @step.actions(@selected_corporation).include?('take_loan')

          take_loan = lambda do
            process_action(Engine::Action::TakeLoan.new(
              @selected_corporation,
              loan: @game.loans[0],
            ))
          end

          h(:button, { on: { click: take_loan } }, 'Take Loan')
        end
      end
    end
  end
end
