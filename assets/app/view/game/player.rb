# frozen_string_literal: true

module View
  module Game
    class Player < Snabberb::Component
      needs :player
      needs :game

      def render
        card_style = {
          border: '1px solid gainsboro',
          width: '20rem',
        }

        if @game.round.can_act?(@player)
          card_style['border'] = '1px solid black'
          card_style['background-color'] = '#dfd'
          card_style['color'] = 'black'
        end

        divs = [
          render_title,
          render_body,
        ]

        divs << render_companies if @player.companies.any?

        h('div.player.card', { style: card_style }, divs)
      end

      def render_title
        props = {
          style: {
            'background-color': @game.round.can_act?(@player) ? '#9b9' : 'gainsboro',
            color: 'black',
            padding: '0.4rem',
          },
        }

        h('div.player.title', props, @player.name)
      end

      def render_body
        props = {
          style: {
            'margin-top': '0.2rem',
            'margin-bottom': '0.4rem',
            display: 'flex',
            'justify-content': 'center',
          },
        }

        divs = [
          render_info,
        ]

        divs << render_shares if @player.shares.any?

        h(:div, props, divs)
      end

      def render_info
        num_certs = @player.num_certs
        cert_limit = @game.cert_limit

        table_props = {
          style: {
            margin: '0 1rem',
          },
        }

        td_cert_props = {
          style: {
            color: num_certs > cert_limit ? 'red' : 'currentColor',
          },
        }

        trs = [
          h(:tr, [
            h(:td, 'Cash'),
            h('td.right', @game.format_currency(@player.cash)),
          ]),
        ]

        if @game.round.auction?
          trs.concat([
            h(:tr, [
              h(:td, 'Committed'),
              h('td.right', @game.format_currency(@game.round.committed_cash(@player))),
            ]),
            h(:tr, [
              h(:td, 'Available'),
              h('td.right', @game.format_currency(@player.cash - @game.round.committed_cash(@player))),
            ]),
          ])
        end

        trs.concat([
          h(:tr, [
            h(:td, 'Value'),
            h('td.right', @game.format_currency(@player.value)),
          ]),
          h(:tr, [
            h(:td, 'Liquidity'),
            h('td.right', @game.format_currency(@game.liquidity(@player))),
          ]),
          h(:tr, [
            h(:td, 'Certs'),
            h('td.right', td_cert_props, "#{num_certs}/#{cert_limit}"),
          ]),
        ])

        if @player == @game.priority_deal_player
          trs << h(:tr, [
            h('td.center.italic', { attrs: { colspan: '2' } }, 'Priority Deal'),
          ])
        end

        h(:table, table_props, trs)
      end

      def render_shares
        props = {
          style: {
            margin: '0 1rem',
          },
        }

        shares = @player
          .shares_by_corporation.reject { |_, s| s.empty? }
          .sort_by { |c, s| [s.sum(&:percent), c.president?(@player) ? 1 : 0, c.name] }
          .reverse
          .map { |c, s| render_corporation_shares(c, s) }

        h(:table, props, shares)
      end

      def render_corporation_shares(corporation, shares)
        td_props = {
          style: {
            padding: '0 0.2rem',
          },
        }
        div_props = {
          style: {
            height: '20px',
          },
        }
        logo_props = {
          attrs: {
            src: corporation.logo,
          },
          style: {
            height: '20px',
          },
        }

        president_marker = corporation.president?(@player) ? '*' : ''
        h('tr.row', [
          h('td.center', td_props, [h(:div, div_props, [h(:img, logo_props)])]),
          h(:td, td_props, corporation.name + president_marker),
          h('td.right', td_props, "#{shares.sum(&:percent)}%"),
        ])
      end

      def render_companies
        companies = @player.companies.map do |company|
          render_company(company)
        end

        h('table.center', [
          h(:tr, [
            h(:th, 'Company'),
            h(:th, 'Value'),
            h(:th, 'Income'),
          ]),
          *companies,
        ])
      end

      def render_company(company)
        h(:tr, [
          h('td.name.nowrap', company.name),
          h('td.right', @game.format_currency(company.value)),
          h('td.right', @game.format_currency(company.revenue)),
        ])
      end
    end
  end
end
