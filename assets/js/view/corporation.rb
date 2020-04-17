# frozen_string_literal: true

module View
  class Corporation < Snabberb::Component
    needs :corporation
    needs :selected_corporation, default: nil, store: true
    needs :game, store: true

    def selected?
      @corporation == @selected_corporation
    end

    def render_trains
      if @corporation.trains.empty?
        h(:div, 'Trains: None')
      else
        h(:div, "Trains: #{@corporation.trains.map(&:name).join(', ')}")
      end
    end

    def render_private_companies
      if @corporation.companies.empty?
        h(:div, 'Private Companies: None')
      else
        h(:div, "Private Companies: #{@corporation.companies.map(&:name).join(', ')}")
      end
    end

    def render_tokens
      token_cost_style = {
        'text-align': 'center'
      }

      standard_list_style = {
        width: '2rem'
      }

      props = {
        attrs: { data: @corporation.logo, width: '25px' },
      }

      inverted = props.merge(style: { filter: 'contrast(15%) grayscale(100%)' })

      @corporation.tokens.map.with_index do |token, i|
        token_text = i.zero? ? @corporation.coordinates : token.price

        h(:div, { style: standard_list_style }, [
          h(:object, token.used? ? inverted : props),
          h(:div, { style: token_cost_style }, token_text),
        ])
      end
    end

    def render
      onclick = lambda do
        selected_corporation = selected? ? nil : @corporation
        store(:selected_corporation, selected_corporation)
      end

      style = {
        display: 'inline-block',
        cursor: 'pointer',
        border: 'solid 1px gainsboro',
        padding: '0.5rem',
        margin: '0.5rem 0.5rem 0 0',
        width: '350px',
        'text-align': 'center',
        'font-weight': 'bold',
        'vertical-align': 'top',
      }

      style['background-color'] = 'lightblue' if selected?

      title_style = {
        background: @corporation.color,
        'text-align': 'center',
        color: '#ffffff',
        padding: '0.5rem 0px'
      }

      token_style = {
        display: 'flex',
        'justify-content': 'center',
        padding: '0.5rem 0px'
      }

      h(:div, { style: style, on: { click: onclick } }, [
        h(:div, { style: title_style }, "#{@corporation.name} (#{@corporation.sym})"),
        h(:div, { style: token_style }, render_tokens),
        render_trains,
        h(:div, "Treasury: #{@game.format_currency(@corporation.cash)}"),
        render_private_companies,
        h(:div, "Available Shares: #{@corporation.shares.size}")
      ])
    end
  end
end
