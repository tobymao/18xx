# frozen_string_literal: true

require 'view/game/auto_action/auction_bid'
require 'view/game/auto_action/buy_shares'
require 'view/game/auto_action/share_pass'

module View
  module Game
    class Auto < Form
      # Note, from the UI point of view this is called 'Auto', but in terms of code base it
      # is known as 'programmed' actions this is so it doesn't clash with 'auto' actions which
      # are where the codebase generates actions for players (which programmed actions relies upon)
      include Actionable

      needs :game, store: true
      needs :user
      needs :buy_corporation, store: true, default: nil

      AUTO_ACTIONS_WIKI = 'https://github.com/tobymao/18xx/wiki/Auto-actions'

      def render_content
        children = [
          h(:h2, 'Auto Actions'),
          h(:p, 'Auto actions allow you to preprogram your moves ahead of time. '\
                'On asynchronous games this can shorten a game considerably.'),
          h(:p, 'Please note, these are not secret from other players.'),
          h(:p, render_wiki),
        ]

        if @game.players.find { |p| p.name == @user&.dig('name') }
          types = {
            Engine::Action::ProgramAuctionBid => ->(settings) { render_auction_bid(settings) },
            Engine::Action::ProgramBuyShares => ->(settings) { render_buy_shares(settings) },
            Engine::Action::ProgramHarzbahnDraftPass => ->(settings) { render_harzbahn_draft_pass(settings) },
            Engine::Action::ProgramIndependentMines => ->(settings) { render_independent_mines(settings) },
            Engine::Action::ProgramMergerPass => ->(settings) { render_merger_pass(settings) },
            Engine::Action::ProgramSharePass => ->(settings) { render_share_pass(settings) },
          }.freeze

          if !(available = @game.available_programmed_actions).empty?
            enabled = @game.programmed_actions[sender]
            available.each do |type|
              if (method = types[type])
                settings = enabled if enabled.is_a?(type)
                children.concat(method.call(settings))
              end
            end
          else
            children << h('p.bold', 'No auto actions are presently available for this game.')
          end
        else
          children << h('p.bold', 'No auto actions available. You are not a player in this game.')
        end

        props = {
          style: {
            maxWidth: '40rem',
          },
        }

        h(:div, props, children)
      end

      def render_wiki
        [h(:a, { attrs: { href: AUTO_ACTIONS_WIKI, target: '_blank' } },
           'Please read this for more details when it will deactivate')]
      end

      def sender
        @game.player_by_id(@user['id']) if @user
      end

      def render_auction_bid(settings)
        h(AutoAction::AuctionBid, game: @game, sender: sender, settings: settings)
      end

      def render_buy_shares(settings)
        h(AutoAction::BuyShares, game: @game, sender: sender, settings: settings)
      end

      def enable_merger_pass(form)
        corporations = {}
        form['corporations'].each do |round, corps|
          corp_settings = params(corps).select { |_k, v| v }.keys.map { |c| @game.corporation_by_id(c) }
          corporations[round.short_name] = corp_settings
        end

        options = params(form['options']).select { |_k, v| v }.keys

        process_action(
          Engine::Action::ProgramMergerPass.new(
            sender,
            corporations_by_round: corporations,
            options: options
          )
        )
      end

      def render_merger_pass(settings)
        corporations = Hash.new { |h, k| h[k] = {} }

        text = 'Auto Pass in Mergers'
        text += ' (Enabled)' if settings
        children = [h(:h3, text)]
        children << h(:p,
                      'This will pass converting/merging or offering your corporations automatically.'\
                      ' It will not pass otherwise still allowing you to buy shares, bid etc.')

        rounds = @game.merge_rounds

        player = sender
        # Which corps can be passed, by default assume all
        passable = @game.merge_corporations.select { |corp| corp.owner == player }
        if @game.round.stock?
          children << h('p.bold', 'Cannot program while in a stock round!')
        elsif passable.empty?
          children << h('p.bold', 'No mergable corporations are owned by you, cannot program!')
        else

          rounds.each do |round|
            tmpform = {}
            round_settings = settings&.corporations_by_round&.dig(round.short_name)
            subchildren = passable.map do |entity|
              id = round.short_name + ',' + entity.name
              input = h(:li, [
                render_input(entity.name,
                             id: id,
                             type: 'checkbox',
                             inputs: tmpform,
                             attrs: {
                               name: 'mode_options',
                               checked: !settings || round_settings&.include?(entity),
                             }),
              ])
              corporations[round][entity.name] = tmpform[id]
              input
            end
            children << h(:div, [
              h(:p, "Pass on Corporations in #{round.round_name}:"),
              h(:ul, { style: { 'list-style': 'none' } }, subchildren),
            ])
          end

          options = {}
          subchildren = [h(:li, [
            render_input('Disable if others merge',
                         id: 'disable_others',
                         type: 'checkbox',
                         inputs: options,
                         attrs: {
                           name: 'mode_options',
                           checked: !settings || settings&.options&.include?('disable_others'),
                         }),
          ])]

          form = { corporations: corporations, options: options }

          children << h(:div, [
            h(:p, 'Options:'),
            h(:ul, { style: { 'list-style': 'none' } }, subchildren),
          ])

          subchildren = [
            render_button(
              settings ? 'Update' : 'Enable'
            ) { enable_merger_pass(form, passable, rounds) },
          ]
          subchildren << render_disable(settings) if settings
          children << h(:div, subchildren)

        end

        children
      end

      def render_share_pass(settings)
        h(AutoAction::SharePass, game: @game, sender: sender, settings: settings)
      end

      def enable_independent_mines(form)
        settings = params(form)

        skip_track = settings['im_skip_track']
        skip_buy = settings['im_skip_buy']
        skip_close = settings['im_skip_close']
        indefinite = settings['im_indefinite']

        process_action(
          Engine::Action::ProgramIndependentMines.new(
            sender,
            skip_track: skip_track,
            skip_buy: skip_buy,
            skip_close: skip_close,
            indefinite: indefinite
          )
        )
      end

      def render_independent_mines(settings)
        form = {}
        text = 'Auto Independent Mines'
        text += ' (Enabled)' if settings
        children = [h(:h3, text)]
        children << h(:p,
                      'Automatically skip independent mine actions.'\
                      ' This will deactivate itself in the next SR, unless set to indefinite.'\
                      ' It will also deactivate itself when a mine has negative income.')

        children << h(:div, [
          render_checkbox('Skip track lay', 'im_skip_track', form, settings ? settings.skip_track : true),
          render_checkbox('Skip switchers', 'im_skip_buy', form, settings ? settings.skip_buy : true),
          render_checkbox('Skip close mine', 'im_skip_close', form, settings ? settings.skip_close : true),
        ])
        children << h(:div, [
          render_checkbox('Indefinite (normally stops after one OR set)', 'im_indefinite', form, settings&.indefinite),
        ])

        subchildren = [render_button(settings ? 'Update' : 'Enable') { enable_independent_mines(form) }]
        subchildren << render_disable(settings) if settings
        children << h(:div, subchildren)

        children
      end

      def enable_harzbahn_draft_pass(form)
        settings = params(form)

        until_premium = settings['hd_until_premium'] ? settings['hd_target_premium'].to_i : nil
        unconditional = settings['hd_unconditional']

        process_action(
          Engine::Action::ProgramHarzbahnDraftPass.new(
            sender,
            until_premium: until_premium,
            unconditional: unconditional,
          )
        )
      end

      def render_harzbahn_draft_pass(settings)
        form = {}
        text = 'Auto Pass in Initial Draft'
        text += ' (Enabled)' if settings
        children = [h(:h3, text)]
        children << h(:p,
                      'Automatically passes in the initial draft.'\
                      ' It will deactivate itself when the specified premium is reached (unless no target).'\
                      ' It will also deactivate itself when anyone buys something (unless you disable this).')

        children << h(:div, [
          render_input(
            'No target premium',
            id: 'hd_no_target',
            type: 'radio',
            inputs: form,
            attrs: {
              name: 'hd_until_condition',
              checked: !settings&.until_premium,
              value: 'no_target',
            }
          ),
        ])
        children << h(:div, [
          render_input(
            'Until premium',
            id: 'hd_until_premium',
            type: 'radio',
            inputs: form,
            attrs: {
              name: 'hd_until_condition',
              checked: !!settings&.until_premium,
              value: 'target',
            }
          ),
          render_input(
            '',
            id: 'hd_target_premium',
            type: :number,
            inputs: form,
            attrs: {
              min: 0,
              step: 10,
              value: settings&.until_premium || 0,
            },
            on: { input: -> { `document.getElementById('hd_until_premium').checked = true` } },
            input_style: { width: '5rem' },
            container_style: { margin: '0' },
          ),
        ])
        children << h(:div, [
          render_checkbox('Keep passing even if someone buys something', 'hd_unconditional', form, !!settings&.unconditional),
        ])

        subchildren = [render_button(settings ? 'Update' : 'Enable') { enable_harzbahn_draft_pass(form) }]
        subchildren << render_disable(settings) if settings
        children << h(:div, subchildren)

        children
      end

      def disable
        process_action(
          Engine::Action::ProgramDisable.new(
            sender,
            reason: 'user'
          )
        )
      end

      def render_disable
        render_button('Disable') { disable }
      end
    end
  end
end
