# frozen_string_literal: true

module View
  class Tile < Snabberb::Component
    needs :engine_tile, default: nil

    # "plain" just meaning two edges of the hex are connected
    def plain_svg_path(path)
      a = path.min
      b = path.max

      diff = b - a
      rotate = 60 * a

      if diff > 3
        diff = (a - b) % 6
        rotate = 60 * b
      end

      transform = "rotate(#{rotate})"

      case diff
      when 1  # sharp
        [
          h(:path, attrs: { transform: transform, d: 'm 0 85 L 0 75 A 43.30125 43.30125 0 0 0 -64.951875 37.5 L -73.612125 42.5', stroke: 'black', 'stroke-width' => 8 }),
        ]
      when 2  # gentle
        [
          h(:path, attrs: { transform: transform, d: 'm 0 85 L 0 75 A 129.90375 129.90375 0 0 0 -64.951875 -37.5 L -73.612125 -42.5', stroke: 'black', 'stroke-width' => 8 }),
        ]
      when 3  # straight
        [
          h(:path, attrs: { transform: transform, d: 'm 0 87 L 0 -87', stroke: 'black', 'stroke-width' => 8 }),
          # h(:path, attrs: { d: 'm -4 86 L -4 -86', stroke: 'white', 'stroke-width' => 2 }),
          # h(:path, attrs: { d: 'm 4 86 L 4 -86', stroke: 'white', 'stroke-width' => 2 }),
        ]
      end
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
      h(:g, { attrs: { transform: '' } }, children)
    end
  end
end
