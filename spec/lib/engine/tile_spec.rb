# frozen_string_literal: true

require './spec/spec_helper'
require 'engine'
require 'engine/game/g_1889'
require 'engine/tile'

module Engine
  include Engine::Part

  describe Tile do
    describe '#exits' do
      it 'should have the right exits' do
        expect(Tile.for('6').exits.to_a).to eq([0, 2])
        expect(Tile.for('7').exits.to_a.sort).to eq([0, 1])
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
      EXPECTED_TILE_UPGRADES = {
        '18Chesapeake' => {
          'X3' => %w[X7],
          'X4' => %w[X7],
          'X5' => %w[X7],
          'X7' => %w[],
        },
        '1889' => {
          'blank' => %w[7 8 9],
          'city' => %w[5 6 57],
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
        },
      }.freeze

      EXPECTED_TILE_UPGRADES.each do |game_title, upgrades|
        context game_title do
          game = Engine::GAMES_BY_TITLE[game_title].new(%w[p1 p2 p3])

          upgrades.keys.each do |t|
            tile = game.tile_by_id("#{t}-0") || Tile.for(t)

            context "tile \"#{t}\"" do
              upgrades.keys.each do |u|
                upgrade = game.tile_by_id("#{u}-0") || Tile.for(t)

                included = upgrades[t].include?(u)

                it "can#{included ? '' : 'not'} upgrade to tile \"#{u}\"" do
                  expect(tile.upgrades_to?(upgrade)).to eq(included)
                end
              end
            end
          end
        end
      end
    end

    describe '#preferred_city_edges' do
      [
        {
          desc: "18Chesapeake's X3",
          code: 'c=r:40;c=r:40;p=a:0,b:_0;p=a:_0,b:2;p=a:3,b:_1;p=a:_1,b:5;l=OO',
          expected: {
            0 => [2, 5],
            1 => [1, 4],
            2 => [4, 1],
            3 => [5, 2],
            4 => [4, 1],
            5 => [1, 4],
          }
        },
        {
          desc: "18Chesapeake's X5",
          code: 'c=r:40;c=r:40;p=a:3,b:_0;p=a:_0,b:5;p=a:0,b:_1;p=a:_1,b:4;l=OO',
          expected: {
            0 => [3, 0],
            1 => [4, 1],
            2 => [5, 2],
            3 => [0, 3],
            4 => [1, 4],
            5 => [2, 5],
          }
        },
        {
          desc: "18Chesapeake's H6 hex (Baltimore)",
          code: 'c=r:30;c=r:30;p=a:1,b:_0;p=a:4,b:_1;l=OO;u=c:40,t:water',
          expected: {
            0 => [1, 4],
          },
        },
        {
          desc: "18Chesapeake's J4 hex (Philadelphia)",
          code: 'c=r:30;c=r:30;p=a:0,b:_0;p=a:3,b:_1;l=OO',
          expected: {
            0 => [0, 3],
          },
        },
        {
          desc: "1846's tile #298 (green Chi)",
          code: 'c=r:40;c=r:40;c=r:40;c=r:40;'\
                'p=a:0,b:_0;p=a:_0,b:3;'\
                'p=a:1,b:_1;p=a:_1,b:3;'\
                'p=a:4,b:_2;p=a:_2,b:3;'\
                'p=a:5,b:_3;p=a:_3,b:3;'\
                'l=Chi',
          expected: {
            0 => [0, 1, 4, 5],
          },
        },
      ].each do |spec|
        describe "with #{spec[:desc]}" do
          tile = Tile.from_code('name', 'color', spec[:code])

          spec[:expected].each do |rotation, expected|
            it "selects #{expected} for rotation #{rotation}" do
              tile.rotate!(rotation)
              actual = tile.preferred_city_edges

              expected_h = expected.map.with_index do |edge, index|
                [tile.cities[index], edge]
              end.to_h

              expect(actual).to eq(expected_h)
            end
          end
        end
      end
    end
  end
end
