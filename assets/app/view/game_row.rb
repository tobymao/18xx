# frozen_string_literal: true

require 'game_manager'
require 'lib/params'
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

    private

    def render_header(header)
      children = [h(:h2, header)]
      p = url_search_params[@type].to_i
      @offset = @type == :hotseat ? (p * @limit) : 0
      if p.positive?
        url_search_params[@type] = p - 1
        children << render_more('Prev', "?#{url_search_params.to_query_string}")
      end
      if @game_row_games.size > @offset + @limit
        url_search_params[@type] = p + 1
        children << render_more('Next', "?#{url_search_params.to_query_string}")
      end

      props = {
        style: {
          display: 'grid',
          grid: '1fr / minmax(10rem, auto) repeat(2, minmax(3rem, auto)) 1fr',
          gap: '1rem',
          alignItems: 'center',
        },
      }

      h('div.card_header', props, children)
    end

    def render_more(text, params)
      click = lambda do
        get_games(params)
        store(:app_route, "#{@app_route.split('?').first}#{params}", skip: true)
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
      @game_row_games.slice(@offset, @limit).map { |game| h(GameCard, gdata: game, user: @user) }
    end

    def url_search_params
      @url_search_params ||= Lib::Params::URLSearchParams.new
    end
  end
end
