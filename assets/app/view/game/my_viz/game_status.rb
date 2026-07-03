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
require 'view/game/my_viz/my_bank'
require 'view/game/my_viz/my_upcoming_trains'
require 'view/game/my_viz/card_animation'
require 'view/game/my_viz/money_animation'

FLOATED = 2
UNFLOATED = 1
UNSTARTED = 0

module View
  module Game
    class GameStatus < Snabberb::Component
      include Lib::Settings
      include Actionable
      include View::ShareCalculation
      needs :game, store: true

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
        @show_privates = @game.respond_to?(:game_phases) && @game.game_phases.any? do |p|
          p[:status]&.any? do |s|
            s.include?('can_buy_companies')
          end
        end

        css = <<~CSS
          #spreadsheet table { border-collapse: collapse; border: 2px solid #333; background-color: #{COLOR_INACTIVE}; }
          #spreadsheet th, #spreadsheet td { border: 1px solid #999; }
          #spreadsheet thead tr:last-child th { border-bottom: 2px solid #333; }
          #spreadsheet tbody tr:last-child td, #spreadsheet tbody tr:last-child th { border-bottom: 2px solid #333; }
          .thick-right { border-right: 2px solid #333 !important; }
        CSS

        h(:div, [
           h('div#spreadsheet', {
               style: {
                 overflow: 'auto',
                 marginTop: '1rem',
               },
             },
             [h(:style, css), render_corporation_table]),
         ])
      end

      def render_corporation_table
        h(:table, table_props, [
          h(:thead, render_titles),
          h(:tbody, render_corporations + render_player_rows),
        ])
      end

      def render_player_rows
        rows = []

        # 1. Cash Row
        cash_cells = [h('th.left', 'Cash')]
        @game.players.each_with_index do |p, idx|
          clean_cash = @game.format_currency(p.cash).gsub(/[^0-9]/, '')
          bg_color = p == active_player ? COLOR_ACTIVE : COLOR_INACTIVE
          is_last = idx == @game.players.size - 1
          cash_cells << h("td.padded_number#{is_last ? '.thick-right' : ''}",
                          { hook: Lib::MoneyAnimation.hook, style: { fontFamily: FONT_CASH, color: COLOR_CASH, fontWeight: 'bold', backgroundColor: bg_color } }, clean_cash)
        end
        rows << cash_cells

        # 2. Loans Row
        if @game.respond_to?(:player_loans)
          loans_cells = [h('th.left', 'Loans')]
          @game.players.each_with_index do |p, idx|
            bg_color = p == active_player ? COLOR_ACTIVE : COLOR_INACTIVE
            is_last = idx == @game.players.size - 1
            loans_cells << h("td.padded_number#{is_last ? '.thick-right' : ''}", { style: { backgroundColor: bg_color } },
                             @game.player_loans(p))
          end
          rows << loans_cells
        end

        # 3. Time Row
        time_cells = [h('th.left', 'Time')]
        @game.players.each_with_index do |p, idx|
          bg_color = p == active_player ? COLOR_ACTIVE : COLOR_INACTIVE
          is_last = idx == @game.players.size - 1
          time_cells << h("td.padded_number#{is_last ? '.thick-right' : ''}", { style: { backgroundColor: bg_color } }, '0:00')
        end
        rows << time_cells

        # 4. Companies Row
        comp_cells = [h('th.left', 'Companies')]
        @game.players.each_with_index do |p, idx|
          bg_color = p == active_player ? COLOR_ACTIVE : COLOR_INACTIVE
          is_last = idx == @game.players.size - 1
          comp_cells << h("td#{is_last ? '.thick-right' : ''}", { style: { backgroundColor: bg_color } }, [render_companies(p)])
        end
        rows << comp_cells

        # 5. Certs Row
        props = { style: { color: 'red' } }
        cert_cells = [h('th.left', 'Cert')]
        @game.players.each_with_index do |player, idx|
        cert_limit = @game.cert_limit(player)

          bg_color = player == active_player ? COLOR_ACTIVE : COLOR_INACTIVE
          num_certs = @game.num_certs(player)
          cell_props = num_certs > cert_limit ? props.merge(style: { backgroundColor: bg_color }) : { style: { backgroundColor: bg_color } }
          is_last = idx == @game.players.size - 1
          cert_cells << h("td.padded_number#{is_last ? '.thick-right' : ''}", cell_props, "#{num_certs}/#{cert_limit}")
        end
        rows << cert_cells

        # Append the bank / extra information cell container to the first row
        rows[0] << h(:td, {
                       attrs: { rowspan: rows.size, colspan: 30 },
                       style: {
                         backgroundColor: '#ffffff',
                         border: 'none',
                         verticalAlign: 'top',
                         paddingLeft: '1.5rem',
                         textAlign: 'left',
                       },
                     }, [render_extra_cards])

        rows.map { |row_cells| h(:tr, tr_default_props, row_cells) }
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
        train_handler = lambda do |train|
          process_action(Engine::Action::BuyTrain.new(
            active_entity,
            train: train,
            price: train.price
          ))
        end

        children << h(MyBank, game: @game, train_handler: train_handler)

        children << h(Tranches, game: @game) if @game.respond_to?(:tranches)
        children << h(MyUpcomingTrains, game: @game)
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
          @is_escrow_game = @game.all_corporations.any? do |c|
            @game.capitalization_type_desc(c)&.include?('Escrow')
          end
          header_label = @is_escrow_game ? 'Escrow' : 'Capitalization'
          extra << h(:th, render_sort_link(header_label, :capitalization_type_desc))
        end
        extra << h(:th, render_sort_link('Loans', :loans)) if @game.total_loans&.nonzero?
        extra << h(:th, render_sort_link('Shorts', :shorts)) if @game.respond_to?(:available_shorts)

        if (@diff_corp_sizes = @game.all_corporations.any? { |c| @game.corporation_size(c) != :small })
          extra << h(:th, render_sort_link('Size', :corp_size))
        end
        @extra_size = extra.size

        corporation_props_size = (@show_privates ? 5 : 4) + extra.size + treasury.size

        players_title = h('th.thick-right', th_props[@game.players.size], 'Players')

        pool_th_props = th_props[2]
        pool_th_props[:style][:backgroundColor] = COLOR_INACTIVE
        pool_title = h('th.thick-right', pool_th_props, 'Pool')

        ipo_th_props = th_props[2]
        ipo_title = h('th.thick-right', ipo_th_props, @game.ipo_name)

        corporation_title = h(:th, th_props[corporation_props_size], ['Corporation ', render_toggle_not_floated_link])

        players_subtitles = []    
        subtitles = []
        @game.players.each_with_index do |p, idx|
          is_active_col = (p == active_player)
          props = { style: { backgroundColor: is_active_col ? COLOR_ACTIVE : 'inherit' } }

          props[:style][:minWidth] = min_width(p)
          is_last = idx == @game.players.size - 1

# Restored full original player name strings
          header_content = []
          header_content.concat(render_sort_link(p.name, p.id))

          if @game.respond_to?(:priority_deal_player) && p == @game.priority_deal_player
           header_content << h(:svg, {
              attrs: { viewBox: '0 0 16 16', width: '16', height: '16', title: 'Priority Deal' },
              style: { display: 'inline-block', marginLeft: '6px', verticalAlign: 'middle', fill: COLOR_CASH }
            }, [
              h(:rect, attrs: { x: '0', y: '2', width: '6', height: '1' }),     # Roof overhang
              h(:rect, attrs: { x: '1', y: '3', width: '4', height: '7' }),     # Driver's cab
              h(:rect, attrs: { x: '11', y: '1', width: '2', height: '4' }),    # Smokestack funnel
              h(:rect, attrs: { x: '4', y: '5', width: '10', height: '5' }),    # Boiler tank
              h(:rect, attrs: { x: '1', y: '10', width: '14', height: '2' }),   # Chassis bed
              h(:polygon, attrs: { points: '14,10 16,12 14,12' }),              # Cowcatcher wedge
              h(:circle, attrs: { cx: '3.5', cy: '13.5', r: '1.5' }),           # Wheel 1
              h(:circle, attrs: { cx: '8.5', cy: '13.5', r: '1.5' }),           # Wheel 2
              h(:circle, attrs: { cx: '12.5', cy: '13.5', r: '1.5' })           # Wheel 3
            ])
          end

          players_subtitles << h("th.name.nowrap#{is_last ? '.thick-right' : ''}", props, header_content)
        end

        bank_sub_th_props = { style: { backgroundColor: COLOR_INACTIVE } }
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
          h(:th, render_sort_link('Last Run', :prev_revenue)),
          h(:th, render_sort_link('Trains', :trains)),
          h(:th, render_sort_link('Tokens', :tokens)),
          *extra,
        ]
        corporation_subtitles << h(:th, render_sort_link('Privates', :companies)) if @show_privates

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
        # Returns a simple flat text element array, decoupling the link layers and disabling sorting
        [text]
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

        all_entities = @game.respond_to?(:minors) ? (@game.minors || []) : []
        all_entities += @game.all_corporations

        all_entities.reject! { |c| c.respond_to?(:closed?) && c.closed? }

        unfloated_corporations =
          (all_entities - operating_array)
            .select { |c| c.respond_to?(:sort_order_key) && c.sort_order_key }
            .sort
            .each_with_index.to_h

        result = all_entities.map do |c|
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
              type_order = corporation.minor? ? 0 : 1
              if /^\d+$/.match?(corporation.id)
                [type_order, 2, corporation.id.to_i]
              else
                [type_order, 1, corporation.id]
              end
            when :ipo_shares
              corporation.minor? ? 0 : num_ipo_shares(corporation)
            when :market_shares
              corporation.minor? ? 0 : num_shares_of(@game.share_pool, corporation)
            when :share_price
              [corporation.share_price&.price || 0, operating_order[0], -operating_order[1]]
            when :par_price
              if corporation.minor?
                minors_list = @game.respond_to?(:minors) ? (@game.minors || []) : []
                minor_idx = minors_list.index(corporation) || 0
                [1, -minor_idx]
              else
                [0, corporation.par_price&.price || 0]
              end
            when :cash
              corporation.cash
            when :prev_revenue
              corporation.operating_history.values.last&.revenue || 0
            when :treasury
              corporation.minor? ? 0 : num_shares_of(corporation, corporation)
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
              if corporation.minor?
                corporation.owner == p ? 10 : -99
              else
                n = p&.num_shares_of(corporation)
                n += 0.01 if corporation.respond_to?(:president?) && corporation.president?(p)
                n.nil? || n.zero? ? -99 : n
              end
            end
          end
        end

        result.reverse! if @spreadsheet_sort_order == 'DESC'
        result
      end

      def render_corporation(corporation, _operating_order, _current_round)
        return '' if @hide_not_floated && !@game.operating_order.include?(corporation)

        step = @game.round.active_step

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
        corp_bg_color = corporation.floated? ? COLOR_MAUVE : COLOR_INACTIVE

        treasury = []
        if @game.separate_treasury?
          treasury << h(:td, { style: { backgroundColor: corp_bg_color } },
                        num_shares_of(corporation, corporation))
        end


