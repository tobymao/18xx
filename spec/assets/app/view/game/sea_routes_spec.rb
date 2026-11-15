# frozen_string_literal: true

require './spec/spec_helper'
require_relative '../../../../lib/engine/game/g_18_oe/route_helpers'
require 'view/game/sea_routes'

module View
  module Game
    describe SeaRoutes do
      include_context 'with 18OE route helpers'

      let(:corp) { game.corporation_by_id('DSJ') }
      let(:four) { buy_train!('4') }
      let(:component) { described_class.new(nil, routes: routes, start_pos: [1, 1]) }

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
          waypoint = crossing.path_hexes[1..-2].first
          expect(waypoint).not_to be_nil
          wx, wy = Hex.coordinates(waypoint, [1, 1])
          expect(points_of(polylines.first)).to include([be_within(0.01).of(wx), be_within(0.01).of(wy)])
        end
      end

      context 'with a land-only route' do
        let(:routes) { [route_through(four, city('I52'), town('H55'))] }

        it 'renders nothing but the group' do
          expect(rendered.map(&:first)).to eq([:g])
        end
      end
    end
  end
end
