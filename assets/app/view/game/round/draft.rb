# frozen_string_literal: true

require 'lib/storage'
require 'view/game/actionable'
require 'view/game/company'
require 'view/game/player'
require 'view/game/undo_and_pass'

module View
  module Game
    module Round
      class Draft < Snabberb::Component
        include Actionable

        needs :selected_company, default: nil, store: true
        needs :hidden, default: true, store: true
        needs :user, store: true, default: nil
        needs :flash_opts, default: {}, store: true
        needs :round, default: nil, store: true

        def render
          round = @game.round
          @player = round.current_entity
          @step = round.active_step
          @current_actions = @step.current_actions
          user_name = @user&.dig('name')

          @block_show = user_name &&
            @game.players.map(&:name).include?(user_name) &&
            @player.name != user_name &&
            !Lib::Storage[@game.id]&.dig('master_mode')

          h(:div, [
            h(UndoAndPass, pass: @current_actions.include?('pass')),
            render_show_button,
            *render_companies,
            render_player,
          ].compact)
        end

        def render_show_button
          toggle = lambda do
            return store(:flash_opts, 'Enter master mode to reveal other hand. Use this feature fairly.') if @block_show

            store(:hidden, !@hidden)
          end

          props = {
            style: {
              display: 'block',
              margin: '1rem 0',
            },
            on: { click: toggle },
          }

          h('button.button', props, @hidden ? 'Show' : 'Hide')
        end

        def render_companies
          return [] if @hidden && !@step.visible?

          props = {
            style: {
              display: 'inline-block',
              'vertical-align': 'top',
            },
          }

          @step.available.map do |company|
            children = [h(Company, company: company)]
            children << render_input if @selected_company == company
            h(:div, props, children)
          end
        end

        def render_input
          choose = lambda do
            store(:hidden, true, skip: true)
            process_action(Engine::Action::Bid.new(@player, company: @selected_company, price: @selected_company.value))
            store(:selected_company, nil, skip: true)
          end

          h('button.button.margined', { style: { display: 'block' }, on: { click: choose } }, 'Choose')
        end

        def render_player
          return nil if @hidden

          draft_dist = @round.steps[-1]
          drafted = draft_dist.choices[@player]

          player = @player.clone
          dummy = Engine::Player.new("_dummy_")
          drafted.reject { |company| draft_dist.blank?(company) }
            .each do |company|
            unless draft_dist.blank?(company)
              company.owner = player
              player.spend(company.min_bid, dummy)
              player.companies << company
            end
          end

          props = {
            style: {
              display: 'inline-block',
              'vertical-align': 'top',
            },
          }

          children = [h(Player, player: player, game: @game)]
          drafted.each do |company|
            children << h(Company, company: company, header_bg: 'orange')
          end
          h(:div, [h(:div, props, children)])
        end
      end
    end
  end
end
