# frozen_string_literal: true

require 'lib/settings'

module View
  module Game
    module GFrost1831
      class InfluenceArena < Snabberb::Component
        include Lib::Settings

        needs :game
        needs :scale, default: 1.0
        BASE_CELL_SIZE = 45
        BASE_BORDER_WIDTH = 3
        BASE_PANEL_WIDTH = 130

        ARENA_COLORS = {
          exp_3: '#e8940a',
          lor_3: '#e07868',
          tec_3: '#e8c517',
          gua_3: '#c0392b',
          exp_2: '#f0a830',
          lor_2: '#e89080',
          tec_2: '#f0d020',
          gua_2: '#d04438',
          exp_1: '#f0b840',
          lor_1: '#f0a898',
          tec_1: '#f8e030',
          gua_1: '#e05048',
          crown: '#3a3a3a',
        }.freeze

        def render
          grid = arena_grid_data
          marker_pos = @game.government_marker

          cell_size = (BASE_CELL_SIZE * @scale).to_i
          border_width = (@scale < 0.8 ? 2 : BASE_BORDER_WIDTH)
          panel_width = (BASE_PANEL_WIDTH * @scale).to_i

          grid_width = 8 * cell_size
          grid_height = 8 * cell_size
          grid_height_half = 4 * cell_size
          title_height = (@scale < 0.8 ? 22 : 32)

          container_style = {
            position: 'relative',
            width: "#{grid_width}px",
            height: "#{grid_height}px",
          }

          cells = render_grid_cells(grid, marker_pos, cell_size, border_width)

          h(:div, { style: { marginTop: (@scale < 0.8 ? '0.8rem' : '2rem'), width: '100%', overflowX: 'auto' } }, [
            h(:div, { style: { display: 'flex', gap: '0.5rem', alignItems: 'flex-start' } }, [
              h(:div, {
                  style: {
                    position: 'relative',
                    minWidth: "#{panel_width}px",
                    height: "#{grid_height}px",
                    marginTop: "#{title_height}px",
                  },
                }, [
                h(:div, { style: { position: 'absolute', top: '0' } }, [render_influence_panel('TEC')]),
                h(:div, { style: { position: 'absolute', top: "#{grid_height_half}px" } }, [render_influence_panel('EXP')]),
              ]),
              h(:div, { style: { position: 'relative' } }, [
                h(:div, {
                    style: {
                      textAlign: 'center',
                      fontWeight: 'bold',
                      fontSize: (@scale < 0.8 ? '0.85rem' : '1rem'),
                      marginBottom: '0.3rem',
                    },
                  }, 'Influence Arena'),
                h(:div, { style: container_style }, cells),
              ]),
              h(:div, {
                  style: {
                    position: 'relative',
                    minWidth: "#{panel_width}px",
                    height: "#{grid_height}px",
                    marginTop: "#{title_height}px",
                  },
                }, [
                h(:div, { style: { position: 'absolute', top: '0' } }, [render_influence_panel('LOR')]),
                h(:div, { style: { position: 'absolute', top: "#{grid_height_half}px" } }, [render_influence_panel('GUA')]),
              ]),
            ]),
          ])
        end

        private

        def render_grid_cells(grid, marker_pos, cell_size, border_width)
          cells = []
          font_size = @scale < 0.8 ? '0.7rem' : '0.85rem'
          label_font_size = @scale < 0.8 ? '0.85rem' : '1.1rem'

          8.times do |row|
            8.times do |col|
              cell = grid[row][col]
              next unless cell

              color = ARENA_COLORS[cell[:color_key]]

              border_top = border_between?(grid, col, row, col, row - 1) ? "#{border_width}px solid #1a1a1a" : 'none'
              border_bottom = border_between?(grid, col, row, col, row + 1) ? "#{border_width}px solid #1a1a1a" : 'none'
              border_left = border_between?(grid, col, row, col - 1, row) ? "#{border_width}px solid #1a1a1a" : 'none'
              border_right = border_between?(grid, col, row, col + 1, row) ? "#{border_width}px solid #1a1a1a" : 'none'

              cell_style = {
                position: 'absolute',
                left: "#{col * cell_size}px",
                top: "#{row * cell_size}px",
                width: "#{cell_size}px",
                height: "#{cell_size}px",
                backgroundColor: color,
                borderTop: border_top,
                borderBottom: border_bottom,
                borderLeft: border_left,
                borderRight: border_right,
                boxSizing: 'border-box',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: font_size,
                fontWeight: 'bold',
                color: 'rgba(60, 60, 60, 0.6)',
              }

              content = []

              if cell[:show_label] && cell[:cost].positive?
                content << h(:span, { style: { fontSize: label_font_size, fontWeight: '900', color: '#ffffff' } },
                             cell[:cost].to_s)
              end

              content << render_faction_marker if row == marker_pos[0] && col == marker_pos[1]

              cells << h(:div, { style: cell_style }, content)
            end
          end

          cells
        end

        def render_influence_panel(faction_sym)
          faction = @game.faction_by_id(faction_sym)
          return h(:div) unless faction

          total = @game.faction_influence(faction_sym)
          limit = @game.faction_influence_limit

          logo = setting_for(:simple_logos, @game) ? faction.simple_logo : faction.logo
          slots = @game.faction_support_remaining(faction_sym)
          diamonds = slots.positive? ? ' ' + ('◆' * slots) : ''
          logo_size = @scale < 0.8 ? 14 : 16
          corp_logo_size = @scale < 0.8 ? 12 : 14
          header_font_size = @scale < 0.8 ? '0.75rem' : '0.85rem'
          corp_font_size = @scale < 0.8 ? '0.7rem' : '0.8rem'
          show_player_colors = setting_for(:show_player_colors, @game)
          player_color_map = show_player_colors ? player_colors(@game.players) : {}
          faction_logo_style = {}
          if show_player_colors && (owner = faction.owner) && @game.players.include?(owner)
            faction_logo_style = {
              border: "2px solid #{player_color_map[owner]}",
              borderRadius: '50%',
            }
          end

          lines = []
          lines << h(:div, {
                       style: {
                         display: 'flex',
                         alignItems: 'center',
                         gap: (@scale < 0.8 ? '3px' : '4px'),
                         marginBottom: '2px',
                         whiteSpace: 'nowrap',
                       },
                     }, [
            h(:img, {
                attrs: { src: logo, width: logo_size.to_s, height: logo_size.to_s },
                style: faction_logo_style,
              }),
            h(:span, { style: { fontWeight: 'bold', fontSize: header_font_size } },
              "#{faction.id} (#{total}/#{limit})"),
            (h(:span, { style: { fontSize: header_font_size, marginLeft: '2px' } }, diamonds) if diamonds.length.positive?),
          ].compact)

          corp_limit = @game.corporation_influence_limit
          op_order = @game.operating_order
          supporting_corps = @game.corporations
            .select { |c| c.type != :faction && !c.closed? && c.floated? }
            .select { |c| @game.corporation_factions(c).include?(faction_sym) }
            .sort_by { |c| [-@game.corporation_influence_for(c, faction_sym), op_order.index(c) || op_order.size] }

          supporting_corps.each do |corp|
            influence = @game.corporation_influence_for(corp, faction_sym)
            corp_logo = setting_for(:simple_logos, @game) ? corp.simple_logo : corp.logo
            corp_logo_style = {}
            if show_player_colors && (corp_owner = corp.owner) && @game.players.include?(corp_owner)
              corp_logo_style = {
                border: "2px solid #{player_color_map[corp_owner]}",
                borderRadius: '50%',
              }
            end

            lines << h(:div, {
                         style: {
                           display: 'flex',
                           alignItems: 'center',
                           gap: '3px',
                           marginLeft: '4px',
                           fontSize: corp_font_size,
                         },
                       }, [
              h(:img, {
                  attrs: { src: corp_logo, width: corp_logo_size.to_s, height: corp_logo_size.to_s },
                  style: corp_logo_style,
                }),
              h(:span, "#{corp.id} (#{influence}/#{corp_limit})"),
            ])
          end

          h(:div, lines)
        end

        def render_faction_marker
          marker_size = @scale < 0.8 ? 22 : 32
          icon_size = @scale < 0.8 ? 18 : 28

          marker_style = {
            width: "#{marker_size}px",
            height: "#{marker_size}px",
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: '10',
          }
          h(:div, { style: marker_style }, [
            h(:img, { attrs: { src: '/icons/frost_1831/crown.svg', width: icon_size.to_s, height: icon_size.to_s } }),
          ])
        end

        def border_between?(grid, col1, row1, col2, row2)
          return true if col2.negative? || row2.negative? || col2 > 7 || row2 > 7

          cell1 = grid[row1][col1]
          cell2 = grid[row2][col2]
          return true if !cell1 || !cell2

          cell1[:block_id] != cell2[:block_id]
        end

        def set_cell(grid, col, row, color_key, cost, block_id, show_label)
          grid[row][col] = {
            color_key: color_key,
            cost: cost,
            block_id: block_id,
            show_label: show_label,
          }
        end

        def arena_grid_data
          grid = Array.new(8) { Array.new(8) }
          set_cell(grid, 0, 0, :exp_3, 3, :exp_tl_a, true)
          set_cell(grid, 1, 0, :exp_3, 3, :exp_tl_a, false)
          set_cell(grid, 2, 0, :exp_3, 3, :exp_tl_b, true)
          set_cell(grid, 3, 0, :exp_3, 3, :exp_tl_b, false)

          set_cell(grid, 0, 1, :exp_3, 3, :exp_tl_a, false)
          set_cell(grid, 1, 1, :exp_2, 2, :exp_ml_a, true)
          set_cell(grid, 2, 1, :exp_2, 2, :exp_ml_a, false)
          set_cell(grid, 3, 1, :exp_2, 2, :exp_ml_b, true)

          set_cell(grid, 0, 2, :exp_3, 3, :exp_bl_a, true)
          set_cell(grid, 1, 2, :exp_2, 2, :exp_ml_a, false)
          set_cell(grid, 2, 2, :exp_1, 1, :exp_in_a, true)
          set_cell(grid, 3, 2, :exp_1, 1, :exp_in_a, false)

          set_cell(grid, 0, 3, :exp_3, 3, :exp_bl_a, false)
          set_cell(grid, 1, 3, :exp_2, 2, :exp_ml_c, true)
          set_cell(grid, 2, 3, :exp_1, 1, :exp_in_a, false)
          set_cell(grid, 3, 3, :crown, 0, :crown_block, false)
          set_cell(grid, 4, 0, :lor_3, 3, :lor_tr_b, false)
          set_cell(grid, 5, 0, :lor_3, 3, :lor_tr_b, true)
          set_cell(grid, 6, 0, :lor_3, 3, :lor_tr_a, false)
          set_cell(grid, 7, 0, :lor_3, 3, :lor_tr_a, true)

          set_cell(grid, 4, 1, :lor_2, 2, :lor_mr_b, true)
          set_cell(grid, 5, 1, :lor_2, 2, :lor_mr_a, false)
          set_cell(grid, 6, 1, :lor_2, 2, :lor_mr_a, true)
          set_cell(grid, 7, 1, :lor_3, 3, :lor_tr_a, false)

          set_cell(grid, 4, 2, :lor_1, 1, :lor_in_a, false)
          set_cell(grid, 5, 2, :lor_1, 1, :lor_in_a, true)
          set_cell(grid, 6, 2, :lor_2, 2, :lor_mr_a, false)
          set_cell(grid, 7, 2, :lor_3, 3, :lor_br_a, true)

          set_cell(grid, 4, 3, :crown, 0, :crown_block, false)
          set_cell(grid, 5, 3, :lor_1, 1, :lor_in_a, false)
          set_cell(grid, 6, 3, :lor_2, 2, :lor_mr_c, true)
          set_cell(grid, 7, 3, :lor_3, 3, :lor_br_a, false)
          set_cell(grid, 0, 4, :tec_3, 3, :tec_bl_a, false)
          set_cell(grid, 1, 4, :tec_2, 2, :tec_ml_c, true)
          set_cell(grid, 2, 4, :tec_1, 1, :tec_in_a, false)
          set_cell(grid, 3, 4, :crown, 0, :crown_block, true)

          set_cell(grid, 0, 5, :tec_3, 3, :tec_bl_a, true)
          set_cell(grid, 1, 5, :tec_2, 2, :tec_ml_a, false)
          set_cell(grid, 2, 5, :tec_1, 1, :tec_in_a, true)
          set_cell(grid, 3, 5, :tec_1, 1, :tec_in_a, false)

          set_cell(grid, 0, 6, :tec_3, 3, :tec_tl_a, false)
          set_cell(grid, 1, 6, :tec_2, 2, :tec_ml_a, true)
          set_cell(grid, 2, 6, :tec_2, 2, :tec_ml_a, false)
          set_cell(grid, 3, 6, :tec_2, 2, :tec_ml_b, true)

          set_cell(grid, 0, 7, :tec_3, 3, :tec_tl_a, true)
          set_cell(grid, 1, 7, :tec_3, 3, :tec_tl_a, false)
          set_cell(grid, 2, 7, :tec_3, 3, :tec_tl_b, true)
          set_cell(grid, 3, 7, :tec_3, 3, :tec_tl_b, false)
          set_cell(grid, 4, 4, :crown, 0, :crown_block, false)
          set_cell(grid, 5, 4, :gua_1, 1, :gua_in_a, false)
          set_cell(grid, 6, 4, :gua_2, 2, :gua_mr_c, true)
          set_cell(grid, 7, 4, :gua_3, 3, :gua_br_a, false)

          set_cell(grid, 4, 5, :gua_1, 1, :gua_in_a, false)
          set_cell(grid, 5, 5, :gua_1, 1, :gua_in_a, true)
          set_cell(grid, 6, 5, :gua_2, 2, :gua_mr_a, false)
          set_cell(grid, 7, 5, :gua_3, 3, :gua_br_a, true)

          set_cell(grid, 4, 6, :gua_2, 2, :gua_mr_b, true)
          set_cell(grid, 5, 6, :gua_2, 2, :gua_mr_a, false)
          set_cell(grid, 6, 6, :gua_2, 2, :gua_mr_a, true)
          set_cell(grid, 7, 6, :gua_3, 3, :gua_tr_a, false)

          set_cell(grid, 4, 7, :gua_3, 3, :gua_tr_b, false)
          set_cell(grid, 5, 7, :gua_3, 3, :gua_tr_b, true)
          set_cell(grid, 6, 7, :gua_3, 3, :gua_tr_a, false)
          set_cell(grid, 7, 7, :gua_3, 3, :gua_tr_a, true)

          grid
        end
      end
    end
  end
end
