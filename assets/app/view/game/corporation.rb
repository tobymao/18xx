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
          border: '1px solid gainsboro',
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
            'background-color': @corporation.color,
            color: @corporation.text_color,
          },
        }
        token_props = {
          attrs: { src: @corporation.logo },
        }

        h('div.corp__title', title_row_props, [
          h('img.corp__herald', token_props),
          h('div.corp__name.title', @corporation.full_name),
        ])
      end

      def render_holdings
        holdings_row_props = {
          style: {
            'background-color': @game.round.can_act?(@corporation) ? '#99bb99' : 'gainsboro',
            color: 'black',
          },
        }

        h('div.corp__holdings', holdings_row_props, [
          h('div.corp__holdings__sym', @corporation.name),
          h('div.corp__holdings__details', [
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
        h('div.corp__holdings__segment', [
          h('div.value.nowrap', value),
          h('div.key', key),
        ])
      end

      def render_tokens
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

          h('div.corp__token', [
            h('img.token', img_props),
            h('div.key', token_text),
          ])
        end
        h('div.corp__token-list', tokens_body)
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

        player_rows = player_info
          .select { |_, _, num_shares, did_sell| num_shares.positive? || did_sell }
          .sort_by { |_, president, num_shares, _| [president ? 0 : 1, -num_shares] }
          .map do |player, president, num_shares, did_sell|
            h('tr.player', [
              h("td.#{president ? 'president' : 'shareholder'}.name", player.name),
              h('td.shares', "#{president ? '* ' : ''}#{num_shares}"),
              did_sell ? h('td.sold', 'Sold') : '',
            ])
          end

        num_ipo_shares = @corporation.num_shares_of(@corporation)
        num_market_shares = @game.share_pool.num_shares_of(@corporation)

        pool_rows = [
          h('tr.ipo', [
            h('td.ipo.name', 'IPO'),
            h('td.shares', share_number_str(num_ipo_shares)),
            h('td.price', share_price_str(@corporation.par_price)),
          ]),
        ]

        if player_rows.any?
          pool_rows << h('tr.market', [
            h('td.market.name', 'Market'),
            h('td.shares', share_number_str(num_market_shares)),
            h('td.price', share_price_str(@corporation.share_price)),
          ])
        end

        rows = [
          *pool_rows,
          *player_rows,
        ]

        h('table.shareholders', [
          h(:thead, [
            h(:tr, [
              h('th.shareholder', 'Shareholder'),
              h('th.shares', 'Shares'),
              h('th.price', 'Price'),
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
              h('th.company', 'Company'),
              h('th.income', 'Income'),
            ]),
          ]),
          h(:tbody, [
            *companies,
          ]),
        ])
      end

      def render_company(company)
        h(:tr, [
          h('td.company.nowrap', company.name),
          h('td.income', @game.format_currency(company.revenue)),
        ])
      end

      def render_revenue_history
        last_run = @corporation.operating_history[@corporation.operating_history.keys.max].revenue
        h('td.last-run', "Last Run: #{@game.format_currency(last_run)}")
      end

      def selected?
        @corporation == @selected_corporation
      end
    end
  end
end
