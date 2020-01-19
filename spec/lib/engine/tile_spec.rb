# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/tile'

module Engine
  describe Tile do
    let(:edge0) { Edge.new(0) }
    let(:edge2) { Edge.new(2) }
    let(:edge3) { Edge.new(3) }
    let(:city) { City.new(20) }

    describe '.for' do
      it 'should render basic tile' do
        expect(Tile.for('8')).to eq(
          Tile.new('8', color: :yellow, parts: [Path.new(edge0, edge2)])
        )
      end

      it 'should render a city' do
        expect(Tile.for('57')).to eq(
          Tile.new('57', color: :yellow, parts: [city, Path.new(edge0, city), Path.new(city, edge3)])
        )
      end
    end
  end
end
