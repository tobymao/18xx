# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/corporation/base'
require 'engine/hex'
require 'engine/tile'

module Engine
  describe Hex do
    subject { Hex.new('B3', layout: :flat, tile: Tile.for('9')) }
    let(:neighbor) { Hex.new('C4', layout: :flat) }
    let(:not_neighbor) { Hex.new('C6', layout: :flat) }

    let(:connected_neighbor) { Hex.new('B5', layout: :flat, tile: Tile.for('9')) }
    let(:rotated_neighbor) { Hex.new('B5', layout: :flat, tile: Tile.for('9', rotation: 1)) }

    describe '#neighbor_direction' do
      it 'is a neighbor' do
        expect(subject.neighbor_direction(neighbor)).to eq(5)
      end

      it 'is not a neighbor' do
        expect(subject.neighbor_direction(not_neighbor)).to be_falsey
      end
    end

    describe '#connected?' do
      it 'is connected' do
        expect(subject.connected?(connected_neighbor)).to be_truthy
      end

      it 'is not connected with no tiles' do
        expect(subject.connected?(neighbor)).to be_falsey
      end

      it 'is not connected with wrong rotation' do
        expect(subject.connected?(rotated_neighbor)).to be_falsey
      end
    end

    describe '#lay' do
      let(:green_tile) { Tile.for('15') }
      let(:brown_tile) { Tile.for('611') }
      let(:corp_1) { Corporation::Base.new('AR', name: 'Awa Railway', tokens: 2) }
      let(:corp_2) { Corporation::Base.new('IR', name: 'Iyo Railway', tokens: 2) }

      context 'laying green' do
        subject { Hex.new('A1', layout: :flat, tile: Tile.for('57')) }

        it 'sets @tile to the given tile' do
          subject.lay(green_tile)

          expect(subject.tile).to eq(Tile.for('15'))
        end

        it 'preserves a placed token' do
          subject.tile.cities[0].place_token(corp_1)

          subject.lay(green_tile)
          expect(subject.tile.cities[0].tokens).to eq([Token.new(corp_1, true), nil])
        end

        it 'preserves a token reservation' do
          subject.tile.cities[0].reservations = ['AR']

          subject.lay(green_tile)
          expect(subject.tile.cities[0].reservations).to eq(['AR'])
        end
      end

      context 'laying brown' do
        subject { Hex.new('A1', layout: :flat, tile: Tile.for('15')) }

        it 'sets @tile to the given tile' do
          subject.lay(brown_tile)

          expect(subject.tile).to eq(Tile.for('611'))
        end

        it 'preserves a placed token' do
          subject.tile.cities[0].place_token(corp_1)

          subject.lay(brown_tile)
          expect(subject.tile.cities[0].tokens).to eq([Token.new(corp_1, true), nil])
        end

        it 'preserves 2 placed tokens' do
          subject.tile.cities[0].place_token(corp_1)
          subject.tile.cities[0].place_token(corp_2)

          subject.lay(brown_tile)

          expect(subject.tile.cities[0].tokens[0]).to eq(Token.new(corp_1, true))
          expect(subject.tile.cities[0].tokens[1]).to eq(Token.new(corp_2, true))
        end

        it 'preserves a placed token and a reservation' do
          subject.tile.cities[0].reservations = ['AR']
          subject.tile.cities[0].place_token(corp_2)

          subject.lay(brown_tile)

          expect(subject.tile.cities[0].tokens).to eq([nil, Token.new(corp_2, true)])
          expect(subject.tile.cities[0].reservations).to eq(['AR'])
        end
      end
    end
  end
end
