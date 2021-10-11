# frozen_string_literal: true

module View
  module Game
    module AlternateCorporations
      def render_independent_mine
        select_mine = lambda do
          if @selectable
            selected_corporation = selected? ? nil : @corporation
            store(:selected_corporation, selected_corporation)
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

        children = [
          render_mine_title,
          render_mine_holdings,
          render_mine_machines(@corporation),
          render_mine_status,
        ]

        h('div.corp.card', { style: card_style, on: { click: select_mine } }, children)
      end

      def render_public_mine
        select_mine = lambda do
          if @selectable
            selected_corporation = selected? ? nil : @corporation
            store(:selected_corporation, selected_corporation)
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

        children = [render_title, render_mine_holdings, render_shares]

        children << render_owned_other_shares if @corporation.corporate_shares.any?
        children << render_submines(use_checkboxes: false)
        children << render_mine_status

        h('div.corp.card', { style: card_style, on: { click: select_mine } }, children)
      end

      def render_mine_title
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
        children = [
          h(:img, logo_props),
          h('div.title', @corporation.full_name),
          h(:div, "Value: #{@game.format_currency(@game.minor_info[@corporation][:value])}"),
        ]

        h('div.corp__title', title_row_props, children)
      end

      def render_mine_status
        operating_props = {
          style: {
            grid: '1fr / repeat(2, max-content)',
            justifyContent: 'center',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
          },
        }

        status_props = {
          style: {
            justifyContent: 'center',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
          },
        }

        subchildren = render_operating_order
        subchildren << h(:div, operating_props, [render_revenue_history]) if @corporation.operating_history.any?
        subchildren << h(:div, @game.status_str(@corporation)) if @game.status_str(@corporation)

        h(:div, status_props, subchildren)
      end

      def render_mine_holdings
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

        children = [render_cash]
        children << h('div.nowrap', "Inc: #{@game.format_currency(@game.mine_revenue(@corporation))}")

        h('div.corp__holdings', holdings_row_props, [
          h(:div, sym_props, @corporation.name),
          h(:div, holdings_props, children),
        ])
      end

      def render_mine_machines(mine)
        machine_size = @game.machine_size(mine)
        switcher_size = @game.switcher_size(mine) || 0

        highlight_prop = { style: { border: '2px solid black' } }
        shade_prop = { style: { backgroundColor: 'gray' } }
        shade_highlight_prop = { style: { border: '2px solid black', backgroundColor: 'gray' } }
        machine_row = @game.minor_info[mine][:machine_revenue].map.with_index do |mr, idx|
          if (idx == machine_size - 1) && (@game.connected_mine?(mine) || idx.zero?)
            h('td.padded_number', highlight_prop, mr)
          elsif idx == machine_size - 1
            h('td.padded_number', shade_highlight_prop, mr)
          elsif @game.connected_mine?(mine) || idx.zero?
            h('td.padded_number', mr)
          else
            h('td.padded_number', shade_prop, mr)
          end
        end
        switcher_row = @game.minor_info[mine][:switcher_revenue].map.with_index do |sr, idx|
          if idx == switcher_size - 2 && @game.connected_mine?(mine)
            h('td.padded_number', highlight_prop, sr)
          elsif idx == switcher_size - 2
            h('td.padded_number', shade_highlight_prop, sr)
          elsif @game.connected_mine?(mine)
            h('td.padded_number', sr)
          else
            h('td.padded_number', shade_prop, sr)
          end
        end
        if @game.connected_mine?(mine)
          switcher_row.unshift(h('td.padded_number', ' '))
        else
          switcher_row.unshift(h('td.padded_number', shade_prop, ' '))
        end
        rows = [
          h('tr', [
            h('td', "#{@game.machine_size(mine)}M"),
            *machine_row,
          ]),
          h('tr', [
            h('td', @game.switcher(mine) ? "#{@game.switcher_size(mine)}S" : '!S'),
            *switcher_row,
          ]),
        ]

        props = { style: { borderCollapse: 'collapse' } }

        h('table.center', props, [
          h(:tbody, rows),
        ])
      end

      def render_submines(use_checkboxes: true)
        mines = @game.public_mine_mines(@corporation)

        row_props = { style: { border: '1px solid black' } }

        item_props = { style: { verticalAlign: 'middle' } }

        rows = mines.map do |m|
          logo_props = {
            attrs: {
              src: m.logo,
            },
            style: {
              paddingRight: '1px',
              paddingLeft: '1px',
              height: '20px',
            },
          }

          row_children = [h('td', item_props, [h(:img, logo_props)])]
          if use_checkboxes
            checkbox = h(
              'input.no_margin',
              style: {
                width: '1rem',
                height: '1rem',
                padding: '0 0 0 0.2rem',
              },
              attrs: {
                type: 'checkbox',
                id: "mine_#{m.name}",
                name: "mine_#{m.name}",
              }
            )
            row_children << h('td', item_props, [checkbox])
            @slot_checkboxes[@game.get_slot(@corporation, m)] = checkbox
          end
          row_children << h('td', item_props, [render_mine_machines(m)])

          h('tr', row_props, row_children)
        end

        empty_cell_props = { style: { minHeight: '1rem' } }

        rows += Array.new((@game.corporation_info[@corporation][:slots] - mines.size)) do |_i|
          h('tr', row_props, [
            h('td', { attrs: { colspan: '3' } }, [h('div', empty_cell_props, '(empty slot)')]),
          ])
        end

        table_props = { style: { borderCollapse: 'collapse' } }

        step = @game.round.active_step
        text = ''
        text = step.checkbox_prompt if step.respond_to?(:checkbox_prompt) && use_checkboxes

        h('div', { style: { padding: '0.5rem' } }, [
          text,
          h('table.center', table_props, [
            h(:tbody, [
              *rows,
            ]),
          ]),
        ])
      end
    end
  end
end
