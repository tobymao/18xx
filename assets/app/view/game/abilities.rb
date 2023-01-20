# frozen_string_literal: true

require 'lib/truncate'
require 'view/game/actionable'

module View
  module Game
    class Abilities < Snabberb::Component
      include Actionable

      needs :show_other_abilities, default: false, store: true

      def render
        companies = @game.companies.select do |company|
          company.owner &&
            !company.closed? &&
            actions_for(company).any? &&
            @game.entity_can_use_company?(@game.current_entity, company)
        end
        return h(:div) if companies.empty? || @game.round.current_entity&.company?

        current, others = companies.partition { |company| @game.current_entity.player == company.player }

        children = [
          h('h3.inline', { style: { marginRight: '0.5rem' } }, 'Abilities:'),
          *render_companies(current),
        ]

        if others.any?
          others.sort! { |company| company.player&.name == @user&.dig(:name) ? 0 : 1 }

          toggle_show = lambda do
            store(:selected_company, nil, skip: true)
            store(:show_other_abilities, !@show_other_abilities)
          end

          props = {
            attrs: { title: "#{@show_other_abilities ? 'Hide' : 'Show'} companies of other players" },
            style: { width: '7.3rem', margin: '0 0 0 0.5rem' },
            on: { click: toggle_show },
          }
          children << h(:button, props, "#{@show_other_abilities ? 'Hide' : 'Show'} Others")
          children << h(:div, render_companies(others)) if @show_other_abilities
        end

        if companies.include?(@selected_company)
          children << h(:div, { style: { margin: '0.5rem 0 0 0', maxWidth: '60rem' } }, @selected_company.desc)
          children.concat(render_actions)
        end

        h(:div, { style: { marginBottom: '0.5rem' } }, children)
      end

      def render_companies(companies)
        companies.map do |company|
          props = {
            on: {
              click: lambda do
                store(:tile_selector, nil, skip: true)
                store(:selected_company, @selected_company == company ? nil : company)
              end,
            },
          }
          props[:class] = { active: true } if @selected_company == company

          company_name = company.name.truncate(company.owner.name.size < 5 ? 32 : 19)
          company_name = "[#{@game.company_size_str(company)}] #{company_name}" if @game.respond_to?(:company_size_str)

          owner_name = company.owner.name.truncate

          h(:button, props, "#{company_name} (#{owner_name})")
        end.compact
      end

      def render_actions
        actions = actions_for(@selected_company)

        views = []
        views << render_purchase_train_button if actions.include?('purchase_train')
        views << render_sell_company_button if actions.include?('sell_company')
        views << render_close_company_button if actions.include?('manual_close_company')
        views << render_ability_choice_buttons if actions.include?('choose_ability')
        views << h(Exchange) if actions.include?('buy_shares')
        views << h(Map, game: @game) if !@game.round.is_a?(Engine::Round::Operating) &&
          (actions & %w[lay_tile place_token]).any?
        if actions.include?('buy_train') && !@game.round.active_step.respond_to?(:buyable_trains)
          views << h(BuyTrains, show_other_players: false, corporation: @selected_company.owner)
        end

        views
      end

      private

      def actions_for(company)
        @game.round.actions_for(company)
      end

      # Render a button for the purchase train action that purchases the
      # currently available depot train
      def render_purchase_train_button
        purchase = lambda do
          process_action(Engine::Action::PurchaseTrain.new(
            @selected_company
          ))
        end
        ability = @game.abilities(@selected_company, :purchase_train)
        # Show the train that will be bought on the button
        train = @game.depot.depot_trains.first
        button_text = if ability&.free
                        "Acquire #{train.name} train from depot"
                      else
                        "Purchase #{train.name} for #{@game.format_currency(train.price)}"
                      end
        h(:button, { on: { click: purchase } }, button_text)
      end

      def render_sell_company_button
        sell = lambda do
          process_action(Engine::Action::SellCompany.new(
            @game.current_entity,
            company: @selected_company,
            price: @selected_company.value
          ))
        end

        h(:button, { on: { click: sell } }, "Sell company (#{@game.format_currency(@selected_company.value)})")
      end

      def render_close_company_button
        close = lambda do
          process_action(Engine::Action::ManualCloseCompany.new(
            @selected_company,
          ))
        end

        h(:button, { on: { click: close } }, 'Close company')
      end

      def render_ability_choice_buttons
        step = @game.round.step_for(@selected_company, 'choose_ability')
        ability_choice_buttons = step.choices_ability(@selected_company).map do |choice, label|
          label ||= choice
          click = lambda do
            process_action(Engine::Action::ChooseAbility.new(
              @selected_company,
              choice: choice,
            ))
          end

          props = {
            style: {
              padding: '0.2rem 0.2rem',
            },
            on: { click: click },
          }
          h('button', props, label)
        end
        h(:div, [*ability_choice_buttons])
      end
    end
  end
end
