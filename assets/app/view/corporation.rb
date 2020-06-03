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
        'border-radius': '10px',
        overflow: 'hidden',
        padding: '0.5rem',
        margin: '0.5rem 0.5rem 0 0',
        width: '320px',
        'vertical-align': 'top',
      }

      if @game.round.can_act?(@corporation)
        card_style['border'] = 'solid 1px black'
        card_style['background-color'] = '#dfd'
        card_style['color'] = 'black'
      end

      if selected?
        card_style['background-color'] = 'lightblue'
        card_style['color'] = 'black'
      end

      children = [
        render_title,
        render_holdings,
        render_shares,
      ]

      children << render_companies if @corporation.companies.any?

      revenue_table_props = {
        style: {
          'text-align': 'center',
          'font-weight': 'bold',
          'margin-left': 'auto',
          'margin-right': 'auto',
        },
      }

      if @corporation.owner
        subchildren = (@corporation.operating_history.empty? ? [] : [render_revenue_history])
        children << h(:table, revenue_table_props, [h(:tr, subchildren)])
      end

      h(:div, { style: card_style, on: { click: onclick } }, children)
    end

    def render_title
      title_style = {
        background: @corporation.color,
        color: @corporation.text_color,
        'text-align': 'center',
        padding: '0.5rem 0px',
        'font-weight': 'bold',
        margin: '-0.5rem -0.5rem 0 -0.5rem',
      }
      h(:div, { style: title_style }, @corporation.full_name)
    end

    def render_holdings
      holdings_style = {
        'text-align': 'center',
        'white-space': 'nowrap',
        'background-color': 'lightgray',
        color: 'black',
        display: 'flex',
        'justify-content': 'center',
        margin: '0 -0.5rem',
      }

      holdings_style['background-color'] = '#9b9' if @game.round.can_act?(@corporation)

      h(:div, { style: holdings_style }, [
        render_header_segment(@corporation.name, 'Sym'),
        render_trains,
        render_header_segment(@game.format_currency(@corporation.cash), 'Cash'),
        render_tokens,
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
          'text-align': 'center',
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
        },
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
        'text-align': 'center',
      }
      token_list_style = {
        width: '2rem',
        float: 'left',
      }

      tokens_body = @corporation.tokens.map.with_index do |token, i|
        props = {
          attrs: {
            src: @corporation.logo,
          },
          style: {
            width: '25px',
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

    def share_price_str(share_price)
      share_price ? @game.format_currency(share_price.price) : ''
    end

    def share_number_str(number)
      number.positive? ? number.to_s : ''
    end

    def render_shares
      td_props = {
        style: {
          padding: '0 0.5rem',
          'line-height': '1.25rem',
        },
      }

      player_info = @game
        .players
        .map do |p|
          [p, @corporation.president?(p), p.num_shares_of(@corporation), @game.round.did_sell?(@corporation, p)]
        end

      player_rows = player_info
        .select { |_, _, num_shares, did_sell| num_shares.positive? || did_sell }
        .sort_by { |_, president, num_shares, _| [president ? 0 : 1, -num_shares] }
        .map do |player, president, num_shares, did_sell|
        name_props = {
          style: {
            padding: '0 0.3rem',
          },
        }

        sold_props = {
          style: {
            padding: '0 0.5rem',
            'line-height': '1.25rem',
            'font-style': 'italic',
          },
        }

        h(:tr, [
          h(:td, name_props, player.name),
          h(:td, td_props, "#{num_shares}#{president ? '*' : ''}"),
          h(:td, sold_props, did_sell ? 'Sold' : ''),
        ])
      end

      market_tr_props = {
        style: {
          'border-bottom': player_rows.any? ? '1px solid #888' : '0',
        },
      }

      num_ipo_shares = @corporation.num_shares_of(@corporation)
      num_market_shares = @game.share_pool.num_shares_of(@corporation)

      pool_rows = [
        h(:tr, [
          h(:td, td_props, 'IPO'),
          h(:td, td_props, share_number_str(num_ipo_shares)),
          h(:td, td_props, share_price_str(@corporation.par_price)),
        ]),
      ]

      if player_rows.any?
        pool_rows << h(:tr, [
          h(:td, td_props, 'Market'),
          h(:td, td_props, share_number_str(num_market_shares)),
          h(:td, td_props, share_price_str(@corporation.share_price)),
        ])
      end

      rows = [
        *pool_rows,
        h(:tr, market_tr_props, [h(:td, { colspan: '100%' }, '')]),
        *player_rows,
      ]

      table_props = {
        style: {
          'border-collapse': 'collapse', # so line under margin will work
          'text-align': 'center',
          'margin-left': 'auto',
          'margin-right': 'auto',
          'margin-top': '0.5rem',
        },
      }

      h(:table, table_props, [
        h(:tr, [
          h(:th, td_props, 'Shareholder'),
          h(:th, td_props, 'Shares'),
          h(:th, td_props, 'Price'),
        ]),
        *rows,
      ])
    end

    def render_companies
      props = {
        style: {
          'margin-top': '1rem',
          'text-align': 'center',
          'margin-left': 'auto',
          'margin-right': 'auto',
        },
      }

      companies = @corporation.companies.map do |company|
        render_company(company)
      end

      h(:table, props, [
        h(:tr, [
          h(:th, 'Company'),
          h(:th, 'Income'),
        ]),
        *companies,
      ])
    end

    def render_company(company)
      props = {
        style: {
          'padding': '0 0.3rem',
          'line-height': '1.25rem',
        },
      }

      h(:tr, [
        h(:td, props, company.name),
        h(:td, props, @game.format_currency(company.revenue)),
      ])
    end

    def render_president
      props = {
        style: {
          'font-weight': 'bold',
        },
      }

      h(:td, props, "President: #{@corporation.owner.name}")
    end

    def render_revenue_history
      props = {
        style: {
          'padding-top': '1rem',
          'text-align': 'center',
          'font-weight': 'bold',
        },
      }

      last_run = @corporation.operating_history[@corporation.operating_history.keys.max].revenue
      h(:td, props, "Last Run: #{@game.format_currency(last_run)}")
    end

    def selected?
      @corporation == @selected_corporation
    end
  end
end
