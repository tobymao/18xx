# frozen_string_literal: true

require 'set'

require 'engine/game_error'

module View
  class Tile < Snabberb::Component
    SHARP = 1
    GENTLE = 2
    STRAIGHT = 3
    # key is how many city slots are part of the city; value is the offset for
    # the first city slot
    CITY_SLOT_POSITION = {
      1 => [0, 0],
      2 => [-25, 0],
      3 => [0, -29],
      4 => [-25, -25],
      5 => [0, -43],
      6 => [0, -50],
    }.freeze

    needs :tile

    # returns SHARP, GENTLE, or STRAIGHT
    def compute_curvilinear_type(edge_a, edge_b)
      diff = edge_b - edge_a
      diff = (edge_a - edge_b) % 6 if diff > 3
      diff
    end

    # degrees to rotate the svg path for this track path; e.g., a normal straight
    # is 0,3; for 1,4, rotate = 60
    def compute_track_rotation_degrees(edge_a, edge_b)
      if (edge_b - edge_a) > 3
        60 * edge_b
      else
        60 * edge_a
      end
    end

    # "just track" means no towns/cities
    def render_just_track
      @tile.lawson? ? render_lawson_track : render_curvilinear_track
    end

    def render_curvilinear_track
      @tile.paths.flat_map do |path|
        render_curvilinear_track_segment(path.a.num, path.b.num)
      end
    end

    def render_curvilinear_track_segment(edge_num_a, edge_num_b)
      a, b = [edge_num_a, edge_num_b].sort

      curvilinear_type = compute_curvilinear_type(a, b)
      rotation = compute_track_rotation_degrees(a, b)

      transform = "rotate(#{rotation})"

      d =
        case curvilinear_type
        when SHARP
          'm 0 85 L 0 75 A 43.30125 43.30125 0 0 0 -64.951875 37.5 L -73.612125 42.5'
        when GENTLE
          'm 0 85 L 0 75 A 129.90375 129.90375 0 0 0 -64.951875 -37.5 L -73.612125 -42.5'
        when STRAIGHT
          'm 0 87 L 0 -87'
        end

      [
        h(:path, attrs: { transform: transform, d: d, stroke: 'black', 'stroke-width' => 8 }),
      ]
    end

    def render_lawson_track
      @tile
        .connections
        .select(&:edge?)
        .map(&:num)
        .flat_map { |e| render_lawson_track_segment(e) }
    end

    def render_lawson_track_segment(edge_num)
      rotate = 60 * edge_num

      props = {
        attrs: {
          transform: "rotate(#{rotate})",
          d: 'M 0 87 L 0 0',
          stroke: 'black',
          'stroke-width' => 8
        }
      }

      [
        h(:path, props),
      ]
    end

    def render_revenue(revenue)
      [
        h(
          :g,
          { attrs: { 'stroke-width': 1, transform: 'translate(-25 40)' } },
          [
            h(:circle, attrs: { r: 14, fill: 'white' }),
            h(:text, { attrs: { transform: 'translate(-8 6)' } }, revenue),
          ]
        )
      ]
    end

    # render the small rectangle representing a town stop between curvilinear
    # track connecting A and B
    def render_town_rect(edge_a, edge_b)
      width = 8
      height = 28

      rotation_edge = (edge_b - edge_a) > 3 ? edge_a : edge_b
      rotation_offset = 60 * rotation_edge

      translation, rotation =
        case compute_curvilinear_type(edge_a, edge_b)
        when SHARP
          [30, -30 + rotation_offset]
        when GENTLE
          [5, -60 + rotation_offset]
        when STRAIGHT
          [-(height / 2), 90 + rotation_offset]
        else
          [0, 0]
        end

      [
        h(
          :g,
          { attrs: { transform: "rotate(#{rotation})" } },
          [
            h(
              :rect,
              attrs: {
                transform: "translate(#{-(width / 2)} #{translation})",
                height: height,
                width: width,
                fill: 'black'
              },
            ),
          ]
        )
      ]
    end

    def render_track_town(town)
      edges = @tile
        .paths
        .select { |p| p.a == town || p.b == town }
        .flat_map { |p| [p.a, p.b].select(&:edge?) }

      if edges.count == 2
        edge_nums = edges.map(&:num).sort
        r_track = render_curvilinear_track_segment(*edge_nums)
        r_town = render_town_rect(*edge_nums)
        r_revenue = render_revenue(town.revenue)
        r_track + r_town + r_revenue
      elsif edges.count == 1
        # TODO, e.g., IR2
      elsif edges.count > 2
        # TODO, e.g., 141
      end
    end

    def render_track_single_town
      render_track_town(@tile.towns.first)
    end

    def render_track_double_town
      @tile.towns.flat_map do |town|
        render_track_town(town)
      end
    end

    def render_city_slots_center(slots = 1)
      x, y = CITY_SLOT_POSITION[slots]

      circles = (0..(slots - 1)).map do |c|
        rotation = (360 / slots) * c
        # use the rotation on the outer <g> to position the circle, then use
        # -rotation on the <circle> so its contents are rendered without
        # rotation
        h(:g, { attrs: { transform: "rotate(#{rotation})" } }, [
          h(:circle, attrs: { r: 25, fill: 'white', transform: "translate(#{x}, #{y}) rotate(#{-rotation})" }),
        ])
      end

      [h(:g, circles)]
    end

    def render_track_single_city
      city = @tile.cities.first
      slots = city.slots

      render_lawson_track + render_city_slots_center(slots) + render_revenue(city.revenue)
    end

    def render_track
      case [@tile.cities.count, @tile.towns.count]
      when [0, 0]
        render_just_track
      when [1, 0]
        render_track_single_city
      when [0, 1]
        render_track_single_town
      when [0, 2]
        render_track_double_town
      else
        raise Engine::GameError, "Don't how to render track for #{@tile.towns.count}"\
                                 " towns and #{@tile.cities.count} cities."
      end
    end

    # render letter label, like "Z", "H", "OO"
    def render_label
      [h(:text, { attrs: { transform: 'scale(2.5) translate(10 30)' } }, @tile.label)]
    end

    # render city/town name iff no other label is present
    def render_name
      # nothing to do if there's already a label (might reconsider this)
      return [] unless @tile.label.to_s == ''

      revenue_center = (@tile.cities + @tile.towns).find(&:name)
      name = revenue_center&.name
      # don't render names starting with "_"; this allows differentiating the
      # towns on a double-town tile by using the name property without rendering
      # the name
      return [] if !name || name[0] == '_'

      [h(:text, { attrs: { transform: 'scale(1.5) translate(10 30)' } }, name)]
    end

    def render
      attrs = {
        fill: 'none',
        'stroke-width' => 1,
      }

      children =
        begin
          render_track + render_label + render_name
        rescue Engine::GameError => e
          # TODO: send to console.error
          puts("Engine::GameError: Cannot render Tile '#{@tile.name}': #{e}")
          [h(:text, { attrs: { transform: 'scale(2.5)' } }, @tile.name)]
        end

      h(:g, { attrs: attrs }, children)
    end
  end
end
