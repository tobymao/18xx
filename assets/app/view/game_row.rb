# frozen_string_literal: true

require 'game_manager'
require 'view/game_card'

module View
  class GameRow < Snabberb::Component
    include GameManager

    needs :header
    needs :game_row_games
    needs :user
    needs :type

    LIMIT = 10

    def render
      h(:div, { key: @header }, [
        render_header(@header),
        *render_row,
      ])
    end

    def render_header(header)
      children = [header]
      p = page.to_i
      children << render_more('Prev', "?#{@type}=#{p - 1}") if p.positive?
      children << render_more('Next', "?#{@type}=#{p + 1}") if @game_row_games.size > LIMIT

      h('div.card_header', children)
    end

    def render_more(text, params)
      click = lambda do
        get_games(params)
        store(:app_route, "#{@app_route.split('?').first}#{params}")
      end
      props = {
        attrs: {
          href: params,
          onclick: 'return false',
        },
        style: {
          'margin-left': '1rem',
        },
        on: {
          click: click,
        },
      }

      h(:a, props, text)
    end

    def render_row
      @game_row_games.map { |game| h(GameCard, gdata: game, user: @user) }.take(LIMIT)
    end

    private

    def page
      return 0 if `typeof URLSearchParams === 'undefined'` # rubocop:disable Lint/LiteralAsCondition

      `(new URLSearchParams(window.location.search)).get(#{@type})` || 0
    end
  end
end