extra = []
        if @game.respond_to?(:capitalization_type_desc)
          desc_text = @game.capitalization_type_desc(corporation)
          if @is_escrow_game && desc_text&.include?('Escrow')
            clean_digits = desc_text.scan(/\d+/).first || '0'
            extra << h(:td, money_props(backgroundColor: corp_bg_color), clean_digits)
          else
            extra << h(:td, { style: { backgroundColor: corp_bg_color } }, desc_text)
          end
        end


        if @game.total_loans&.nonzero?
          extra << h(:td, { style: { backgroundColor: corp_bg_color } }, [render_loan_dots(corporation)])
        end
        if @game.respond_to?(:available_shorts)
          taken, total = if @game.respond_to?(:available_shorts)
                           @game.available_shorts(corporation)
                         else
                           [0, 0]
                         end
          extra << h(:td, { style: { backgroundColor: corp_bg_color } }, "#{taken} / #{total}")
        end
        
        if @diff_corp_sizes
          size_name = if corporation.minor?
                        'Minor'
                      elsif @game.respond_to?(:corporation_size_name)
                        @game.corporation_size_name(corporation)
                      else
                        ''
                      end
          extra << h(:td, { style: { backgroundColor: corp_bg_color } }, size_name)
        end

        n_ipo_shares = corporation.minor? ? 0 : num_ipo_shares(corporation)
        n_market_shares = num_shares_of(@game.share_pool, corporation)

        players_row_content = []

        @game.players.each do |p|
          is_active_col = (p == active_player) && !is_active_row
          bg_color = is_active_col ? COLOR_ACTIVE : 'inherit'

          step = @game.round.active_step

          player_shares = p.respond_to?(:shares_of) ? p.shares_of(corporation) : []
          bundles = []

          if step&.current_actions&.include?('sell_shares') && p == active_player
            sorted_shares = player_shares.sort_by { |s| s.respond_to?(:president) && s.president ? 1 : 0 }

            (1..sorted_shares.size).each do |num|
              chosen_shares = sorted_shares[0...num]
              total_percent = 0
              chosen_shares.each { |s| total_percent += (s.respond_to?(:percent) ? s.percent : 10) }

              numeric_price = corporation.share_price ? corporation.share_price.price : 0
              bundles << { shares: chosen_shares, percent: total_percent, share_price: numeric_price }
            end
          end

          can_sell = (p == active_player) && !bundles.empty?

          # Check if the active player can buy from this specific player (e.g., Nationalization)
          valid_player_buys = []
          if !can_sell && p != active_player && step&.respond_to?(:can_buy?)
            player_shares.each do |s|
              valid_player_buys << s if step.can_buy?(active_player, s.to_bundle)
            end
          end
          can_buy_from_player = !valid_player_buys.empty?

          border_color = '#999999'
          click_handler = nil

          if can_sell
            border_color = '#cc0000'
            click_handler = if bundles.size > 1
                              lambda {
                                Lib::Storage['sell_menu_player'] = p.id
                                Lib::Storage['sell_menu_corp'] = corporation.id
                                update
                              }
                            else
                              lambda { |event|
                                target_bundle = bundles.first
                                Lib::CardAnimation.fly(event, "#pool_shares_#{corporation.id}") do
                                  process_action(Engine::Action::SellShares.new(
                                    p,
                                    shares: target_bundle[:shares],
                                    share_price: target_bundle[:share_price],
                                    percent: target_bundle[:percent]
                                  ))
                                end
                              }
                            end
          elsif can_buy_from_player
            border_color = '#00cc00'
            click_handler = if valid_player_buys.uniq { |s| s.to_bundle.percent }.size > 1
                              lambda {
                                Lib::Storage['buy_player_menu_player'] = p.id
                                Lib::Storage['buy_player_menu_corp'] = corporation.id
                                update
                              }
                            else
                              lambda {
                                bnd = valid_player_buys.first.to_bundle
                                process_action(Engine::Action::BuyShares.new(
                                  active_player,
                                  shares: bnd.shares,
                                  share_price: bnd.share_price,
                                  percent: bnd.percent
                                ))
                              }
                            end
          end

          if corporation.minor?
            players_row_content << if corporation.owner == p
                                     h(:td, { style: { backgroundColor: bg_color, textAlign: 'center' } }, [
                                       h(View::Game::Card, text: '100%', border_color: border_color, click_action: click_handler),
                                     ])
                                   else
                                     h(:td, { style: { backgroundColor: bg_color } }, '')
                                   end
          else
            n_shares = num_shares_of(p, corporation)

            just_sold = begin
              step&.did_sell?(corporation, p)
            rescue StandardError
              false
            end

            if n_shares.zero? && !can_buy_from_player && !just_sold
              players_row_content << h(:td, { style: { backgroundColor: bg_color } }, '')
            else
              percent = p.percent_of(corporation) || (n_shares * 10)
              is_president = corporation.respond_to?(:president?) && corporation.president?(p)
              text = if n_shares.zero?
                       '0%'
                     else
                       "#{percent}%#{is_president ? 'P' : ''}"
                     end

              border_color = '#cc0000' if just_sold && !click_handler

              card = h(View::Game::Card, text: text, border_color: border_color, click_action: click_handler)
              card = h(:span, { style: { visibility: 'hidden', display: 'inline-block' } }, [card]) if n_shares.zero?

              td_children = [card]

              if just_sold
                td_children << h(:span, {
                                   style: {
                                     display: 'inline-block',
                                     width: '6px',
                                     height: '6px',
                                     backgroundColor: '#cc0000',
                                     borderRadius: '50%',
                                     marginLeft: '4px',
                                     verticalAlign: 'middle',
                                   },
                                 })
              end

              if Lib::Storage['sell_menu_player'] == p.id && Lib::Storage['sell_menu_corp'] == corporation.id && can_sell
                options = bundles.map do |bundle|
                  {
                    label: "#{bundle[:percent]}%",
                    action: lambda {
                      Lib::Storage['sell_menu_player'] = nil
                      Lib::Storage['sell_menu_corp'] = nil
                      process_action(Engine::Action::SellShares.new(
                        p,
                        shares: bundle[:shares],
                        share_price: bundle[:share_price],
                        percent: bundle[:percent]
                      ))
                    },
                  }
                end

                cancel_handler = lambda {
                  Lib::Storage['sell_menu_player'] = nil
                  Lib::Storage['sell_menu_corp'] = nil
                  update
                }
                td_children << render_choice_menu('How many shares to sell?', options, cancel_handler)
              end

              if Lib::Storage['buy_player_menu_player'] == p.id && Lib::Storage['buy_player_menu_corp'] == corporation.id && can_buy_from_player
                options = valid_player_buys.map do |share|
                  {
                    label: "Buy #{share.to_bundle.percent}%",
                    action: lambda {
                      Lib::Storage['buy_player_menu_player'] = nil
                      Lib::Storage['buy_player_menu_corp'] = nil
                      bnd = share.to_bundle
                      process_action(Engine::Action::BuyShares.new(
                        active_player,
                        shares: bnd.shares,
                        share_price: bnd.share_price,
                        percent: bnd.percent
                      ))
                    },
                  }
                end

                cancel_handler = lambda {
                  Lib::Storage['buy_player_menu_player'] = nil
                  Lib::Storage['buy_player_menu_corp'] = nil
                  update
                }
                td_children << render_choice_menu('Nationalize share bundle?', options, cancel_handler)
              end

              players_row_content << h(:td, { attrs: { id: "player_shares_#{p.id}_#{corporation.id}" }, style: { backgroundColor: bg_color, textAlign: 'center', position: 'relative' } },
                                       td_children)
            end
          end
        end

        # --- Pool Shares Content ---
        pool_share_text = if corporation.minor? || n_market_shares.zero?
                            ''
                          else
                            is_receivership = corporation.respond_to?(:receivership?) && corporation.receivership?
                            "#{is_receivership ? '*' : ''}#{n_market_shares * 10}%"
                          end

        pool_border_color = '#999999'
        pool_click_handler = nil
        valid_pool_shares = []

        if step&.respond_to?(:can_buy?) && active_player
          pool_shares = step.respond_to?(:pool_shares) ? step.pool_shares(corporation) : (@game.share_pool.shares_by_corporation[corporation] || [])
          valid_pool_shares = pool_shares.select do |s|
            (s.respond_to?(:buyable) ? s.buyable : true) && step.can_buy?(active_player, s.to_bundle)
          end

          unless valid_pool_shares.empty?
            pool_border_color = '#00cc00'
            pool_click_handler = if valid_pool_shares.uniq { |s| s.to_bundle.percent }.size > 1
                                   lambda {
                                     Lib::Storage['buy_pool_menu_corp'] = corporation.id
                                     update
                                   }
                                 else
                                   lambda { |event|
                                     bnd = valid_pool_shares.first.to_bundle
                                     Lib::CardAnimation.fly(event, "#player_shares_#{active_player.id}_#{corporation.id}") do
                                       process_action(Engine::Action::BuyShares.new(
                                         active_player,
                                         shares: bnd.shares,
                                         share_price: bnd.share_price,
                                         percent: bnd.percent
                                       ))
                                     end
                                   }
                                 end
          end
        end

        pool_cell_children = []
        unless pool_share_text.empty?
          pool_cell_children << h(View::Game::Card, text: pool_share_text, border_color: pool_border_color,
                                                    click_action: pool_click_handler)

          if Lib::Storage['buy_pool_menu_corp'] == corporation.id && !valid_pool_shares.empty?
            options = valid_pool_shares.map do |share|
              {
                label: "Buy #{share.to_bundle.percent}%",
                action: lambda { |event|
                  Lib::Storage['buy_pool_menu_corp'] = nil
                  bnd = share.to_bundle
                  Lib::CardAnimation.fly(event, "#player_shares_#{active_player.id}_#{corporation.id}") do
                    process_action(Engine::Action::BuyShares.new(
                      active_player,
                      shares: bnd.shares,
                      share_price: bnd.share_price,
                      percent: bnd.percent
                    ))
                  end
                },
              }
            end
            cancel_handler = lambda {
              Lib::Storage['buy_pool_menu_corp'] = nil
              update
            }
            pool_cell_children << render_choice_menu('Buy from Pool:', options, cancel_handler)
          end
        end

        # --- Pool Market Price Content ---
        market_style = {
          fontFamily: FONT_CASH,
          color: COLOR_CASH,
          fontWeight: 'bold',
          borderRight: border_style,
          backgroundColor: COLOR_INACTIVE,
        }
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
           h('td.padded_number',
             { attrs: { id: "pool_shares_#{corporation.id}" }, style: { backgroundColor: COLOR_INACTIVE, position: 'relative' } }, pool_cell_children),
           h('td.padded_number', { style: market_style }, clean_market_price),
         ]

        # --- IPO Shares Content ---
        ipo_share_text = n_ipo_shares.zero? ? '' : "#{n_ipo_shares * 10}%"

        ipo_border_color = '#999999'
        ipo_click_handler = nil
        valid_ipo_shares = []

        can_par = active_player && @game.respond_to?(:can_par?) && @game.can_par?(corporation, active_player)
