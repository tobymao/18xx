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
    class GameStatus < Snabberb::Component
      include Lib::Settings
      include Actionable
      include View::ShareCalculation

      needs :game

      PLAYER_COL_MAX_WIDTH = '4.5rem'

      FONT_STD = '"Helvetica Neue", Helvetica, Arial, sans-serif'
      FONT_MONEY = '"Courier New", Courier, monospace'
      FONT_CASH = '"Arial Black", Gadget, sans-serif'
      COLOR_CASH = '#4b0082' # Dark Purple (Indigo)
      COLOR_BANK = '#f5cda8'
      COLOR_ACTIVE = '#ffffff'
      COLOR_INACTIVE = '#e0e0e0'
      COLOR_MAUVE = '#dda0dd'

      def active_entity
        @game.round.active_step&.current_entity
      end

      def active_player
        entity = active_entity
        entity&.player? ? entity : entity&.owner
      end

      def render
        @spreadsheet_sort_by = Lib::Storage['spreadsheet_sort_by']
        @spreadsheet_sort_order = Lib::Storage['spreadsheet_sort_order']
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
              h(:tr, { style: { height: '0px' } }, []),
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
              render_player_loans,
              render_player_time,
              render_player_companies,
              render_player_certs,
            ]),
          ]),
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

        corporation_props_size = 5 + extra.size + treasury.size

        players_title = h(:th, th_props[@game.players.size], 'Players')

        pool_th_props = th_props[2]
        pool_th_props[:style][:backgroundColor] = COLOR_BANK
        pool_title = h(:th, pool_th_props, 'Pool')

        ipo_th_props = th_props[2]
        ipo_title = h(:th, ipo_th_props, @game.ipo_name)

        corporation_title = h(:th, th_props[corporation_props_size, false], ['Corporation ', render_toggle_not_floated_link])

        subtitles = []
        players_subtitles = []
        @game.players.map do |p|
          is_active_col = (p == active_player)
          props = if p == @game.priority_deal_player
                    pd_props
                  else
                    { style: { backgroundColor: is_active_col ? COLOR_ACTIVE : 'inherit' } }
                  end
          props[:style][:minWidth] = min_width(p)
          players_subtitles << h('th.name.nowrap', props, render_sort_link(p.name, p.id))
        end

        bank_sub_th_props = { style: { backgroundColor: COLOR_BANK } }
        pool_subtitles = [
          h(:th, bank_sub_th_props, render_sort_link('Shares', :market_shares)),
          h(:th, bank_sub_th_props, render_sort_link('Prices', :share_price)),
        ]
        ipo_subtitles = [
          h(:th, render_sort_link('Shares', :ipo_shares)),
          h(:th, render_sort_link('Price', :par_price)),
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
          pool_title,
          ipo_title,
        ]
        subtitles.concat(players_subtitles)
        subtitles.concat(pool_subtitles)
        subtitles.concat(ipo_subtitles)
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
        is_active_row = (active_entity == corporation)

        name_props = {
          style: {
            backgroundColor: is_active_row ? COLOR_MAUVE : corporation.color,
            color: corporation.text_color,
            fontFamily: FONT_STD,
            fontWeight: 'bold',
          },
        }

        tr_props = tr_default_props(is_active_row)

        tr_props[:style][:opacity] = '0.5' unless @game.operating_order.include?(corporation)

        order_props = { style: { paddingLeft: '1.2em' } }
        order_props[:style][:color] =
          if operating_order[0] == UNSTARTED
            'transparent'
          elsif corporation.operating_history.keys[-1] == current_round
            convert_hex_to_rgba(color_for(:font2), 0.5)
          end

        treasury = []
        treasury << h(:td, num_shares_of(corporation, corporation)) if @game.separate_treasury?

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
          is_active_col = (p == active_player) && !is_active_row
          bg_color = is_active_col ? COLOR_ACTIVE : 'inherit'

          n_shares = num_shares_of(p, corporation)

          if n_shares.zero?
            players_row_content << h(:td, { style: { backgroundColor: bg_color } }, '')
          else
            percent = p.percent_of(corporation) || (n_shares * 10)
            is_president = corporation.president?(p)
            text = "#{percent}%#{is_president ? 'P' : ''}"

            just_sold = @game.round.active_step&.did_sell?(corporation, p)
            border_color = just_sold ? '#cc0000' : '#999999'

            players_row_content << h(:td, { style: { backgroundColor: bg_color, textAlign: 'center' } }, [
              h(View::Game::Card, text: text, border_color: border_color),
            ])
          end
        end

        # --- Pool Shares Content ---
        pool_share_text = if n_market_shares.zero?
                            ''
                          else
                            "#{corporation.receivership? ? '*' : ''}#{n_market_shares * 10}%"
                          end
        pool_share_card = pool_share_text.empty? ? '' : h(View::Game::Card, text: pool_share_text, border_color: '#999999')

        # --- Pool Market Price Content ---
        market_style = { fontFamily: FONT_CASH, color: COLOR_CASH, fontWeight: 'bold', borderRight: border_style }
        if corporation.share_price&.highlight? &&
          (m_color = StockMarket::COLOR_MAP[@game.class::STOCKMARKET_COLORS[corporation.share_price.type]])
          market_style[:backgroundColor] = m_color
          market_style[:color] = contrast_on(m_color)
        end
        clean_market_price = if corporation.share_price
                               @game.format_currency(corporation.share_price.price).gsub(/[^0-9]/,
                                                                                         '')
                             else
                               ''
                             end

        pool_row_content = [
          h('td.padded_number', { style: { backgroundColor: COLOR_BANK } }, [pool_share_card]),
          h('td.padded_number', { style: market_style }, clean_market_price),
        ]

        # --- IPO Shares Content ---
        ipo_share_text = n_ipo_shares.zero? ? '' : "#{n_ipo_shares * 10}%"
        ipo_share_card = ipo_share_text.empty? ? '' : h(View::Game::Card, text: ipo_share_text, border_color: '#999999')

        # --- IPO Par Price Content ---
        clean_par_price = corporation.par_price ? @game.format_currency(corporation.par_price.price).gsub(/[^0-9]/, '') : ''

        ipo_row_content = [
          h('td.padded_number', { style: { borderLeft: border_style } }, [ipo_share_card]),
          h('td.padded_number', { style: { fontFamily: FONT_CASH, color: COLOR_CASH, fontWeight: 'bold' } }, clean_par_price),
        ]

        train_cards = corporation.trains.map do |t|
          h(View::Game::Card, text: t.obsolete ? "(#{t.name})" : t.name)
        end

        clean_corp_cash = @game.format_currency(corporation.cash).gsub(/[^0-9]/, '')
        corporation_row_content = [
          h('td.padded_number', { style: { fontFamily: FONT_CASH, color: COLOR_CASH, fontWeight: 'bold' } }, clean_corp_cash),
          *treasury,
          h(:td, { style: { fontFamily: FONT_STD } }, train_cards),
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
        row_content.concat(pool_row_content)
        row_content.concat(ipo_row_content)
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
        company_cards = entity.companies.map do |c|
          h(View::Game::Card, text: c.sym)
        end

        h(:td, props || {}, company_cards)
      end

      def render_player_companies
        h(:tr, tr_default_props, [
          h('th.left', 'Companies'),
          *@game.players.map do |p|
            is_active_col = (p == active_player)
            bg_color = is_active_col ? COLOR_ACTIVE : COLOR_INACTIVE
            h(:td, { style: { backgroundColor: bg_color } }, [render_companies(p)])
          end,
        ])
      end

      def render_player_cash
        h(:tr, tr_default_props, [
          h('th.left', 'Cash'),
          *@game.players.map do |p|
            clean_cash = @game.format_currency(p.cash).gsub(/[^0-9]/, '')
            is_active_col = (p == active_player)
            bg_color = is_active_col ? COLOR_ACTIVE : COLOR_INACTIVE
            h('td.padded_number',
              { style: { fontFamily: FONT_CASH, color: COLOR_CASH, fontWeight: 'bold', backgroundColor: bg_color } }, clean_cash)
          end,
        ])
      end

      def render_player_time
        h(:tr, tr_default_props, [
          h('th.left', 'Time'),
          *@game.players.map do |p|
            is_active_col = (p == active_player)
            bg_color = is_active_col ? COLOR_ACTIVE : COLOR_INACTIVE
            h('td.padded_number', { style: { backgroundColor: bg_color } }, '0:00')
          end,
        ])
      end

      def render_player_certs
        cert_limit = @game.cert_limit
        props = { style: { color: 'red' } }
        h(:tr, tr_default_props, [
          h('th.left', 'Cert'),
          *@game.players.map do |player|
            is_active_col = (player == active_player)
            bg_color = is_active_col ? COLOR_ACTIVE : COLOR_INACTIVE
            num_certs = @game.num_certs(player)
            cell_props = num_certs > cert_limit ? props.merge(style: { backgroundColor: bg_color }) : { style: { backgroundColor: bg_color } }
            h('td.padded_number', cell_props, "#{num_certs}/#{cert_limit}")
          end,
        ])
      end

      def render_player_loans
        return '' unless @game.respond_to?(:player_loans)

        h(:tr, tr_default_props, [
          h('th.left', 'Loans'),
          *@game.players.map do |p|
            is_active_col = (p == active_player)
            bg_color = is_active_col ? COLOR_ACTIVE : COLOR_INACTIVE
            h('td.padded_number', { style: { backgroundColor: bg_color } }, @game.player_loans(p))
          end,
        ])
      end

      def tr_default_props(is_active_row = false)
        {
          style: {
            backgroundColor: is_active_row ? COLOR_ACTIVE : COLOR_INACTIVE,
            color: '#000000',
            fontFamily: FONT_STD,
          },
        }
      end

      def money_props(extra_style = {})
        { style: { fontFamily: FONT_MONEY, fontWeight: 'bold' }.merge(extra_style) }
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
        if @game.separate_treasury?
          num_shares_of(@game.bank, corporation)
        elsif corporation.respond_to?(:num_ipo_shares)
          corporation.num_ipo_shares
        else
          num_shares_of(corporation, corporation)
        end
      end

      def min_width(entity)
        PLAYER_COL_MAX_WIDTH if entity.companies.size > 1 || @game.format_currency(entity.value).size > 6
      end
    end
  end
end
