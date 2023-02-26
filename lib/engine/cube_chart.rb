# frozen_string_literal: true

module Engine
  class CubeChart
    attr_reader :header, :footer, :layout, :row_labels

    def initialize(header, footer, layout, row_labels)
      @header = header
      @footer = footer
      @layout = layout.map do |row|
        row.map do |label|
          { 'label' => label, 'cube' => true }
        end
      end
      @row_labels = row_labels
      @next_cube = [0, 0]
    end

    def remove_cube!
      return unless @next_cube

      @layout[@next_cube[0]][@next_cube[1]]['cube'] = false
      @next_cube = next_cell(@next_cube)
    end

    def add_cube!
      prev = prev_cell(@next_cube)
      return unless prev

      @next_cube = prev
      @layout[@next_cube[0]][@next_cube[1]]['cube'] = true
    end

    def next_cell(cell)
      return nil unless cell

      if @layout[cell[0]].length == cell[1] + 1
        [cell[0] + 1, 0] if @layout.length > cell[0] + 1
      else
        [cell[0], cell[1] + 1]
      end
    end

    def prev_cell(cell)
      return last_cell unless cell

      if (cell[1]).zero?
        [cell[0] - 1, @layout[cell[0] - 1].length - 1] if (cell[0]).positive?
      else
        [cell[0], cell[1] - 1]
      end
    end

    def last_cell
      [@layout.length - 1, @layout[@layout.length - 1].length - 1]
    end

    def label_last_open_space
      cell = prev_cell(@next_cube)
      @row_labels[cell ? cell[0] : 0]
    end

    def any_cubes?
      @next_cube ? true : false
    end
  end
end
