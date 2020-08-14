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
          'town' => %w[3 58 437],
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
        it "correctly upgrades tiles for #{game_title}" do
          game = Engine::GAMES_BY_TITLE[game_title].new(%w[p1 p2 p3])

          aggregate_failures 'tile upgrades' do
            upgrades.keys.each do |t|
              tile = game.hex_by_id(t)&.tile || game.tile_by_id("#{t}-0") || Tile.for(t)

              upgrades.keys.each do |u|
                upgrade = game.hex_by_id(u)&.tile || game.tile_by_id("#{u}-0") || Tile.for(u)

                expected_included = upgrades[t].include?(u)
                expected_string = "#{t} #{expected_included ? '<' : '!<'} #{u}"

                actual_included = game.upgrades_to?(tile, upgrade)
                actual_string = "#{t} #{actual_included ? '<' : '!<'} #{u}"

                expect(actual_string).to eq(expected_string)
              end
            end
          end
        end
      end
    end

    describe '#preferred_city_town_edges' do
      [
        {
          desc: "18Chesapeake's X3",
          code: 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:5;label=OO',
          expected: {
            0 => [2, 5],
            1 => [1, 4],
            2 => [4, 1],
            3 => [5, 2],
            4 => [4, 1],
            5 => [1, 4],
          },
        },
        {
          desc: "18Chesapeake's X5",
          code: 'city=revenue:40;city=revenue:40;path=a:3,b:_0;path=a:_0,b:5;path=a:0,b:_1;path=a:_1,b:4;label=OO',
          expected: {
            0 => [3, 0],
            1 => [4, 1],
            2 => [5, 2],
            3 => [0, 3],
            4 => [1, 4],
            5 => [2, 5],
          },
        },
        {
          desc: "18Chesapeake's H6 hex (Baltimore)",
          code: 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=OO;upgrade=cost:40,terrain:water',
          expected: {
            0 => [1, 4],
          },
        },
        {
          desc: "18Chesapeake's J4 hex (Philadelphia)",
          code: 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:3,b:_1;label=OO',
          expected: {
            0 => [0, 3],
          },
        },
        {
          desc: "1846's tile #298 (green Chi)",
          code: 'city=revenue:40;city=revenue:40;city=revenue:40;city=revenue:40;'\
                'path=a:0,b:_0;path=a:_0,b:3;'\
                'path=a:1,b:_1;path=a:_1,b:3;'\
                'path=a:4,b:_2;path=a:_2,b:3;'\
                'path=a:5,b:_3;path=a:_3,b:3;'\
                'label=Chi',
          expected: {
            0 => [0, 1, 4, 5],
          },
        },
        {
          desc: "18Carolina's G19 hex (Wilmington)",
          code: 'city=revenue:30;city=revenue:0;path=a:1,b:_0;label=C',
          expected: {
            0 => [1, 4],
          },
        },
      ].each do |spec|
        describe "with #{spec[:desc]}" do
          tile = Tile.from_code('name', 'color', spec[:code])

          spec[:expected].each do |rotation, expected|
            it "selects #{expected} for rotation #{rotation}" do
              tile.rotate!(rotation)
              actual = tile.preferred_city_town_edges

              expected_h = expected.map.with_index do |edge, index|
                [tile.cities[index], edge]
              end.to_h

              expect(actual).to eq(expected_h)
            end
          end
        end
      end
    end

    describe '#revenue_to_render' do
      {
        '1846' => {
          'C15' => [40],
          'C17' => [{ yellow: 40, brown: 60 }],
          'D6' => [10, 10, 10, 10],
        },
        '1882' => {
          'D8' => [30],
          'J10' => [40, 40],
          'O11' => [{ yellow: 30, brown: 30 }],
        },
      }.each do |game_title, specs|
        game = Engine::GAMES_BY_TITLE[game_title].new(%w[p1 p2 p3])
        describe game_title do
          specs.each do |hex, expected_revenue|
            tile = game.hex_by_id(hex).tile
            it "returns #{expected_revenue} for #{tile.name}" do
              expect(tile.revenue_to_render).to eq(expected_revenue)
            end
          end
        end
      end
    end
  end
end
