# frozen_string_literal: true

require './spec/spec_helper'
require_relative '../../../../lib/engine/game/g_18_oe/route_helpers'
require_relative '../../../../lib/engine/game/g_18_oe/helpers'
require 'view/game/sea_crossings'

module View
  module Game
    describe SeaCrossings do
      include_context 'with 18OE route helpers'

      let(:corp) { game.corporation_by_id('DSJ') }
      let(:four) { buy_train!('4') }
      let(:component) { described_class.new(nil, routes: routes, start_pos: [1, 1], game: game) }

      def rendered
        calls = []
        allow(component).to receive(:route_prop) { |index, prop| prop == :color ? %w[#A40122 #099FFA #F9A01B][index] : 8 }
        allow(component).to receive(:h) do |tag, props = {}, children = nil|
          calls << [tag, props, children]
          [tag, props, children]
        end
        component.render
        calls
      end

      def coords(hex_id)
        Hex.coordinates(game.hex_by_id(hex_id), [1, 1])
      end

      def pulled(hex_id, toward_id, distance)
        x, y = coords(hex_id)
        tx, ty = coords(toward_id)
        length = Math.hypot(tx - x, ty - y)
        [x + ((tx - x) * distance / length), y + ((ty - y) * distance / length)]
      end

      def polylines
        rendered.select { |tag, _, _| tag == :polyline }.map { |_, props, _| props[:attrs] }
      end

      def points_of(attrs)
        attrs[:points].split.map { |pair| pair.split(',').map(&:to_f) }
      end

      def offset_from_line(point, hex_a, hex_b)
        ax, ay = coords(hex_a)
        bx, by = coords(hex_b)
        length = Math.hypot(bx - ax, by - ay)
        (((point[0] - ax) * (by - ay)) - ((point[1] - ay) * (bx - ax))) / length
      end

      def gap(point, hex_id)
        Math.hypot(point[0] - coords(hex_id)[0], point[1] - coords(hex_id)[1])
      end

      before do
        baltic!
        token!('I50', corp)
        token!('I52', corp)
      end

      context 'with one crossing' do
        let(:routes) { [route_through(four, city('I50'), city('I52'), town('H55'))] }

        it 'draws one dashed polyline from København via the port markers to Malmö, without a zone label' do
          expect(polylines.size).to eq(1)
          attrs = polylines.first
          expect(attrs).to include(fill: 'none', stroke: '#A40122', 'stroke-width': 8, 'stroke-dasharray': '18 12',
                                   'stroke-linecap': 'round', 'stroke-linejoin': 'round')
          pts = points_of(attrs)
          expect(pts.size).to eq(4)
          start = pulled('I50', 'H49', 29)
          finish = pulled('I52', 'J51', 29)
          expect(pts[0]).to match([be_within(0.01).of(start[0]), be_within(0.01).of(start[1])])
          expect(pts[1]).to match([be_within(0.01).of(coords('H49')[0]), be_within(0.01).of(coords('H49')[1])])
          expect(pts[2]).to match([be_within(0.01).of(coords('J51')[0]), be_within(0.01).of(coords('J51')[1])])
          expect(pts[3]).to match([be_within(0.01).of(finish[0]), be_within(0.01).of(finish[1])])
          expect(rendered.map(&:first)).not_to include(:text, :line)
          expect(rendered.last[1][:attrs]).to include('pointer-events': 'none')
        end
      end

      context 'with routes sharing a sea leg' do
        let(:three) { buy_train!('3') }
        let(:first_route) { route_through(four, city('I50'), city('I52'), town('H55')) }
        let(:second_route) { route_through(three, city('I50'), city('C48')) }
        let(:routes) { [first_route, second_route].each { |r| r.routes = [first_route, second_route] } }

        it 'joins the shared lane to the unshared leg at the marker with a single continuous line (§11.3.8)' do
          expect(polylines.size).to eq(2)
          first, second = polylines.map { |a| points_of(a) }
          expect(polylines.map { |a| a[:stroke] }).to eq(%w[#A40122 #099FFA])
          expect(offset_from_line(second[0], 'I50', 'H49').abs).to be_within(0.01).of(6)
          lane = offset_from_line(second[0], 'I50', 'H49')
          expect(offset_from_line(second[1], 'I50', 'H49')).to be_within(0.01).of(lane / 2)
          expect(offset_from_line(second[1], 'H49', 'E46')).to be_within(0.01).of(lane / 2)
          expect(offset_from_line(second[2], 'H49', 'E46')).to be_within(0.01).of(0)
          expect(offset_from_line(second.last, 'E46', 'C48')).to be_within(0.01).of(0)
          expect(gap(second.last, 'C48')).to be_within(0.01).of(29)
          expect(offset_from_line(first[0], 'I50', 'H49').abs).to be_within(0.01).of(6)
          expect(offset_from_line(first[0], 'I50', 'H49') + offset_from_line(second[0], 'I50', 'H49')).to be_within(0.01).of(0)
        end
      end

      context 'with routes sharing a sea leg at a route node' do
        let(:three) { buy_train!('3') }
        let(:first_route) { route_through(four, city('I50'), city('I52'), town('H55')) }
        let(:second_route) { route_through(three, city('I50'), city('C48')) }
        let(:routes) { [first_route, second_route].each { |r| r.routes = [first_route, second_route] } }

        it 'stops each line at the city edge plus half its stroke width along its own lane' do
          expect(polylines.size).to eq(2)
          polylines.each { |a| expect(gap(points_of(a).first, 'I50')).to be_within(0.01).of(Math.sqrt((29**2) + (6**2))) }
        end
      end

      context 'with a crossing that bends' do
        let(:crossing) { game.sea_crossing(:crossing, ['I50', 5], ['D41', 0], [city('I50'), town('D41')]) }
        let(:routes) { [double(chains: [{ crossing: crossing }])] }

        it 'passes through the centre of an interior waypoint on an unshared leg' do
          waypoint = SeaCrossings::Path.for(game).straighten(SeaCrossings::Path.for(game).path(*crossing.hexes, crossing),
                                                             crossing)[1..-2].first
          expect(waypoint).not_to be_nil
          wx, wy = Hex.coordinates(waypoint, [1, 1])
          expect(points_of(polylines.first)).to include([be_within(0.01).of(wx), be_within(0.01).of(wy)])
        end
      end

      context 'with routes leaving København by the same sea to Stavanger and New York' do
        let(:five) { buy_train!('5') }
        let(:first_route) do
          lay_code!('D41', 'town=revenue:10;path=a:0,b:_0;path=a:3,b:_0')
          explicit_route(four, city('I50'), town('D41'))
        end
        let(:second_route) { explicit_route(five, city('I50'), offboard('N1')) }
        let(:routes) { [first_route, second_route].each { |r| r.routes = [first_route, second_route] } }

        def hex_sequence(attrs)
          points_of(attrs).map do |x, y|
            game.hexes.min_by { |hex| Math.hypot(Hex.coordinates(hex, [1, 1])[0] - x, Hex.coordinates(hex, [1, 1])[1] - y) }
          end
        end

        def lane_side(points, index, hexes)
          ax, ay = Hex.coordinates(hexes[index], [1, 1])
          bx, by = Hex.coordinates(hexes[index + 1], [1, 1])
          mx = (points[index][0] + points[index + 1][0]) / 2.0
          my = (points[index][1] + points[index + 1][1]) / 2.0
          ((bx - ax) * (my - ay)) - ((by - ay) * (mx - ax))
        end

        it 'keeps the first route on one side of its travel along every shared leg and splits after the junction' do
          first, second = polylines
          first_hexes = hex_sequence(first)
          second_hexes = hex_sequence(second)
          shared = (1..first_hexes.size - 3).select do |i|
            second_hexes.each_cons(2).any? do |a, b|
              [a, b].sort_by(&:id) == [first_hexes[i], first_hexes[i + 1]].sort_by(&:id)
            end
          end
          expect(shared.size).to be >= 2
          sides = shared.map { |i| lane_side(points_of(first), i, first_hexes) }
          expect(sides.map(&:abs)).to all(be > 1)
          expect(sides.map { |side| side <=> 0 }.uniq.size).to eq(1)
          expect(first_hexes.last).not_to eq(second_hexes.last)
        end
      end

      context 'with a land-only route' do
        let(:routes) { [route_through(four, city('I52'), town('H55'))] }

        it 'renders nothing but the group' do
          expect(rendered.map(&:first)).to eq([:g])
        end
      end

      describe SeaCrossings::Path do
        include G18OESpecHelpers

        let(:game) { new_game }
        let(:crossing) do
          game.sea_crossing(:crossing, ['I50', 5], ['D41', 0],
                            [game.hex_by_id('I50').tile.cities.first, game.hex_by_id('D41').tile.towns.first])
        end
        let(:crossing_path_finder) { described_class.for(game) }

        def raw_path(from, to)
          crossing_path_finder.path(from, to, crossing)
        end

        def straight(hexes)
          crossing_path_finder.straighten(hexes, crossing)
        end

        def routed(from, to)
          straight(raw_path(from, to))
        end

        def distance(hex)
          crossing_path_finder.send(:land_distance, hex, crossing)
        end

        def sea_line(from, to)
          crossing_path_finder.send(:line_hexes, from, to)
        end

        let(:from_hex) { game.hex_by_id('H49') }

        it 'bends around Jutland on the way to Stavanger, touching only sea hexes between waypoints' do
          to_hex = game.port_marker_hex('D41', 0)
          path = routed(from_hex, to_hex)
          expect(path.first).to eq(from_hex)
          expect(path.last).to eq(to_hex)
          expect(path.size).to be > 2
          path.each_cons(2) do |a, b|
            expect(sea_line(a, b).map { |hex| game.sea_zone(hex.id) }).to all(be)
          end
        end

        it 'keeps mid-route waypoints in open water where the sea is wide' do
          path = routed(from_hex, game.port_marker_hex('N1', 5))
          expect(path[2..-2]).not_to be_empty
          expect(path[2..-2].map { |hex| distance(hex) }).to all(be >= 2)
        end

        it 'has interior waypoints at sea on the Stavanger run, where the water is one hex wide' do
          path = routed(from_hex, game.port_marker_hex('D41', 0))
          expect(path[1..-2]).not_to be_empty
          expect(path[1..-2].map { |hex| distance(hex) }).to all(be >= 1)
        end

        it 'counts the map edge as a coast for sea hexes with only sea neighbours' do
          edge = game.hexes.find do |hex|
            game.sea_zone(hex.id) && hex.all_neighbors.size < 6 && hex.all_neighbors.values.all? { |n| game.sea_zone(n.id) }
          end
          expect(edge).not_to be_nil
          expect(distance(edge)).to eq(1)
        end

        it 'keeps the København to New York line off the map edge' do
          path = routed(from_hex, game.port_marker_hex('N1', 5))
          expect(path[1..-2].map { |hex| hex.all_neighbors.size }).to all(eq(6))
        end

        it 'finds the same raw sea path in either direction' do
          to_hex = game.port_marker_hex('N1', 5)
          expect(raw_path(from_hex, to_hex)).to eq(raw_path(to_hex, from_hex).reverse)
        end

        it 'straightens a hex run the same way in either direction' do
          path = raw_path(from_hex, game.port_marker_hex('N1', 5))
          expect(straight(path).reverse).to eq(straight(path.reverse))
        end

        it 'measures distance to land in hex steps' do
          expect(distance(game.hex_by_id('I50'))).to eq(0)
          expect(distance(from_hex)).to eq(1)
        end

        it 'crosses land once when two seas have no sea-hex link' do
          expect(routed(from_hex, game.hex_by_id('J51'))).to eq([from_hex, game.hex_by_id('J51')])
        end

        it 'returns just the hex for the same hex' do
          expect(routed(from_hex, from_hex)).to eq([from_hex])
        end

        it 'memoises the result' do
          to_hex = game.port_marker_hex('D41', 0)
          expect(raw_path(to_hex, from_hex)).to equal(raw_path(to_hex, from_hex))
        end
      end
    end
  end
end
