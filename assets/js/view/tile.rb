# frozen_string_literal: true

require 'snabberb/component'

require 'view/city'
require 'view/tile_parts/upgrade'

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
    needs :route, default: nil, store: true

    # returns SHARP, GENTLE, or STRAIGHT
    def compute_curvilinear_type(edge_a, edge_b)
      edge_a, edge_b = edge_b, edge_a if edge_b < edge_a
      diff = edge_b - edge_a
      diff = (edge_a - edge_b) % 6 if diff > 3
      diff
    end

    # degrees to rotate the svg path for this track path; e.g., a normal straight
    # is 0,3; for 1,4, rotate = 60
    def compute_track_rotation_degrees(edge_a, edge_b)
      edge_a, edge_b = edge_b, edge_a if edge_b < edge_a

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
      color = 'red' if @route_paths.any?

      @tile.paths.flat_map do |path|
        render_curvilinear_track_segment(*path.exits, color)
      end
    end

    def render_curvilinear_track_segment(edge_a, edge_b, color = nil)
      curvilinear_type = compute_curvilinear_type(edge_a, edge_b)
      rotation = compute_track_rotation_degrees(edge_a, edge_b)

      transform = "rotate(#{rotation})"

      d =
        case curvilinear_type
        when SHARP
          'm 0 85 L 0 75 A 43.30125 43.30125 0 0 0 -64.951875 37.5 L -73.612125 42.5'
        when GENTLE
          'm 0 85 L 0 75 A 129.90375 129.90375 0 0 0 -64.951875 -37.5 L -73.612125 -42.5'
        when STRAIGHT
          'm 0 87 L 0 -87'
        else
          raise
        end

      [h(:path, attrs: { transform: transform, d: d, stroke: color || 'black', 'stroke-width' => 8 })]
    end

    def render_lawson_track
      exits = @route_paths.flat_map(&:exits)

      @tile.exits.flat_map do |e|
        color = 'red' if exits.include?(e)
        render_lawson_track_segment(e, color)
      end
    end

    def render_lawson_track_segment(edge_num, color = 'black')
      rotate = 60 * edge_num

      props = {
        attrs: {
          transform: "rotate(#{rotate})",
          d: 'M 0 87 L 0 0',
          stroke: color,
          'stroke-width' => 8
        }
      }

      [
        h(:path, props),
      ]
    end

    def render_revenue(revenue)
      return [] if revenue.zero?

      [
        h(
          :g,
          { attrs: { 'stroke-width': 1, transform: 'translate(-41 71)' } },
          [
            h(:circle, attrs: { r: 14, fill: 'white' }),
            h(:text, { attrs: { fill: 'black', transform: 'translate(-8 6)' } }, revenue),
          ]
        )
      ]
    end

    # render the small rectangle representing a town stop between curvilinear
    # track connecting A and B
    def render_town_rect(edge_a, edge_b)
      edge_a, edge_b = edge_b, edge_a if edge_b < edge_a
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
      color = 'red' if @route_paths.flat_map(&:towns).any?

      exits = @tile
        .paths
        .select { |p| p.a == town || p.b == town }
        .flat_map(&:exits)

      if exits.size == 2
        r_track = render_curvilinear_track_segment(*exits, color)
        r_town = render_town_rect(*exits)
        r_revenue = render_revenue(town.revenue)
        r_track + r_town + r_revenue
      elsif exits.count == 1
        # TODO, e.g., IR2
      elsif exits.count > 2
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

    def render_city(city)
      x, y = CITY_SLOT_POSITION[city.slots]
      h(City, city: city, x: x, y: y)
    end

    def render_track_single_city
      city = @tile.cities.first

      render_lawson_track + render_city(city) + render_revenue(city.revenue)
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
        puts "Don't how to render track for #{@tile.towns.count} towns and #{@tile.cities.count} cities."
        []
      end
    end

    # render letter label, like "Z", "H", "OO"
    def render_label
      [h(:text, { attrs: { fill: 'black', transform: 'scale(2.5) translate(10 30)' } }, @tile.label.to_s)]
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

      [h(:text, { attrs: { fill: 'black', transform: 'scale(1.5) translate(10 30)' } }, name)]
    end

    def render_upgrades
      @tile.upgrades.flat_map do |upgrade|
        h(TileParts::Upgrade, cost: upgrade.cost, terrains: upgrade.terrains)
      end
    end

    def render_town_dot
      h(:circle, attrs: { fill: '#000',
                          cx: '0',
                          cy: '0',
                          r: '10' })
    end

    def render
      attrs = {
        fill: 'none',
        'stroke-width' => 1,
      }

      if @tile.paths.empty?
        track =
          if @tile.cities.count == 1
            render_city(@tile.cities.first)
          elsif @tile.towns.count == 1
            [render_town_dot]
          else
            []
          end
      else
        @route_paths = @route&.paths_for(@tile.paths) || []

        track = render_track

        if track.empty?
          puts "Cannot render Tile '#{@tile.name}'"
          track = [h(:text, { attrs: { transform: 'scale(2.5)' } }, @tile.name)]
        end
      end

      children = track + render_upgrades + render_label + render_name

      h(:g, { attrs: attrs }, children)
    end
  end
end
