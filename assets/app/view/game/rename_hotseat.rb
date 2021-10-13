# frozen_string_literal: true

require 'view/game/actionable'
require 'view/form'

module View
  module Game
    class RenameHotseat < Form
      include Actionable

      def render_content
        return h(:div) if @game_data[:mode] != :hotseat

        h(:div, [
          render_input('Hotseat Description',
                       placeholder: 'Add a title',
                       id: :description,
                       attrs: {
                         title: 'Edit hotseat description',
                         value: @game_data[:description],
                       },
                       on: { change: -> { submit } }),
        ])
      end

      def submit
        @game_data[:description] = params['description']
        store(:game_data, @game_data, skip: true)

        Lib::Storage[@game_data[:id]] = @game_data
      end
    end
  end
end
