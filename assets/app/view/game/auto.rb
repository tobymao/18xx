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

      def render_content
        children = [
          h(:h2, 'Auto Actions'),
          h(:p, 'Auto actions allow you to preprogram your moves ahead of time. '\
                'On asynchronous games this can shorten a game considerably.'),
          h(:p, 'Please note, these are not secret from other players.'),
          h(:p, 'This feature is presently under development. More actions will be available soon.'),
        ]

        if @game.players.find { |p| p.name == @user&.dig('name') }
          types = {
            Engine::Action::ProgramBuyShares => ->(settings) { render_buy_shares(settings) },
            Engine::Action::ProgramMergerPass => ->(settings) { render_merger_pass(settings) },
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
        children << h(:div,
                      'This will pass converting/merging or offering your corporations automatically.'\
                      ' It will not pass otherwise still allowing you to buy shares, bid etc')

        rounds = @game.merge_rounds

        player = sender
        # Which corps can be passed, by default assume all
        passable = @game.merge_corporations.select { |corp| corp.owner == player }
        if @game.round.stock?
          children << h('div.bold', 'Cannot program while in a stock round')
        elsif passable.empty?
          children << h('div.bold', 'No mergable corporations are owned by you, cannot program!')
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
                           },
                           input_style: { float: 'left', margin: '5px' },),
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
                           },
                           input_style: { float: 'left', margin: '5px' },),
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
        process_action(
          Engine::Action::ProgramBuyShares.new(
            sender,
            corporation: @game.corporation_by_id(params(form)['corporation']),
            until_condition: 'float'
          )
        )
      end

      def render_buy_shares(settings)
        form = {}
        text = 'Auto Buy shares till float'
        text += ' (Enabled)' if settings
        children = [h(:h3, text)]
        children << h(:div,
                      'Warning! At present this does not take into account other players’ actions. '\
                      'We suggest not enabling after the first stock round.')

        # @todo: later this will support buying to a certain percentage
        floatable = @game.corporations.select { |corp| corp.ipoed && !corp.floated? }
        if floatable.empty?
          children << h('div.bold', 'No corporations are ipoed and not floated, cannot program!')
        else
          values = floatable.map do |entity|
            attrs = { value: entity.name }
            attrs[:selected] = true if settings&.corporation == entity
            h(:option, { attrs: attrs }, entity.name)
          end
          children << render_input('Corporation', id: 'corporation', el: 'select', on: { input2: :limit_range },
                                                  children: values, inputs: form)

          subchildren = [render_button(settings ? 'Save' : 'Enable') { enable_buy_shares(form) }]
          subchildren << render_disable(settings) if settings
          children << h(:div, subchildren)

        end
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
