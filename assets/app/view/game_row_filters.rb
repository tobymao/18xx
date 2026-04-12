# frozen_string_literal: true

require 'game_manager'
require 'lib/params'

module View
  class GameRowFilters < Snabberb::Component
    include GameManager

    def render
      url_search_params = Lib::Params::URLSearchParams.new
      return '' if url_search_params.unsupported

      title_elm = render_title(url_search_params)

      h('div#game_filters.game_row', { key: @header }, [
        h(:h2, 'Filters'),
        title_elm,
        render_reset,
      ])
    end

    private

    def render_title(url_search_params)
      selected_titles = url_search_params.get_all('title[]')

      # Build lookup for display names
      title_display = {}
      Engine::VISIBLE_GAMES_WITH_VARIANTS.sort_by(&:display_title).each do |meta|
        title_display[meta.title] = meta.display_title
      end

      # Dropdown options: exclude already-selected titles
      game_options = [h(:option, { attrs: { value: '' } }, '(Add a title filter...)')]
      title_display.each do |value, display|
        next if selected_titles.include?(value)

        game_options << h(:option, { attrs: { value: value } }, display)
      end

      on_select = lambda do |e|
        target = e.JS['currentTarget']
        title = target.JS['value']
        return if title.empty?

        new_titles = (selected_titles + [title]).uniq
        url_search_params.set_array('title[]', new_titles)
        update_filters(url_search_params.to_query_string)
        target.JS['value'] = ''
      end

      children = []

      # Render chips for selected titles
      unless selected_titles.empty?
        chips = selected_titles.map do |t|
          display = title_display[t] || t
          on_remove = lambda do
            new_titles = selected_titles.reject { |x| x == t }
            url_search_params.set_array('title[]', new_titles)
            update_filters(url_search_params.to_query_string)
          end

          h(:span, {
              style: {
                display: 'inline-flex',
                alignItems: 'center',
                background: '#4a4a4a',
                color: '#fff',
                borderRadius: '3px',
                padding: '2px 6px',
                margin: '2px',
                fontSize: '0.9em',
              },
            }, [
            h(:span, "\u{1F682} #{display}"),
            h(:span, {
                style: { marginLeft: '4px', cursor: 'pointer', fontWeight: 'bold' },
                on: { click: on_remove },
              }, "\u00d7"),
          ])
        end

        children << h(:div, { style: { marginBottom: '4px' } }, chips)
      end

      children << h('select', { on: { input: on_select }, style: { maxWidth: '90vw' } }, game_options)

      h(:div, children)
    end

    def render_reset
      attrs = {
        on: {
          click: lambda do
            update_filters('')
          end,
        },
      }

      h('button', attrs, 'Reset filters')
    end

    def update_filters(params)
      params = "?#{params}"
      get_games(params)
      store(:app_route, "#{@app_route.split('?').first}#{params}", skip: true)
    end
  end
end
