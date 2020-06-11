# frozen_string_literal: true

module View
  module Game
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
          position: 'relative',
          display: 'inline-block',
          overflow: 'hidden',
          'vertical-align': 'top',
          width: '24rem',
          margin: '0.5rem 0.5rem 0 0',
          border: 'solid 1px gainsboro',
          'border-radius': '0.7rem',
          cursor: 'pointer',
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
            'margin-left': 'auto',
            'margin-right': 'auto',
            'font-weight': 'bold',
            'text-align': 'center',
          },
        }

        if @corporation.owner
          subchildren = (@corporation.operating_history.empty? ? [] : [render_revenue_history])
          children << h(:table, revenue_table_props, [h(:tr, subchildren)])
        end

        h('div.corporation', { style: card_style, on: { click: onclick } }, children)
      end

      def render_title
        title_row_style = {
          display: 'grid',
          grid: '1fr / 2rem auto',
          'align-items': 'center',
          gap: '0 1rem',
          padding: '0.4rem',
          background: @corporation.color,
          color: @corporation.text_color,
        }
        token_props = {
          attrs: { src: @corporation.logo },
          style: {
            height: '2rem',
            width: '2rem',
            'justify-self': 'start',
            border: "0.2rem solid #{@corporation.text_color}",
            'border-radius': '0.5rem',
          },
        }
        name_style = {
          'justify-self': 'center',
          color: @corporation.text_color,
          'font-weight': 'bold',
        }

        h('div.corp__title__row', { style: title_row_style }, [
          h('img.token', token_props),
          h('div.corp__title__name', { style: name_style }, @corporation.full_name),
        ])
      end

      def render_holdings
        holdings_row_style = {
          display: 'grid',
          grid: '1fr / 4.5rem auto',
          gap: '0 0.2rem',
          'align-items': 'center',
          'justify-items': 'center',
          padding: '0.1rem 0.5rem',
          background: 'gainsboro',
          color: 'black',
        }
        sym_style = {
          'font-size': '2rem',
          'font-weight': 'bold',
          'justify-self': 'start',
        }
        holdings_style = {
          display: 'grid',
          grid: '1fr / 1fr 1fr auto',
          gap: '0 0.3rem',
        }

        holdings_row_style['background'] = '#99bb99' if @game.round.can_act?(@corporation)

        h('div.corp__holdings__row', { style: holdings_row_style }, [
          h('div.corp__sym', { style: sym_style }, @corporation.name),
          h('div.corp__holdings', { style: holdings_style }, [
            render_trains,
            render_header_segment(@game.format_currency(@corporation.cash), 'Cash'),
            render_tokens,
          ]),
        ])
      end

      def render_trains
        train_value = @corporation.trains.empty? ? 'None' : @corporation.trains.map(&:name).join(',')
        render_header_segment(train_value, 'Trains')
      end

      def render_header_segment(value, key)
        segment_style = {
          display: 'grid',
          grid: '3fr 2fr / 1fr',
          'align-items': 'center',
          'justify-items': 'center',
        }
        value_style = {
          'max-width': '7.5rem',
          overflow: 'hidden',
          'font-weight': 'bold',
          'text-overflow': 'ellipsis',
          'white-space': 'nowrap',
        }
        key_style = {
          'align-self': 'end',
        }

        h('div.header__segment', { style: segment_style }, [
          h('div.value', { style: value_style }, value),
          h('div.key', { style: key_style }, key),
        ])
      end

      def render_treasury
        h('div.corp__treasury', "Treasury: #{@game.format_currency(@corporation.cash)}")
      end

      def render_tokens
        token_list_style = {
          display: 'grid',
          grid: '1fr / auto-flow repeat(auto-fit, minmax(1.8rem, 1fr))',
          gap: '0 0.2rem',
          'align-items': 'center',
          'justify-items': 'center',
          'padding-left': '1rem',
        }
        token_column_style = {
          display: 'grid',
          grid: '3fr 2fr / 1fr',
          'align-items': 'center',
          'justify-items': 'center',
        }
        token_text_style = {
          'align-self': 'end',
        }

        tokens_body = @corporation.tokens.map.with_index do |token, i|
          img_props = {
            attrs: {
              src: @corporation.logo,
            },
            style: {
              width: '1.8rem',
            },
          }

          img_props[:style][:filter] = 'contrast(50%) grayscale(100%)' if token.used?

          token_text = i.zero? ? @corporation.coordinates : token.price

          h('div.corp__token', { style: token_column_style }, [
            h('img.token', img_props),
            h('div.key', { style: token_text_style }, token_text),
          ])
        end
        h('div.corp__tokens', { style: token_list_style }, tokens_body)
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

          h('tr.player', [
            h('td.shareholder.name', name_props, player.name),
            h('td.shares', td_props, "#{president ? '* ' : ''}#{num_shares}"),
            h('td.sold', sold_props, did_sell ? 'Sold' : ''),
          ])
        end

        market_tr_props = {
          style: {
            'border-bottom': player_rows.any? ? '1px solid currentColor' : '0',
          },
        }

        num_ipo_shares = @corporation.num_shares_of(@corporation)
        num_market_shares = @game.share_pool.num_shares_of(@corporation)

        pool_rows = [
          h('tr.ipo', [
            h('td.shareholder.ipo', td_props, 'IPO'),
            h('td.shares', td_props, share_number_str(num_ipo_shares)),
            h('td.price', td_props, share_price_str(@corporation.par_price)),
          ]),
        ]

        if player_rows.any?
          pool_rows << h('tr.market', market_tr_props, [
            h('td.shareholder.market', td_props, 'Market'),
            h('td.shares', td_props, share_number_str(num_market_shares)),
            h('td.price', td_props, share_price_str(@corporation.share_price)),
          ])
        end

        rows = [
          *pool_rows,
          *player_rows,
        ]

        table_props = {
          style: {
            'border-collapse': 'collapse', # so line under margin will work
            'margin-left': 'auto',
            'margin-right': 'auto',
            'margin-top': '0.5rem',
          },
        }

        h('table.shareholders', table_props, [
          h(:thead, [
            h('tr', [
              h('th.shareholder', td_props, 'Shareholder'),
              h('th.shares', td_props, 'Shares'),
              h('th.price', td_props, 'Price'),
            ]),
          ]),
          h(:tbody, [
            *rows,
          ]),
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

        h('td.president', props, "President: #{@corporation.owner.name}")
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
        h('td.last-run', props, "Last Run: #{@game.format_currency(last_run)}")
      end

      def selected?
        @corporation == @selected_corporation
      end
    end
  end
end
