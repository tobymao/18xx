# frozen_string_literal: true

module View
  class Tile < Snabberb::Component
    needs :engine_tile, default: nil
    needs :rotate_steps, default: 0  # 0-5

    # "plain" just meaning two edges of the hex are connected
    def plain_svg_path(path)
      a = path.min
      b = path.max

      # diff = how many steps apart the two edges connected by the path are
      #
      # rotate = degrees to rotate the svg path for this track path; e.g., a
      # normal gentle is 0,2; for 1,3, rotate = 60
      diff = b - a
      if diff > 3
        diff = (a - b) % 6
        rotate = 60 * b
      else
        rotate = 60 * a
      end

      transform = "rotate(#{rotate})"

      d = case diff

      # sharp
      when 1
          'm 0 85 L 0 75 A 43.30125 43.30125 0 0 0 -64.951875 37.5 L -73.612125 42.5'

      # gentle
      when 2
          'm 0 85 L 0 75 A 129.90375 129.90375 0 0 0 -64.951875 -37.5 L -73.612125 -42.5'

      # straight
      when 3
          'm 0 87 L 0 -87'
          # h(:path, attrs: { d: 'm -4 86 L -4 -86', stroke: 'white', 'stroke-width' => 2 }),
          # h(:path, attrs: { d: 'm 4 86 L 4 -86', stroke: 'white',
          # 'stroke-width' => 2 }),

      else
        ''
      end

      [
        h(:path, attrs: { transform: transform, d: d, stroke: 'black', 'stroke-width' => 8 }),
      ]
    end

    def hex_paths_to_svg_paths
      @engine_tile.paths.flat_map do |path|
        if path.all? { |x| x.is_a?(Numeric) }
          plain_svg_path(path)
        end
      end
    end

    def render
      children = hex_paths_to_svg_paths
      h(:g, { attrs: { transform: "rotate(#{60 * @rotate_steps})" } }, children)
    end
  end
end
