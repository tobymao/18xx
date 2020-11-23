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

        @players = @game.players.reject(&:bankrupt)
        @hide_ipo = @game.all_corporations.reject(&:minor?).all?(&:always_market_price)
        @show_corporation_size = @game.all_corporations.any?(&@game.method(:show_corporation_size?))

        children = []
        children << h(Bank, game: @game)
        children << render_table

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
        ])
        # TODO: consider adding OR information (could do both corporation OR revenue and player change in value)
        # TODO: consider adding train availability
      end

      def or_history(corporations)
        corporations.flat_map { |c| c.operating_history.keys }.uniq.sort
      end

      def render_history_titles(corporations)
        or_history(corporations).map { |turn, round| h(:th, @game.or_description_short(turn, round)) }
      end

      def render_history(corporation)
        hist = corporation.operating_history
        if hist.empty?
          # This is a company that hasn't floated yet
          []
        else
          or_history(@game.all_corporations).map do |x|
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
                  textDecorationLine: hist[x].dividend.kind == 'half' ? 'underline' : '',
                  textDecorationStyle: hist[x].dividend.kind == 'half' ? 'dotted' : '',
                  padding: '0 0.15rem',
                },
              }

              if hist[x]&.dividend&.id&.positive?
                link_h = history_link(hist[x].revenue.abs.to_s,
                                      "Go to run #{x} of #{corporation.name}",
                                      hist[x].dividend.id - 1)
                h(:td, props, [link_h])
              else
                h(:td, props, hist[x].revenue.abs.to_s)
              end
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

        or_history_titles = render_history_titles(@game.all_corporations)

        pd_props = {
          style: {
            background: 'salmon',
            color: 'black',
          },
        }

        extra = []
        extra << h(:th, render_sort_link('Loans', :loans)) if @game.total_loans&.nonzero?
        extra << h(:th, render_sort_link('Shorts', :shorts)) if @game.respond_to?(:available_shorts)
        extra << h(:th, render_sort_link('Size', :size)) if @show_corporation_size
        [
          h(:tr, [
            h(:th, ''),
            h(:th, th_props[@players.size], 'Players'),
            h(:th, th_props[2, true], 'Bank'),
            h(:th, th_props[@hide_ipo ? 1 : 2], 'Prices'),
            h(:th, th_props[5 + extra.size, true, false], 'Corporation'),
            h(:th, ''),
            h(:th, th_props[or_history_titles.size, false, false], 'OR History'),
          ]),
          h(:tr, [
            h(:th, { style: { paddingBottom: '0.3rem' } }, render_sort_link('SYM', :id)),
            *@players.map do |p|
              h('th.name.nowrap.right', p == @game.priority_deal_player ? pd_props : '', render_sort_link(p.name, p.id))
            end,
            h(:th, @game.ipo_name),
            h(:th, 'Market'),
            *(@hide_ipo ?
                [h(:th, render_sort_link('Price', :share_price))] :
                [h(:th, render_sort_link(@game.ipo_name, :par_price)),
                  h(:th, render_sort_link('Market', :share_price))]),
            h(:th, render_sort_link('Cash', :cash)),
            h(:th, render_sort_link('Order', :order)),
            h(:th, 'Trains'),
            h(:th, 'Tokens'),
            *extra,
            h(:th, 'Companies'),
            h(:th, ''),
            *or_history_titles,
          ].compact),
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
          render_corporation(*corp_array, current_round, index)
        end
      end

      def sorted_corporations
        floated_corporations = @game.round.entities

        result = @game.all_corporations.reject(&:closed?)
        result = @game.all_corporations.select { |c| c.minor? || c.ipoed }
        result = result.sort.each.with_index.map do |c, order|
          operating_order = (floated_corporations.find_index(c) || -1) + 1
          [c, operating_order, order + 1]
        end

        result = result.map { |c, _, order| [c, order, order] } if result.to_enum.with_object(1).map(&:[]).all?(0)

        result.sort_by! do |corporation, operating_order, order|
          [case @spreadsheet_sort_by
            when :cash
              corporation.cash
            when :id
              corporation.id
            when :order
              (operating_order.positive? ? operating_order : Float::INFINITY)
            when :par_price
              corporation.par_price&.price || 0
            when :share_price
              corporation.share_price&.price || 0
            when :loans
              corporation.loans.size
            when :short
              @game.available_shorts(corporation)
            when :size
              corporation.total_shares
            else
              @game.player_by_id(@spreadsheet_sort_by)&.num_shares_of(corporation)
          end, order]
        end

        result.each(&:pop)

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
        if operating_order.positive?
          operating_order_text = operating_order.to_s
          operating_order_text += '*' if @game.round.has_acted?(corporation)
        end

        extra = []
        extra << h(:td, "#{corporation.loans.size} / #{@game.maximum_loans(corporation)}") if @game.total_loans&.nonzero?
        extra << h(:td, "#{@game.available_shorts(corporation)}") if @game.respond_to?(:available_shorts)
        extra << h(:td, @game.show_corporation_size?(corporation) ? corporation.total_shares.to_s : '') if @show_corporation_size

        h(:tr, tr_props, [
          h(:th, name_props, corporation.name),
          *@players.map do |p|
            sold_props = { style: {} }
            if @game.round.active_step&.did_sell?(corporation, p)
              sold_props[:style][:backgroundColor] = '#9e0000'
              sold_props[:style][:color] = 'white'
            elsif num_shares_of(p, corporation) == 0
              sold_props[:style][:opacity] = '0.5'
            end

            sold_props[:style][:fontWeight] = 'bold' if corporation.president?(p)
            share_holding = num_shares_of(p, corporation).to_s unless corporation.minor?
            share_holding = '*' if corporation.minor? && corporation.president?(p)
            h('td.padded_number', sold_props, share_holding || '')
          end,
          h('td.padded_number', { style: { borderLeft: border_style } }, num_shares_of(corporation, corporation).to_s),
          h('td.padded_number', { style: { borderRight: border_style } },
            "#{corporation.receivership? ? '*' : ''}#{num_shares_of(@game.share_pool, corporation)}"),
          (h('td.padded_number', corporation.par_price ? @game.format_currency(corporation.par_price.price) : '') unless @hide_ipo),
          h('td.padded_number', market_props,
            corporation.share_price ? @game.format_currency(corporation.share_price.price) : ''),
          h('td.padded_number', @game.format_currency(corporation.cash)),
          h('td.left', order_props, operating_order_text),
          h(:td, corporation.trains.map(&:name).join(', ')),
          h(:td, "#{corporation.tokens.map { |t| t.used ? 0 : 1 }.sum} / #{corporation.tokens.size}"),
          *extra,
          render_companies(corporation),
          h(:th, name_props, corporation.name),
          *render_history(corporation),
        ].compact)
      end

      def render_companies(entity)
        h(:td, entity.companies.map(&:sym).join(', '))
      end

      def render_player_companies
        h(:tr, zebra_props, [
          h(:th, 'Companies'),
          *@players.map { |p| render_companies(p) },
        ])
      end

      def render_player_cash
        h(:tr, zebra_props, [
          h('th.left', 'Cash'),
          *@players.map { |p| h('td.padded_number', @game.format_currency(p.cash)) },
        ])
      end

      def render_player_value
        h(:tr, zebra_props(true), [
          h('th.left', 'Value'),
          *@players.map { |p| h('td.padded_number', @game.format_currency(p.value)) },
        ])
      end

      def render_player_liquidity
        h(:tr, zebra_props, [
          h('th.left', 'Liquidity'),
          *@players.map { |p| h('td.padded_number', @game.format_currency(@game.liquidity(p))) },
        ])
      end

      def render_player_shares
        h(:tr, zebra_props(true), [
          h('th.left', 'Shares'),
          *@players.map do |p|
            h('td.padded_number', @game.all_corporations.sum { |c| c.minor? ? 0 : num_shares_of(p, c) })
          end,
        ])
      end

      def render_player_certs
        cert_limit = @game.cert_limit
        props = { style: { color: 'red' } }
        h(:tr, zebra_props(true), [
          h('th.left', "Certs/#{cert_limit}"),
          *@players.map { |player| render_player_cert_count(player, cert_limit, props) },
        ])
      end

      def render_player_cert_count(player, cert_limit, props)
        num_certs = @game.num_certs(player)
        h('td.padded_number', num_certs > cert_limit ? props : '', num_certs)
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
