# frozen_string_literal: true

module View
  class Corporation < Snabberb::Component
    needs :corporation
    needs :selected_corporation, default: nil, store: true
    needs :game, store: true

    def render
      onclick = lambda do
        selected_corporation = selected? ? nil : @corporation
        store(:selected_corporation, selected_corporation)
      end

      card_style = {
        display: 'inline-block',
        cursor: 'pointer',
        position: 'relative',
        border: 'solid 1px gainsboro',
        padding: '0.5rem',
        margin: '0.5rem 0.5rem 0 0',
        width: '320px',
        'vertical-align': 'top',
      }

      card_style['background-color'] = 'lightblue' if selected?

      if @game.round.can_act?(@corporation)
        card_style['border'] = 'solid 1px black'
        card_style['background-color'] = '#dfd'
      end

      children = [
        render_title,
        render_holdings,
        render_shares,
      ]

      children << render_companies if @corporation.companies.any?

      table_props = {
        style: {
          'text-align': 'center',
          'font-weight': 'bold',
          'margin-left': 'auto',
          'margin-right': 'auto',
          'border-spacing': '1rem',
        }
      }

      if @corporation.owner
        subchildren = [render_president] + (@corporation.revenue_history.empty? ? [] : [render_revenue_history])
        children << h(:table, table_props, [h(:tr, subchildren)])
      end

      h(:div, { style: card_style, on: { click: onclick } }, children)
    end

    def render_title
      title_style = {
        background: @corporation.color,
        'text-align': 'center',
        color: '#ffffff',
        padding: '0.5rem 0px',
        'font-weight': 'bold',
        margin: '-0.5rem -0.5rem 0 -0.5rem'
      }
      h(:div, { style: title_style }, @corporation.full_name)
    end

    def render_holdings
      holdings_style = {
        'text-align': 'center',
        'white-space': 'nowrap',
        'background-color': 'lightgray',
        display: 'flex',
        'justify-content': 'center',
        margin: '0 -0.5rem'
      }

      holdings_style['background-color'] = '#9b9' if @game.round.can_act?(@corporation)

      h(:div, { style: holdings_style }, [
        render_header_segment(@corporation.name, 'Sym'),
        render_trains,
        render_header_segment(@game.format_currency(@corporation.cash), 'Cash'),
        render_tokens
      ])
    end

    def render_trains
      train_value = @corporation.trains.empty? ? 'None' : @corporation.trains.map(&:name).join(',')
      render_header_segment(train_value, 'Trains')
    end

    def render_header_segment(value, key)
      props = {
        style: {
          display: 'inline-block',
          margin: '0.5em',
          'text-align': 'right',
        },
      }

      value_props = {
        style: {
          'font-size': '16px',
          'font-weight': 'bold',
          'max-width': '120px',
          'white-space': 'nowrap',
          'text-overflow': 'ellipsis',
          overflow: 'hidden',
        }
      }
      h(:div, props, [
        h(:div, value_props, value),
        h(:div, key),
      ])
    end

    def render_treasury
      h(:div, "Treasury: #{@game.format_currency(@corporation.cash)}")
    end

    def render_tokens
      token_style = {
        margin: '0.5rem',
        'text-align': 'center'
      }
      token_list_style = {
        width: '2rem',
        float: 'left'
      }

      tokens_body = @corporation.tokens.map.with_index do |token, i|
        props = {
          attrs: {
            src: @corporation.logo
          },
          style: {
            width: '25px'
          },
        }

        props[:style][:filter] = 'contrast(15%) grayscale(100%)' if token.used?

        token_text = i.zero? ? @corporation.coordinates : token.price

        h(:div, { style: token_list_style }, [
          h(:img, props),
          h(:div, token_text),
        ])
      end
      h(:div, { style: token_style }, tokens_body)
    end

    def render_shares
      shares_style = {
        margin: '0.5rem',
        'text-align': 'center'
      }

      share_price = @corporation.share_price ? @corporation.share_price.price : 0
      par_price = @corporation.par_price ? @corporation.par_price.price : 0

      h(:div, { style: shares_style }, [
        h(:div, 'Shares'),
        render_share_type('Market', @game.share_pool.num_shares_of(@corporation), share_price),
        render_share_type('IPO', @corporation.num_shares_of(@corporation), par_price)
      ])
    end

    def render_share_type(source_name, quantity, price)
      share_style = {
        display: 'inline-block',
        margin: '0.2em 0.5em'
      }
      h(:div, { style: share_style }, [
        h(:div, source_name),
        render_number('Number', quantity),
        render_number('Price', @game.format_currency(price))
      ])
    end

    def render_number(title, number)
      number_box_style = {
        display: 'inline-block',
        margin: '0 0.5em'
      }
      number_style = {
        'font-size': '16px',
        'font-weight': 'bold',
        'max-width': '120px',
        'white-space': 'nowrap',
        'text-overflow': 'ellipsis',
        'overflow': 'hidden'
      }
      h(:div, { style: number_box_style }, [
        h(:div, { style: number_style }, number),
        h(:div, title)
      ])
    end

    def render_companies
      props = {
        style: {
          'text-align': 'center'
        }
      }

      companies = @corporation.companies.map do |company|
        render_company(company)
      end

      h(:table, props, [
        h(:tr, [
          h(:th, 'Company'),
          h(:th, 'Value'),
          h(:th, 'Income'),
        ]),
        *companies
      ])
    end

    def render_company(company)
      name_props = {
        style: {
          overflow: 'hidden',
          'width': '200px',
          'white-space': 'nowrap',
          'text-overflow': 'ellipsis',
        }
      }

      number_props = {
        style: {
          'width': '50px'
        }
      }

      h(:tr, [
        h(:td, name_props, company.name),
        h(:td, number_props, @game.format_currency(company.value)),
        h(:td, number_props, @game.format_currency(company.revenue)),
      ])
    end

    def render_president
      props = {
        style: {
          'font-weight': 'bold',
        }
      }

      h(:td, props, "President: #{@corporation.owner.name}")
    end

    def render_revenue_history
      props = {
        style: {
          'text-align': 'center',
          'font-weight': 'bold',
        }
      }

      last_run = @corporation.revenue_history[@corporation.revenue_history.keys.max]
      h(:td, props, "Last Run: #{@game.format_currency(last_run)}")
    end

    def selected?
      @corporation == @selected_corporation
    end
  end
end
