# frozen_string_literal: true

require './spec/spec_helper'
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
      context '1889' do
        EXPECTED_TILE_UPGRADES = {
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
  end
end
