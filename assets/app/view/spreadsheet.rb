# frozen_string_literal: true

require 'view/stock_market'
require 'lib/color'

module View
  class Spreadsheet < Snabberb::Component
    needs :game

    def render
      h(:div, { style: {
        overflow: 'auto',
        margin: '0 -1rem'
      } }, [render_table])
    end

    def render_table
      h(:table, { style: {
        margin: '1rem 0 1.5rem 0',
        'text-align': 'center',
      } }, [
        *render_title,
        *render_corporations,
        h(:tr, [
          h(:td, { style: { width: '20px' } }, ''),
          h(:th, { attrs: { colspan: @game.players.size } }, 'Player Finances'),
        ]),
        render_player_cash,
        render_player_privates,
        render_player_worth,
        render_player_certs,
      ])
      # TODO: consider adding OR information (could do both corporation OR revenue and player change in value)
      # TODO: consider adding train availability
    end

    def or_history(corporations)
      corporations.flat_map { |c| c.revenue_history.keys }.uniq.sort
    end

    def render_history_titles(corporations)
      or_history(corporations).map { |turn, round| h(:th, "#{turn}.#{round}") }
    end

    def render_history(corporation)
      hist = corporation.revenue_history
      if hist.empty?
        # This is a company that hasn't floated yet
        []
      else
        or_history(@game.corporations).map do |x|
          if hist[x]
            props = {
              style: {
                color: hist[x].negative? ? '#aaa' : 'black',
                padding: '0 0.15rem'
              }
            }
            h(:td, props, hist[x].abs)
          else
            h(:td, '')
          end
        end
      end
    end

    def render_title
      or_history_titles = render_history_titles(@game.corporations)
      props = { style: { padding: '0 0.3rem' } }

      [
        h(:tr, [
          h(:th, { style: { width: '20px' } }, ''),
          h(:th, { attrs: { colspan: @game.players.size } }, 'Players'),
          h(:th, { attrs: { colspan: 2 } }, 'Bank'),
          h(:th, { attrs: { colspan: 2 } }, 'Prices'),
          h(:th, { attrs: { colspan: 4 } }, 'Corporation'),
          h(:th, { style: { width: '20px' } }, ''),
          h(:th, { attrs: { colspan: or_history_titles.size } }, 'OR History'),
          ]),
        h(:tr, [
          h(:th, { style: { width: '20px' } }, ''),
          *@game.players.map { |p| h(:th, props, p.name) },
          h(:th, props, 'IPO'),
          h(:th, props, 'Market'),
          h(:th, props, 'IPO'),
          h(:th, props, 'Market'),
          h(:th, props, 'Cash'),
          h(:th, props, 'Trains'),
          h(:th, props, 'Tokens'),
          h(:th, props, 'Privates'),
          h(:th, { style: { width: '20px' } }, ''),
          *or_history_titles
        ])
      ]
    end

    def render_corporations
      @game.corporations.map { |c| render_corporation(c) }
    end

    def render_corporation(corporation)
      corporation_color =
        {
          style: {
            background: corporation.color,
            color: '#ffffff'
          }
        }

      props = { style: {} }
      market_props = { style: {} }

      if !corporation.floated?
        props[:style]['background-color'] = 'rgba(220,220,220,0.4)'
      elsif !corporation.counts_for_limit && (color = StockMarket::COLOR_MAP[corporation.share_price.color])
        market_props[:style]['background-color'] = Lib::Color.convert_hex_to_rgba(color, 0.4)
      end

      h(:tr, props, [
        h(:th, corporation_color, corporation.name),
        *@game.players.map do |p|
          sold_props = { style: {} }
          sold_props[:style]['background-color'] = 'rgba(225,0,0,0.4)' if @game.round.did_sell?(corporation, p)
          h(:td, sold_props, p.num_shares_of(corporation).to_s + (corporation.president?(p) ? '*' : ''))
        end,
        h(:td, corporation.num_shares_of(corporation)),
        h(:td, @game.share_pool.num_shares_of(corporation)),
        h(:td, corporation.par_price ? @game.format_currency(corporation.par_price.price) : ''),
        h(:td, market_props, corporation.share_price ? @game.format_currency(corporation.share_price.price) : ''),
        h(:td, @game.format_currency(corporation.cash)),
        h(:td, corporation.trains.map(&:name).join(',')),
        h(:td, "#{corporation.tokens.map { |t| t.used? ? 0 : 1 }.sum}/#{corporation.tokens.size}"),
        render_companies(corporation),
        h(:th, corporation_color, corporation.name),
        *render_history(corporation)
      ])
    end

    def render_companies(entity)
      h(:td, entity.companies.map(&:short_name).join(','))
    end

    def render_player_privates
      h(:tr, [
        h(:th, 'Privates'),
        *@game.players.map { |p| render_companies(p) }
      ])
    end

    def render_player_cash
      h(:tr, [
        h(:th, 'Cash'),
        *@game.players.map { |p| h(:td, @game.format_currency(p.cash)) }
      ])
    end

    def render_player_worth
      h(:tr, [
        h(:th, 'Worth'),
        *@game.players.map { |p| h(:td, @game.format_currency(p.value)) }
      ])
    end

    def render_player_certs
      h(:tr, [
        h(:th, 'Certs'),
        *@game.players.map { |p| h(:td, p.num_certs) }
      ])
    end
  end
end
