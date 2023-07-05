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
        @num_columns = @loan_chart[0][:loans].size + 1

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
        contents << h(:div, { style: grid_style }, render_chart)
        h(:div, contents)
      end

      def render_chart
        contents = []
        @loan_chart.each do |row|
          contents << render_row_header(row[:header])
          row[:loans].each do |loan|
            contents << render_loan(loan)
          end
        end
        contents
      end

      def render_row_header(label)
        stock_movement_style = {
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          fontSize: 'xx-large',
          backgroundColor: 'gray',
        }

        h(:div, { style: stock_movement_style }, label)
      end

      def render_loan(loan)
        return h(:div, nil) unless loan

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
        contents << h(:div, { style: cell_style }, loan[:value])
        contents << h(:div, { style: cell_style }, [h(:img, cube_props)]) unless loan[:loan_taken]
        h(:div, { style: grid_style }, contents)
      end
    end
  end
end
