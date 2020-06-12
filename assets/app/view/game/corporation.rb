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
          cursor: 'pointer',
        }

        if @game.round.can_act?(@corporation)
          card_style['border'] = '1px solid black'
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

        if @corporation.owner
          subchildren = (@corporation.operating_history.empty? ? [] : [render_revenue_history])
          children << h('table.revenue', [h(:tr, subchildren)])
        end

        h('div.corp.card', { style: card_style, on: { click: onclick } }, children)
      end

      def render_title
        title_row_props = {
          style: {
            grid: '1fr / 2rem auto',
            gap: '0 1rem',
            padding: '0.4rem',
            background: @corporation.color,
            color: @corporation.text_color,
          },
        }
        token_props = {
          attrs: { src: @corporation.logo },
          style: {
            height: '2rem',
            width: '2rem',
            'justify-self': 'start',
            border: '0.2rem solid currentColor',
            'border-radius': '0.5rem',
          },
        }
        name_props = {
          style: {
            color: 'currentColor',
          },
        }

        h('div.corp__title', title_row_props, [
          h(:img, token_props),
          h('div.title', name_props, @corporation.full_name),
        ])
      end

      def render_holdings
        holdings_row_props = {
          style: {
            grid: '1fr / 4.5rem auto',
            gap: '0 0.2rem',
            padding: '0.2rem 0.5rem',
            'background-color': @game.round.can_act?(@corporation) ? '#99bb99' : 'gainsboro',
            color: 'black',
          },
        }
        sym_props = {
          style: {
            'font-size': '2rem',
            'font-weight': 'bold',
            'justify-self': 'start',
          },
        }
        holdings_props = {
          style: {
            grid: '1fr / 1fr 1fr auto',
            gap: '0 0.3rem',
          },
        }

        h('div.corp__holdings', holdings_row_props, [
          h(:div, sym_props, @corporation.name),
          h(:div, holdings_props, [
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
        segment_props = {
          style: {
            grid: '3fr 2fr / 1fr',
          },
        }
        value_props = {
          style: {
            'max-width': '7.5rem',
            'font-weight': 'bold',
          },
        }
        key_props = {
          style: {
            'align-self': 'end',
          },
        }
        h(:div, segment_props, [
          h('div.right.nowrap', value_props, value),
          h(:div, key_props, key),
        ])
      end

      def render_tokens
        token_list_props = {
          style: {
            grid: '1fr / auto-flow repeat(auto-fit, minmax(1.8rem, 1fr))',
            gap: '0 0.2rem',
            'padding-left': '1rem',
          },
        }
        token_column_props = {
          style: {
            grid: '3fr 2fr / 1fr',
          },
        }
        token_text_props = {
          style: {
            'align-self': 'end',
          },
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

          h(:div, token_column_props, [
            h(:img, img_props),
            h(:div, token_text_props, token_text),
          ])
        end
        h(:div, token_list_props, tokens_body)
      end

      def share_price_str(share_price)
        share_price ? @game.format_currency(share_price.price) : ''
      end

      def share_number_str(number)
        number.positive? ? number.to_s : ''
      end

      def render_shares
        player_info = @game
          .players
          .map do |p|
          [p, @corporation.president?(p), p.num_shares_of(@corporation), @game.round.did_sell?(@corporation, p)]
        end

        shares_props = {
          style: {
            'padding-right': '1.5rem',
          },
        }

        player_rows = player_info
          .select { |_, _, num_shares, did_sell| num_shares.positive? || did_sell }
          .sort_by { |_, president, num_shares, _| [president ? 0 : 1, -num_shares] }
          .map do |player, president, num_shares, did_sell|
            h('tr.player', [
              h("td.name.#{president ? 'president' : ''}", player.name),
              h('td.right', shares_props, "#{president ? '* ' : ''}#{num_shares}"),
              did_sell ? h('td.italic', 'Sold') : '',
            ])
          end

        num_ipo_shares = @corporation.num_shares_of(@corporation)
        num_market_shares = @game.share_pool.num_shares_of(@corporation)

        pool_rows = [
          h('tr.ipo', [
            h('td.name', 'IPO'),
            h('td.right', shares_props, share_number_str(num_ipo_shares)),
            h('td.right', share_price_str(@corporation.par_price)),
          ]),
        ]

        market_tr_props = {
          style: {
            'border-bottom': player_rows.any? ? '1px solid currentColor' : '0',
          },
        }

        if player_rows.any?
          pool_rows << h('tr.market', market_tr_props, [
            h('td.name', 'Market'),
            h('td.right', shares_props, share_number_str(num_market_shares)),
            h('td.right', share_price_str(@corporation.share_price)),
          ])
        end

        rows = [
          *pool_rows,
          *player_rows,
        ]

        h('table.shareholders', [
          h(:thead, [
            h(:tr, [
              h(:th, 'Shareholder'),
              h(:th, 'Shares'),
              h(:th, 'Price'),
            ]),
          ]),
          h(:tbody, [
            *rows,
          ]),
        ])
      end

      def render_companies
        companies = @corporation.companies.map do |company|
          render_company(company)
        end

        h('table.companies', [
          h(:thead, [
            h(:tr, [
              h(:th, 'Company'),
              h(:th, 'Income'),
            ]),
          ]),
          h(:tbody, [
            *companies,
          ]),
        ])
      end

      def render_company(company)
        h(:tr, [
          h('td.name.nowrap', company.name),
          h('td.right', @game.format_currency(company.revenue)),
        ])
      end

      def render_revenue_history
        last_run = @corporation.operating_history[@corporation.operating_history.keys.max].revenue
        h('td.bold', "Last Run: #{@game.format_currency(last_run)}")
      end

      def selected?
        @corporation == @selected_corporation
      end
    end
  end
end
