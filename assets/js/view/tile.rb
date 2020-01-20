# frozen_string_literal: true

require 'set'

require 'engine/edge'

module View
  class Tile < Snabberb::Component
    needs :tile

    # TODO: support for track when city is not in center of tile (e.g., NY, OO)
    def render_track_edge_to_city(path)
      edge = path.find { |p| p.is_a?(Engine::Edge) }

      rotate = 60 * edge.num

      transform = "rotate(#{rotate})"

      d = 'M 0 87 L 0 0'

      [
        h(:path, attrs: { transform: transform, d: d, stroke: 'black', 'stroke-width' => 8 }),
      ]
    end

    # TODO: extract diff and rotate computations to small function and add unit
    # tests
    # TODO: add white border to track
    def render_track_edge_to_edge(path)
      a, b = path.sort

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

      d =
        case diff
        when 1 # sharp
          'm 0 85 L 0 75 A 43.30125 43.30125 0 0 0 -64.951875 37.5 L -73.612125 42.5'
        when 2 # gentle
          'm 0 85 L 0 75 A 129.90375 129.90375 0 0 0 -64.951875 -37.5 L -73.612125 -42.5'
        when 3 # straight
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

    # TODO: support for multiple station locations in one city
    # TOOD: support for multiple cities on one tile (e.g., NY, OO)
    def render_cities
      return [] if @tile.cities.empty?

      city = @tile.cities.first

      city_spot = h(:g, { attrs: { transform: '' } }, [
        h(:circle, attrs: { r: 25, fill: 'white' })
      ])

      city_revenue = h(
        :g,
        { attrs: { 'stroke-width': 1, transform: "translate(-25 40) rotate(-#{60 * @tile.rotation})" } },
        [
          h(:circle, attrs: { r: 14, fill: 'white' }),
          h(:text, attrs: { transform: 'translate(-8 6)' }, props: { innerHTML: city.revenue }),
        ]
      )

      [city_spot, city_revenue]
    end

    # TODO: support for lawson track
    def render_track
      @tile.paths.flat_map do |path|
        a = path.a
        b = path.b

        if [a, b].all? { |x| x.is_a?(Engine::Edge) }
          render_track_edge_to_edge([a.num, b.num])
        elsif ::Set.new([a.class, b.class]) == ::Set.new([Engine::Edge, Engine::City])
          render_track_edge_to_city([a, b])
        end
      end
    end

    def render
      attrs = {
        transform: "rotate(#{60 * @tile.rotation})",
        'stroke-width' => 1,
      }

      h(:g, { attrs: attrs }, render_track + render_cities)
    end
  end
end
