# frozen_string_literal: true

require './spec/spec_helper'
require 'json'

module Engine
  describe Route do
    let(:data) { JSON.parse(File.read('spec/fixtures/1830/26855.json')) }
    let(:action) { data['actions'].find { |a| a['id'] == 200 } }
    let(:saved_route) { action['routes'].first }
    let(:hex_ids) { saved_route['connections'].first }
    let(:game) { Game.load(data, at_action: action['id'] - 1) }
    let(:route) do
      Route.new(game, game.phase, game.train_by_id(saved_route['train']),
                connection_hexes: saved_route['connections'], revenue: saved_route['revenue'])
    end
    let(:serialized_connection) do
      connection = route.connection_data.first
      {
        'from' => connection[:left].signature,
        'to' => connection[:right].signature,
        'hexes' => hex_ids,
      }
    end

    describe '#find_matching_chains' do
      it 'finds the chains for a list of hex ids' do
        chains = route.send(:find_matching_chains, hex_ids)

        expect(chains.map { |chain| chain[:id] }).to eq([hex_ids])
      end

      it 'finds the chains for a serialized connection' do
        chains = route.send(:find_matching_chains, serialized_connection)

        expect(chains.map { |chain| chain[:id] }).to eq([hex_ids])
      end
    end

    describe '#connection_data' do
      it 'reads a route saved with serialized connections' do
        restored = Route.new(game, game.phase, game.train_by_id(saved_route['train']),
                             connection_hexes: [serialized_connection], revenue: saved_route['revenue'])

        expect(restored.connection_data.size).to eq(1)
        expect(restored.visited_stops.map(&:signature))
          .to eq(route.visited_stops.map(&:signature))
      end
    end

    describe '#shared_cache' do
      it 'is cleared by clear_cache!' do
        route.shared_cache[:key] = 'value'

        route.clear_cache!

        expect(route.shared_cache).to be_empty
      end

      it 'is cleared when only routes are cleared' do
        route.shared_cache[:key] = 'value'

        route.clear_cache!(only_routes: true)

        expect(route.shared_cache).to be_empty
      end
    end
  end
end
