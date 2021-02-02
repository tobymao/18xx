# frozen_string_literal: true

require 'game_manager'
require 'lib/params'
require 'lib/storage'
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
      h('div#games_list', { key: @header, style: { minHeight: '70rem' } }, [
        render_header(@header),
        *render_row,
      ])
    end

    def render_header(header)
      p = Lib::Params['p']&.to_i || 0
      @search_string = Lib::Params['s']
      params = "games=#{@type}&status=#{@status}"
      params += "&s=#{`encodeURIComponent(#{@search_string})`}" if @search_string

      @offset = @type == :hs ? (p * LIMIT) : 0
      pagination = []
      pagination << render_more('<', "?#{params}&p=#{p - 1}") if p.positive?
      pagination << render_more('>', "?#{params}&p=#{p + 1}") if @game_row_games.size > @offset + LIMIT

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
      children = [h(:div, props, [h(:h2, header), *pagination])]
      children << render_search unless @type == 'hs'

      h(:div, children)
    end

    def render_more(text, params)
      params += @search_param if @search_param

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
      search_games = lambda do |event|
        if event.JS['type'] == 'click' || event.JS['keyCode'] == 13
          val = Native(@inputs['search']).elm.value
          if val.match(/^[^&|:*!]+$/)
            # no tsquery => attach :* to all terms and put & in-between
            val = val.gsub(/(.+)\b$/, '\1:*').gsub(/\b\s+\b/, ':* & ')
            Native(@inputs['search']).elm.value = val
          end
          @search_param = val.empty? ? '' : "&s=#{`encodeURIComponent(#{val})`}"
          params = "/?games=#{@type}&status=#{@status}#{@search_param}"
          get_games(params)
          store(:app_route, params)
        end
      end

      input_props = {
        attrs: {
          id: 'search',
          name: 'q',
          type: 'search',
          value: @search_string || '',
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
        @inputs['search'] = h('input.no_margin', input_props),
        h('button.small', {
            attrs: {
              title: 'Search',
            },
            style: {
              width: '2.5rem',
              margin: '0',
            },
            on: { click: search_games },
          },
          '🔍'),
        h('a.button_link.small', {
            attrs: {
              href: 'https://github.com/tobymao/18xx/wiki/FAQ#search',
              title: 'Click to open help!

text:* = trailing wildcard
& = and
| = or
! = not
() = group
text:ABCD = limit to …
A = game title
B = users
C = description
D = round/turn/rules',
            },
            style: {
              width: '2.5rem',
              margin: '0',
            },
          },
          '?'),
      ])
    end

    def render_row
      if @game_row_games.any?
        @game_row_games.slice(@offset, LIMIT).map { |game| h(GameCard, gdata: game, user: @user) }
      else
        [h(:div, 'No games to display')]
      end
    end
  end
end
