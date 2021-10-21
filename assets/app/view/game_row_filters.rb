# frozen_string_literal: true

require 'game_manager'
require 'lib/params'

module View
  class GameRowFilters < Snabberb::Component
    include GameManager

    def render
      url_search_params = Lib::Params::URLSearchParams.new
      return if url_search_params.unsupported

      h('div#game_filters.game_row', { key: @header }, [
        h(:h2, 'Filters'),
        render_title(url_search_params),
        render_reset,
      ])
    end

    private

    def render_title(url_search_params)
      selected_title = url_search_params['title']
      game_options = [h(:option, { attrs: { value: '' } }, '(All titles)')]
      Engine::VISIBLE_GAMES.map(&:title).sort.each do |title|
        # Don't use game::GAME_DROPDOWN_TITLE since it's not what is displayed in game cards.
        game_options << h(:option, { attrs: { value: title, selected: title == selected_title } }, title)
      end
      title_change = lambda do |e|
        title = e.JS['currentTarget'].JS['value']
        url_search_params['title'] = title.empty? ? nil : title
        update_filters(url_search_params.to_query_string)
      end
      attrs = {
        on: { input: title_change },
        style: { maxWidth: '90vw' },
      }
      h('select', attrs, game_options)
    end

    def render_reset
      attrs = {
        on: { click: -> { update_filters('') } },
      }
      h('button', attrs, 'Reset filters')
    end

    def update_filters(params)
      params = "?#{params}" unless params.start_with?('?')
      get_games(params)
      store(:app_route, "#{@app_route.split('?').first}#{params}")
    end
  end
end
