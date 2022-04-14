# frozen_string_literal: true

module View
  module Game
    module AlternateCompanies
      SYMBOL_SIZE = 30
      CIRCLE_SIZE = 30
      RECT_SIZE = 30
      SYMBOL_FONT_SIZE = {
        1 => 10,
        2 => 10,
        3 => 10,
        4 => 10,
        5 => 8,
      }.freeze

      def render_rs_company
        header_style = {
          display: 'block',
          background: @game.company_colors(@company)[0],
          color: @game.company_colors(@company)[1],
          fontSize: '110%',
          textAlign: 'center',
          border: '1px solid',
          borderRadius: '5px',
          marginBottom: '0.5rem',
        }

        element_style = {
          display: 'inline-block',
          textAlign: 'center',
          margin: '0 0.5rem',
        }

        box_style = {
          margin: '1px',
        }

        box_style[:color] = @game.company_colors(@company)[4] if @game.company_highlight[@company]

        label_style = {
          fontSize: '60%',
          fontWeight: 'normal',
        }

        name_style = {
          fontSize: '75%',
        }

        owner_style = {
          marginTop: '0.5rem',
          display: 'inline-block',
          clear: 'both',
          width: '100%',
          fontWeight: 'normal',
          fontSize: '90%',
        }

        props = {
          style: {
            cursor: 'pointer',
            boxSizing: 'border-box',
            padding: '0.5rem',
            margin: '0.5rem 5px 0 0',
            textAlign: 'center',
            fontWeight: 'bold',
            color: 'black',
            backgroundColor: @game.company_colors(@company)[2],
          },
          on: { click: ->(event) { select_company(event) } },
        }

        if selected?
          props[:style][:backgroundColor] = 'lightblue'
          props[:style][:border] = '1px solid'
        end
        props[:style][:border] = '1px dashed' unless @game.company_available?(@company)
        props[:style][:display] = @display

        company_name_str = "#{@game.level_symbol(@game.company_level[@company])} #{@company.name}"

        header = [
          h(:div, { style: element_style }, [
            h(:div, { style: box_style }, @game.company_header(@company)),
            h(:div, { style: label_style }, 'Company'),
          ]),
          h(:div, { style: element_style }, [
            h(:div, @game.format_currency(@company.value)),
            h(:div, { style: label_style }, 'Value'),
          ]),
          h(:div, { style: element_style }, [
            h(:div, "(#{@game.format_currency(@company.min_price)}-#{@game.format_currency(@company.max_price)})"),
            h(:div, { style: label_style }, 'Range'),
          ]),
          h(:div, { style: element_style }, [
            h(:div, @game.format_currency(@game.company_income(@company)).to_s),
            h(:div, { style: label_style }, 'Income'),
          ]),
        ]

        children = [
          h(:div, { style: header_style }, header),
          h(:div, { style: name_style }, company_name_str),
          render_synergies,
        ]

        if @company.owner && @layout != :table
          children << h('div.nowrap', { style: owner_style }, "Owner: #{@company.owner.name}")
        end

        h('div.company.card', props, children)
      end

      def render_synergies
        value_style = {
          margin: '2px 2px',
          display: 'inline-block',
        }

        symbol_row_style = {
          display: 'flex',
          flexWrap: 'wrap',
        }

        line_style = {
          display: 'flex',
          textAlign: 'left',
        }

        groups = @game.company_synergies[@company].keys.group_by { |c| @game.synergy_value_by_level(@company, c) }

        set = @company&.owner&.corporation? ? @company.owner.companies : []

        synergy_lines = []
        groups.each do |k, v|
          synergy_value = h(:div, { style: value_style }, "+#{@game.format_currency(k)}")

          synergy_items = v.map do |synergy|
            symbol_style = {
              padding: '1px',
              display: 'inline-block',
            }

            higher = @company.value > synergy.value
            h(:div, { style: symbol_style }, [render_symbol(synergy, higher, set.include?(synergy))])
          end

          synergy_row = h(:div, { style: symbol_row_style }, synergy_items)

          synergy_lines << h(:hr) unless synergy_lines.empty?
          synergy_lines << h(:div, { style: line_style }, [synergy_value, synergy_row])
        end

        h(:div, synergy_lines)
      end

      def render_symbol(synergy, higher, border)
        text = synergy.sym
        stroke_width = border ? 2 : 1

        circle_attrs = {
          cx: "#{CIRCLE_SIZE / 2}px",
          cy: "#{CIRCLE_SIZE / 2}px",
          r: "#{(CIRCLE_SIZE - stroke_width) / 2}px",
          fill: @game.company_colors(synergy)[0],
          stroke: border ? 'black' : 'rgba(0,0,0,0.2)',
          'stroke-width': "#{stroke_width}px",
        }

        rect_attrs = {
          height: "#{RECT_SIZE * 0.707}px",
          width: "#{RECT_SIZE * 0.707}px",
          x: "#{RECT_SIZE / 2 * 0.707}px",
          y: "-#{RECT_SIZE / 2 * 0.707}px",
          rx: '3px',
          ry: '3px',
          fill: @game.company_colors(synergy)[0],
          stroke: border ? 'black' : 'rgba(0,0,0,0.2)',
          'stroke-width': "#{stroke_width}px",
          transform: 'rotate(45)',
        }

        text_attrs = {
          x: "#{SYMBOL_SIZE / 2}px",
          y: "#{SYMBOL_SIZE / 2}px",
          'dominant-baseline': 'central',
          'text-anchor': 'middle',
          fill: @game.company_colors(synergy)[@game.company_highlight[synergy] ? 4 : 1],
          'font-size': (SYMBOL_FONT_SIZE[text.length]).to_s,
        }

        svg_attrs = {
          width: "#{SYMBOL_SIZE}px",
          height: "#{SYMBOL_SIZE}px",
        }

        if higher
          h(:svg, { attrs: svg_attrs }, [
            h(:g, [
              h(:circle, attrs: circle_attrs),
              h(:text, { attrs: text_attrs }, text),
            ]),
          ])
        else
          h(:svg, { attrs: svg_attrs }, [
            h(:g, [
              h(:rect, attrs: rect_attrs),
              h(:text, { attrs: text_attrs }, text),
            ]),
          ])
        end
      end
    end
  end
end
