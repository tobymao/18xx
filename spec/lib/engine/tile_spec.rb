# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/game/g_1889'
require 'engine/part/city'
require 'engine/part/edge'
require 'engine/part/junction'
require 'engine/part/label'
require 'engine/part/offboard'
require 'engine/part/path'
require 'engine/part/town'
require 'engine/part/upgrade'
require 'engine/tile'

# rubocop: disable Metrics/ModuleLength
module Engine
  include Engine::Part

  describe Tile do
    let(:edge0) { Edge.new(0) }
    let(:edge1) { Edge.new(1) }
    let(:edge2) { Edge.new(2) }
    let(:edge3) { Edge.new(3) }
    let(:edge4) { Edge.new(4) }
    let(:edge5) { Edge.new(5) }
    let(:city) { City.new('20') }
    let(:city2) { City.new('30', 2) }
    let(:kotohira40) { City.new('40', 1) }
    let(:town) { Town.new('10') }
    let(:town_a) { Town.new('10', 0) }
    let(:town_b) { Town.new('10', 1) }
    let(:junction) { Junction.new }

    describe '.for' do
      it 'should render basic tile' do
        expect(Tile.for('8')).to eq(
          Tile.new('8', color: :yellow, parts: [Path.new(edge0, edge4)])
        )
      end

      it 'should render basic tile' do
        expect(Tile.for('blank')).to eq(
          Tile.new('blank', color: :white, parts: [])
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

      it 'should render a green town' do
        actual = Tile.for('87')

        expected = Tile.new(
          '87',
          color: :green,
          parts: [
            town_a,
            Path.new(edge0, town_a),
            Path.new(edge1, town_a),
            Path.new(edge2, town_a),
            Path.new(edge3, town_a),
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

      it 'should render tile with variable revenue' do
        code = 'c=r:yellow_30|green_40|brown_50|gray_70'
        actual = Tile.from_code('tile', :gray, code)

        revenue = 'yellow_30|green_40|brown_50|gray_70'

        expected = Tile.new('tile', color: :gray, parts: [City.new(revenue)])

        expect(actual).to eq(expected)
      end

      it 'should render an offboard tile' do
        code = 'o=r:yellow_30|brown_60|diesel_100;p=a:0,b:_0;p=a:1,b:_0'
        actual = Tile.from_code('test_tile', :red, code)

        revenue = 'yellow_30|brown_60|diesel_100'
        offboard = Offboard.new(revenue)
        expected = Tile.new('test_tile',
                            color: :red,
                            parts: [offboard,
                                    Path.new(Edge.new(0), offboard),
                                    Path.new(Edge.new(1), offboard)])

        expect(actual).to eq(expected)
      end
    end

    describe '#exits' do
      it 'should have the right exits' do
        expect(Tile.for('6').exits.to_a).to eq([0, 2])
        expect(Tile.for('7').exits.to_a.sort).to eq([0, 5])
      end
    end

    describe '#paths_are_subset_of?' do
      context "Tile 9's path set" do
        subject { Tile.for('9') }

        it 'is subset of itself' do
          straight_path = [Path.new(Edge.new(0), Edge.new(3))]
          expect(subject.paths_are_subset_of?(straight_path)).to be_truthy
        end

        it 'is subset of itself reversed' do
          straight_path = [Path.new(Edge.new(3), Edge.new(0))]
          expect(subject.paths_are_subset_of?(straight_path)).to be_truthy
        end

        it 'is subset of itself rotated 1' do
          straight_path = [Path.new(Edge.new(1), Edge.new(4))]
          expect(subject.paths_are_subset_of?(straight_path)).to be_truthy
        end
      end
    end

    describe '#upgrades_to?' do
      context '1889' do
        EXPECTED_TILE_UPGRADES = {
          'blank' => %w[7 8 9],
          'city' => %w[5 6 57],
          'mtn80' => %w[7 8 9],
          'mtn+wtr80' => %w[7 8 9],
          'wtr80' => %w[7 8 9],
          'town' => %w[3 58],
          '3' => %w[],
          '5' => %w[12 14 15 205 206],
          '6' => %w[12 13 14 15 205 206],
          '7' => %w[26 27 28 29],
          '8' => %w[16 19 23 24 25 28 29],
          '9' => %w[19 20 23 24 26 27],
          '12' => %w[448 611],
          '13' => %w[611],
          '14' => %w[611],
          '15' => %w[448 611],
          '16' => %w[],
          '19' => %w[45 46],
          '20' => %w[47],
          '23' => %w[41 45 47],
          '24' => %w[42 46 47],
          '25' => %w[40 45 46],
          '26' => %w[42 45],
          '27' => %w[41 46],
          '28' => %w[39 46],
          '29' => %w[39 45],
          '39' => %w[],
          '40' => %w[],
          '41' => %w[],
          '42' => %w[],
          '45' => %w[],
          '46' => %w[],
          '47' => %w[],
          '57' => %w[14 15 205 206],
          '58' => %w[],
          '205' => %w[448 611],
          '206' => %w[448 611],
          '437' => %w[],
          '438' => %w[439],
          '439' => %w[492],
          '440' => %w[466],
          '448' => %w[],
          '465' => %w[],
          '466' => %w[],
          '492' => %w[],
          '611' => %w[],
        }.freeze

        EXPECTED_TILE_UPGRADES.keys.each do |t|
          EXPECTED_TILE_UPGRADES.keys.each do |u|
            tile = Tile.for(t)
            upgrade = Tile.for(u)
            included = EXPECTED_TILE_UPGRADES[t].include?(u)

            it "#{t} can#{included ? '' : 'not'} upgrade to #{u}" do
              expect(tile.upgrades_to?(upgrade)).to eq(included)
            end
          end
        end
      end
    end

    describe '#paths_with' do
      context 'selecting a town' do
        [
          {
            tile_ids: %w[1 2 55 56 69 630 631 632 633],
            town_paths: {
              0 => [0, 1],
              1 => [2, 3],
            }
          },
          {
            tile_ids: %w[3 4 58 437],
            town_paths: {
              0 => [0, 1],
            }
          },
          {
            tile_ids: %w[87],
            town_paths: {
              0 => [0, 1, 2, 3],
            }
          },
        ].each do |spec|
          spec[:tile_ids].each do |tile_id|
            tile = Tile.for(tile_id)

            spec[:town_paths].each do |town_id, expected_path_ids|
              town = tile.towns[town_id]

              it "selects the correct paths for town #{town_id} on tile #{tile_id}" do
                filtered_paths = tile.paths_with(%w[town], town)

                expected_paths = expected_path_ids.map { |id| tile.paths[id] }

                expect(filtered_paths).to eq(expected_paths)
              end
            end
          end
        end
      end

      context 'selecting for edge count' do
        [
          {
            tile_ids: %w[1 2 55 56 69 630 631 632 633],
            paths_edges: {
              [0, 1, 2, 3] => 1
            }
          },
          {
            tile_ids: %w[3 4 5 6 57 58 437],
            paths_edges: {
              [0, 1] => 1
            }
          },
          {
            tile_ids: %w[12 13],
            paths_edges: {
              [0, 1, 2] => 1,
            }
          },
          {
            tile_ids: %w[14 15 87],
            paths_edges: {
              [0, 1, 2, 3] => 1,
            }
          },
          {
            tile_ids: %w[7 8 9],
            paths_edges: {
              [0] => 2,
            }
          },
          {
            tile_ids: %w[16 18 19 20 23 24 25 26 27 28 29],
            paths_edges: {
              [0, 1] => 2,
            }
          },
        ].each do |spec|
          spec[:tile_ids].each do |tile_id|
            tile = Tile.for(tile_id)

            spec[:paths_edges].each do |expected_path_ids, edge_count|
              it "selects the paths with #{edge_count} edges on tile #{tile_id}" do
                filtered_paths = tile.paths_with(%w[edges size], edge_count)

                expected_paths = expected_path_ids.map { |id| tile.paths[id] }

                expect(filtered_paths).to eq(expected_paths)
              end
            end
          end
        end
      end
    end
  end
end
# rubocop: enable Metrics/ModuleLength
