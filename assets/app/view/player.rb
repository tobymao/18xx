# frozen_string_literal: true

module View
  class Player < Snabberb::Component
    needs :player
    needs :game

    def render
      card_style = {
        display: 'inline-block',
        position: 'relative',
        border: 'solid 1px gainsboro',
        padding: '0.5rem',
        margin: '0.5rem 0.5rem 0 0',
        width: '320px',
        'vertical-align': 'top',
      }

      if @game.round.can_act?(@player)
        card_style['border'] = 'solid 1px black'
        card_style['background-color'] = '#dfd'
      end

      h(:div, { style: card_style }, [
        render_header,
        render_body,
      ])
    end

    def render_header
      header_style = {
         margin: '-0.5em',
         'text-align': 'center',
         'white-space': 'nowrap',
         'background-color': 'lightgray',
      }

      header_style['background-color'] = '#9b9' if @game.round.can_act?(@player)

      h(:div, { style: header_style }, [
        render_header_segment(@player.name, 'Player'),
        render_header_segment(order_number, 'Order'),
        render_header_segment(@game.format_currency(@player.cash), 'Cash'),
        render_header_segment(@game.format_currency(@player.value), 'Value'),
        render_header_segment("#{@player.num_certs}/#{@game.cert_limit}", 'Certs'),
      ])
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

    def order_number
      number = @game.players.find_index(@player) + 1
      return '1st' if number == 1
      return '2nd' if number == 2
      return '3rd' if number == 3

      number.to_s + 'th'
    end

    def render_body
      props = {
        style: {
          'margin-top': '1rem',
        },
      }

      h(:div, props, [
        render_shares,
        render_companies,
      ])
    end

    def render_shares
      shares = @player
        .shares_by_corporation.reject { |_, s| s.empty? }
        .sort_by { |c, s| [s.sum(&:percent), c.president?(@player) ? 1 : 0, c.name] }
        .reverse
        .map { |c, s| render_corporation_shares(c, s) }

      props = {
        style: {
          display: 'inline-block',
          'text-align': 'right',
        }
      }

      h(:table, props, [
        h(:tr, [
          h(:th, { style: { width: '20px' } }, ''),
          h(:th, 'Corp'),
          h(:th, 'Share'),
        ]),
        *shares
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

      president_marker = corporation.president?(@player) ? '*' : ''

      h(:tr, [
        h(:td, { style: { position: 'relative' } }, [h(:img, logo_props)]),
        h(:td, corporation.name + president_marker),
        h(:td, "#{shares.sum(&:percent)}%"),
      ])
    end

    def render_companies
      props = {
        style: {
          display: 'inline-block',
          float: 'right',
          'text-align': 'right',
        }
      }

      companies = @player.companies.map do |company|
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
          'max-width': '30px',
          'white-space': 'nowrap',
          'text-overflow': 'ellipsis',
        }
      }

      h(:tr, [
        h(:td, name_props, company.name),
        h(:td, @game.format_currency(company.value)),
        h(:td, @game.format_currency(company.revenue)),
      ])
    end
  end
end
