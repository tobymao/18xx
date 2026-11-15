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

      def segment_attrs(from, to, color, width)
        x1, y1 = coords(from)
        x2, y2 = coords(to)
        {
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
          stroke: color,
          'stroke-width': width,
          'stroke-dasharray': '18 12',
          'stroke-linecap': 'round',
        }
      end

      def pulled(hex_id, toward_id, distance)
        x, y = coords(hex_id)
        tx, ty = coords(toward_id)
        length = Math.hypot(tx - x, ty - y)
        [x + ((tx - x) * distance / length), y + ((ty - y) * distance / length)]
      end

      def distance_from_centre(line, hex_id)
        cx, cy = coords(hex_id)
        near = [[line[:x1], line[:y1]], [line[:x2], line[:y2]]].min_by { |x, y| Math.hypot(x - cx, y - cy) }
        Math.hypot(near[0] - cx, near[1] - cy)
      end

      def pulled_end(hex_id, toward_id, distance, xkey, ykey)
        x, y = pulled(hex_id, toward_id, distance)
        { xkey => x.round(2), ykey => y.round(2) }
      end

      def shared_leg_lines
        hx, hy = coords('H49')
        lines.select do |l|
          Math.hypot(l[:x1] - hx, l[:y1] - hy) < 8 && distance_from_centre(l, 'I50') < 40
        end
      end

      def lines
        rendered.select { |tag, _, _| tag == :line }.map { |_, props, _| props[:attrs] }
      end

      before do
        baltic!
        token!('I50', corp)
        token!('I52', corp)
      end

      context 'with one crossing' do
        let(:routes) { [route_through(four, city('I50'), city('I52'), town('H55'))] }

        it 'draws one dashed line per leg from København via the port markers to Malmö, without a zone label' do
          expect(lines).to eq([
            segment_attrs('H49', 'I50', '#A40122', 8).merge(pulled_end('I50', 'H49', 29, :x2, :y2)),
            segment_attrs('H49', 'J51', '#A40122', 8),
            segment_attrs('I52', 'J51', '#A40122', 8).merge(pulled_end('I52', 'J51', 29, :x1, :y1)),
          ])
          expect(rendered.map(&:first)).not_to include(:text)
          expect(rendered.last[1][:attrs]).to include('pointer-events': 'none')
        end
      end

      context 'with routes sharing a sea leg' do
        let(:three) { buy_train!('3') }
        let(:first_route) { route_through(four, city('I50'), city('I52'), town('H55')) }
        let(:second_route) { route_through(three, city('I50'), city('C48')) }
        let(:routes) { [first_route, second_route].each { |r| r.routes = [first_route, second_route] } }

        it 'draws the shared leg as two parallel lanes 12 apart and unshared legs once (§11.3.8)' do
          shared = shared_leg_lines
          expect(shared.map { |l| [l[:stroke], l[:'stroke-width']] }).to eq([['#A40122', 8], ['#099FFA', 8]])
          first, second = shared
          cx, cy = coords('H49')
          tx, ty = coords('I50')
          length = Math.hypot(tx - cx, ty - cy)
          side = ->(l) { (((l[:x1] - cx) * (ty - cy)) - ((l[:y1] - cy) * (tx - cx))) / length }
          expect(side.call(first).abs).to be_within(0.01).of(6)
          expect(side.call(second).abs).to be_within(0.01).of(6)
          expect(side.call(first) - side.call(second)).to be_within(0.01).of(-12).or be_within(0.01).of(12)
          expect(side.call(first) + side.call(second)).to be_within(0.01).of(0)
          expect(lines.select { |l| l[:stroke] == '#A40122' }.map { |l| l[:'stroke-width'] }).to eq([8, 8, 8])
        end
      end

      context 'with routes sharing a sea leg at a route node' do
        let(:three) { buy_train!('3') }
        let(:first_route) { route_through(four, city('I50'), city('I52'), town('H55')) }
        let(:second_route) { route_through(three, city('I50'), city('C48')) }
        let(:routes) { [first_route, second_route].each { |r| r.routes = [first_route, second_route] } }

        it 'stops each line at the city edge plus half its stroke width along its own lane' do
          lanes = shared_leg_lines
          expect(lanes.size).to eq(2)
          lanes.each { |l| expect(distance_from_centre(l, 'I50')).to be_within(0.01).of(Math.sqrt((29**2) + (6**2))) }
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
