# frozen_string_literal: true

require './spec/spec_helper'
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
  end
end
