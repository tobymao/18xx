# frozen_string_literal: true

require 'view/game/actionable'
require 'view/form'

module View
  module Game
    class RenameHotseat < Form
      include Actionable
      needs :user_notes, default: nil, store: true

      def render_content
        return h(:div) if @game_data[:mode] != :hotseat

        description = @game_data&.dig('description')

        h(:div, [
          render_input('Hotseat Description:',
                       placeholder: 'Add a title',
                       id: :description, attrs: { value: description }),
          render_button('Save') { submit },
        ])
      end

      def submit
        @game_data['description'] = params['description']
        store(:game_data, @game_data, skip: true)

        Lib::Storage[@game_data[:id]] = @game_data
      end
    end
  end
end
