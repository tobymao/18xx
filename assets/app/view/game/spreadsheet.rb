# frozen_string_literal: true

require 'lib/color'
require 'lib/settings'
require 'lib/storage'
require 'view/link'
require 'view/game/bank'
require 'view/game/stock_market'
require 'view/game/actionable'

module View
  module Game
    class Spreadsheet < Snabberb::Component
      include Lib::Color
      include Lib::Settings
      include Actionable

      needs :game

      def render
        @spreadsheet_sort_by = Lib::Storage['spreadsheet_sort_by']
        @spreadsheet_sort_order = Lib::Storage['spreadsheet_sort_order']
        @delta_value = Lib::Storage['delta_value']

        @hide_connection_runs = !@game.respond_to?(:connection_runs) || @game.connection_runs.none?

        children = []

        top_line_props = {
          style: {
            display: 'grid',
            grid: 'auto / repeat(auto-fill, minmax(20rem, 1fr))',
            gap: '3rem 1.2rem',
          },
        }
        top_line = h(:div, top_line_props, [
          h(Bank, game: @game),
          h(GameInfo, game: @game, layout: 'upcoming_trains'),
        ])

        children << top_line
        children << render_table
        children << render_spreadsheet_controls

        h('div#spreadsheet', { style: {
          overflow: 'auto',
        } }, children.compact)
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
          h(:thead, [
            h(:tr, { style: { height: '1rem' } }, ''),
          ]),
          *render_player_history,
        ])
        # TODO: consider adding OR information (could do both corporation OR revenue and player change in value)
        # TODO: consider adding train availability
      end

      def or_history(corporations)
        corporations.flat_map { |c| c.operating_history.keys }.uniq.sort
      end

      def render_history_titles(corporations)
        conn = if @hide_connection_runs
                 []
               else
                 [h(:th, ''), h(:th, { attrs: { colSpan: 2 } }, 'Conn')]
               end

        conn.concat(or_history(corporations).map { |turn, round| h(:th, @game.or_description_short(turn, round)) })
      end

      def render_player_history
        # OR history should exist in all
        zebra_row = true
        last_values = nil
        @game.players.first.history.map do |h|
          values = @game.players.map do |p|
            p.history.find { |h2| h2.round == h.round }.value
          end
          next if values == last_values

          delta_v = (last_values || Array.new(values.size, 0)).map(&:-@).zip(values).map(&:sum) if @delta_value
          last_values = values
          zebra_row = !zebra_row
          row_content = values.map.with_index do |v, i|
            disp_value = @delta_value ? delta_v[i] : v
            h('td.padded_number',
              disp_value.negative? ? { style: { color: 'red' } } : {},
              @game.format_currency(disp_value))
          end

          h(:tr, zebra_props(zebra_row), [
            h('th.left', h.round),
            *row_content,
          ])
        end.compact.reverse
      end

      def render_connection_history(corporation)
        if @hide_connection_runs
          []
        elsif @game.connection_runs[corporation]
          round = @game.or_description_short(*@game.connection_runs[corporation][:turn])
          children << h(:td, round)
          children << h(:td, [render_dividend(round, @game.connection_runs[corporation][:info], corporation)])
        else
          children << h(:td, '')
          children << h(:td, '')
        end
      end

      def render_history(corporation)
        hist = corporation.operating_history

        if hist.empty?
          # This is a company that hasn't floated yet
          []
        else
          or_history(@game.all_corporations).map do |x|
            round = @game.or_description_short(*x)

            h(:td, hist[x] ? [render_dividend(round, hist[x], corporation)] : '')
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

        or_history_titles = render_history_titles(@game.all_corporations)

        pd_props = {
          style: {
            background: 'salmon',
            color: 'black',
          },
        }

        extra = []
        extra << h(:th, 'Loans') if @game.total_loans&.nonzero?
        [
          h(:tr, [
            h(:th, ''),
            h(:th, th_props[@game.players.size], 'Players'),
            h(:th, th_props[2, true], 'Bank'),
            h(:th, th_props[2], 'Prices'),
            h(:th, th_props[5 + extra.size, true, false], 'Corporation'),
            h(:th, ''),
            h(:th, th_props[or_history_titles.size, false, false], 'OR History'),
          ]),
          h(:tr, [
            h(:th, { style: { paddingBottom: '0.3rem' } }, render_sort_link('SYM', :id)),
            *@game.players.map do |p|
              h('th.name.nowrap.right', p == @game.priority_deal_player ? pd_props : '', render_sort_link(p.name, p.id))
            end,
            h(:th, @game.ipo_name),
            h(:th, 'Market'),
            h(:th, render_sort_link(@game.ipo_name, :par_price)),
            h(:th, render_sort_link('Market', :share_price)),
            h(:th, render_sort_link('Cash', :cash)),
            h(:th, render_sort_link('Order', :order)),
            h(:th, 'Trains'),
            h(:th, 'Tokens'),
            *extra,
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

      def toggle_delta_value
        Lib::Storage['delta_value'] = !@delta_value
        update
      end

      def render_spreadsheet_controls
        h(:button, { on: { click: -> { toggle_delta_value } } }, "Show #{@delta_value ? 'Total' : 'Delta'} Value")
      end

      def render_corporations
        current_round = @game.turn_round_num

        sorted_corporations.map.with_index do |corp_array, index|
          render_corporation(corp_array[1], corp_array[0], current_round, index)
        end
      end

      def sorted_corporations
        floated_corporations = @game.round.entities

        result = @game.all_corporations.map do |c|
          operating_order = (floated_corporations.find_index(c) || -1) + 1
          [operating_order, c]
        end

        result.sort_by! do |operating_order, corporation|
          case @spreadsheet_sort_by
          when :cash
            corporation.cash
          when :id
            corporation.id
          when :order
            operating_order
          when :par_price
            corporation.par_price&.price || 0
          when :share_price
            corporation.share_price&.price || 0
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
        elsif corporation.share_price&.highlight? &&
          (color = StockMarket::COLOR_MAP[@game.class::STOCKMARKET_COLORS[corporation.share_price.type]])
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

        extra = []
        extra << h(:td, "#{corporation.loans.size}/#{@game.maximum_loans(corporation)}") if @game.total_loans&.nonzero?

        h(:tr, tr_props, [
          h(:th, name_props, corporation.name),
          *@game.players.map do |p|
            sold_props = { style: {} }
            if @game.round.active_step&.did_sell?(corporation, p)
              sold_props[:style][:backgroundColor] = '#9e0000'
              sold_props[:style][:color] = 'white'
            end
            share_holding = corporation.president?(p) ? '*' : ''
            share_holding += num_shares_of(p, corporation).to_s unless corporation.minor?
            h('td.padded_number', sold_props, share_holding)
          end,
          h('td.padded_number', { style: { borderLeft: border_style } }, num_shares_of(corporation, corporation).to_s),
          h('td.padded_number', { style: { borderRight: border_style } },
            "#{corporation.receivership? ? '*' : ''}#{num_shares_of(@game.share_pool, corporation)}"),
          h('td.padded_number', corporation.par_price ? @game.format_currency(corporation.par_price.price) : ''),
          h('td.padded_number', market_props,
            corporation.share_price ? @game.format_currency(corporation.share_price.price) : ''),
          h('td.padded_number', @game.format_currency(corporation.cash)),
          h('td.left', order_props, operating_order_text),
          h(:td, corporation.trains.map(&:name).join(', ')),
          h(:td, "#{corporation.tokens.map { |t| t.used ? 0 : 1 }.sum}/#{corporation.tokens.size}"),
          *extra,
          render_companies(corporation),
          h(:th, name_props, corporation.name),
          *render_connection_history(corporation),
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
          *@game.players.map { |p| h('td.padded_number', @game.format_currency(@game.player_value(p))) },
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
          *@game.players.map do |p|
            h('td.padded_number', @game.all_corporations.sum { |c| c.minor? ? 0 : num_shares_of(p, c) })
          end,
        ])
      end

      def render_player_certs
        cert_limit = @game.cert_limit
        props = { style: { color: 'red' } }
        h(:tr, zebra_props(true), [
          h('th.left', "Certs/#{cert_limit}"),
          *@game.players.map { |player| render_player_cert_count(player, cert_limit, props) },
        ])
      end

      def render_player_cert_count(player, cert_limit, props)
        num_certs = @game.num_certs(player)
        h('td.padded_number', num_certs > cert_limit ? props : '', num_certs)
      end

      def render_dividend(round, info, corporation)
        kind = info.dividend.kind
        revenue = info.revenue.abs.to_s

        props = {
          style: {
            opacity: case kind
                     when 'withhold'
                       '0.5'
                     when 'half'
                       '0.75'
                     else
                       '1.0'
                     end,
            textDecorationLine: kind == 'half' ? 'underline' : '',
            textDecorationStyle: kind == 'half' ? 'dotted' : '',
          },
        }

        if info.dividend&.id&.positive?
          link_h = history_link(revenue,
                                "Go to run #{round} of #{corporation.name}",
                                info.dividend.id - 1)
          h(:span, props, [link_h])
        else
          h(:span, props, revenue)
        end
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

      private

      def num_shares_of(entity, corporation)
        return corporation.president?(entity) ? 1 : 0 if corporation.minor?

        entity.num_shares_of(corporation, ceil: false)
      end
    end
  end
end
