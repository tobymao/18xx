# frozen_string_literal: true

require 'game_manager'
require 'lib/storage'
require 'view/game_card'

module View
  class GameRow < Snabberb::Component
    include GameManager

    needs :header
    needs :game_row_games
    needs :search_string, default: nil
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
      @search_string ||= Lib::Storage["search_#{@type}_#{@status}"] || nil

      @offset = @type == :hs ? (p * @limit) : 0
      children << render_more('<', "?#{params}&p=#{p - 1}") if p.positive?
      children << render_more('>', "?#{params}&p=#{p + 1}") if @game_row_games.size > @offset + @limit

      props = {
        style: {
          display: 'inline-grid',
          grid: '1fr / 13rem 2.5rem 2.5rem',
          gap: '0 0.5rem',
          alignItems: 'center',
          width: '20rem',
          marginRight: '0.5rem',
        },
      }
      h(:div, [h('div#header', props, children), render_search])
    end

    def render_more(text, params)
      params += "&s=#{@search_string}" if @search_string

      change_page = lambda do
        get_games(params)
        store(:app_route, params)
      end

      props = {
        attrs: {
          href: params,
          onclick: 'return false',
        },
        on: {
          click: change_page,
        },
        style: {
          justifySelf: 'center',
          gridColumnStart: text == '>' ? '3' : '2',
          width: '2.5rem',
          margin: '0',
        },
      }

      h('a.button_link.small.no_margin', props, text)
    end

    def render_search
      search_id = "search_#{@type}_#{@status}"

      search_games = lambda do |event|
        if event.JS['type'] == 'click' || event.JS['keyCode'] == 13
          val = Native(@inputs[search_id]).elm.value
          val == '' ? Lib::Storage.delete(search_id) : Lib::Storage[search_id] = val
          params = "/?games=#{@type}&status=#{@status}#{"&s=#{val}" if val != ''}"
          get_games(params)
          store(:app_route, params)
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
        style: { width: '13rem' },
        on: { keyup: search_games },
      }

      props = {
        style: {
          display: 'inline-grid',
          grid: '1fr / 13rem 2.5rem 2.5rem',
          gap: '0 0.5rem',
          width: '20rem',
          alignItems: 'center',
          marginBottom: '1rem',
        },
      }
      @inputs = {}
      h(:div, props, [
        @inputs[search_id] = h('input.no_margin', input_props),
        h('button.small', { style: { width: '2.5rem', margin: '0' }, on: { click: search_games } }, '🔍'),
        h('a.button_link.small',
          {
            attrs: {
              href: 'https://github.com/tobymao/18xx/wiki',
              title: 'ts_vector explanation', # TODO: short overview + wiki page
            },
            style: { width: '2.5rem', textAlign: 'center', margin: '0' },
          },
          '?'),
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