par_prices = []
    if can_par
      par_prices = if step.respond_to?(:get_par_prices_with_help)
                     step.get_par_prices_with_help(active_player, corporation).sort_by(&:price)
                   elsif step.respond_to?(:get_par_prices)
                     step.get_par_prices(active_player, corporation).sort_by(&:price)
                   elsif @game.respond_to?(:par_prices)
                     @game.par_prices(corporation).sort_by(&:price)
                   else
                     @game.stock_market.par_prices.sort_by(&:price)
                   end

      unless par_prices.empty?
        ipo_border_color = '#00cc00'
        ipo_click_handler = lambda {
          Lib::Storage['par_menu_corp'] = corporation.id
          update
        }
      end
    elsif step&.respond_to?(:can_buy?) && active_player
      ipo_shares = corporation.respond_to?(:ipo_shares) ? corporation.ipo_shares : []
      valid_ipo_shares = ipo_shares.select do |s|
        (s.respond_to?(:buyable) ? s.buyable : true) && step.can_buy?(active_player, s.to_bundle)
      end

      unless valid_ipo_shares.empty?
        ipo_border_color = '#00cc00'
        ipo_click_handler = if valid_ipo_shares.uniq { |s| s.to_bundle.percent }.size > 1
                              lambda {
                                Lib::Storage['buy_ipo_menu_corp'] = corporation.id
                                update
                              }
                            else
                              lambda { |event|
                                bnd = valid_ipo_shares.first.to_bundle
                                Lib::CardAnimation.fly(event, "#player_shares_#{active_player.id}_#{corporation.id}") do
                                  process_action(Engine::Action::BuyShares.new(
                                    active_player,
                                    shares: bnd.shares,
                                    share_price: bnd.share_price,
                                    percent: bnd.percent
                                  ))
                                end
                              }
                            end
      end
    end

        ipo_cell_children = []
        unless ipo_share_text.empty?
          ipo_cell_children << h(View::Game::Card, text: ipo_share_text, border_color: ipo_border_color,
                                                   click_action: ipo_click_handler)

          if Lib::Storage['buy_ipo_menu_corp'] == corporation.id && !valid_ipo_shares.empty?
            options = valid_ipo_shares.map do |share|
              {
                label: "Buy #{share.to_bundle.percent}%",
                action: lambda { |event|
                  Lib::Storage['buy_ipo_menu_corp'] = nil
                  bnd = share.to_bundle
                  Lib::CardAnimation.fly(event, "#player_shares_#{active_player.id}_#{corporation.id}") do
                    process_action(Engine::Action::BuyShares.new(
                      active_player,
                      shares: bnd.shares,
                      share_price: bnd.share_price,
                      percent: bnd.percent
                    ))
                  end
                },
              }
            end
            cancel_handler = lambda {
              Lib::Storage['buy_ipo_menu_corp'] = nil
              update
            }
            ipo_cell_children << render_choice_menu('Buy from IPO:', options, cancel_handler)
          end
          if Lib::Storage['par_menu_corp'] == corporation.id && can_par && !par_prices.empty?
            cancel_handler = lambda {
              Lib::Storage['par_menu_corp'] = nil
              update
            }
            ipo_cell_children << render_par_matrix_menu(corporation, par_prices, cancel_handler)
          end
        end

        # --- IPO Par Price Content ---
        clean_par_price = corporation.par_price ? @game.format_currency(corporation.par_price.price).gsub(/[^0-9]/, '') : ''

        ipo_row_content = [
          h('td.padded_number', { style: { borderLeft: border_style, backgroundColor: COLOR_INACTIVE, position: 'relative' } },
            ipo_cell_children),
          h('td.padded_number',
            { style: { fontFamily: FONT_CASH, color: COLOR_CASH, fontWeight: 'bold', backgroundColor: COLOR_INACTIVE } }, clean_par_price),
        ]

        train_buyable_step = step&.current_actions&.include?('buy_train')

        train_cards = corporation.trains.map do |t|
          train_border_color = '#999999'
          train_click_handler = nil
          menu_dropdown = nil

          # Only highlight if owned by the same player AND it's not the active company's own train
          owned_by_same_player = active_player && corporation.owner == active_player
          not_own_train = active_entity && corporation != active_entity

          if train_buyable_step && not_own_train && owned_by_same_player && step.respond_to?(:can_buy_train?) && step.can_buy_train?(
active_entity, t
)
            train_border_color = '#00cc00'
            menu_storage_key = "buy_train_menu_#{corporation.id}_#{t.id}"
            price_storage_key = "buy_train_price_#{corporation.id}_#{t.id}"

            train_click_handler = lambda {
              Lib::Storage[menu_storage_key] = true
              Lib::Storage[price_storage_key] = 1 # Initialize default price string
              update
            }

            if Lib::Storage[menu_storage_key]
              menu_title = "#{active_entity.name} buys #{t.name} from #{corporation.name} for how much?"

              confirm_handler = lambda {
                price_value = Lib::Storage[price_storage_key].to_i
                price_value = 1 if price_value < 1

                Lib::Storage[menu_storage_key] = nil
                Lib::Storage[price_storage_key] = nil
                process_action(Engine::Action::BuyTrain.new(
                  active_entity,
                  train: t,
                  price: price_value
                ))
              }

              cancel_handler = lambda {
                Lib::Storage[menu_storage_key] = nil
                Lib::Storage[price_storage_key] = nil
                update
              }

              menu_dropdown = h(:div, {
                                  style: {
                                    position: 'absolute',
                                    top: '105%',
                                    left: '50%',
                                    transform: 'translateX(-50%)',
                                    backgroundColor: '#ffffff',
                                    border: '2px solid #333333',
                                    borderRadius: '4px',
                                    padding: '0.5rem',
                                    zIndex: '9999',
                                    boxShadow: '0px 4px 10px rgba(0,0,0,0.3)',
                                  },
                                }, [
                h(:div,
                  { style: { fontSize: '0.75rem', fontWeight: 'bold', marginBottom: '0.4rem', color: '#333', whiteSpace: 'nowrap' } }, menu_title),
                h(:input, {
                    style: {
                      display: 'block',
                      width: '100%',
                      marginBottom: '0.4rem',
                      boxSizing: 'border-box',
                      padding: '3px 6px',
                      fontSize: '0.85rem',
                    },
                    attrs: {
                      type: 'number',
                      min: '1',
                      value: Lib::Storage[price_storage_key] || '1',
                    },
                    on: {
                      input: lambda { |event|
                        Lib::Storage[price_storage_key] = event.JS[:target].JS[:value]
                      },
                    },
                  }),
                h(:button, {
                    style: {
                      display: 'block',
                      width: '100%',
                      marginBottom: '0.2rem',
                      cursor: 'pointer',
                      fontSize: '0.75rem',
                      fontWeight: 'bold',
                      padding: '3px 6px',
                      backgroundColor: '#007bff',
                      border: '1px solid #0056b3',
                      color: '#ffffff',
                      borderRadius: '3px',
                    },
                    on: { click: confirm_handler },
                  }, 'Confirm'),
                h(:button, {
                    style: {
                      display: 'block',
                      width: '100%',
                      cursor: 'pointer',
                      fontSize: '0.75rem',
                      padding: '3px 6px',
                      backgroundColor: '#e0e0e0',
                      border: '1px solid #999',
                      borderRadius: '3px',
                    },
                    on: { click: cancel_handler },
                  }, 'Cancel'),
              ])
            end
          end

          h(:div, { style: { display: 'inline-block', position: 'relative' } }, [
            h(View::Game::Card, text: t.obsolete ? "(#{t.name})" : t.name, border_color: train_border_color,
                                click_action: train_click_handler),
            menu_dropdown,
          ].compact)
        end

        limit = begin
          @game.train_limit(corporation)
        rescue StandardError
          corporation.trains.size
        end
        limit = corporation.trains.size if limit < corporation.trains.size

        empty_count = [limit - corporation.trains.size, 0].max
        empty_count.times do
          train_cards << h(:div, {
                             style: {
                               width: '42px',
                               height: '22px',
                               backgroundColor: 'transparent',
                               border: '1px dashed #999',
                               borderRadius: '3px',
                               margin: '2px',
                               boxSizing: 'border-box',
                               display: 'inline-block',
                               verticalAlign: 'middle',
                             },
                           })
        end

        clean_corp_cash = @game.format_currency(corporation.cash).gsub(/[^0-9]/, '')

        last_rev = corporation.operating_history.values.last&.revenue
        clean_rev = last_rev ? @game.format_currency(last_rev).gsub(/[^0-9]/, '') : ''

        corporation_row_content = [
                  h('td.padded_number',
                    { hook: Lib::MoneyAnimation.hook, style: { backgroundColor: corp_bg_color, fontFamily: FONT_CASH, color: COLOR_CASH, fontWeight: 'bold' } }, clean_corp_cash),
                  *treasury,
                  h('td.padded_number',
                    { hook: Lib::MoneyAnimation.hook, style: { backgroundColor: corp_bg_color, fontFamily: FONT_CASH, color: COLOR_CASH, fontWeight: 'bold' } }, clean_rev),
                  h(:td, { style: { backgroundColor: corp_bg_color, fontFamily: FONT_STD } }, train_cards),
                  h(:td, { style: { backgroundColor: corp_bg_color } }, [render_unplaced_tokens(corporation)]),
                  *extra,
                ]
        corporation_row_content << render_companies(corporation, corp_bg_color) if @show_privates

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

      def render_loan_dots(entity)
        return h(:div, '') unless entity && entity.respond_to?(:loans) && @game.respond_to?(:maximum_loans)

        loans_taken = entity.loans.size
        max_loans = @game.maximum_loans(entity)
        interest_owed = @game.respond_to?(:interest_owed) ? @game.interest_owed(entity) : 0

        dots = []
        loans_taken.times do
          dots << h(:span, { style: { display: 'inline-block', width: '8px', height: '8px', backgroundColor: '#dc3545', borderRadius: '50%', margin: '0 2px', verticalAlign: 'middle' } })
        end
        [max_loans - loans_taken, 0].max.times do
          dots << h(:span, { style: { display: 'inline-block', width: '8px', height: '8px', border: '1px solid #dc3545', borderRadius: '50%', margin: '0 2px', verticalAlign: 'middle', boxSizing: 'border-box' } })
        end

        dots << h(:span, { style: { marginLeft: '4px', fontSize: '0.75rem', fontWeight: 'bold', verticalAlign: 'middle' } }, "(#{interest_owed})")

        h(:div, { style: { display: 'flex', alignItems: 'center', justifyContent: 'center' } }, dots)
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

        companies_list = entity.respond_to?(:companies) ? entity.companies : []
        companies_list = companies_list.reject { |c| c.respond_to?(:closed?) && c.closed? }
        company_cards = companies_list.map do |c|
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
              { hook: Lib::MoneyAnimation.hook, style: { fontFamily: FONT_CASH, color: COLOR_CASH, fontWeight: 'bold', backgroundColor: bg_color } }, clean_cash)
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

      def render_choice_menu(title, options, cancel_handler)
        menu_elements = [
          h(:div,
            { style: { fontSize: '0.75rem', fontWeight: 'bold', marginBottom: '0.4rem', color: '#333', whiteSpace: 'nowrap' } }, title),
        ]

        options.each do |opt|
          menu_elements << h(:button, {
                               style: {
                                 display: 'block',
                                 width: '100%',
                                 marginBottom: '0.2rem',
                                 cursor: 'pointer',
                                 fontSize: '0.75rem',
                                 fontWeight: 'bold',
                                 padding: '3px 6px',
                                 backgroundColor: '#ffffff',
                                 border: '1px solid #cc0000',
                                 borderRadius: '3px',
                               },
                               on: { click: opt[:action] },
                             }, opt[:label])
        end

        menu_elements << h(:button, {
                             style: {
                               display: 'block',
                               width: '100%',
                               cursor: 'pointer',
                               fontSize: '0.75rem',
                               padding: '3px 6px',
                               backgroundColor: '#e0e0e0',
                               border: '1px solid #999',
                               borderRadius: '3px',
                               marginTop: '0.2rem',
                             },
                             on: { click: cancel_handler },
                           }, 'Cancel')

        h(:div, {
            style: {
              position: 'absolute',
              top: '105%',
              left: '50%',
              transform: 'translateX(-50%)',
              backgroundColor: '#ffffff',
              border: '2px solid #333333',
              borderRadius: '4px',
              padding: '0.5rem',
              zIndex: '9999',
              boxShadow: '0px 4px 10px rgba(0,0,0,0.3)',
            },
          }, menu_elements)
      end

      def render_par_matrix_menu(corporation, par_prices, cancel_handler)
        shares_range = (2..10).to_a

        headers = [h(:th, { style: { padding: '5px', border: '1px solid #999', backgroundColor: COLOR_INACTIVE } }, 'Par \ Shares')]
        shares_range.each do |n|
          headers << h(:th, { style: { padding: '5px', border: '1px solid #999', backgroundColor: COLOR_INACTIVE } }, n.to_s)
        end

        rows = []
        par_prices.each do |par_node|
          par_price = par_node.price

          # Calculate required float shares, defaulting to float_percent logic if standard method isn't present
          float_shares = if @game.respond_to?(:total_shares_to_float)
                           @game.total_shares_to_float(corporation, par_price)
                         else
                           (corporation.float_percent || 60) / (corporation.share_percent || 10)
                         end

          cells = [h(:th, { style: { padding: '5px', border: '1px solid #999', backgroundColor: COLOR_INACTIVE } }, @game.format_currency(par_price))]

          shares_range.each do |n|
            cost = n * par_price
            can_afford = active_player.cash >= cost
            is_float = n == float_shares

            bg_color = can_afford ? '#c8e6c9' : '#000000'
            fg_color = can_afford ? '#000000' : '#ffffff'
            border_style = is_float ? '3px solid #ff0000' : '1px solid #999'

            cell_props = {
              style: {
                padding: '5px',
                border: border_style,
                backgroundColor: bg_color,
                color: fg_color,
                cursor: can_afford ? 'pointer' : 'not-allowed',
                textAlign: 'center',
                fontWeight: is_float ? 'bold' : 'normal'
              },
              on: {}
            }

            if can_afford
              cell_props[:on][:click] = lambda {
                Lib::Storage['par_menu_corp'] = nil
                process_action(Engine::Action::Par.new(
                  active_player,
                  corporation: corporation,
                  share_price: par_node
                ))
              }
            end

            cells << h(:td, cell_props, @game.format_currency(cost))
          end
          rows << h(:tr, cells)
        end

        table = h(:table, { style: { borderCollapse: 'collapse', marginTop: '10px' } }, [
          h(:thead, [h(:tr, headers)]),
          h(:tbody, rows)
        ])

        h(:div, {
          style: {
            position: 'absolute',
            top: '105%',
            left: '50%',
            transform: 'translateX(-50%)',
            backgroundColor: '#ffffff',
            border: '2px solid #333333',
            borderRadius: '4px',
            padding: '1rem',
            zIndex: '9999',
            boxShadow: '0px 4px 10px rgba(0,0,0,0.3)',
          },
        }, [
          h(:div, { style: { fontSize: '1rem', fontWeight: 'bold', marginBottom: '0.5rem', color: '#333' } }, "Select Par Price for #{corporation.name}"),
          table,
          h(:button, {
            style: {
              display: 'block',
              width: '100%',
              cursor: 'pointer',
              fontSize: '0.85rem',
              padding: '5px',
              backgroundColor: '#e0e0e0',
              border: '1px solid #999',
              borderRadius: '3px',
              marginTop: '10px',
            },
            on: { click: cancel_handler },
          }, 'Cancel')
        ])
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
