# frozen_string_literal: true

require './spec/spec_helper'

require 'engine'

module Engine
  describe Connection do
    let(:game) { GAMES_BY_TITLE['1889'].new(%w[a b]) }

    describe '#connections' do
      subject { game.hex_by_id('K8') }

      it 'should not connect offboards' do
        subject.lay(game.tile_by_id('5-0').rotate!(3))
        expect(subject.connections[4][0].connections.size).to eq(2)
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
          nodes: [node],
          hexes: [subject],
        )

        expect(subject.connections[3].size).to eq(1)
        expect(subject.connections[3][0]).to have_attributes(
          nodes: [node],
          hexes: [subject, neighbor_3]
        )
      end

      it 'connects on an upgrade' do
        neighbor_3.lay(game.tile_by_id('23-0'))
        connections0 = subject.connections[0]
        expect(connections0.size).to eq(1)
        expect(connections0[0]).to have_attributes(
          nodes: [subject.tile.cities[0]],
          paths: [subject.tile.paths[0]],
        )

        connections3 = subject.connections[3]
        expect(connections3.size).to eq(2)
        expect(connections3[0]).to have_attributes(
          nodes: [subject.tile.cities[0]],
          paths: [subject.tile.paths[1], neighbor_3.tile.paths[0]],
        )
        expect(connections3[1]).to have_attributes(
          nodes: [subject.tile.cities[0]],
          paths: [subject.tile.paths[1], neighbor_3.tile.paths[1]],
        )
      end
    end

    context 'with iyo' do
      subject { game.hex_by_id('E2') }

      it 'connects the upgrade' do
        subject.lay(game.tile_by_id('6-0').rotate!(4))
        expect(subject.connections[4][0].hexes.map(&:name)).to eq(%w[E2 F1])
        subject.lay(game.tile_by_id('12-0').rotate!(5))
        expect(subject.connections[4][0].hexes.map(&:name)).to eq(%w[E2 F1])
      end
    end

    context 'with ko and sr' do
      subject { game.hex_by_id('J3') }

      it 'can upgrade fork to 3 stops' do
        game.hex_by_id('I2').lay(game.tile_by_id('6-0').rotate!(4))
        subject.lay(game.tile_by_id('8-0').rotate!(3))
        game.hex_by_id('I2').lay(game.tile_by_id('12-0').rotate!(5))
        subject.lay(game.tile_by_id('23-0').rotate!(5))
        subject.lay(game.tile_by_id('47-0').rotate!(2))
        expect(subject.connections.size).to eq(4)
        # expect(subject.connections).to eq({})
        expect(subject.connections[0].size).to eq(2)
        expect(subject.connections[2].size).to eq(2)
        connections3 = subject.connections[3]
        expect(connections3.size).to eq(2)
        expect(subject.connections[5].size).to eq(2)
        expect(connections3[0].hexes.map(&:name)).to eq(%w[K4 J3 J1])
        expect(connections3[1].hexes.map(&:name)).to eq(%w[J1 J3])
      end
    end

    context 'with awa' do
      subject { game.hex_by_id('K8') }

      it 'connects complex' do
        subject.lay(game.tile_by_id('6-0').rotate!(2))
        game.hex_by_id('I8').lay(game.tile_by_id('7-0').rotate!(3))
        game.hex_by_id('I6').lay(game.tile_by_id('9-0'))
        kotohira = game.hex_by_id('I4')
        kotohira.lay(game.tile_by_id('438-0').rotate!(4))
        game.hex_by_id('I6').lay(game.tile_by_id('23-0'))
        ritsurin = game.hex_by_id('J5')
        ritsurin.lay(game.tile_by_id('58-0').rotate!(1))

        expect(subject.all_connections.size).to eq(3)

        naruoto = game.hex_by_id('L7')
        expect(subject.connections[4][0]).to have_attributes(
          nodes: [subject.tile.cities[0], naruoto.tile.offboards[0]],
          paths: [subject.tile.paths[1], naruoto.tile.paths[0]],
        )

        kotohira_connection = subject.connections[2][0]
        expect(kotohira_connection.nodes).to eq([
          subject.tile.cities[0],
          kotohira.tile.cities[0],
        ])
        expect(kotohira_connection.hexes.map(&:name)).to eq(%w[K8 J7 I8 I6 I4])

        ritsurin_connection = subject.connections[2][1]
        expect(ritsurin_connection.nodes).to eq([
          ritsurin.tile.towns[0],
          subject.tile.cities[0],
        ])
        expect(ritsurin_connection.hexes.map(&:name)).to eq(%w[J5 I6 I8 J7 K8])
        expect(game.hex_by_id('J7').connections[5].size).to eq(2)
      end

      it 'connects deep' do
        subject.lay(game.tile_by_id('57-0').rotate!(1))
        komatsujima = game.hex_by_id('J9')
        komatsujima.lay(game.tile_by_id('58-0').rotate!(2))
        game.hex_by_id('I8').lay(game.tile_by_id('9-0').rotate!(2))
        game.hex_by_id('I8').lay(game.tile_by_id('26-0').rotate!(5))

        expect(komatsujima.all_connections.size).to eq(3)
        straight = komatsujima.connections[2][0]
        expect(straight.nodes).to eq([komatsujima.tile.towns[0]])
        expect(straight.hexes.map(&:name)).to eq(%w[J9 I8])

        curve = komatsujima.connections[2][1]
        expect(curve.nodes).to eq([komatsujima.tile.towns[0]])
        expect(curve.hexes.map(&:name)).to eq(%w[J9 I8 J7])
      end
    end
  end
end
