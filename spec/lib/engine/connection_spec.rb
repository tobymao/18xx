# frozen_string_literal: true

require './spec/spec_helper'

require 'engine'

module Engine
  describe Connection do
    let(:game) { GAMES_BY_TITLE['1889'].new(['a', 'b']) }

    describe '.layable_hexes' do
      subject { game.hex_by_id('K8') }

      it 'should not connect offboards' do
        subject.lay(game.tile_by_id('5-0').rotate!(3))

        expect(Connection.layable_hexes(subject.all_connections)).to eq(
          game.hex_by_id('K6') => [0],
          game.hex_by_id('K8') => [3, 4],
          game.hex_by_id('L7') => [1],
        )
      end
    end

    describe '.connect!' do
      subject { game.hex_by_id('H7') }

      let(:neighbor_3) { subject.neighbors[3] }

      before :each do
        subject.lay(game.tile_by_id('57-0'))
        neighbor_3.lay(game.tile_by_id('9-0'))
      end

      it 'connects on a new edge' do
        node = subject.tile.paths[0].node

        expect(subject.connections.size).to eq(2)

        expect(subject.connections[0].size).to eq(1)
        expect(subject.connections[0][0]).to have_attributes(
          node_a: node,
          node_b: nil,
          hexes: [subject],
        )

        expect(subject.connections[3].size).to eq(1)
        expect(subject.connections[3][0]).to have_attributes(
          node_a: node,
          node_b: nil,
          hexes: [subject, neighbor_3]
        )
      end

      it 'connects on an upgrade' do
        neighbor_3.lay(game.tile_by_id('23-0'))
        connections_0 = subject.connections[0]
        expect(connections_0.size).to eq(1)
        expect(connections_0[0]).to have_attributes(
          node_a: subject.tile.cities[0],
          node_b: nil,
          paths: [subject.tile.paths[0]],
        )

        connections_3 = subject.connections[3]
        expect(connections_3.size).to eq(2)
        expect(connections_3[0]).to have_attributes(
          node_a: subject.tile.cities[0],
          node_b: nil,
          paths: [subject.tile.paths[1], neighbor_3.tile.paths[0]],
        )
        expect(connections_3[1]).to have_attributes(
          node_a: subject.tile.cities[0],
          node_b: nil,
          paths: [subject.tile.paths[1], neighbor_3.tile.paths[1]],
        )
      end
    end

    context 'with awa connection' do
      subject { game.hex_by_id('K8') }

      it 'connects complex' do
        subject.lay(game.tile_by_id('6-0').rotate!(2))
        game.hex_by_id('I8').lay(game.tile_by_id('7-0').rotate!(4))
        game.hex_by_id('I6').lay(game.tile_by_id('9-0'))
        kotohira = game.hex_by_id('I4')
        kotohira.lay(game.tile_by_id('438-0').rotate!(4))
        game.hex_by_id('I6').lay(game.tile_by_id('23-0'))
        ritsurin = game.hex_by_id('J5')
        ritsurin.lay(game.tile_by_id('58-0').rotate!(1))

        expect(subject.all_connections.size).to eq(3)

        naruoto = game.hex_by_id('L7')
        expect(subject.connections[4][0]).to have_attributes(
          node_a: naruoto.tile.offboards[0],
          node_b: subject.tile.cities[0],
          paths: [naruoto.tile.paths[0], subject.tile.paths[1]],
        )

        kotohira_connection = subject.connections[2][0]
        expect(kotohira_connection).to have_attributes(
          node_a: subject.tile.cities[0],
          node_b: kotohira.tile.cities[0],
        )
        expect(kotohira_connection.hexes.map(&:name)).to eq(%w[J7 K8 I8 I4 I6])

        ritsurin_connection = subject.connections[2][1]
        expect(ritsurin_connection).to have_attributes(
          node_a: subject.tile.cities[0],
          node_b: ritsurin.tile.towns[0],
        )
        expect(ritsurin_connection.hexes.map(&:name)).to eq(%w[I8 J7 K8 I6 J5])
      end

      it 'connects deep' do
        subject.lay(game.tile_by_id('57-0').rotate!(1))
        komatsujima = game.hex_by_id('J9')
        komatsujima.lay(game.tile_by_id('58-0').rotate!(2))
        game.hex_by_id('I8').lay(game.tile_by_id('9-0').rotate!(2))
        game.hex_by_id('I8').lay(game.tile_by_id('26-0').rotate!(5))

        expect(komatsujima.all_connections.size).to eq(3)
        straight = komatsujima.connections[2][0]
        expect(straight).to have_attributes(
          node_a: komatsujima.tile.towns[0],
          node_b: nil
        )
        expect(straight.hexes.map(&:name)).to eq(%w[J9 I8])

        curve = komatsujima.connections[2][1]
        expect(curve).to have_attributes(
          node_a: komatsujima.tile.towns[0],
          node_b: nil
        )
        expect(curve.hexes.map(&:name)).to eq(%w[J9 J7 I8])
      end
    end
  end
end
