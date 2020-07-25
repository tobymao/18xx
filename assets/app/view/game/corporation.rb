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

      needs :corporation
      needs :selected_company, default: nil, store: true
      needs :selected_corporation, default: nil, store: true
      needs :game, store: true
      needs :display, default: 'inline-block'

      def render
        select_corporation = lambda do
          selected_corporation = selected? ? nil : @corporation
          store(:selected_corporation, selected_corporation)

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
        card_style[:border] = '4px solid' if @game.round.can_act?(@corporation)
        card_style[:display] = @display

        if selected?
          card_style[:backgroundColor] = 'lightblue'
          card_style[:color] = 'black'
        end

        children = [render_title, render_holdings]

        unless @corporation.minor?
          children << render_shares
          children << h(Companies, owner: @corporation, game: @game) if @corporation.companies.any?
        end

        abilities = @corporation.all_abilities.select { |ability| ability.owner.corporation? }
        children << render_abilities(abilities) if abilities&.any?

        if @corporation.owner
          subchildren = (@corporation.operating_history.empty? ? [] : [render_revenue_history])
          children << h('table.center', [h(:tr, subchildren)])
        end

        h('div.corp.card', { style: card_style, on: { click: select_corporation } }, children)
      end

      def render_title
        title_row_props = {
          style: {
            grid: '1fr / auto auto',
            padding: '0.2rem 0.4rem',
            background: @corporation.color,
            color: @corporation.text_color,
            height: '2.4rem',
          },
        }
        logo_props = {
          attrs: { src: @corporation.logo },
          style: {
            height: '1.6rem',
            width: '1.6rem',
            padding: '1px',
            alignSelf: 'center',
            justifySelf: 'start',
            border: '2px solid currentColor',
            borderRadius: '0.5rem',
          },
        }
        name_props = {
          style: {
            color: 'currentColor',
            display: 'inline-block',
            justifySelf: 'start',
          },
        }

        h('div.corp__title', title_row_props, [
          h(:img, logo_props),
          h('div.title', name_props, @corporation.full_name),
        ])
      end

      def render_holdings
        holdings_row_props = {
          style: {
            grid: '1fr / max-content auto minmax(4rem, max-content)',
            gap: '0 0.3rem',
            padding: '0.2rem 0.2rem 0.2rem 0.4rem',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
          },
        }
        sym_props = {
          style: {
            fontSize: '1.5rem',
            fontWeight: 'bold',
            justifySelf: 'start',
          },
        }
        holdings_props = {
          style: {
            grid: '1fr / repeat(auto-fit, auto)',
            gridAutoFlow: 'column',
            gap: '0 0.4rem',
          },
        }

        holdings =
          if !@corporation.corporation? || @corporation.floated?
            h(:div, holdings_props, [render_trains, render_cash])
          else
            h(:div, holdings_props, "#{@corporation.percent_to_float}% to float")
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

      def render_trains
        train_value = @corporation.trains.empty? ? 'None' : @corporation.trains.map(&:name).join(' ')
        render_header_segment(train_value, 'Trains')
      end

      def render_header_segment(value, key)
        segment_props = {
          style: {
            grid: '25px auto / 1fr',
          },
        }
        value_props = {
          style: {
            maxWidth: '7.5rem',
            fontWeight: 'bold',
          },
        }
        key_props = {
          style: {
            alignSelf: 'end',
          },
        }
        h(:div, segment_props, [
          h('div.right.nowrap', value_props, value),
          h(:div, key_props, key),
        ])
      end

      def render_tokens
        token_list_props = {
          style: {
            grid: '1fr / auto-flow',
            justifySelf: 'right',
            gap: '0 0.2rem',
            width: '100%',
            overflow: 'auto',
          },
        }
        token_column_props = {
          style: {
            grid: '25px auto / 1fr',
            justifyItems: 'center',
          },
        }
        token_text_props = {
          style: {
            alignSelf: 'end',
          },
        }

        tokens_body = @corporation.tokens.map.with_index do |token, i|
          img_props = {
            attrs: {
              src: token.logo,
            },
            style: {
              width: '1.5rem',
            },
          }
          img_props[:style][:filter] = 'contrast(50%) grayscale(100%)' if token.used

          token_text =
            if i.zero? && @corporation.coordinates
              @corporation.coordinates
            else
              token.city ? token.city.hex.name : token.price
            end

          h(:div, token_column_props, [
            h(:img, img_props),
            h(:div, token_text_props, token_text),
          ])
        end
        h(:div, token_list_props, tokens_body)
      end

      def share_price_str(share_price)
        share_price ? @game.format_currency(share_price.price) : ''
      end

      def share_number_str(number)
        number.positive? ? number.to_s : ''
      end

      def render_shares
        player_info = @game.players.map do |player|
          [
            player,
            @corporation.president?(player),
            player.num_shares_of(@corporation),
            @game.round.active_step.did_sell?(@corporation, player),
            !@corporation.holding_ok?(player, 1),
          ]
        end

        shares_props = {
          style: {
            paddingRight: '1.5rem',
          },
        }

        player_rows = player_info
          .select { |_, _, num_shares, did_sell| num_shares.positive? || did_sell }
          .sort_by { |_, president, num_shares, _| [president ? 0 : 1, -num_shares] }
          .map do |player, president, num_shares, did_sell, at_limit|
            flags = (president ? '*' : '') + (at_limit ? 'L' : '')
            h('tr.player', [
              h("td.name.nowrap.#{president ? 'president' : ''}", player.name),
              h('td.right', shares_props, "#{flags.empty? ? '' : flags + ' '}#{num_shares}"),
              did_sell ? h('td.italic', 'Sold') : '',
            ])
          end

        pool_rows = [
          h('tr.ipo', [
            h('td.name', @game.class::IPO_NAME),
            h('td.right', shares_props, share_number_str(@corporation.num_ipo_shares)),
            h('td.right', share_price_str(@corporation.par_price)),
          ]),
        ]

        market_tr_props = {
          style: {
            borderBottom: player_rows.any? ? '1px solid currentColor' : '0',
          },
        }

        if player_rows.any?
          if !@corporation.counts_for_limit && (color = StockMarket::COLOR_MAP[@corporation.share_price.color])
            market_tr_props[:style][:backgroundColor] = color
            market_tr_props[:style][:color] = contrast_on(color)
          end

          pool_rows << h('tr.market', market_tr_props, [
            h('td.name', 'Market'),
            h('td.right', shares_props,
              (@game.share_pool.bank_at_limit?(@corporation) ? 'L ' : '') +
              share_number_str(@corporation.num_market_shares)),
            h('td.right', share_price_str(@corporation.share_price)),
          ])
        end

        rows = [
          *pool_rows,
          *player_rows,
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

      def render_revenue_history
        last_run = @corporation.operating_history[@corporation.operating_history.keys.max].revenue
        h('td.bold', "Last Run: #{@game.format_currency(last_run)}")
      end

      def render_abilities(abilities)
        attribute_lines = []

        abilities.each do |ability|
          attribute_lines << h('div.name.nowrap', ability.name)
          attribute_lines << h('div.right', ability.display_value || '')
        end

        table_props = {
          style: {
            padding: '0 0.5rem',
            grid: 'auto / 3fr 2fr',
            gap: '0 0.2rem',
          },
        }

        h('div#company_table', table_props, [
          h('div.bold', 'Attribute'),
          h('div.bold.right', 'Value'),
          *attribute_lines,
        ])
      end

      def selected?
        @corporation == @selected_corporation
      end

      def can_assign_corporation?
        @selected_corporation && @selected_company&.abilities(:assign)
      end
    end
  end
end
