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
            segment_attrs('H49', 'I50', '#A40122', 8),
            segment_attrs('H49', 'J51', '#A40122', 8),
            segment_attrs('I52', 'J51', '#A40122', 8),
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

        it 'nests the shared leg with the lower route index underneath and draws unshared legs once (§11.3.8)' do
          from = coords('H49')
          to = coords('I50')
          shared = lines.select { |l| (from + to) == [l[:x1], l[:y1], l[:x2], l[:y2]] }
          expect(shared.map { |l| [l[:stroke], l[:'stroke-width']] }).to eq([['#A40122', 24], ['#099FFA', 8]])
          expect(lines.select { |l| l[:stroke] == '#A40122' }.map { |l| l[:'stroke-width'] }).to eq([24, 8, 8])
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
