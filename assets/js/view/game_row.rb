# frozen_string_literal: true

require 'view/game_card'

module View
  class GameRow < Snabberb::Component
    needs :header
    needs :games
    needs :user

    def render
      h(:div, [
        render_header(@header),
        render_row,
      ])
    end

    def render_header(header)
      h('div.card_header', header)
    end

    def render_row
      props = {
      }

      h(:div, props, @games.map { |game| h(GameCard, game: game, user: @user) })
    end
  end
end
