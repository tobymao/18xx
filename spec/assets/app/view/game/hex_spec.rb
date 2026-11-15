# frozen_string_literal: true

require './spec/spec_helper'
require_relative '../../../../lib/engine/game/g_18_oe/route_helpers'
require 'view/game/hex'

module View
  module Game
    describe Hex do
      include_context 'with 18OE route helpers'

      let(:corp) { game.corporation_by_id('BJV') }
      let(:train) { buy_train!('3') }
      let(:route) { Engine::Route.new(game, game.phase, train, routes: []).tap { |r| r.routes = [r] } }
      let(:christiania) { game.hex_by_id('C48') }
      let(:component) do
        described_class.new(nil, hex: christiania, actions: ['run_routes'], clickable: true, game: game, selected_route: route)
      end

      before do
        token!('C48', corp)
        allow(game).to receive(:active_step).and_return(double('Step', current_actions: ['run_routes']))
        allow(component).to receive(:store)
      end

      it 'touches the only city of a pathless hex in the Route step (row 22)' do
        component.on_hex_click
        expect(route.last_node).to eq(christiania.tile.cities.first)
      end
    end
  end
end
