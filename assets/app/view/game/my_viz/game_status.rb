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

        css = <<~CSS
          #spreadsheet table { border-collapse: collapse; border: 2px solid #333; background-color: #{COLOR_INACTIVE}; }
          #spreadsheet th, #spreadsheet td { border: 1px solid #999; }
          #spreadsheet thead tr:last-child th { border-bottom: 2px solid #333; }
          #spreadsheet tbody tr:last-child td, #spreadsheet tbody tr:last-child th { border-bottom: 2px solid #333; }
          .thick-right { border-right: 2px solid #333 !important; }
        CSS

        h('div#spreadsheet', {
            style: {
              overflow: 'auto',
              marginTop: '1rem',
            },
          },
          [h(:style, css), render_corporation_table, render_extra_cards])
      end

      def render_corporation_table
        h('div#corporation_table', [
          h(:table, table_props, [
            h(:thead, render_titles),
            h(:tbody, render_corporations),
            h('tbody#player_details', [
              render_player_cash,
              render_player_loans,
              render_player_time,
              render_player_companies,
              render_player_certs,
            ].compact),
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

        corporation_props_size = 4 + extra.size + treasury.size

        players_title = h('th.thick-right', th_props[@game.players.size], 'Players')

        pool_th_props = th_props[2]
        pool_th_props[:style][:backgroundColor] = COLOR_BANK
        pool_title = h('th.thick-right', pool_th_props, 'Pool')

        ipo_th_props = th_props[2]
        ipo_title = h('th.thick-right', ipo_th_props, @game.ipo_name)

        corporation_title = h(:th, th_props[corporation_props_size], ['Corporation ', render_toggle_not_floated_link])

        subtitles = []
        players_subtitles = @game.players.map.with_index do |p, idx|
          is_active_col = (p == active_player)
          props = if p == @game.priority_deal_player
                    pd_props
                  else
                    { style: { backgroundColor: is_active_col ? COLOR_ACTIVE : 'inherit' } }
                  end
          props[:style][:minWidth] = min_width(p)
          is_last = idx == @game.players.size - 1
          h("th.name.nowrap#{is_last ? '.thick-right' : ''}", props, render_sort_link(p.name, p.id))
        end

        bank_sub_th_props = { style: { backgroundColor: COLOR_BANK } }
        pool_subtitles = [
          h(:th, bank_sub_th_props, render_sort_link('Shares', :market_shares)),
          h('th.thick-right', bank_sub_th_props, render_sort_link('Prices', :share_price)),
        ]
        ipo_subtitles = [
          h(:th, render_sort_link('Shares', :ipo_shares)),
          h('th.thick-right', render_sort_link('Price', :par_price)),
        ]
        corporation_subtitles = [
          h(:th, render_sort_link('Treasury', :cash)),
          *treasury,
          h(:th, render_sort_link('Trains', :trains)),
          h(:th, render_sort_link('Tokens', :tokens)),
          *extra,
          h(:th, render_sort_link('Privates', :companies)),
        ]

        titles = [
          players_title,
          pool_title,
          ipo_title,
          corporation_title,
        ]
        subtitles.concat(players_subtitles)
        subtitles.concat(pool_subtitles)
        subtitles.concat(ipo_subtitles)
        subtitles.concat(corporation_subtitles)

        [
          h(:tr, [
            h('th.thick-right', { style: { minWidth: '5rem' } }, ''),
            *titles,
          ]),
          h(:tr, [
            h('th.thick-right', { style: { paddingBottom: '0.3rem' } }, render_sort_link('SYM', :id)),
            *subtitles,
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

      def render_corporation(corporation, _operating_order, _current_round)
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

        # Map active corporate property cells
        corp_bg_color = is_active_row ? COLOR_MAUVE : COLOR_INACTIVE

        treasury = []
        if @game.separate_treasury?
          treasury << h(:td, { style: { backgroundColor: corp_bg_color } },
                        num_shares_of(corporation, corporation))
        end

        extra = []
        if @game.respond_to?(:capitalization_type_desc)
          extra << h(:td, { style: { backgroundColor: corp_bg_color } },
                     @game.capitalization_type_desc(corporation))
        end
        if @game.total_loans&.nonzero?
          extra << h(:td, { style: { backgroundColor: corp_bg_color } },
                     "#{corporation.loans.size}/#{@game.maximum_loans(corporation)}")
        end
        if @game.respond_to?(:available_shorts)
          taken, total = @game.available_shorts(corporation)
          extra << h(:td, { style: { backgroundColor: corp_bg_color } }, "#{taken} / #{total}")
        end
        if @game.total_loans.positive?
          extra << h(:td, { style: { backgroundColor: corp_bg_color } },
                     @game.format_currency(@game.buying_power(corporation, full: true)))
          interest_props = { style: { backgroundColor: corp_bg_color } }
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
        if @diff_corp_sizes
          extra << h(:td, { style: { backgroundColor: corp_bg_color } },
                     @game.corporation_size_name(corporation))
        end

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
                               @game.format_currency(corporation.share_price.price).gsub(/[^0-9]/, '')
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

        def render_unplaced_tokens(corporation)
          return h(:span, '') unless corporation.respond_to?(:tokens)

          unplaced = corporation.tokens.select do |t|
            has_hex = t.respond_to?(:hex) && t.hex
            is_placed = t.respond_to?(:placed?) && t.placed?
            !has_hex && !is_placed
          end

          return h(:span, '') if unplaced.empty?

          logo_src = begin
            setting_for(:simple_logos, @game) ? corporation.simple_logo : corporation.logo
          rescue StandardError
            nil
          end

          token_icons = unplaced.map do |_token|
            style = {
              width: '20px',
              height: '20px',
              margin: '2px',
              borderRadius: '50%',
              boxSizing: 'border-box',
              display: 'inline-block',
              border: '1px solid #333',
            }

            if logo_src
              style[:backgroundColor] = corporation.color || '#fff'
              h(:img, { attrs: { src: logo_src }, style: style })
            else
              style[:lineHeight] = '18px'
              style[:textAlign] = 'center'
              style[:backgroundColor] = corporation.color || '#4169e1'
              style[:color] = corporation.text_color || '#fff'
              style[:fontSize] = '0.55rem'
              style[:fontWeight] = 'bold'
              h(:div, { style: style }, corporation.id.to_s[0..2])
            end
          end

          h(:div, { style: { display: 'flex', flexDirection: 'row', justifyContent: 'center', flexWrap: 'wrap' } }, token_icons)
        end

        corporation_row_content = [
          h('td.padded_number',
            { style: { backgroundColor: corp_bg_color, fontFamily: FONT_CASH, color: COLOR_CASH, fontWeight: 'bold' } }, clean_corp_cash),
          *treasury,
          h(:td, { style: { backgroundColor: corp_bg_color, fontFamily: FONT_STD } }, train_cards),
          h(:td, { style: { backgroundColor: corp_bg_color } }, [render_unplaced_tokens(corporation)]),
          *extra,
          render_companies(corporation, corp_bg_color),
        ]

        row_content = []
        row_content.concat(players_row_content)
        row_content.concat(pool_row_content)
        row_content.concat(ipo_row_content)
        row_content.concat(corporation_row_content)

        h(:tr, tr_props, [
          h(:th, name_props, corporation.name),
          *row_content,
        ])
      end

      def render_corp_tokens(corporation)
        return h(:span, '') unless corporation.respond_to?(:tokens)

        tokens = corporation.tokens
        return h(:span, '') if tokens.empty?

        logo_src = begin
          setting_for(:simple_logos, @game) ? corporation.simple_logo : corporation.logo
        rescue StandardError
          nil
        end

        token_icons = tokens.map do |token|
          is_placed = token.respond_to?(:hex) && token.hex

          style = {
            width: '20px',
            height: '20px',
            margin: '2px',
            borderRadius: '50%',
            boxSizing: 'border-box',
            display: 'inline-block',
            border: '1px solid #333',
            opacity: is_placed ? '1' : '0.3',
          }

          if logo_src
            style[:backgroundColor] = corporation.color || '#fff'
            h(:img, { attrs: { src: logo_src }, style: style })
          else
            style[:lineHeight] = '18px'
            style[:textAlign] = 'center'
            style[:backgroundColor] = corporation.color || '#4169e1'
            style[:color] = corporation.text_color || '#fff'
            style[:fontSize] = '0.55rem'
            style[:fontWeight] = 'bold'
            h(:div, { style: style }, corporation.id.to_s[0..2])
          end
        end

        h(:div, { style: { display: 'flex', flexDirection: 'row', justifyContent: 'center', flexWrap: 'wrap' } }, token_icons)
      end

      def render_companies(entity, bg_color = nil)
        props = {}
        props[:style] = if entity.player?
                          {
                            maxWidth: PLAYER_COL_MAX_WIDTH,
                            whiteSpace: 'normal',
                            textAlign: 'right',
                            minWidth: min_width(entity),
                          }
                        else
                          {}
                        end
        props[:style][:backgroundColor] = bg_color if bg_color

        company_cards = entity.companies.map do |c|
          h(View::Game::Card, text: c.sym)
        end

        h(:td, props, company_cards)
      end

      def render_player_companies
        h(:tr, tr_default_props, [
           h('th.left', 'Companies'),
           *@game.players.map.with_index do |p, idx|
             is_active_col = (p == active_player)
             bg_color = is_active_col ? COLOR_ACTIVE : COLOR_INACTIVE
             is_last = idx == @game.players.size - 1
             h("td#{is_last ? '.thick-right' : ''}", { style: { backgroundColor: bg_color } }, [render_companies(p)])
           end,
           h(:td, { attrs: { colspan: 30 }, style: { border: 'none' } }, ''),
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
        *@game.players.map.with_index do |p, idx|
          is_active_col = (p == active_player)
          bg_color = is_active_col ? COLOR_ACTIVE : COLOR_INACTIVE
          is_last = idx == @game.players.size - 1
          h("td.padded_number#{is_last ? '.thick-right' : ''}", { style: { backgroundColor: bg_color } }, '0:00')
        end,
        h(:td, { attrs: { colspan: 30 }, style: { border: 'none' } }, ''),
      ])
      end

      def render_player_certs
        cert_limit = @game.cert_limit
        props = { style: { color: 'red' } }
        h(:tr, tr_default_props, [
    h('th.left', 'Cert'),
    *@game.players.map.with_index do |player, idx|
      is_active_col = (player == active_player)
      bg_color = is_active_col ? COLOR_ACTIVE : COLOR_INACTIVE
      num_certs = @game.num_certs(player)
      cell_props = num_certs > cert_limit ? props.merge(style: { backgroundColor: bg_color }) : { style: { backgroundColor: bg_color } }
      is_last = idx == @game.players.size - 1
      h("td.padded_number#{is_last ? '.thick-right' : ''}", cell_props, "#{num_certs}/#{cert_limit}")
    end,
    h(:td, { attrs: { colspan: 30 }, style: { border: 'none' } }, ''),
  ])
      end

      def render_player_loans
        return '' unless @game.respond_to?(:player_loans)

        h(:tr, tr_default_props, [
         h('th.left', 'Loans'),
         *@game.players.map.with_index do |p, idx|
           is_active_col = (p == active_player)
           bg_color = is_active_col ? COLOR_ACTIVE : COLOR_INACTIVE
           is_last = idx == @game.players.size - 1
           h("td.padded_number#{is_last ? '.thick-right' : ''}", { style: { backgroundColor: bg_color } }, @game.player_loans(p))
         end,
         h(:td, { attrs: { colspan: 30 }, style: { border: 'none' } }, ''),
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
