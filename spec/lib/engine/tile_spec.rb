# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/part/city'
require 'engine/part/junction'
require 'engine/part/label'
require 'engine/part/town'
require 'engine/part/upgrade'
require 'engine/tile'

module Engine
  include Engine::Part

  describe Tile do
    let(:edge0) { Edge.new(0) }
    let(:edge1) { Edge.new(1) }
    let(:edge2) { Edge.new(2) }
    let(:edge3) { Edge.new(3) }
    let(:edge4) { Edge.new(4) }
    let(:edge5) { Edge.new(5) }
    let(:city) { City.new(20) }
    let(:city2) { City.new(30, 2) }
    let(:kotohira40) { City.new(40, 1, 'Kotohira') }
    let(:town) { Town.new(10) }
    let(:town_a) { Town.new(10, '_A') }
    let(:town_b) { Town.new(10, '_B') }
    let(:junction) { Junction.new }

    describe '.for' do
      it 'should render basic tile' do
        expect(Tile.for('8')).to eq(
          Tile.new('8', color: :yellow, parts: [Path.new(edge0, edge4)])
        )
      end

      it 'should render basic tile' do
        expect(Tile.for('_0')).to eq(
          Tile.new('_0', color: :white, parts: [])
        )
      end

      it 'should render a lawson track tile' do
        actual = Tile.for('81A')

        expected = Tile.new(
          '81A',
          color: :green,
          parts: [Path.new(edge0, junction), Path.new(edge2, junction), Path.new(edge4, junction)]
        )

        expect(actual).to eq(expected)
      end

      it 'should render a city' do
        expect(Tile.for('57')).to eq(
          Tile.new('57', color: :yellow, parts: [city, Path.new(edge0, city), Path.new(city, edge3)])
        )
      end

      it 'should render a city with two slots' do
        actual = Tile.for('14')
        expected = Tile.new(
          '14',
          color: :green,
          parts: [city2, Path.new(edge0, city2), Path.new(edge1, city2), Path.new(edge3, city2), Path.new(edge4, city2)]
        )

        expect(actual).to eq(expected)
      end

      it 'should render a tile with a city and a letter (438, 1889 Kotohira)' do
        actual = Tile.for('438')
        expected = Tile.new(
          '438',
          color: :yellow,
          parts: [
            kotohira40,
            Path.new(edge0, kotohira40),
            Path.new(kotohira40, edge2),
            Label.new('H'),
            Upgrade.new(80),
]
        )

        expect(actual).to eq(expected)
      end

      it 'should render a town' do
        expect(Tile.for('3')).to eq(
          Tile.new('3', color: :yellow, parts: [town, Path.new(edge0, town), Path.new(town, edge1)])
        )
      end

      it 'should render a double town' do
        actual = Tile.for('1')

        expected = Tile.new(
          '1',
          color: :yellow,
          parts: [
            town_a,
            Path.new(edge0, town_a),
            Path.new(town_a, edge4),
            town_b,
            Path.new(edge1, town_b),
            Path.new(town_b, edge3),
          ]
        )
        expect(actual).to eq(expected)
      end
    end

    describe '.from_code' do
      it 'should render tile with upgrade cost and terrain' do
        expect(Tile.from_code('name', :white, 'u=c:80,t:mountain+water')).to eq(
          Tile.new('name', color: :white, parts: [Upgrade.new(80, %i[mountain water])])
        )
      end
    end

    describe '#exits' do
      it 'should have the right exits' do
        expect(Tile.for('6').exits.to_a).to eq([0, 2])
        expect(Tile.for('7').exits.to_a.sort).to eq([0, 5])
      end
    end
  end
end
