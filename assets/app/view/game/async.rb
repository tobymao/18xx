# frozen_string_literal: true

module View
  module Game
    class Async < Form
      include Actionable

      needs :game, store: true
      needs :user

      def render_content
        children = [
          h(:p, 'Programmed actions allows you to preprogram your moves ahead of time.'),
          h(:p, 'On asynchronous games this can shorten a game considerably.'),
          h(:p, 'Please note, these are not to be considered secret from other players and when activated are logged'),
          h(:p, 'This is presently under development, more actions will be available soon.'),
        ]

        if !(available = @game.available_programmed_actions).empty?
          available.each do |type|
            case type
            when Engine::Action::ProgramBuyShares.class
              children.concat(render_buy_shares)
            end
          end
          enabled = @game.programmed_actions[sender]
          children.concat(render_disable(enabled)) if enabled
        else
          children << h(:p, 'No programmed actions are presently available for this game')
        end

        h(:div, children)
      end

      def sender
        @game.player_by_id(@user['id']) if @user
      end

      def enable_buy_shares
        process_action(
          Engine::Action::ProgramBuyShares.new(
            sender,
            corporation: @game.corporation_by_id(params['corporation']),
            until_condition: 'float'
          )
        )
      end

      def render_buy_shares
        children = [h(:div, { style: { fontWeight: 'bold', margin: '2vmin 0' } }, 'Program buy shares till float')]
        children << h(:div,
                      'Warning! At present this does not take into account what other players do'\
                      ', we suggest not enabling after the first stock round.')

        # @todo: later this will support buying to a certain percentage
        floatable = @game.corporations.select { |corp| corp.ipoed && !corp.floated? }
        if floatable.empty?
          children << h(:div, { style: { fontWeight: 'bold' } },
                        'No corporations are ipoed but not floated, cannot program!')
        else
          values = floatable.map do |entity|
            h(:option, { attrs: { value: entity.name } }, entity.full_name)
          end
          children << render_input('Corporation:', id: 'corporation', el: 'select', on: { input2: :limit_range },
                                                   children: values)
          children << render_button('Enable Buy Shares') { enable_buy_shares }
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

      def render_disable(enabled)
        children = [h(:div, { style: { fontWeight: 'bold', margin: '2vmin 0' } },
                      "Disable program '#{enabled.class.print_name}'")]
        children << render_button("Disable '#{enabled.class.print_name}'") { disable }
        children
      end
    end
  end
end
