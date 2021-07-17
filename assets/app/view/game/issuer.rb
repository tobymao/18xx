# frozen_string_literal: true

require 'lib/settings'
require 'lib/truncate'
require 'view/game/actionable'

module View
  module Game
    class Issuer < Snabberb::Component
      include Actionable
      include Lib::Settings

      needs :issuer
      needs :selected_issuer, default: nil, store: true
      needs :tile_selector, default: nil, store: true
      needs :display, default: 'inline-block'
      needs :layout, default: nil

      def selected?
        @issuer == @selected_issuer
      end

      def select_issuer(event)
        event.JS.stopPropagation
        selected_issuer = selected? ? nil : @issuer

        store(:tile_selector, nil, skip: true)
        store(:selected_issuer, selected_issuer)
      end

      def render
        if @layout == :table
          @hidden_divs = {}
          render_issuer_on_card(@issuer)
        else
          header_style = {
            background: @issuer.color,
            color: @issuer.text_color,
            border: '1px solid',
            borderRadius: '5px',
            marginBottom: '0.5rem',
            fontSize: '90%',
          }

          description_style = {
            margin: '0.5rem 0',
            fontSize: '80%',
            textAlign: 'left',
            fontWeight: 'normal',
          }

          value_style = {
            float: 'left',
          }

          revenue_style = {
            float: 'right',
          }

          props = {
            style: {
              cursor: 'pointer',
              boxSizing: 'border-box',
              padding: '0.5rem',
              margin: '0.5rem 5px 0 0',
              textAlign: 'center',
              fontWeight: 'bold',
            },
            on: { click: ->(event) { select_issuer(event) } },
          }
          if selected?
            props[:style][:backgroundColor] = 'lightblue'
            props[:style][:color] = 'black'
            props[:style][:border] = '1px solid'
          end
          props[:style][:display] = @display

          header_text = @game.respond_to?(:issuer_header) ? @game.issuer_header(@issuer) : 'ISSUER'
          revenue_str = if @game.respond_to?(:issuer_revenue_str)
                          @game.issuer_revenue_str(@issuer)
                        else
                          @game.format_currency(@issuer.revenue)
                        end

          children = [
            h(:div, { style: header_style }, header_text),
            h(:div, @issuer.full_name),
            h(:div, { style: description_style }, @issuer.desc),
            h(:div, { style: value_style }, "Bond Value: #{@game.format_currency(@issuer.value)}"),
            h(:div, { style: revenue_style }, "Revenue: #{revenue_str}"),
          ]

          if @game.issuer_status_str(@issuer)
            status_style = {
              marginTop: '0.5rem',
              clear: 'both',
              display: 'inline-block',
              justifyContent: 'center',
              width: '100%',
              backgroundColor: color_for(:bg2),
              color: color_for(:font2),
            }
            if @game.respond_to?(:issuer_revenue_str) && @game.issuer_status_str(issuer)
              children << h(:div, { style: status_style }, @game.issuer_status_str(@issuer))
            end
          end

          bond_props = {
            style: {
              paddingRight: '1.3rem',
            },
          }

          pool_bonds = @issuer.bonds.select(&:owned_by_issuer?)
          pool_rows = []
          if pool_bonds.any?
            pool_rows << h('tr.ipo', [
              h('td.left', 'Market'),
              h('td.right', bond_props, pool_bonds.size),
            ])
          end

          player_rows = entities_rows(@game.players)
          corp_rows = entities_rows(@game.corporations)

          rows = [
            *pool_rows,
            *player_rows,
            *corp_rows,
          ]

          owner_props = {
            style: {
              borderCollapse: 'collapse',
              fontWeight: 'normal',
            },
          }

          children << h('table.center', owner_props, [
                        h(:thead, [
                          h(:tr, [
                            h(:th, 'Owner'),
                            h(:th, 'Bonds'),
                          ]),
                        ]),
                        h(:tbody, [
                          *rows,
                        ]),
                      ])

          h('div.issuer.card', props, children)
        end
      end

      def toggle_desc(event, issuer)
        event.JS.stopPropagation
        elm = Native(@hidden_divs[issuer.sym]).elm
        elm.style.display = elm.style.display == 'none' ? 'grid' : 'none'
      end

      def render_issuer_on_card(issuer)
        extra = []
        if @game.respond_to?(:issuer_revenue_str) && @game.issuer_status_str(issuer)
          extra << " #{@game.issuer_status_str(issuer)}"
        end

        name_props = {
          attrs: { title: "#{title_str}, click to toggle description" },
          style: {
            cursor: 'pointer',
            grid: '1fr / 1fr auto',
            gap: '0 0.2rem',
          },
          on: { click: ->(event) { toggle_desc(event, issuer) } },
        }
        hidden_props = {
          style: {
            display: 'none',
            gridColumnEnd: '3',
            marginBottom: '0.5rem',
            padding: '0.1rem 0.2rem',
            fontSize: '80%',
          },
        }
        @hidden_divs[issuer.sym] = h(:div, hidden_props, issuer.desc)
        revenue_str = if @game.respond_to?(:issuer_revenue_str)
                        @game.issuer_revenue_str(issuer)
                      else
                        @game.format_currency(issuer.revenue)
                      end

        [h(:div, name_props, [h('span.nowrap', issuer_name_str), h(:span, extra)]),
         h('div.right', @game.format_currency(usser.value)),
         h('div.padded_number', revenue_str),
         @hidden_divs[issuer.sym]]
      end

      def entities_rows(entities)
        entity_info = entities.map do |entity|
          [
            entity,
            entity.bonds_of(@issuer).size,
            @game.round.active_step&.did_sell?(@issuer, entity),
            @game.round.active_step&.last_acted_upon?(@issuer, entity),
          ]
        end

        bond_props = {
          style: {
            paddingRight: '1.3rem',
          },
        }

        entity_info
        .select { |_, num_bonds, did_sell| !num_bonds.zero? || did_sell }
        .sort_by { |_, num_bonds, _| -num_bonds }
        .map do |entity, num_bonds, did_sell, last_acted_upon|
          type = entity.player? ? 'tr.player' : 'tr.corp'
          type += '.bold' if last_acted_upon
          name = entity.player? ? entity.name : "© #{entity.name}"

          h(type, [
            h('td.left.name.nowrap', name),
            h('td.right', bond_props, bond_number_str(num_bonds).to_s),
            did_sell ? h('td.italic', 'Sold') : '',
          ])
        end
      end

      def bond_number_str(number)
        return '' if number.zero?

        number.to_s
      end
    end
  end
end
