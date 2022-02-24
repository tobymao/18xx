# frozen_string_literal: true

require 'view/game/auto_action/auction_bid'

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

      def render_content
        children = [
          h(:h2, 'Auto Actions'),
          h(:p, 'Auto actions allow you to preprogram your moves ahead of time. '\
                'On asynchronous games this can shorten a game considerably.'),
          h(:p, 'Please note, these are not secret from other players.'),
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

      def sender
        @game.player_by_id(@user['id']) if @user
      end

      def render_auction_bid(settings)
        h(AutoAction::AuctionBid, game: @game, sender: sender, settings: settings)
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

      def enable_buy_shares(form)
        settings = params(form)

        corporation = @game.corporation_by_id(settings['corporation'])
        auto_pass_after = settings['auto_pass_after']

        if settings['float']
          until_condition = 'float'
          from_market = false
        elsif settings['ipo']
          until_condition = settings['buy_ipo'].to_i
          from_market = false
        elsif settings['market']
          until_condition = settings['buy_market'].to_i
          from_market = true
        end

        process_action(
          Engine::Action::ProgramBuyShares.new(
            sender,
            corporation: corporation,
            until_condition: until_condition,
            from_market: from_market,
            auto_pass_after: auto_pass_after,
          )
        )
      end

      AUTO_ACTIONS_WIKI = 'https://github.com/tobymao/18xx/wiki/Auto-actions'
      def render_share_choice(form, corporation, shares, name, print_name, selected, settings)
        owned = sender.num_shares_of(corporation, ceil: false)
        default_value = owned + 1
        default_value = settings&.until_condition if selected && settings && settings&.until_condition != 'float'
        input = render_input(
          "Buy from #{print_name} until at ",
          id: "buy_#{name}",
          type: :number,
          inputs: form,
          attrs: {
            min: owned,
            max: owned + shares.size,
            value: default_value,
            required: true,
          },
          input_style: { width: '5rem' },
          container_style: { margin: '0' },
        )

        h(:div, [render_input([input, 'share(s)'],
                              id: name,
                              type: 'radio',
                              name: 'mode',
                              inputs: form,
                              attrs: {
                                name: 'mode_options',
                                checked: selected,
                              })])
      end

      def render_buy_shares(settings)
        form = {}
        text = 'Auto Buy Shares'
        text += ' (Enabled)' if settings
        children = [h(:h3, text)]
        children << h(:p,
                      'Automatically buy shares in a corporation.'\
                      ' This will deactivate itself if other players do actions that may impact you.'\
                      ' It will also deactivate if there are multiple share sizes (5%, 10%, 20%)'\
                      ' available for purchase.')
        children << h(:p,
                      [h(:a, { attrs: { href: AUTO_ACTIONS_WIKI, target: '_blank' } },
                         'Please read this for more details when it will deactivate')])

        buyable = @game.corporations.select do |corp|
          corp.ipoed && (!corp.ipo_shares.empty? || !@game.share_pool.shares_by_corporation[corp].empty?)
        end

        if buyable.empty?
          children << h('p.bold', 'No corporations have shares available to buy, cannot program!')
        else
          selected = @buy_corporation || settings&.corporation || buyable.first
          values = buyable.map do |entity|
            attrs = { value: entity.name }
            attrs[:selected] = true if selected == entity
            h(:option, { attrs: attrs }, entity.name)
          end
          buy_corp_change = lambda do
            corp = Native(form[:corporation]).elm&.value
            store(:buy_corporation, @game.corporation_by_id(corp))
          end
          children << h(:div, [render_input('Corporation',
                                            id: 'corporation',
                                            el: 'select',
                                            on: { input: buy_corp_change },
                                            children: values, inputs: form)])

          children << h(Corporation, corporation: selected)
          corp_settings = settings if selected == settings&.corporation

          # Which settings should be checked
          settings_checked = if corp_settings&.until_condition == 'float'
                               :float
                             elsif corp_settings&.from_market
                               :from_market
                             elsif corp_settings
                               :from_ipo
                             else
                               first_radio = true
                               nil
                             end

          # Because the program does not deactivate it could be there
          # is nothing left in the ipo/market/float. Show it anyway
          # if it is activated
          if !selected.floated? || settings_checked == :float
            # There is a settings and it's floated, otherwise true if not selected already
            checked = first_radio || settings_checked == :float

            children << h(:div, [render_input('Until float',
                                              id: 'float',
                                              type: 'radio',
                                              name: 'mode',
                                              inputs: form,
                                              attrs: {
                                                name: 'mode_options',
                                                checked: checked,
                                              })])
            first_radio = false
          end

          if !selected.ipo_shares.empty? || settings_checked == :from_ipo
            checked = first_radio || settings_checked == :from_ipo
            children << render_share_choice(form,
                                            selected,
                                            selected.ipo_shares,
                                            'ipo',
                                            @game.ipo_name(selected),
                                            checked,
                                            corp_settings)
            first_radio = false
          end

          if !@game.share_pool.shares_by_corporation[selected].empty? || settings_checked == :from_market
            checked = first_radio
            checked = (corp_settings&.until_condition != 'float' && corp_settings&.from_market) if corp_settings
            children << render_share_choice(form,
                                            selected,
                                            @game.share_pool.shares_by_corporation[selected],
                                            'market',
                                            'Market',
                                            checked,
                                            corp_settings)
          end
          children << render_checkbox('Switch to auto-pass after successful completion.',
                                      'auto_pass_after',
                                      form,
                                      !!settings&.auto_pass_after)
          subchildren = [render_button(settings ? 'Update' : 'Enable') { enable_buy_shares(form) }]
          subchildren << render_disable(settings) if settings
          children << h(:div, subchildren)

        end
        children
      end

      def enable_share_pass(form)
        settings = params(form)

        unconditional = settings['sr_unconditional']
        indefinite = settings['sr_indefinite']

        process_action(
          Engine::Action::ProgramSharePass.new(
            sender,
            unconditional: unconditional,
            indefinite: indefinite,
          )
        )
      end

      def render_share_pass(settings)
        form = {}
        text = 'Auto Pass in Stock Round'
        text += ' (Enabled)' if settings
        children = [h(:h3, text)]
        children << h(:p,
                      'Automatically pass in the stock round.'\
                      ' This will deactivate itself if other players do actions that may impact you.'\
                      ' It will only pass on your normal turn and allow you to bid etc.')
        children << h(:p,
                      [h(:a, { attrs: { href: AUTO_ACTIONS_WIKI, target: '_blank' } },
                         'Please read this for more details when it will deactivate')])
        children << render_checkbox('Pass even if other players do actions that may impact you.',
                                    'sr_unconditional',
                                    form,
                                    !!settings&.unconditional)
        children << render_checkbox('Continue passing in future SR as well.',
                                    'sr_indefinite',
                                    form,
                                    !!settings&.indefinite)

        subchildren = [render_button(settings ? 'Update' : 'Enable') { enable_share_pass(form) }]
        subchildren << render_disable(settings) if settings
        children << h(:div, subchildren)

        children
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
