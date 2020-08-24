# frozen_string_literal: true

require 'lib/color'
require 'lib/settings'
require 'lib/storage'
require 'view/link'
require 'view/game/bank'
require 'view/game/stock_market'

module View
  module Game
    class Spreadsheet < Snabberb::Component
      include Lib::Color
      include Lib::Settings

      needs :game

      def render
        @spreadsheet_sort_by = Lib::Storage['spreadsheet_sort_by']
        @spreadsheet_sort_order = Lib::Storage['spreadsheet_sort_order']

        children = []
        children << h(Bank, game: @game)
        children << render_table

        h('div#spreadsheet', { style: {
          overflow: 'auto',
        } }, children)
      end

      def render_table
        h(:table, { style: {
          margin: '1rem 0 1.5rem 0',
          borderCollapse: 'collapse',
          textAlign: 'center',
          whiteSpace: 'nowrap',
        } }, [
          h(:thead, render_title),
          h(:tbody, render_corporations),
          h(:thead, [
            h(:tr, { style: { height: '1rem' } }, ''),
          ]),
          h(:tbody, [
            render_player_cash,
            render_player_value,
            render_player_liquidity,
            render_player_shares,
            render_player_companies,
            render_player_certs,
          ]),
        ])
        # TODO: consider adding OR information (could do both corporation OR revenue and player change in value)
        # TODO: consider adding train availability
      end

      def or_history(corporations)
        corporations.flat_map { |c| c.operating_history.keys }.uniq.sort
      end

      def render_history_titles(corporations)
        or_history(corporations).map { |turn, round| h(:th, "#{turn}.#{round}") }
      end

      def render_history(corporation)
        hist = corporation.operating_history
        if hist.empty?
          # This is a company that hasn't floated yet
          []
        else
          or_history(@game.corporations).map do |x|
            if hist[x]
              props = {
                style: {
                  opacity: case hist[x].dividend.kind
                           when 'withhold'
                             '0.5'
                           when 'half'
                             '0.75'
                           else
                             '1.0'
                           end,
                  textDecoration: hist[x].dividend.kind == 'half' ? 'underline dotted' : '',
                  padding: '0 0.15rem',
                },
              }
              h(:td, props, hist[x].revenue.abs)
            else
              h(:td, '')
            end
          end
        end
      end

      def render_title
        th_props = lambda do |cols, alt_bg = false, border_right = true|
          props = zebra_props(alt_bg)
          props[:attrs] = { colspan: cols }
          props[:style][:padding] = '0.3rem'
          props[:style][:borderRight] = "1px solid #{color_for(:font2)}" if border_right
          props[:style][:fontSize] = '1.1rem'
          props[:style][:letterSpacing] = '1px'
          props
        end

        or_history_titles = render_history_titles(@game.corporations)

        pd_props = {
          style: {
            background: 'salmon',
            color: 'black',
          },
        }

        [
          h(:tr, [
            h(:th, ''),
            h(:th, th_props[@game.players.size], 'Players'),
            h(:th, th_props[2, true], 'Bank'),
            h(:th, th_props[2], 'Prices'),
            h(:th, th_props[5, true, false], 'Corporation'),
            h(:th, ''),
            h(:th, th_props[or_history_titles.size, false, false], 'OR History'),
          ]),
          h(:tr, [
            h(:th, { style: { paddingBottom: '0.3rem' } }, render_sort_link('SYM', :id)),
            *@game.players.map do |p|
              h('th.name.nowrap.right', p == @game.priority_deal_player ? pd_props : '', render_sort_link(p.name, p.id))
            end,
            h(:th, @game.class::IPO_NAME),
            h(:th, 'Market'),
            h(:th, @game.class::IPO_NAME),
            h(:th, render_sort_link('Market', :share_price)),
            h(:th, render_sort_link('Cash', :cash)),
            h(:th, render_sort_link('Order', :order)),
            h(:th, 'Trains'),
            h(:th, 'Tokens'),
            h(:th, 'Companies'),
            h(:th, ''),
            *or_history_titles,
          ]),
        ]
      end

      def render_sort_link(text, sort_by)
        [
          h(
            Link,
            href: '',
            title: 'Sort',
            click: lambda {
              mark_sort_column(sort_by)
              toggle_sort_order
            },
            children: text,
          ),
          h(:span, @spreadsheet_sort_by == sort_by ? sort_order_icon : ''),
        ]
      end

      def sort_order_icon
        return '↓' if @spreadsheet_sort_order == 'ASC'

        '↑'
      end

      def mark_sort_column(sort_by)
        Lib::Storage['spreadsheet_sort_by'] = sort_by
        update
      end

      def toggle_sort_order
        Lib::Storage['spreadsheet_sort_order'] = @spreadsheet_sort_order == 'ASC' ? 'DESC' : 'ASC'
        update
      end

      def render_corporations
        current_round = @game.turn_round_num

        sorted_corporations.map.with_index do |corp_array, index|
          render_corporation(corp_array[1], corp_array[0], current_round, index)
        end
      end

      def sorted_corporations
        floated_corporations = @game.round.entities

        result = @game.corporations.map do |c|
          operating_order = (floated_corporations.find_index(c) || -1) + 1
          [operating_order, c]
        end

        result.sort_by! do |operating_order, corporation|
          case @spreadsheet_sort_by
          when :order
            operating_order
          when :cash
            corporation.cash
          when :share_price
            corporation.share_price&.price || 0
          when :id
            corporation.id
          else
            @game.player_by_id(@spreadsheet_sort_by)&.num_shares_of(corporation)
          end
        end

        result.reverse! if @spreadsheet_sort_order == 'DESC'
        result
      end

      def render_corporation(corporation, operating_order, current_round, index)
        border_style = "1px solid #{color_for(:font2)}"

        name_props =
          {
            style: {
              background: corporation.color,
              color: corporation.text_color,
            },
        }

        tr_props = zebra_props(index.odd?)
        market_props = { style: { borderRight: border_style } }
        if !corporation.floated?
          tr_props[:style][:opacity] = '0.6'
        elsif !corporation.counts_for_limit && (color = StockMarket::COLOR_MAP[corporation.share_price.color])
          market_props[:style][:backgroundColor] = color
          market_props[:style][:color] = contrast_on(color)
        end

        order_props = { style: { paddingLeft: '1.2em' } }
        operating_order_text = ''
        if operating_order.positive?
          corporation.operating_history.each do |history|
            operating_order_text = "#{operating_order}#{history[0] == current_round ? '*' : ''}"
          end
        end

        h(:tr, tr_props, [
          h(:th, name_props, corporation.name),
          *@game.players.map do |p|
            sold_props = { style: {} }
            if @game.round.active_step&.did_sell?(corporation, p)
              sold_props[:style][:backgroundColor] = '#9e0000'
              sold_props[:style][:color] = 'white'
            end
            h('td.padded_number', sold_props, "#{corporation.president?(p) ? '*' : ''}#{p.num_shares_of(corporation)}")
          end,
          h('td.padded_number', { style: { borderLeft: border_style } }, corporation.num_shares_of(corporation)),
          h('td.padded_number', { style: { borderRight: border_style } },
            "#{corporation.receivership? ? '*' : ''}#{@game.share_pool.num_shares_of(corporation)}"),
          h('td.padded_number', corporation.par_price ? @game.format_currency(corporation.par_price.price) : ''),
          h('td.padded_number', market_props,
            corporation.share_price ? @game.format_currency(corporation.share_price.price) : ''),
          h('td.padded_number', @game.format_currency(corporation.cash)),
          h('td.left', order_props, operating_order_text),
          h(:td, corporation.trains.map(&:name).join(', ')),
          h(:td, "#{corporation.tokens.map { |t| t.used ? 0 : 1 }.sum}/#{corporation.tokens.size}"),
          render_companies(corporation),
          h(:th, name_props, corporation.name),
          *render_history(corporation),
        ])
      end

      def render_companies(entity)
        h(:td, entity.companies.map(&:sym).join(', '))
      end

      def render_player_companies
        h(:tr, zebra_props, [
          h(:th, 'Companies'),
          *@game.players.map { |p| render_companies(p) },
        ])
      end

      def render_player_cash
        h(:tr, zebra_props, [
          h('th.left', 'Cash'),
          *@game.players.map { |p| h('td.padded_number', @game.format_currency(p.cash)) },
        ])
      end

      def render_player_value
        h(:tr, zebra_props(true), [
          h('th.left', 'Value'),
          *@game.players.map { |p| h('td.padded_number', @game.format_currency(p.value)) },
        ])
      end

      def render_player_liquidity
        h(:tr, zebra_props, [
          h('th.left', 'Liquidity'),
          *@game.players.map { |p| h('td.padded_number', @game.format_currency(@game.liquidity(p))) },
        ])
      end

      def render_player_shares
        h(:tr, zebra_props(true), [
          h('th.left', 'Shares'),
          *@game.players.map { |p| h('td.padded_number', @game.corporations.sum { |c| p.num_shares_of(c) }) },
        ])
      end

      def render_player_certs
        cert_limit = @game.cert_limit
        props = { style: { color: 'red' } }
        h(:tr, zebra_props(true), [
          h('th.left', "Certs/#{cert_limit}"),
          *@game.players.map { |p| h('td.padded_number', p.num_certs > cert_limit ? props : '', p.num_certs) },
        ])
      end

      def zebra_props(alt_bg = false)
        factor = Native(`window.matchMedia('(prefers-color-scheme: dark)').matches`) ? 0.9 : 0.5
        {
          style: {
            backgroundColor: alt_bg ? convert_hex_to_rgba(color_for(:bg2), factor) : color_for(:bg2),
            color: color_for(:font2),
          },
        }
      end
    end
  end
end
