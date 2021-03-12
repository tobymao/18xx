# frozen_string_literal: true

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
          h(:p, 'This feature is presently under development.'),
        ]

        if @game.players.find { |p| p.name == @user&.dig('name') }
          types = {
            Engine::Action::ProgramBuyShares => ->(settings) { render_buy_shares(settings) },
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

      def enable_merger_pass(form, passable, rounds)
        settings = params(form)

        selected_corps = passable.select { |corp| settings[corp.name] }
        selected_rounds = rounds.select { |round| settings[round.round_name] }.map(&:short_name)
        process_action(
          Engine::Action::ProgramMergerPass.new(
            sender,
            corporations: selected_corps,
            rounds: selected_rounds
          )
        )
      end

      def render_merger_pass(settings)
        form = {}
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

          subchildren = passable.map do |entity|
            h(:li, [
              render_input(entity.name,
                           id: entity.name,
                           type: 'checkbox',
                           inputs: form,
                           attrs: {
                             name: 'mode_options',
                             checked: !settings || settings&.corporations&.include?(entity),
                           }),
            ])
          end

          children << h(:div, [
            h(:p, 'Pass on Corporations:'),
            h(:ul, { style: { 'list-style': 'none' } }, subchildren),
          ])

          # Which rounds does it apply to, by default assume all
          subchildren = rounds.map do |round|
            h(:li, [
              # Use the long name to ensure no clash with corp ids
              render_input(round.round_name,
                           id: round.round_name,
                           type: 'checkbox',
                           inputs: form,
                           attrs: {
                             name: 'mode_options',
                             checked: !settings || settings&.rounds&.include?(round.short_name),
                           }),
            ])
          end

          children << h(:div, [
            h(:p, 'Pass in Rounds:'),
            h(:ul, { style: { 'list-style': 'none' } }, subchildren),
          ])

          subchildren = [render_button(settings ? 'Save' : 'Enable') { enable_merger_pass(form, passable, rounds) }]
          subchildren << render_disable(settings) if settings
          children << h(:div, subchildren)

        end

        children
      end

      def enable_buy_shares(form)
        settings = params(form)

        corporation = @game.corporation_by_id(settings['corporation'])

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
            from_market: from_market
          )
        )
      end

      AUTO_ACTIONS_WIKI = 'https://github.com/tobymao/18xx/wiki/Auto-actions'
      def render_share_choice(form, shares, name, print_name, selected, settings)
        owned = sender.num_shares_of(shares.first.corporation, ceil: false)
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
          input_style: { width: '2.5rem' },
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
                      ' It will also decative if there are multiple size shares (5%, 10%, 20%) available for purchase.')
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
                                            @game.share_pool.shares_by_corporation[selected],
                                            'market',
                                            'Market',
                                            checked,
                                            corp_settings)
          end
          subchildren = [render_button(settings ? 'Save' : 'Enable') { enable_buy_shares(form) }]
          subchildren << render_disable(settings) if settings
          children << h(:div, subchildren)

        end
        children
      end

      def enable_share_pass
        process_action(
          Engine::Action::ProgramSharePass.new(
            sender
          )
        )
      end

      def render_share_pass(settings)
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

        subchildren = [render_button(settings ? 'Save' : 'Enable') { enable_share_pass }]
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
