# frozen_string_literal: true

module View
  class Corporation < Snabberb::Component
    needs :corporation
    needs :selected_corporation, default: nil, store: true

    def selected?
      @corporation == @selected_corporation
    end

    def render_trains
      if @corporation.trains.length.zero?
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
      tokens_used = @corporation.max_tokens - @corporation.tokens.length
      token_display_array = []
      token_cost_style = {
        'text-align': 'center'
      }

      standard_list_style = {
        width: '2rem'
      }

      props = {
        attrs: { data: @corporation.logo, width: '25px' },
        style: {}
      }

      invert_props = {
        attrs: {
          data: @corporation.logo,
          width: '25px',
          style: 'filter: contrast(15%) grayscale(100%)'
        },
      }

      @corporation.max_tokens.times do |i|
        # Show Token or don't
        if tokens_used.positive?
          props_used = invert_props
          tokens_used -= 1
        else
          props_used = props
        end
        # Show Home Coordinates or Cost
        token_text = if i.zero?
                       @corporation.coordinates
                     else
                       '40'
                     end
        token_display_array.push(h(:div, { style: standard_list_style }, [
          h(:object, props_used), h(:div, { style: token_cost_style }, token_text)
        ]))
      end
      token_display_array
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
        width: '300px',
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
        h(:div, { style: title_style }, @corporation.name),
        h(:div, { style: token_style }, render_tokens),
        render_trains,
        h(:div, "Treasury: #{@corporation.cash}"),
        render_private_companies,
        h(:div, "Available Shares: #{@corporation.shares.size}")
      ])
    end
  end
end
