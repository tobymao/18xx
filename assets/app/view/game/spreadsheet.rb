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
        ].compact)

        children << top_line
        children << render_table
        children << render_spreadsheet_controls

        h('div#spreadsheet', {
            style: {
              overflow: 'auto',
            },
          }, children.compact)
      end

      def render_table
        h(:table, {
            style: {
              margin: '1rem 0 0.5rem 0',
              borderCollapse: 'collapse',
              textAlign: 'center',
              whiteSpace: 'nowrap',
            },
          }, [
          h(:thead, render_title),
          h(:tbody, render_corporations),
          h(:thead, [
            h(:tr, { style: { height: '1rem' } }, [
              h(:td, { attrs: { colspan: @game.players.size + 8 } }, ''),
              h(:td, { attrs: { colspan: 2 } }, @game.respond_to?(:token_note) ? @game.token_note : ''),
              h(:td, { attrs: { colspan: 1 + @extra_size } }, ''),
              h(:td, { attrs: { colspan: @halfpaid ? 6 : 3 } }, "[withheld]#{' ¦half-paid¦' if @halfpaid}"),
            ]),
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
          h(:tbody, [*render_player_history]),
        ])
        # TODO: consider adding OR information (could do both corporation OR revenue and player change in value)
        # TODO: consider adding train availability
      end

      def or_history(corporations)
        corporations.flat_map { |c| c.operating_history.keys }.uniq.sort
      end

      def render_history_titles(corporations)
        or_history(corporations).map do |turn, round|
          h(:th, render_sort_link(@game.or_description_short(turn, round), [turn, round]))
        end
      end

      def render_player_history
        # OR history should exist in all
        last_values = nil
        @game.players.first.history.map do |h|
          values = @game.players.map do |p|
            p.history.find { |h2| h2.round == h.round }.value
          end
          next if values == last_values

          delta_v = (last_values || Array.new(values.size, 0)).map(&:-@).zip(values).map(&:sum) if @delta_value
          last_values = values
          row_content = values.map.with_index do |v, i|
            disp_value = @delta_value ? delta_v[i] : v
            h('td.padded_number',
              disp_value.negative? ? { style: { color: 'red' } } : {},
              @game.format_currency(disp_value))
          end

          h(:tr, tr_default_props, [
            h('th.left', h.round),
            *row_content,
          ])
        end.compact.reverse
      end

      def render_history(corporation)
        hist = corporation.operating_history
        if hist.empty?
          # This is a company that hasn't floated yet
          []
        else
          or_history(@game.all_corporations).map do |x|
            render_or_history_row(hist, corporation, x)
          end
        end
      end

      def render_or_history_row(hist, corporation, x)
        if hist[x]
          revenue_text, alpha =
            case (hist[x].dividend.is_a?(Engine::Action::Dividend) ? hist[x].dividend.kind : 'withhold')
            when 'withhold'
              ["[#{hist[x].revenue}]", '0.5']
            when 'half'
              ["¦#{hist[x].revenue}¦", '0.75']
            else
              [hist[x].revenue.to_s, '1.0']
            end

          props = {
            style: {
              color: convert_hex_to_rgba(color_for(:font2), alpha),
              padding: '0 0.15rem',
            },
          }

          if hist[x]&.dividend&.id&.positive?
            link_h = history_link(revenue_text,
                                  "Go to run #{x} of #{corporation.name}",
                                  hist[x].dividend.id - 1,
                                  { textDecoration: 'none' })
            h(:td, props, [link_h])
          else
            h(:td, props, revenue_text)
          end
        else
          h(:td, '')
        end
      end

      def render_title
        th_props = lambda do |cols, border_right = true|
          props = tr_default_props
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
            backgroundColor: 'salmon',
            color: 'black',
          },
        }

        extra = []
        extra << h(:th, render_sort_link('Loans', :loans)) if @game.total_loans&.nonzero?
        extra << h(:th, render_sort_link('Shorts', :shorts)) if @game.respond_to?(:available_shorts)
        if @game.total_loans.positive?
          extra << h(:th, render_sort_link('Buying Power', :buying_power))
          extra << h(:th, render_sort_link('Interest Due', :interest))
        end
        @extra_size = extra.size
        [
          h(:tr, [
            h(:th, ''),
            h(:th, th_props[@game.players.size], 'Players'),
            h(:th, th_props[2], 'Bank'),
            h(:th, th_props[2], 'Prices'),
            h(:th, th_props[5 + extra.size, false], 'Corporation'),
            h(:th, ''),
            h(:th, th_props[or_history_titles.size, false], 'OR History'),
          ]),
          h(:tr, [
            h(:th, { style: { paddingBottom: '0.3rem' } }, render_sort_link('SYM', :id)),
            *@game.players.map do |p|
              h('th.name.nowrap.right', p == @game.priority_deal_player ? pd_props : '', render_sort_link(p.name, p.id))
            end,
            h(:th, render_sort_link(@game.ipo_name, :ipo_shares)),
            h(:th, render_sort_link('Market', :market_shares)),
            h(:th, render_sort_link(@game.ipo_name, :par_price)),
            h(:th, render_sort_link('Market', :share_price)),
            h(:th, render_sort_link('Cash', :cash)),
            h(:th, render_sort_link('Order', :order)),
            h(:th, render_sort_link('Trains', :trains)),
            h(:th, render_sort_link('Tokens', :tokens)),
            *extra,
            h(:th, render_sort_link('Companies', :companies)),
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
        h(:button, {
            style: { minWidth: '9.5rem' },
            on: { click: -> { toggle_delta_value } },
          },
          "Show #{@delta_value ? 'Total' : 'Delta'} Values")
      end

      def render_corporations
        current_round = @game.turn_round_num

        sorted_corporations.map do |corp_array|
          render_corporation(corp_array[1], corp_array[0], current_round)
        end
      end

      def sorted_corporations
        operating_corporations =
          if @game.round.operating?
            @game.round.entities
          else
            @game.operating_order
          end

        result = @game.all_corporations.map do |c|
          operating_order = (operating_corporations.find_index(c) || -1) + 1
          [operating_order, c]
        end

        result.sort_by! do |operating_order, corporation|
          if @spreadsheet_sort_by.is_a?(Array)
            corporation.operating_history[@spreadsheet_sort_by]&.revenue || -1
          else
            case @spreadsheet_sort_by
            when :id
              corporation.id
            when :ipo_shares
              num_shares_of(corporation, corporation)
            when :market_shares
              num_shares_of(@game.share_pool, corporation)
            when :share_price
              [corporation.share_price&.price || 0, -operating_order]
            when :par_price
              corporation.par_price&.price || 0
            when :cash
              corporation.cash
            when :order
              operating_order
            when :trains
              corporation.floated? ? corporation.trains.size : -1
            when :tokens
              @game.count_available_tokens(corporation)
            when :loans
              corporation.loans.size
            when :shorts
              @game.available_shorts(corporation) if @game.respond_to?(:available_shorts)
            when :buying_power
              @game.buying_power(corporation, full: true)
            when :interest
              @game.interest_owed(corporation) if @game.total_loans.positive?
            when :companies
              corporation.companies.size
            else
              @game.player_by_id(@spreadsheet_sort_by)&.num_shares_of(corporation)
            end
          end
        end

        result.reverse! if @spreadsheet_sort_order == 'DESC'
        result
      end

      def render_corporation(corporation, operating_order, current_round)
        border_style = "1px solid #{color_for(:font2)}"

        name_props =
          {
            style: {
              backgroundColor: corporation.color,
              color: corporation.text_color,
            },
          }

        tr_props = tr_default_props
        market_props = { style: { borderRight: border_style } }
        if !corporation.floated?
          tr_props[:style][:opacity] = '0.6'
        elsif corporation.share_price&.highlight? &&
          (color = StockMarket::COLOR_MAP[@game.class::STOCKMARKET_COLORS[corporation.share_price.type]])
          market_props[:style][:backgroundColor] = color
          market_props[:style][:color] = contrast_on(color)
        end

        order_props = { style: { paddingLeft: '1.2em' } }
        operating_order_text = "#{operating_order}#{corporation.operating_history.keys[-1] == current_round ? '*' : ''}"

        extra = []
        extra << h(:td, "#{corporation.loans.size}/#{@game.maximum_loans(corporation)}") if @game.total_loans&.nonzero?
        if @game.respond_to?(:available_shorts)
          taken, total = @game.available_shorts(corporation)
          extra << h(:td, "#{taken} / #{total}")
        end
        if @game.total_loans.positive?
          extra << h(:td, @game.format_currency(@game.buying_power(corporation, full: true)))
          interest_props = { style: {} }
          unless @game.can_pay_interest?(corporation)
            color = StockMarket::COLOR_MAP[:yellow]
            interest_props[:style][:backgroundColor] = color
            interest_props[:style][:color] = contrast_on(color)
          end
          extra << h(:td, interest_props, @game.format_currency(@game.interest_owed(corporation)).to_s)
        end

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
          h(:td, @game.token_string(corporation)),
          *extra,
          render_companies(corporation),
          h(:th, name_props, corporation.name),
          *render_history(corporation),
        ])
      end

      def render_companies(entity)
        h('td.padded_number', entity.companies.map(&:sym).join(', '))
      end

      def render_player_companies
        h(:tr, tr_default_props, [
          h('th.left', 'Companies'),
          *@game.players.map { |p| render_companies(p) },
        ])
      end

      def render_player_cash
        h(:tr, tr_default_props, [
          h('th.left', 'Cash'),
          *@game.players.map { |p| h('td.padded_number', @game.format_currency(p.cash)) },
        ])
      end

      def render_player_value
        h(:tr, tr_default_props, [
          h('th.left', 'Value'),
          *@game.players.map { |p| h('td.padded_number', @game.format_currency(@game.player_value(p))) },
        ])
      end

      def render_player_liquidity
        h(:tr, tr_default_props, [
          h('th.left', 'Liquidity'),
          *@game.players.map { |p| h('td.padded_number', @game.format_currency(@game.liquidity(p))) },
        ])
      end

      def render_player_shares
        h(:tr, tr_default_props, [
          h('th.left', 'Shares'),
          *@game.players.map do |p|
            h('td.padded_number', @game.all_corporations.sum { |c| c.minor? ? 0 : num_shares_of(p, c) })
          end,
        ])
      end

      def render_player_certs
        cert_limit = @game.cert_limit
        props = { style: { color: 'red' } }
        h(:tr, tr_default_props, [
          h('th.left', 'Certs' + (@game.show_game_cert_limit? ? "/#{cert_limit}" : '')),
          *@game.players.map { |player| render_player_cert_count(player, cert_limit, props) },
        ])
      end

      def render_player_cert_count(player, cert_limit, props)
        num_certs = @game.num_certs(player)
        h('td.padded_number', num_certs > cert_limit ? props : '', num_certs)
      end

      def tr_default_props
        {
          style: {
            backgroundColor: color_for(:bg2),
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
