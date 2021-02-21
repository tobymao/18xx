# frozen_string_literal: true

require 'game_manager'
require 'lib/storage'
require 'view/game/game_data'
require 'view/game/notepad'
require 'view/game/actionable'

module View
  module Game
    class Tools < Snabberb::Component
      include GameManager
      include Actionable

      needs :game, store: true
      needs :user
      needs :confirm_endgame, store: true, default: false

      def render
        @settings = Lib::Storage[@game.id] || {}
        h(:div, [
          h(Notepad),
          h(RenameHotseat),
          *render_tools,
          h(GameData, actions: @game.raw_actions.map(&:to_h)),
          *help_links,
        ])
      end

      def master_mode
        mode = @settings[:master_mode] || false
        toggle = lambda do
          Lib::Storage[@game.id] = @settings.merge('master_mode' => !mode)
          update
        end

        h('div.margined', [
          h(:button, { on: { click: toggle } }, "#{mode ? 'Disable' : 'Enable'} Master Mode"),
          h(:label, "#{mode ? 'You can' : 'Enable to'} move for others"),
        ])
      end

      def end_game
        end_game = if @confirm_endgame
                     confirm = lambda do
                       store(:confirm_endgame, false)
                       player = @game.players.find { |p| p.name == @user&.dig('name') }
                       process_action(Engine::Action::EndGame.new(player || @game.current_entity))
                       # Go to main page
                       store(:app_route, @app_route.split('#').first)
                     end
                     [
                       h(:button, { on: { click: confirm } }, 'Confirm End Game'),
                       h(:button, { on: { click: -> { store(:confirm_endgame, false) } } }, 'Cancel'),
                     ]
                   else
                     [
                       h(:button, { on: { click: -> { store(:confirm_endgame, true) } } }, 'End Game'),
                     ]
                   end

        h('div.margined', end_game)
      end

      def render_tools
        children = [master_mode]
        children << end_game unless @game.finished
        children
      end

      def help_links
        props = {
          attrs: {
            href: 'https://github.com/tobymao/18xx/wiki/Power-User-Features#hotkeys--shortcuts',
            title: 'Open wiki: hotkeys & shortcuts',
          },
        }

        [h(:h2, 'Help'), h(:a, props, 'Hotkeys & Shortcuts')]
      end
    end
  end
end
