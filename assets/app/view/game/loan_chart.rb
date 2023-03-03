# frozen_string_literal: true

# attrs frozen_string_literal: true

require 'view/game/actionable'
require 'lib/settings'

module View
  module Game
    class LoanChart < Snabberb::Component
      include Actionable
      include Lib::Settings

      def render
        @loan_chart = @game.loan_chart
        @num_rows = @loan_chart.size
        @num_columns = @loan_chart.map(&:size).max
        @empty_cube_spaces = @game.loans_taken

        name_style = {
          padding: '1rem',
          fontSize: 'large',
        }

        grid_style = {
          display: 'grid',
          gridTemplateColumns: "repeat(#{@num_columns}, 4rem)",
          gridTemplateRows: "repeat(#{@num_rows}, 4rem)",
          border: 'solid 1px rgba(0,0,0,1)',
          padding: '4px',
          color: color_for(:font2),
          width: '100%',
          overflow: 'auto',
          rowGap: '1px',
          columnGap: '1px',
        }

        contents = []
        contents << h(:div, { style: name_style }, @game.loan_entity_name)
        contents << h(:div, { style: grid_style }, chart)
        h(:div, contents)
      end

      def chart
        contents = []
        @loan_chart.each do |row|
          contents << render_first_cell(row[0])
          row.drop(1).each do |cell|
            contents << render_cube_cell(cell, @empty_cube_spaces.zero?)
            @empty_cube_spaces -= 1 if @empty_cube_spaces.positive?
          end
          (@num_columns - row.size).times { contents << render_empty_cell }
        end
        contents
      end

      def render_first_cell(label)
        @stock_movement_style = {
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          fontSize: 'xx-large',
          backgroundColor: 'gray',
        }

        h(:div, { style: @stock_movement_style }, label)
      end

      def render_cube_cell(cell, has_cube)
        grid_style = {
          display: 'grid',
          gridTemplateRows: '30% 70%',
          backgroundColor: '#DCDCDC',
        }

        cell_style = {
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          fontSize: 'large',
          paddingTop: '5px',
          paddingBottom: '5px',
        }

        cube_props = {
          attrs: {
            src: '../icons/red_cube.svg',
            title: 'cube',
          },
          style: {
            objectFit: 'scale-down',
            width: '100%',
            maxHeight: '100%',
          },
        }

        contents = []
        contents << h(:div, { style: cell_style }, cell)
        contents << h(:div, { style: cell_style }, [h(:img, cube_props)]) if has_cube
        h(:div, { style: grid_style }, contents)
      end

      def render_empty_cell
        h(:div, nil)
      end
    end
  end
end
