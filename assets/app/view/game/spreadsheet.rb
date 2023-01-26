# frozen_string_literal: true

require 'lib/settings'
require 'lib/storage'
require 'view/link'
require 'view/share_calculation'
require 'view/game/bank'
require 'view/game/stock_market'
require 'view/game/tranches'
require 'view/game/actionable'
require 'lib/truncate'

FLOATED = 2
UNFLOATED = 1
UNSTARTED = 0

module View
  module Game
    class Spreadsheet < Snabberb::Component
      include Lib::Settings
      include Actionable
      include View::ShareCalculation

      needs :game

      PLAYER_COL_MAX_WIDTH = '4.5rem'

      def render
        @spreadsheet_sort_by = Lib::Storage['spreadsheet_sort_by']
        @spreadsheet_sort_order = Lib::Storage['spreadsheet_sort_order']
        @delta_value = Lib::Storage['spreadsheet_delta_value']
        @hide_not_floated = Lib::Storage['spreadsheet_hide_not_floated']

        h('div#spreadsheet', {
            style: {
              overflow: 'auto',
              marginTop: '1rem',
            },
          },
          [render_corporation_table, render_player_table, render_extra_cards])
      end

      def render_corporation_table
        h('div#corporation_table', [
          h(:table, table_props, [
            h(:thead, render_titles),
            h(:tbody, render_corporations),
            h(:tfoot, [
              h(:tr, { style: { height: '1rem' } }, [
                h(:td, { attrs: { colspan: @game.players.size + 8 } }, ''),
                h(:td, { attrs: { colspan: 2 } }, @game.respond_to?(:token_note) ? @game.token_note : ''),
                h(:td, { attrs: { colspan: 1 + @extra_size } }, ''),
                h(:td, { attrs: { colspan: @halfpaid ? 6 : 3 } }, "[withheld]#{' ¦half-paid¦' if @halfpaid}"),
              ]),
            ]),
          ]),
        ])
      end

      def render_player_table
        h('div#player_table', { style: { float: 'left', marginRight: '1rem' } }, [
          h(:table, table_props, [
            h(:thead),
            h('tbody#player_details', [
              render_player_cash,
              render_player_value,
              render_player_liquidity,
              render_player_shares,
              render_player_companies,
              render_player_certs,
            ]),
            h(:thead, [
              h(:th, { style: { minWidth: '5rem' } }, ''),
              *@game.players.map do |p|
                h('th.name.nowrap', p == @game.priority_deal_player ? pd_props : '', p.name)
              end,
            ]),
            h('tbody#player_or_history', [*render_player_or_history]),
          ]),
          render_spreadsheet_controls,
        ])
      end

      def render_extra_cards
        children = []
        children << h(Bank, game: @game)
        children << h(Tranches, game: @game) if @game.respond_to?(:tranches)
        children << h(GameInfo, game: @game, layout: 'upcoming_trains')
        h('div#extra_cards', { style: { marginBottom: '1rem' } }, children.compact)
      end

      def or_history(corporations)
        corporations.flat_map { |c| c.operating_history.keys }.uniq.sort
      end

      def render_history_titles(corporations)
        or_history(corporations).map do |turn, round|
          h(:th, render_sort_link(@game.or_description_short(turn, round), [turn, round]))
        end
      end

      def render_player_or_history
        # OR history should exist in all
        last_values = nil
        @game.players.first.history.map do |h|
          values = @game.players.map do |p|
            p.history.find { |h2| h2.round == h.round }.value
          end

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
        or_history(@game.all_corporations).map do |turn, round|
          if (op_history = corporation.operating_history[[turn, round]])
            revenue_text, alpha =
              case op_history.dividend_kind
              when 'withhold'
                ["[#{op_history.revenue}]", 0.5]
              when 'half'
                @halfpaid = true
                ["¦#{op_history.revenue}¦", 0.75]
              else
                [op_history.revenue.to_s, 1]
              end

            props = {
              style: {
                color: convert_hex_to_rgba(color_for(:font2), alpha),
              },
            }

            if op_history&.dividend&.id&.positive?
              link_h = history_link(revenue_text,
                                    "Go to run #{@game.or_description_short(turn, round)} of #{corporation.name}",
                                    op_history.dividend.id - 1)
              h('td.right', props, [link_h])
            else
              h('td.right', props, revenue_text)
            end
          else
            h(:td, '')
          end
        end
      end

      def render_connection_run(corporation)
        return [] unless @game.respond_to?(:connection_run)
        return [h(:td)] unless @game.connection_run[corporation]

        turn, round, c_run = @game.connection_run[corporation]
        revenue_text, alpha = c_run.dividend.kind == 'withhold' ? ["[#{c_run.revenue}]", 0.5] : [c_run.revenue, 1]
        props = {
          style: {
            color: convert_hex_to_rgba(color_for(:font2), alpha),
          },
        }
        link_h = history_link(
          "#{@game.or_description_short(turn, round)}: #{revenue_text}",
          "Go to connection run of #{corporation.name} (in #{@game.or_description_short(turn, round)})",
          c_run.dividend.id - 1
        )

        [h('td.right', props, [link_h])]
      end

      def render_titles
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

        treasury = []
        treasury << h(:th, render_sort_link('Shares', :treasury)) if @game.separate_treasury?

        extra = []
        if @game.respond_to?(:capitalization_type_desc)
          extra << h(:th, render_sort_link('Capitalization', :capitalization_type_desc))
        end
        extra << h(:th, render_sort_link('Loans', :loans)) if @game.total_loans&.nonzero?
        extra << h(:th, render_sort_link('Shorts', :shorts)) if @game.respond_to?(:available_shorts)
        if @game.total_loans.positive?
          extra << h(:th, render_sort_link('Buying Power', :buying_power))
          extra << h(:th, render_sort_link('Interest Due', :interest)) if @game.corporation_show_interest?
        end
        if (@diff_corp_sizes = @game.all_corporations.any? { |c| @game.corporation_size(c) != :small })
          extra << h(:th, render_sort_link('Size', :corp_size))
        end
        @extra_size = extra.size

        connection_run_header = @game.respond_to?(:connection_run) ? [h(:th, th_props[1, false], '')] : []
        connection_run_subheader = @game.respond_to?(:connection_run) ? [h(:th, render_sort_link('C-Run', :c_run))] : []
        bank_width = 2
        reserved_header = []
        if any_reserved_shares?
          bank_width += 1
          reserved_header << h(:th, render_sort_link(@game.ipo_reserved_name, :reserved_shares))
        end

        corporation_props_size = 5 + extra.size + treasury.size

        players_title = h(:th, th_props[@game.players.size], 'Players')
        bank_title = h(:th, th_props[bank_width], 'Bank')
        prices_title = h(:th, th_props[2], 'Prices')
        corporation_title = h(:th, th_props[corporation_props_size, false], ['Corporation ', render_toggle_not_floated_link])

        subtitles = []
        players_subtitles = []
        @game.players.map do |p|
          props = p == @game.priority_deal_player ? pd_props : { style: {} }
          props[:style][:minWidth] = min_width(p)
          players_subtitles << h('th.name.nowrap', props, render_sort_link(p.name, p.id))
        end
        bank_subtitles = [
          *reserved_header,
          h(:th, render_sort_link(@game.ipo_name, :ipo_shares)),
          h(:th, render_sort_link('Market', :market_shares)),
        ]
        prices_subtitles = [
          h(:th, render_sort_link(@game.ipo_name, :par_price)),
          h(:th, render_sort_link('Market', :share_price)),
        ]
        corporation_subtitles = [
          h(:th, render_sort_link('Cash', :cash)),
          *treasury,
          h(:th, render_sort_link('Trains', :trains)),
          h(:th, render_sort_link('Tokens', :tokens)),
          *extra,
          h(:th, render_sort_link('Order', :order)),
          h(:th, render_sort_link('Companies', :companies)),
        ]

        titles = [
          players_title,
          bank_title,
          prices_title,
          corporation_title,
        ]
        subtitles.concat(players_subtitles)
        subtitles.concat(bank_subtitles)
        subtitles.concat(prices_subtitles)
        subtitles.concat(corporation_subtitles)

        [
          h(:tr, [
            h(:th, { style: { minWidth: '5rem' } }, ''),
            *titles,
            h(:th, ''),
            *connection_run_header,
            h(:th, th_props[or_history_titles.size, false], 'OR History'),
          ]),
          h(:tr, [
            h(:th, { style: { paddingBottom: '0.3rem' } }, render_sort_link('SYM', :id)),
            *subtitles,
            h(:th, ''),
            *connection_run_subheader,
            *or_history_titles,
          ]),
        ]
      end

      def render_sort_link(text, sort_by)
        [
          h(:span, @spreadsheet_sort_by == sort_by ? sort_order_icon : ''),
          h(
            Link,
            href: '',
            title: 'Sort',
            click: lambda {
              mark_sort_column(sort_by)
              toggle_sort_order if @spreadsheet_sort_by == sort_by
            },
            children: text,
          ),
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
        Lib::Storage['spreadsheet_delta_value'] = !@delta_value
        update
      end

      def render_toggle_not_floated_link
        toggle = lambda do
          Lib::Storage['spreadsheet_hide_not_floated'] = !@hide_not_floated
          update
        end

        h('span.small_font', [
          '(',
          h(:a,
            {
              attrs: {
                onclick: 'return false',
                title: @hide_not_floated ? 'Show all corporations' : 'Hide not floated corporations',
              },
              on: { click: toggle },
              style: {
                cursor: 'pointer',
                textDecoration: 'underline',
              },
            },
            @hide_not_floated ? 'Show unfloated' : 'Hide unfloated'),
          ')',
         ])
      end

      def render_spreadsheet_controls
        h('div#spreadsheet_controls', { style: { marginBottom: '1rem' } }, [
          h(:button, {
              style: { minWidth: '9.5rem' },
              on: { click: -> { toggle_delta_value } },
            },
            "Show #{@delta_value ? 'Total' : 'Delta'} Values"),
        ])
      end

      def render_corporations
        current_round = @game.turn_round_num

        sorted_corporations.map do |corp_array|
          render_corporation(corp_array[1], corp_array[0], current_round)
        end
      end

      def sorted_corporations
        operating_array =
          if @game.round.operating?
            @game.round.entities
          else
            @game.operating_order
          end
        operating_corporations = operating_array.each_with_index.to_h

        unfloated_corporations =
          (@game.all_corporations - operating_array)
            .select { |c| c.respond_to?(:sort_order_key) && c.sort_order_key }
            .sort
            .each_with_index.to_h

        result = @game.all_corporations.map do |c|
          operating_order =
            if (index = operating_corporations[c])
              [FLOATED, index + 1]
            elsif (index = unfloated_corporations[c])
              [UNFLOATED, index + 1]
            else
              [UNSTARTED, 0]
            end
          [operating_order, c]
        end

        result.sort_by! do |operating_order, corporation|
          if @spreadsheet_sort_by.is_a?(Array)
            corporation.operating_history[@spreadsheet_sort_by]&.revenue || -1
          else
            case @spreadsheet_sort_by
            when :id
              if /^\d+$/.match?(corporation.id)
                [2, corporation.id.to_i]
              else
                [1, corporation.id]
              end
            when :reserved_shares
              num_reserved_shares(corporation)
            when :ipo_shares
              num_ipo_shares(corporation)
            when :market_shares
              num_shares_of(@game.share_pool, corporation)
            when :share_price
              [corporation.share_price&.price || 0, operating_order[0], -operating_order[1]]
            when :par_price
              corporation.par_price&.price || 0
            when :cash
              corporation.cash
            when :treasury
              num_shares_of(corporation, corporation)
            when :order
              operating_order
            when :trains
              ct = corporation.trains.sort_by(&:name).reverse
              train_limit = @game.phase.train_limit(corporation)
              corporation.floated? ? [ct.size, [Array.new(train_limit) { |i| ct[i]&.name }]] : [-1, []]
            when :tokens
              @game.count_available_tokens(corporation)
            when :capitalization_type_desc
              @game.capitalization_type_desc(corporation) if @game.respond_to?(:capitalization_type_desc)
            when :loans
              corporation.loans.size
            when :shorts
              @game.available_shorts(corporation) if @game.respond_to?(:available_shorts)
            when :buying_power
              @game.buying_power(corporation, full: true)
            when :interest
              @game.interest_owed(corporation) if @game.total_loans.positive?
            when :corp_size
              @game.corporation_size(corporation)
            when :companies
              corporation.companies.size
            when :c_run
              if @game.respond_to?(:connection_run)
                _turn, _round, c_run = @game.connection_run[corporation]
                c_run&.revenue || 0
              end
            else
              p = @game.player_by_id(@spreadsheet_sort_by)
              n = p&.num_shares_of(corporation)
              n += 0.01 if corporation.president?(p)
              n.nil? || n.zero? ? -99 : n # sort shorts between longs and 0 shares
            end
          end
        end

        result.reverse! if @spreadsheet_sort_order == 'DESC'
        result
      end

      def render_corporation(corporation, operating_order, current_round)
        return '' if @hide_not_floated && !@game.operating_order.include?(corporation)

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
        if !@game.operating_order.include?(corporation)
          tr_props[:style][:opacity] = '0.5'
        elsif corporation.share_price&.highlight? &&
          (color = StockMarket::COLOR_MAP[@game.class::STOCKMARKET_COLORS[corporation.share_price.type]])
          market_props[:style][:backgroundColor] = color
          market_props[:style][:color] = contrast_on(color)
        end

        order_props = { style: { paddingLeft: '1.2em' } }
        order_props[:style][:color] =
          if operating_order[0] == UNSTARTED
            'transparent'
          elsif corporation.operating_history.keys[-1] == current_round
            convert_hex_to_rgba(color_for(:font2), 0.5)
          end

        treasury = []
        treasury << h(:td, num_shares_of(corporation, corporation)) if @game.separate_treasury?

        reserved = []
        if any_reserved_shares?
          reserved << h('td.padded_number', {
                          style: {
                            borderLeft: border_style,
                            color: num_reserved_shares(corporation).zero? ? 'transparent' : 'inherit',
                          },
                        },
                        num_reserved_shares(corporation))
        end

        extra = []
        extra << h(:td, @game.capitalization_type_desc(corporation)) if @game.respond_to?(:capitalization_type_desc)
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
          if @game.corporation_show_interest?
            extra << h(:td, interest_props,
                       @game.format_currency(@game.interest_owed(corporation)).to_s)
          end
        end
        extra << h(:td, @game.corporation_size_name(corporation)) if @diff_corp_sizes

        n_ipo_shares = num_ipo_shares(corporation)
        n_market_shares = num_shares_of(@game.share_pool, corporation)

        players_row_content = []
        @game.players.map do |p|
          props = { style: {} }
          if @game.round.active_step&.did_sell?(corporation, p)
            props[:style][:backgroundColor] = '#9e0000'
            props[:style][:color] = 'white'
          end
          n_shares = num_shares_of(p, corporation)
          props[:style][:color] = 'transparent' if n_shares.zero?
          share_holding = corporation.president?(p) ? '*' : ''
          share_holding += n_shares.to_s unless corporation.minor?
          players_row_content << h('td.padded_number', props, share_holding)
        end

        bank_market_props = { style: { color: n_market_shares.zero? ? 'transparent' : 'inherit', borderRight: border_style } }
        bank_row_content = [
          *reserved,
          h('td.padded_number', {
              style: {
                borderLeft: any_reserved_shares? ? '0px' : border_style,
                color: n_ipo_shares.zero? ? 'transparent' : 'inherit',
              },
            },
            n_ipo_shares),
          h('td.padded_number', bank_market_props,
            "#{corporation.receivership? ? '*' : ''}#{n_market_shares}"),
        ]

        prices_row_content = [
          h('td.padded_number', corporation.par_price ? @game.format_currency(corporation.par_price.price) : ''),
          h('td.padded_number', market_props,
            corporation.share_price ? @game.format_currency(corporation.share_price.price) : ''),
        ]

        corporation_row_content = [
          h('td.padded_number', @game.format_currency(corporation.cash)),
          *treasury,
          h(:td, corporation.trains.map { |t| t.obsolete ? "(#{t.name})" : t.name }.join(', ')),
          h(:td, @game.token_string(corporation)),
          *extra,
          h('td.padded_number', order_props, if operating_order[0] == UNFLOATED
                                               "[#{operating_order[1]}]"
                                             else
                                               operating_order[1]
                                             end),
          render_companies(corporation),
        ]

        row_content = []
        row_content.concat(players_row_content)
        row_content.concat(bank_row_content)
        row_content.concat(prices_row_content)
        row_content.concat(corporation_row_content)

        h(:tr, tr_props, [
          h(:th, name_props, corporation.name),
          *row_content,
          h(:th, name_props, corporation.name),
          *render_connection_run(corporation),
          *render_history(corporation),
        ])
      end

      def render_companies(entity)
        if entity.player?
          props = {
            style: {
              maxWidth: PLAYER_COL_MAX_WIDTH,
              whiteSpace: 'normal',
              textAlign: 'right',
            },
          }
          props[:style][:minWidth] = min_width(entity)
        end
        h(:td, props, entity.companies.map(&:sym).join(', '))
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

      def table_props
        {
          style: {
            borderCollapse: 'collapse',
            textAlign: 'center',
            whiteSpace: 'nowrap',
          },
        }
      end

      def pd_props
        {
          style: {
            backgroundColor: 'salmon',
            color: 'black',
          },
        }
      end

      private

      def num_ipo_shares(corporation)
        num_shares_of(@game.separate_treasury? ? @game.bank : corporation, corporation) - num_reserved_shares(corporation)
      end

      def num_reserved_shares(corporation)
        return 0 unless corporation.respond_to?(:num_ipo_reserved_shares)

        corporation.num_ipo_reserved_shares
      end

      def any_reserved_shares?
        @game.all_corporations.any? { |c| num_reserved_shares(c).positive? }
      end

      def min_width(entity)
        PLAYER_COL_MAX_WIDTH if entity.companies.size > 1 || @game.format_currency(entity.value).size > 6
      end
    end
  end
end
