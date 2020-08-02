# frozen_string_literal: true

require 'view/game/actionable'
require 'view/form'

module View
  module Game
    class Notepad < Form
      include Actionable
      needs :user_notes, default: nil, store: true

      def render_content
        return h(:div) if @game_data[:mode] == :hotseat || !@game.players.map(&:name).include?(@user&.dig('name'))

        saved_notes = @game_data&.dig('user_settings', 'notepad')

        @user_notes ||= saved_notes
        saved = (@user_notes == saved_notes)

        notepad = render_input(
          '',
          id: :notepad,
          el: :textarea,
          attrs: {
            placeholder: 'Private notepad, will not be seen by other players',
            rows: 10,
            cols: 80,
          },
          container_style: {
            display: 'block',
          },
          on: {
            change: -> { local_save },
          },
          children: @user_notes
        )

        h(:div, [
          notepad,
          render_button("Save Notepad#{saved ? '' : ' (Unsaved)'}") { submit },
          ])
      end

      def local_save
        # non-persistently save the notepad in case the user switches tabs
        store(:user_notes, params['notepad'])
      end

      def submit
        setting = { notepad: params['notepad'] }
        save_user_settings(setting)
        store(:user_notes, params['notepad'])
      end
    end
  end
end
