# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/bank'
require 'view/game/buy_sell_shares'
require 'view/game/company'
require 'view/game/corporation'
require 'view/game/par'
require 'view/game/par_chart'
require 'view/game/players'
require 'view/game/sell_shares'
require 'view/game/stock_market'
require 'view/game/tranches'
require 'view/game/bid'

module View
  module Game
    module Round
      class Stock < Snabberb::Component
        include Actionable
        needs :selected_corporation, default: nil, store: true
        needs :selected_company, default: nil, store: true
        needs :last_player, default: nil, store: true
        needs :corporation_to_par, default: nil, store: true
        needs :show_other_players, default: nil, store: true

        def render
          round = @game.round
          @step = round.active_step
          entity = @step.current_entity
          @current_actions = round.actions_for(entity)

          @selected_corporation ||= @step.selected_corporation if @step.respond_to?(:selected_corporation)
          @auctioning_corporation = @step.auctioning_corporation if @step.respond_to?(:auctioning_corporation)
          @selected_corporation ||= @auctioning_corporation
          @auctioning_company = @step.auctioning_company if @step.respond_to?(:auctioning_company)
          @selected_company ||= @auctioning_company
          @mergeable_entity = @step.mergeable_entity if @step.respond_to?(:mergeable_entity)
          @price_protection = @step.price_protection if @step.respond_to?(:price_protection)
          @selected_corporation ||= @price_protection&.corporation

          @bank_first = @step.respond_to?(:bank_first?) && @step.bank_first?

          @hide_corporations = @step.respond_to?(:hide_corporations?) && @step.hide_corporations?

          @current_entity = @step.current_entity
          if @last_player != @current_entity && !@auctioning_corporation
            store(:selected_corporation, nil, skip: true)
            store(:last_player, @current_entity, skip: true)
            store(:corporation_to_par, nil, skip: true)
          end

          return render_select_par_slot if @corporation_to_par && @current_actions.include?('par')

          children = []

          children << h(Choose) if @current_actions.include?('choose') && @step.choice_available?(@current_entity)

          if @step.respond_to?(:must_sell?) && @step.must_sell?(@current_entity)
            children << if @game.num_certs(@current_entity) > @game.cert_limit(@current_entity)
                          h('div.margined', 'Must sell stock: above certificate limit')
                        else
                          h('div.margined', 'Must sell stock: above 60% limit in corporation(s)')
                        end
          end

          if @price_protection
            num_presentation = @game.share_pool.num_presentation(@price_protection)
            children << h('div.margined',
                          "You can price protect #{num_presentation} of #{@price_protection.corporation.name} "\
                          "for #{@game.format_currency(@price_protection.price)}")
          end

          children.concat(render_buttons)
          children << h(SpecialBuy) if @current_actions.include?('special_buy')
          children.concat(render_failed_merge) if @current_actions.include?('failed_merge')
          children.concat(render_bank_companies) if @bank_first
          children.concat(render_corporations) unless @hide_corporations
          children.concat(render_mergeable_entities) if @current_actions.include?('merge')
          children.concat(render_player_companies) if @current_actions.include?('sell_company')
          children.concat(render_bank_companies) unless @bank_first
          children << h(Players, game: @game)
          if @step.respond_to?(:purchasable_companies) && !@step.purchasable_companies(@current_entity).empty?
            children << h(BuyCompanyFromOtherPlayer, game: @game)
          end
          children << render_bank
          children << h(StockMarket, game: @game, show_bank: true)

          h(:div, children)
        end

        def render_buttons
          buttons = []
          buttons.concat(render_merge_button) if @current_actions.include?('merge')
          buttons.concat(render_payoff_player_debt_button) if @current_actions.include?('payoff_player_debt')
          buttons.concat(render_take_loan) if @current_actions.include?('take_loan')
          buttons.concat(render_payoff_loan) if @current_actions.include?('payoff_loan')
          buttons.any? ? [h(:div, buttons)] : []
        end

        def render_merge_button
          selected_corporation = @selected_corporation

          merge = lambda do
            if selected_corporation
              do_merge = lambda do
                to_merge = if selected_corporation.corporation?
                             { corporation: selected_corporation }
                           else
                             { minor: selected_corporation }
                           end
                process_action(Engine::Action::Merge.new(
                  @mergeable_entity,
                  **to_merge
                ))
              end

              if @mergeable_entity.owner == selected_corporation.owner
                do_merge.call
              else
                check_consent(@mergeable_entity, selected_corporation.owner, do_merge)
              end
            else
              store(:flash_opts, 'Select a corporation to merge with')
            end
          end

          [h(:button, { on: { click: merge } }, @step.merge_action)]
        end

        def render_payoff_player_debt_button
          payoffloan = lambda do
            process_action(Engine::Action::PayoffPlayerDebt.new(@current_entity))
          end
          [h(:button, { on: { click: payoffloan } }, 'Payoff Loan')]
        end

        def render_failed_merge
          return [] unless @step.merge_failed?

          failed_merge = lambda do
            process_action(Engine::Action::Undo.new(@game.current_entity, action_id: @step.action_id_before_merge))
            process_action(Engine::Action::FailedMerge.new(@game.current_entity,
                                                           corporations: @step.merging_corporations))
          end

          text = 'The merger has failed. The President did not have a share to donate to the system.' \
                 " Press the 'Merge Failed' button to continue. You will not be able to undo to this point afterwards."
          [h(:div, text),
           h(:button, { on: { click: failed_merge } }, 'Merge Failed')]
        end

        def render_corporations
          props = {
            style: {
              display: 'inline-block',
              verticalAlign: 'top',
            },
          }

          merging = @step.respond_to?(:merge_in_progress?) && @step.merge_in_progress?

          corporations = if @step.respond_to?(:visible_corporations)
                           @step.visible_corporations
                         else
                           @game.sorted_corporations.reject(&:closed?)
                         end

          corporations.map do |corporation|
            next if @auctioning_corporation && @auctioning_corporation != corporation
            next if @mergeable_entity && @mergeable_entity != corporation
            next if @price_protection && @price_protection.corporation != corporation

            children = []
            children.concat(render_subsidiaries)
            input = render_input(corporation) if @game.corporation_available?(corporation)
            children << h(Corporation, corporation: corporation, interactive: input || merging)
            children << input if input && @selected_corporation == corporation
            h(:div, props, children)
          end.compact
        end

        def render_input(corporation)
          inputs = [
            corporation.ipoed ? h(BuySellShares, corporation: corporation) : render_pre_ipo(corporation),
            render_loan(corporation),
          ]
          inputs << h(IssueShares, entity: corporation) unless (@step.actions(corporation) & %w[buy_shares sell_shares]).empty?
          inputs << h(BuyTrains, corporation: corporation) if @step.actions(corporation).include?('buy_train')
          inputs << h(ScrapTrains, corporation: corporation) if @step.actions(corporation).include?('scrap_train')
          inputs << h(Choose, entity: corporation) if @current_actions.include?('choose') && @step.choice_available?(corporation)
          inputs = inputs.compact
          h('div.margined_bottom', { style: { width: '20rem' } }, inputs) if inputs.any?
        end

        def render_pre_ipo(corporation)
          children = []

          type = @step.ipo_type(corporation)
          case type
          when :par
            children << h(Par, corporation: corporation) if @current_actions.include?('par')
          when :bid
            children << h(Bid, entity: @current_entity, corporation: corporation) if @current_actions.include?('bid')
          when :form
            children << h(FormCorporation, corporation: corporation) if @current_actions.include?('par')
          when String
            children << h(:div, type)
          end
          children << h(BuySellShares, corporation: corporation)

          children.compact!
          return h(:div, children) unless children.empty?

          nil
        end

        def render_subsidiaries
          return [] unless @current_actions.include?('assign')

          @step.available_subsidiaries.map do |company|
            h(Company, company: company)
          end
        end

        def render_loan(corporation)
          return unless @step.actions(corporation).include?('take_loan')

          take_loan = lambda do
            process_action(Engine::Action::TakeLoan.new(
              corporation,
              loan: @game.loans[0],
            ))
          end

          h(:button, { on: { click: take_loan } }, 'Take Loan')
        end

        def render_mergeable_entities
          return unless @step.current_actions.include?('merge')
          return unless @step.mergeable_entities

          children = []

          props = {
            style: {
              margin: '0.5rem 1rem 0 0',
            },
          }
          children << h(:div, props, @step.mergeable_type(@mergeable_entity))

          hidden_corps = false
          @show_other_players = true if @step.show_other_players
          @step.mergeable_entities.each do |target|
            if @show_other_players || target.owner == @mergeable_entity.owner || !target.owner
              children << h(Corporation, corporation: target, selected_corporation: @selected_corporation)
            else
              hidden_corps = true
            end
          end

          button_props = {
            style: {
              display: 'grid',
              gridColumn: '1/4',
              width: 'max-content',
            },
          }

          if hidden_corps
            children << h('button',
                          { on: { click: -> { store(:show_other_players, true) } }, **button_props },
                          'Show corporations from other players')
          elsif @show_other_players
            children << h('button',
                          { on: { click: -> { store(:show_other_players, false) } }, **button_props },
                          'Hide corporations from other players')
          end

          children
        end

        def render_player_companies
          props = {
            style: {
              display: 'inline-block',
              verticalAlign: 'top',
            },
          }

          @step.sellable_companies(@current_entity).map do |company|
            children = []
            children << h(Company, company: company)
            if @selected_company == company
              children << h('div.margined_bottom', { style: { width: '20rem' } }, render_sell_input(company))
            end
            h(:div, props, children)
          end
        end

        def render_sell_input(company)
          price = @step.sell_price(company)
          buy = lambda do
            process_action(Engine::Action::SellCompany.new(
              @current_entity,
              company: company,
              price: price
            ))
            store(:selected_company, nil, skip: true)
          end
          [h(:button,
             { on: { click: buy } },
             "Sell #{@selected_company.sym} to Bank for #{@game.format_currency(price)}")]
        end

        def render_bank_companies
          props = {
            style: {
              display: 'inline-block',
              verticalAlign: 'top',
            },
          }

          @game.buyable_bank_owned_companies.map do |company|
            children = []
            children << h(Company, company: company,
                                   bids: (@current_actions.include?('bid') ? @step.bids[company] : nil))
            if @selected_company == company
              inputs = []
              inputs.concat(render_buy_input(company)) if @current_actions.include?('buy_company')
              inputs.concat(render_bid_input(company)) if @current_actions.include?('bid')
              children << h('div.margined_bottom', { style: { width: '20rem' } }, inputs)
            end
            h(:div, props, children)
          end
        end

        def render_buy_input(company)
          return [] unless @step.can_buy_company?(@current_entity, company)
          return render_buy_input_interval(company) if company.interval

          buy = lambda do
            process_action(Engine::Action::BuyCompany.new(
              @current_entity,
              company: company,
              price: company.value,
            ))
            store(:selected_company, nil, skip: true)
          end
          [h(:button,
             { on: { click: buy } },
             "Buy #{@selected_company.sym} from Bank for #{@game.format_currency(company.value)}")]
        end

        def render_buy_input_interval(company)
          prices = company.interval.sort

          buy_buttons = prices.map do |price|
            buy = lambda do
              process_action(Engine::Action::BuyCompany.new(
                @current_entity,
                company: company,
                price: price,
              ))
            end

            props = {
              style: {
                width: 'calc(17.5rem/6)',
                padding: '0.2rem',
              },
              on: { click: buy },
            }

            h('button.small.buy_company', props, @game.format_currency(price).to_s)
          end

          div_class = buy_buttons.size < 5 ? '.inline' : ''
          [h(:div, [
            h("div#{div_class}", { style: { marginTop: '0.5rem' } }, "Buy #{@selected_company.sym}: "),
            *buy_buttons,
          ])]
        end

        def render_bid_input(company)
          return [] if !@step.respond_to?(:can_bid_company?) || !@step.can_bid_company?(@current_entity, company)

          [h(Bid, entity: @current_entity, corporation: company)]
        end

        def render_bank
          children = []
          props = {
            style: {
              marginBottom: '1rem',
            },
          }
          children << h(Tranches, game: @game) if @game.respond_to?(:tranches)
          children << h(TrainSchedule, game: @game) unless @game.depot.trains.empty?
          h(:div, props, children)
        end

        def render_select_par_slot
          children = [h(:div, [h(:button, { on: { click: -> { store(:corporation_to_par, nil) } } }, 'Cancel (Par)')])]
          children << h(Corporation, corporation: @corporation_to_par)
          children << h(ParChart, corporation_to_par: @corporation_to_par)

          h(:div, children)
        end

        def render_take_loan
          take_loan = lambda do
            process_action(Engine::Action::TakeLoan.new(@current_entity, loan: nil))
          end
          [h(:button, { on: { click: take_loan } }, "Take Loan (#{@game.format_currency(@game.loan_amount)})")]
        end

        def render_payoff_loan
          payoff_loan = lambda do
            process_action(Engine::Action::PayoffLoan.new(@current_entity, loan: nil))
          end
          [h(:button, { on: { click: payoff_loan } }, "Payoff Loan (#{@game.format_currency(@game.loan_amount)})")]
        end
      end
    end
  end
end
