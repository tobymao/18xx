# frozen_string_literal: true

module View
  module Game
    class Player < Snabberb::Component
      needs :player
      needs :game

      def render
        card_style = {
          border: '1px solid gainsboro',
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
        title_style = {
          'background-color': @game.round.can_act?(@player) ? '#9b9' : 'gainsboro',
          color: 'black',
        }

        h('div.player.title', { style: title_style }, @player.name)
      end

      def render_body
        props = {
          style: {
            'margin-top': '1rem',
            'margin-bottom': '0.5rem',
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

        div_props = {
          style: {
            display: 'inline-block',
            margin: '0rem 1rem',
          },
        }

        td_cert_props = {
          style: {
            color: num_certs > cert_limit ? 'red' : 'currentColor',
            'text-align': 'right',
          },
        }

        trs = [
          h(:tr, [
            h(:td, 'Cash'),
            h('td.value', @game.format_currency(@player.cash)),
          ]),
        ]

        if @game.round.auction?
          trs.concat([
            h(:tr, [
              h(:td, 'Committed'),
              h('td.value', @game.format_currency(@game.round.committed_cash(@player))),
            ]),
            h(:tr, [
              h(:td, 'Available'),
              h('td.value', @game.format_currency(@player.cash - @game.round.committed_cash(@player))),
            ]),
          ])
        end

        trs.concat([
          h(:tr, [
            h(:td, 'Value'),
            h('td.value', @game.format_currency(@player.value)),
          ]),
          h(:tr, [
            h(:td, 'Liquidity'),
            h('td.value', @game.format_currency(@game.liquidity(@player))),
          ]),
          h(:tr, [
            h(:td, 'Certs'),
            h('td.value', td_cert_props, "#{num_certs}/#{cert_limit}"),
          ]),
        ])

        if @player == @game.priority_deal_player
          trs << h(:tr, [
            h(:td, { attrs: { colspan: '2' }, style: { 'text-align': 'center' } }, 'Priority Deal'),
          ])
        end

        h(:div, div_props, [
          h(:table, trs),
        ])
      end

      def render_shares
        props = {
          style: {
            'text-align': 'right',
          },
        }

        div_props = {
          style: {
            display: 'inline-block',
            'margin-left': '1rem',
            'margin-right': '1rem',
          },
        }

        shares = @player
          .shares_by_corporation.reject { |_, s| s.empty? }
          .sort_by { |c, s| [s.sum(&:percent), c.president?(@player) ? 1 : 0, c.name] }
          .reverse
          .map { |c, s| render_corporation_shares(c, s) }

        h(:div, div_props, [
          h(:table, props, shares),
        ])
      end

      def render_corporation_shares(corporation, shares)
        logo_props = {
          attrs: {
            src: corporation.logo,
          },
          style: {
            position: 'absolute',
            width: '20px',
            top: '0',
            left: '0',
          },
        }

        logo_td_props = {
          style: {
            position: 'relative',
            width: '20px',
          },
        }

        td_props = {
          style: {
            padding: '0.1rem 0.2rem',
            'text-align': 'left',
          },
        }

        president_marker = corporation.president?(@player) ? '*' : ''
        h(:tr, [
          h(:td, logo_td_props, [h(:img, logo_props)]),
          h(:td, td_props, corporation.name + president_marker),
          h(:td, td_props, "#{shares.sum(&:percent)}%"),
        ])
      end

      def render_companies
        div_props = {
          style: {
            'margin-top': '1rem',
            'margin-bottom': '0.5rem',
            'text-align': 'center',
          },
        }

        props = {
          style: {
            display: 'inline-block',
            'text-align': 'right',
            'margin-left': 'auto',
            'margin-right': 'auto',
          },
        }

        th_props = {
          style: {
            'text-align': 'center',
            padding: '0 0.3rem',
          },
        }

        companies = @player.companies.map do |company|
          render_company(company)
        end

        h(:div, div_props, [
          h(:table, props, [
            h(:tr, [
              h(:th, th_props, 'Company'),
              h(:th, th_props, 'Value'),
              h(:th, th_props, 'Income'),
            ]),
            *companies,
          ]),
        ])
      end

      def render_company(company)
        name_props = {
          style: {
            'max-width': '200px',
            'text-align': 'left',
          },
        }

        td_props = {
          style: {
            padding: '0 0.5rem',
            'text-align': 'right',
          },
        }

        h(:tr, [
          h('td.company.nowrap', name_props, company.name),
          h(:td, td_props, @game.format_currency(company.value)),
          h(:td, td_props, @game.format_currency(company.revenue)),
        ])
      end
    end
  end
end
