# frozen_string_literal: true

require 'lib/color'
require 'lib/settings'
require 'view/game/actionable'
require 'view/game/companies'

module View
  module Game
    class Corporation < Snabberb::Component
      include Actionable
      include Lib::Color
      include Lib::Settings

      needs :user, default: nil, store: true
      needs :corporation
      needs :selected_company, default: nil, store: true
      needs :selected_corporation, default: nil, store: true
      needs :game, store: true
      needs :display, default: 'inline-block'
      needs :selectable, default: true
      needs :interactive, default: true

      def render
        select_corporation = lambda do
          if @selectable
            selected_corporation = selected? ? nil : @corporation
            store(:selected_corporation, selected_corporation)
          end

          if can_assign_corporation?
            company = @selected_company
            target = @corporation
            store(:selected_corporation, nil, skip: true)
            store(:selected_company, nil, skip: true)
            process_action(Engine::Action::Assign.new(company, target: target))
          end
        end

        card_style = {
          cursor: 'pointer',
        }

        card_style[:display] = @display

        unless @interactive
          factor = color_for(:bg2).to_s[1].to_i(16) > 7 ? 0.3 : 0.6
          card_style[:backgroundColor] = convert_hex_to_rgba(color_for(:bg2), factor)
          card_style[:border] = '1px dashed'
        end

        card_style[:border] = '4px solid' if @game.round.can_act?(@corporation)

        if selected?
          card_style[:backgroundColor] = 'lightblue'
          card_style[:color] = 'black'
          card_style[:border] = '1px solid'
        end

        children = [render_title, render_holdings]

        unless @corporation.minor?
          children << render_shares unless @corporation.hide_shares?
          children << render_reserved if @corporation.reserved_shares.any?
          children << render_owned_other_shares if @corporation.corporate_shares.any?
          children << h(Companies, owner: @corporation, game: @game) if @corporation.companies.any?
        end

        abilities_to_display = @corporation.all_abilities.select do |ability|
          ability.owner.corporation? && ability.description
        end
        children << render_abilities(abilities_to_display) if abilities_to_display.any?

        extras = []
        extras.concat(render_loans) if @game.total_loans&.nonzero?
        if @corporation.corporation? && @corporation.floated? &&
              @game.total_loans.positive? && @corporation.can_buy?
          extras << render_buying_power
        end
        if @corporation.corporation? && @corporation.respond_to?(:capitalization_type_desc)
          extras << render_capitalization_type
        end
        if @corporation.corporation? && @corporation.respond_to?(:escrow) && @corporation.escrow
          extras << render_escrow_account
        end
        if extras.any?
          props = { style: { borderCollapse: 'collapse' } }
          children << h('table.center', props, [h(:tbody, extras)])
        end

        if @corporation.owner
          props = {
            style: {
              grid: '1fr / repeat(2, max-content)',
              justifyContent: 'center',
              backgroundColor: color_for(:bg2),
              color: color_for(:font2),
            },
          }

          subchildren = render_operating_order
          subchildren << render_revenue_history if @corporation.operating_history.any?
          children << h(:div, props, subchildren)
        end

        status_props = {
          style: {
            justifyContent: 'center',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
          },
        }
        status_array_props = {
          style: {
            display: 'inline-block',
            width: '100%',
            textAlign: 'center',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
          },
        }
        item_props = {
          style: {
            display: 'inline-block',
            padding: '0 0.5rem',
          },
        }

        if @corporation.trains.any? && !@corporation.floated?
          children << h(:div, status_props, @game.float_str(@corporation))
        end
        children << h(:div, status_props, @game.status_str(@corporation)) if @game.status_str(@corporation)
        if @game.status_array(@corporation)
          children << h(:div, status_array_props,
                        @game.status_array(@corporation).map { |text, klass| h("div.#{klass}", item_props, text) })
        end

        h('div.corp.card', { style: card_style, on: { click: select_corporation } }, children)
      end

      def render_title
        title_row_props = {
          style: {
            grid: '1fr / auto 1fr auto',
            gap: '0 0.4rem',
            padding: '0.2rem 0.35rem',
            background: @corporation.color,
            color: @corporation.text_color,
            height: '2.4rem',
          },
        }
        logo_props = {
          attrs: { src: logo_for_user(@corporation) },
          style: {
            height: '1.6rem',
            width: '1.6rem',
            padding: '1px',
            border: '2px solid currentColor',
            borderRadius: '0.5rem',
          },
        }
        children = [h(:img, logo_props), h('div.title', @corporation.full_name)]

        if @corporation.system?
          logo_props[:attrs][:src] = logo_for_user(@corporation.corporations.last)
          children << h(:img, logo_props)
        end

        h('div.corp__title', title_row_props, children)
      end

      def render_holdings
        holdings_row_props = {
          style: {
            grid: '1fr / max-content minmax(max-content, 1fr) minmax(4rem, max-content)',
            gap: '0 0.5rem',
            padding: '0.2rem 0.2rem 0.2rem 0.35rem',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
          },
        }
        sym_props = {
          attrs: {
            title: 'Corporation Symbol',
          },
          style: {
            fontSize: '1.5rem',
            fontWeight: 'bold',
          },
        }
        holdings_props = {
          style: {
            grid: '1fr / repeat(auto-fit, auto)',
            gridAutoFlow: 'column',
            gap: '0 0.5rem',
            justifyContent: 'space-evenly',
            justifySelf: 'normal',
          },
        }

        holdings =
          if !@corporation.corporation? || @corporation.floated? || @corporation.trains.any?
            h(:div, holdings_props, [render_trains, render_cash])
          elsif @corporation.cash.positive?
            h(:div, holdings_props, [render_to_float, render_cash])
          else
            h(:div, [render_to_float])
          end

        h('div.corp__holdings', holdings_row_props, [
          h(:div, sym_props, @corporation.name),
          holdings,
          render_tokens,
        ])
      end

      def render_cash
        render_header_segment(@game.format_currency(@corporation.cash), 'Cash')
      end

      def render_to_float
        props = { style: { textAlign: 'center' } }
        props[:style][:maxWidth] = '3.5rem' if @corporation.cash.positive? && @corporation.tokens.size > 3
        h(:div, props, @game.float_str(@corporation))
      end

      def render_trains
        trains = (@corporation.system? ? @corporation.shells : [@corporation]).map do |c|
          if c.trains.empty?
            'None'
          else
            c.trains.map { |t| t.obsolete ? "(#{t.name})" : t.name }.join(' ')
          end
        end

        render_header_segment(trains, 'Trains')
      end

      def render_header_segment(values, key)
        values = [values] unless values.is_a?(Array)

        value_props = {
          style: {},
          attrs: {
            title: key,
          },
        }
        value_props[:style][:fontSize] = '80%' if values.max_by(&:size).size > 10

        h('div.bold', values.map { |v| h('div.nowrap', value_props, v) })
      end

      def render_tokens
        token_list_props = {
          style: {
            grid: '1fr / auto-flow',
            gap: '0 0.2rem',
            width: '100%',
            overflow: 'auto',
          },
        }
        token_column_props = {
          attrs: {},
          style: {
            grid: '1fr auto / 1fr',
          },
        }

        tokens_body = @corporation.tokens.map.with_index do |token, i|
          token_text =
            if i.zero? && @corporation.coordinates
              @corporation.coordinates.is_a?(Array) ? @corporation.coordinates.join('/') : @corporation.coordinates
            else
              token.city ? token.city.hex.name : token.price
            end
          [logo_for_user(token), token.used, token_text]
        end
        tokens_body.sort_by! { |t| t[1] ? 1 : -1 }

        @corporation.assignments.each do |assignment, _active|
          img = @game.class::ASSIGNMENT_TOKENS[assignment]
          tokens_body << [img, true, assignment]
        end

        h(:div, token_list_props, tokens_body.map do |logo, used, text|
          token_column_props[:attrs][:title] = "token #{used ? 'location: ' : 'cost: '}#{text}"
          img_props = {
            attrs: {
              src: logo,
            },
            style: {
              width: '1.5rem',
            },
          }
          img_props[:style][:filter] = 'contrast(50%) grayscale(100%)' if used

          h(:div, token_column_props, [
            h(:img, img_props),
            h(:div, text),
          ])
        end)
      end

      def share_price_str(share_price)
        share_price ? @game.format_currency(share_price.price) : ''
      end

      def share_number_str(number)
        return '' if number.zero?

        result = number.to_s
        return result unless @corporation.fraction_shares

        result.index('.') ? result : "#{result}.0"
      end

      def render_shares
        player_info = @game.players.map do |player|
          [
            player,
            @corporation.president?(player),
            player.num_shares_of(@corporation, ceil: false),
            @game.round.active_step&.did_sell?(@corporation, player),
            !@corporation.holding_ok?(player, 1),
            player.shares_of(@corporation).any?(&:double_cert),
          ]
        end

        shares_props = {
          style: {
            paddingRight: '1.3rem',
          },
        }

        player_rows = player_info
          .select { |_, _, num_shares, did_sell| !num_shares.zero? || did_sell }
          .sort_by { |_, president, num_shares, _| [president ? 0 : 1, -num_shares] }
          .map do |player, president, num_shares, did_sell, at_limit, double_cert|
            flags = (president ? '*' : '') + (double_cert ? 'd' : '') + (at_limit ? 'L' : '')
            h('tr.player', [
              h("td.left.name.nowrap.#{president ? 'president' : ''}", player.name),
              h('td.right', shares_props, "#{flags.empty? ? '' : flags + ' '}#{share_number_str(num_shares)}"),
              did_sell ? h('td.italic', 'Sold') : '',
            ])
          end

        other_corp_info = @game.corporations.reject { |c| c == @corporation }.map do |other_corp|
          [
            other_corp,
            @corporation.president?(other_corp),
            other_corp.num_shares_of(@corporation, ceil: false),
            @game.round.active_step&.did_sell?(@corporation, other_corp),
            !@corporation.holding_ok?(other_corp, 1),
          ]
        end

        other_corp_rows = other_corp_info
          .select { |_, _, num_shares, did_sell| !num_shares.zero? || did_sell }
          .sort_by { |_, president, num_shares, _| [president ? 0 : 1, -num_shares] }
          .map do |other_corp, president, num_shares, did_sell, at_limit|
            flags = (president ? '*' : '') + (at_limit ? 'L' : '')
            h('tr.corp', [
              h("td.left.name.nowrap.#{president ? 'president' : ''}", "© #{other_corp.name}"),
              h('td.right', shares_props, "#{flags.empty? ? '' : flags + ' '}#{share_number_str(num_shares)}"),
              did_sell ? h('td.italic', 'Sold') : '',
            ])
          end

        num_ipo_shares = share_number_str(@corporation.num_ipo_shares - @corporation.num_ipo_reserved_shares)
        if !num_ipo_shares.empty? && @corporation.capitalization != @game.class::CAPITALIZATION
          num_ipo_shares = '* ' + num_ipo_shares
        end
        dc = @corporation.shares_of(@corporation).any?(&:double_cert)
        dc_reserved = @corporation.reserved_shares.any?(&:double_cert)
        double_cert = dc && !dc_reserved

        pool_rows = []
        if !num_ipo_shares.empty? || double_cert || @corporation.capitalization != :full
          pool_rows << h('tr.ipo', [
            h('td.left', @game.ipo_name(@corporation)),
            h('td.right', shares_props, (double_cert ? 'd ' : '') + num_ipo_shares),
            h('td.padded_number', share_price_str(@corporation.par_price)),
          ])
        end

        if @corporation.reserved_shares.any?
          flags = (dc_reserved ? 'd ' : '') + 'R'
          pool_rows << h('tr.reserved', [
            h('td.left', @game.ipo_reserved_name),
            h('td.right', shares_props, flags + ' ' + share_number_str(@corporation.num_ipo_reserved_shares)),
            h('td.padded_number', share_price_str(@corporation.par_price)),
          ])
        end

        market_tr_props = {
          style: {
            borderBottom: player_rows.any? ? '1px solid currentColor' : '0',
          },
        }

        if player_rows.any?
          if @corporation.share_price&.highlight? &&
            (color = StockMarket::COLOR_MAP[@game.class::STOCKMARKET_COLORS[@corporation.share_price.type]])
            market_tr_props[:style][:backgroundColor] = color
            market_tr_props[:style][:color] = contrast_on(color)
          end
        end

        if player_rows.any? || @corporation.num_market_shares.positive?
          at_limit = @game.share_pool.bank_at_limit?(@corporation)
          double_cert = @game.share_pool.shares_of(@corporation).any?(&:double_cert)

          flags = (@corporation.receivership? ? '*' : '') + (double_cert ? 'd' : '') + (at_limit ? 'L' : '')

          pool_rows << h('tr.market', market_tr_props, [
            h('td.left', 'Market'),
            h('td.right', shares_props,
              flags + ' ' +
              share_number_str(@corporation.num_market_shares)),
            h('td.padded_number', share_price_str(@corporation.share_price)),
          ])
        end

        rows = [
          *pool_rows,
          *player_rows,
          *other_corp_rows,
        ]

        props = { style: { borderCollapse: 'collapse' } }

        h('table.center', props, [
          h(:thead, [
            h(:tr, [
              h(:th, 'Shareholder'),
              h(:th, 'Shares'),
              h(:th, 'Price'),
            ]),
          ]),
          h(:tbody, [
            *rows,
          ]),
        ])
      end

      def render_owned_other_shares
        shares = @corporation
          .shares_by_corporation.reject { |c, s| s.empty? || c == @corporation }
          .sort_by { |c, s| [s.sum(&:percent), c.president?(@corporation) ? 1 : 0, c.name] }
          .reverse
          .map { |c, s| render_owned_other_corp(c, s) }

        h(:table, shares)
      end

      def render_owned_other_corp(corporation, shares)
        td_props = {
          style: {
            padding: '0 0.2rem',
          },
        }
        div_props = {
          style: {
            height: '20px',
          },
        }
        logo_props = {
          attrs: {
            src: logo_for_user(corporation),
          },
          style: {
            height: '20px',
          },
        }

        president_marker = corporation.president?(@corporation) ? '*' : ''
        h('tr.row', [
          h('td.center', td_props, [h(:div, div_props, [h(:img, logo_props)])]),
          h(:td, td_props, corporation.name + president_marker),
          h('td.right', td_props, "#{shares.sum(&:percent)}%"),
        ])
      end

      def render_reserved
        bold = { style: { fontWeight: 'bold' } }
        h('table.center', [
          h(:tbody, [
            h('tr.reserved', [
              h('td.left', bold, "#{@game.ipo_reserved_name} shares:"),
              h('td.right', @corporation.reserved_shares.map { |s| "#{s.percent}%" }.join(', ')),
            ]),
          ]),
        ])
      end

      def render_revenue_history
        last_run = @corporation.operating_history[@corporation.operating_history.keys.max].revenue
        h(:div, { style: { display: 'inline', marginLeft: '2rem' } }, [
          'Last Run: ',
          h('span.bold', @game.format_currency(last_run)),
        ])
      end

      def render_operating_order
        round = @game.round
        order =
          if @game.round.operating?
            @game.round.entities.index(@corporation)
          else
            @game.operating_order.index(@corporation)
          end

        if order
          m = round.entities.index(round.current_entity) if @game.round.operating?
          span_class = '.bold' if order && m && order >= m
          [h(:div, { style: { display: 'inline' } }, [
            'Order: ',
            h("span#{span_class}", order + 1),
          ])]
        else
          []
        end
      end

      def render_loans
        interest_props = { style: {} }
        unless @game.can_pay_interest?(@corporation)
          color = StockMarket::COLOR_MAP[:yellow]
          interest_props[:style][:backgroundColor] = color
          interest_props[:style][:color] = contrast_on(color)
        end

        [
          h('tr.ipo', [
            h('td.right', 'Loans'),
            h('td.padded_number', "#{@corporation.loans.size}/"\
            "#{@game.maximum_loans(@corporation)}"),
          ]),
          h('tr.ipo', interest_props, [
            h('td.right', 'Interest Due'),
            h('td.padded_number', @game.format_currency(@game.interest_owed(@corporation)).to_s),
          ]),
        ]
      end

      def render_capitalization_type
        h('tr.ipo', [
          h('td.right', 'Cap. Type'),
          h('td.padded_number', @corporation.capitalization_type_desc.to_s),
        ])
      end

      def render_escrow_account
        h('tr.ipo', [
          h('td.right', 'Escrow'),
          h('td.padded_number', @game.format_currency(@corporation.escrow)),
        ])
      end

      def render_buying_power
        h('tr.ipo', [
          h('td.right', 'Buying Power'),
          h('td.padded_number', @game.format_currency(@game.buying_power(@corporation, full: true)).to_s),
        ])
      end

      def render_abilities(abilities)
        attribute_lines = abilities.map do |ability|
          h('div.nowrap.inline-block', ability.description)
        end

        table_props = {
          style: {
            padding: '0.5rem',
            justifyContent: 'center',
          },
        }

        h('div#attribute_table', table_props, [
          h('div.bold', 'Ability'),
          *attribute_lines,
        ])
      end

      def selected?
        @corporation == @selected_corporation
      end

      def logo_for_user(entity)
        @user&.dig('settings', 'simple_logos') ? entity.simple_logo : entity.logo
      end

      def can_assign_corporation?
        @selected_corporation && @game.abilities(@selected_company, :assign_corporation)
      end
    end
  end
end
