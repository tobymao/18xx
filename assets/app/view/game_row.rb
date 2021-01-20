# frozen_string_literal: true

require 'game_manager'
require 'lib/storage'
require 'view/form'
require 'view/game_card'

module View
  class GameRow < Snabberb::Component
    include GameManager

    needs :header
    needs :game_row_games
    needs :status, default: 'active'
    needs :type
    needs :user

    LIMIT = 12

    def render
      @limit = @type == :personal ? 8 : LIMIT
      h("div##{@type}.game_row", { key: @header }, [
        render_header(@header),
        *render_row,
      ])
    end

    def render_header(header)
      children = [h(:h2, header)]
      p = page.to_i
      params = "games=#{@type}#{@type != :hs ? "&status=#{@status}" : ''}"
      @offset = @type == :hs ? (p * @limit) : 0
      children << render_more('<', "?#{params}&p=#{p - 1}") if p.positive?
      children << render_more('>', "?#{params}&p=#{p + 1}") if @game_row_games.size > @offset + @limit
      children << render_search

      props = {
        style: {
          display: 'grid',
          grid: '1fr / 11.5rem 3rem 3rem 1fr',
          gap: '1rem',
          alignItems: 'center',
        },
      }

      h(:div, props, children)
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
          gridColumnStart: text == '>' ? '3' : '2',
          margin: '0',
        },
      }

      h('a.button_link', props, text)
    end

    def render_search
      search_id = "search_#{@type}_#{@status}"

      search_games = lambda do |event|
        if event.JS['type'] == 'click' || event.JS['keyCode'] == 13
          val = Native(@inputs[search_id]).elm.value
          val == '' ? Lib::Storage.delete(search_id) : Lib::Storage[search_id] = val
          update
        end
      end

      input_props = {
        attrs: {
          id: search_id,
          name: 'q',
          type: 'search',
          value: Lib::Storage[search_id] || '',
          placeholder: 'game, description, players, …',
        },
        style: { width: '13.5rem' },
        on: { keyup: search_games },
      }
      @inputs = {}

      h(:div, { style: { gridColumnStart: 4 } }, [
        @inputs[search_id] = h(:input, input_props),
        h(:button, { on: { click: search_games } }, 'Search'),
      ])
    end

    def render_row
      if @game_row_games.any?
        @game_row_games.slice(@offset, @limit).map { |game| h(GameCard, gdata: game, user: @user) }
      else
        [h(:div, 'No games to display')]
      end
    end

    private

    def page
      return 0 if `typeof URLSearchParams === 'undefined'` # rubocop:disable Lint/LiteralAsCondition

      `(new URLSearchParams(window.location.search)).get('p')` || 0
    end
  end
end
