# frozen_string_literal: true

require 'view/game/pass_button'
require 'view/game/undo_button'
require 'view/game/redo_button'

module View
  module Game
    class GameEnd < Snabberb::Component
      include Actionable

      def render
        h(:div, [
          h(Game::Map, game: @game, opacity: 1.0),
          h(Game::Spreadsheet, game: @game),
        ])
      end
    end
  end
end
