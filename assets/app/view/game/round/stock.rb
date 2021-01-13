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
require 'view/game/bid'

module View
  module Game
    module Round
      class Stock < Snabberb::Component
        include Actionable
        needs :selected_corporation, default: nil, store: true
        needs :selected_company, default: nil, store: true
        needs :last_player, default: nil, store: true
        needs :show_other_players, default: nil, store: true

        def render
          @step = @game.round.active_step
          @current_actions = @step.current_actions
          @auctioning_corporation = @step.auctioning_corporation if @step.respond_to?(:auctioning_corporation)
          @mergeable_entity = @step.mergeable_entity if @step.respond_to?(:mergeable_entity)
          @selected_corporation ||= @auctioning_corporation

          @price_protection = @step.price_protection if @step.respond_to?(:price_protection)
          @selected_corporation ||= @price_protection&.corporation

          @current_entity = @step.current_entity
          if @last_player != @current_entity && !@auctioning_corporation
            store(:selected_corporation, nil, skip: true)
            store(:last_player, @current_entity, skip: true)
          end

          children = []

          children << h(Choose) if @current_actions.include?('choose') && @step.choice_available?(@current_entity)

          if @step.respond_to?(:must_sell?) && @step.must_sell?(@current_entity)
            children << if @game.num_certs(@current_entity) > @game.cert_limit
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
          children.concat(render_failed_merge) if @current_actions.include?('failed_merge')
          children << h(BuyCompaniesAtFaceValue, game: @game) if @current_actions.include?('buy_company') &&
            @step.purchasable_unsold_companies.any?
          children.concat(render_corporations)
          children.concat(render_mergeable_entities) if @current_actions.include?('merge')
          children.concat(render_player_companies) if @current_actions.include?('sell_company')
          children.concat(render_bank_companies)
          children << h(Players, game: @game)
          if @step.respond_to?(:purchasable_companies) && @step.purchasable_companies(@current_entity).any?
            children << h(BuyCompanyFromOtherPlayer, game: @game)
          end
          children << h(StockMarket, game: @game)

          h(:div, children)
        end

        def render_buttons
          buttons = []
          buttons.concat(render_merge_button) if @current_actions.include?('merge')

          buttons.any? ? [h(:div, buttons)] : []
        end

        def render_merge_button
          merge = lambda do
            if @selected_corporation
              process_action(Engine::Action::Merge.new(
                @mergeable_entity,
                corporation: @selected_corporation,
              ))
            else
              store(:flash_opts, 'Select a corporation to merge with')
            end
          end

          [h(:button, { on: { click: merge } }, @step.merge_action)]
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

          @game.sorted_corporations.reject(&:closed?).map do |corporation|
            next if @auctioning_corporation && @auctioning_corporation != corporation
            next if @mergeable_entity && @mergeable_entity != corporation
            next if @price_protection && @price_protection.corporation != corporation

            children = []
            children.concat(render_subsidiaries)

            input = render_input(corporation) if @game.corporation_available?(corporation)
            choose = h(Choose) if @current_actions.include?('choose') && @step.choice_available?(corporation)

            children << h(Corporation, corporation: corporation, interactive: input || choose || merging)
            children << input if input && @selected_corporation == corporation
            children << choose if choose

            h(:div, props, children)
          end.compact
        end

        def render_input(corporation)
          inputs = [
            corporation.ipoed ? h(BuySellShares, corporation: corporation) : render_pre_ipo(corporation),
            render_loan(corporation),
            render_buy_tokens(corporation),
          ]
          inputs << h(IssueShares, entity: corporation) if @step.actions(corporation).include?('buy_shares')
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

        def render_buy_tokens(corporation)
          return unless @step.actions(corporation).include?('buy_tokens')

          buy_tokens = lambda do
            process_action(Engine::Action::BuyTokens.new(
              corporation
            ))
          end

          h(:button, { on: { click: buy_tokens } }, 'Buy Tokens')
        end

        def render_mergeable_entities
          step = @game.round.active_step
          return unless step.current_actions.include?('merge')

          mergeable_entities = @step.mergeable_entities
          player_corps = mergeable_entities.select do |target|
            target.owner == @mergeable_entity.owner || @step.show_other_players
          end
          @selected_corporation = player_corps.first if mergeable_entities.one?
          return unless mergeable_entities

          children = []

          props = {
            style: {
              margin: '0.5rem 1rem 0 0',
            },
          }
          children << h(:div, props, @step.mergeable_type(@mergeable_entity))

          hidden_corps = false
          @show_other_players = true if @step.show_other_players
          mergeable_entities.each do |target|
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
            children << h('div.margined_bottom', { style: { width: '20rem' } },
                          render_sell_input(company)) if @selected_company == company
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

          @game.companies.select { |c| c.owner == @game.bank }.map do |company|
            children = []
            children << h(Company, company: company)
            children << h('div.margined_bottom', { style: { width: '20rem' } },
                          render_buy_input(company)) if @selected_company == company
            h(:div, props, children)
          end
        end

        def render_buy_input(company)
          return [] unless @current_actions.include?('buy_company')
          return [] unless @step.can_buy_company?(@current_entity, company)

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
      end
    end
  end
end
