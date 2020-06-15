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

        def render
          @round = @game.round
          @player = @round.current_entity
          @only_one_company = @round.only_one_company?

          user_name = @user&.dig('name')

          @block_show = user_name &&
            @player.name == user_name &&
            !Lib::Storage[@game.id]&.dig('master_mode')

          h(:div, [
            h(UndoAndPass, pass: @only_one_company),
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
          return [] if @hidden && !@only_one_company

          props = {
            style: {
              display: 'inline-block',
              'vertical-align': 'top',
            },
          }

          @round.available.map do |company|
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

          h(:div, [
            h(Player, player: @player, game: @game),
          ])
        end
      end
    end
  end
end
