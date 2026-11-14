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
        allow(component).to receive(:route_prop) { |_index, prop| prop == :color ? '#A40122' : 8 }
        allow(component).to receive(:h) do |tag, props = {}, children = nil|
          calls << [tag, props, children]
          [tag, props, children]
        end
        component.render
        calls
      end

      before do
        baltic!
        token!('I50', corp)
        token!('I52', corp)
      end

      context 'with one crossing' do
        let(:routes) { [route_through(four, city('I50'), city('I52'), town('H55'))] }

        it 'draws one dashed line from København via the port markers to Malmö, labelled with the zone count (row 21)' do
          lines = rendered.select { |tag, _, _| tag == :polyline }
          texts = rendered.select { |tag, _, _| tag == :text }
          points = %w[I50 H49 J51 I52].map { |id| Hex.coordinates(game.hex_by_id(id), [1, 1]).join(',') }.join(' ')
          h49 = Hex.coordinates(game.hex_by_id('H49'), [1, 1])
          j51 = Hex.coordinates(game.hex_by_id('J51'), [1, 1])

          expect(lines.size).to eq(1)
          expect(lines.first[1][:attrs]).to include(stroke: '#A40122', 'stroke-dasharray': '18 12', points: points)
          expect(texts.map(&:last)).to eq(['2'])
          expect(texts.first[1][:attrs]).to include(x: (h49[0] + j51[0]) / 2.0, y: (h49[1] + j51[1]) / 2.0)
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
