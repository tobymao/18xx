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

    LIMIT = 12

    def render
      @limit = @type == :personal ? 1000 : LIMIT
      h("div##{@type}.game_row", { key: @header }, [
        render_header(@header),
        *render_row,
      ])
    end

    def render_header(header)
      children = [h(:h2, header)]
      p = page.to_i
      children << render_more('Prev', "?#{@type}=#{p - 1}") if p.positive?
      children << render_more('Next', "?#{@type}=#{p + 1}") if @game_row_games.size > @limit

      props = {
        style: {
          display: 'grid',
          grid: '1fr / 10rem 4rem 4rem',
          alignItems: 'center',
        },
      }

      h('div.card_header', props, children)
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
        on: {
          click: click,
        },
        style: {
          justifySelf: 'center',
          gridColumnStart: text == 'Next' ? '3' : '2',
        },
      }

      h("a.#{text.downcase}", props, text)
    end

    def render_row
      @game_row_games.map { |game| h(GameCard, gdata: game, user: @user) }.take(@limit)
    end

    private

    def page
      return 0 if `typeof URLSearchParams === 'undefined'` # rubocop:disable Lint/LiteralAsCondition

      `(new URLSearchParams(window.location.search)).get(#{@type})` || 0
    end
  end
end
