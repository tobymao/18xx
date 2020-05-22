# frozen_string_literal: true

require './spec/spec_helper'

require 'engine'

module Engine
  describe Hex do
    let(:game) { GAMES_BY_TITLE['1889'].new(%w[a b]) }
    subject { game.hex_by_id('H7') }

    describe '#neighbor_direction' do
      it 'is a neighbor' do
        expect(subject.neighbor_direction(game.hex_by_id('I8'))).to eq(5)
      end

      it 'is not a neighbor' do
        expect(subject.neighbor_direction(game.hex_by_id('I4'))).to be_falsey
      end
    end

    describe '#lay' do
      let(:green_tile) { game.tile_by_id('15-0') }
      let(:brown_tile) { game.tile_by_id('611-0') }
      let(:corp_1) { game.corporation_by_id('AR') }
      let(:corp_2) { game.corporation_by_id('IR') }

      context 'laying green' do
        it 'sets @tile to the given tile' do
          subject.lay(green_tile)
          expect(subject.tile).to have_attributes(name: '15')
        end

        it 'preserves a placed token' do
          subject.tile.cities[0].place_token(corp_1)

          subject.lay(green_tile)
          expect(subject.tile.cities[0].tokens[0]).to have_attributes(corporation: corp_1)
          expect(subject.tile.cities[0].tokens[1]).to be_nil
        end

        it 'preserves a token reservation' do
          subject.tile.cities[0].reservations = ['AR']

          subject.lay(green_tile)
          expect(subject.tile.cities[0].reservations).to eq(['AR'])
        end
      end

      context 'laying brown' do
        before(:each) { subject.lay(green_tile) }

        it 'sets @tile to the given tile' do
          subject.lay(brown_tile)

          expect(subject.tile).to have_attributes(name: '611')
        end

        it 'preserves a placed token' do
          subject.tile.cities[0].place_token(corp_1)

          subject.lay(brown_tile)
          expect(subject.tile.cities[0].tokens[0]).to have_attributes(corporation: corp_1)
          expect(subject.tile.cities[0].tokens[1]).to be_nil
        end

        it 'preserves 2 placed tokens' do
          subject.tile.cities[0].place_token(corp_1)
          subject.tile.cities[0].place_token(corp_2)

          subject.lay(brown_tile)

          expect(subject.tile.cities[0].tokens[0]).to have_attributes(
            corporation: corp_1,
            used?: true,
          )

          expect(subject.tile.cities[0].tokens[1]).to have_attributes(
            corporation: corp_2,
            used?: true,
          )
        end

        it 'preserves a placed token and a reservation' do
          subject.tile.cities[0].reservations = ['AR']
          subject.tile.cities[0].place_token(corp_2)

          subject.lay(brown_tile)

          expect(subject.tile.cities[0].tokens[0]).to be_nil
          expect(subject.tile.cities[0].tokens[1]).to have_attributes(corporation: corp_2)
          expect(subject.tile.cities[0].reservations).to eq(['AR'])
        end
      end

      context 'OO tile on 18Chesapeake J4 (Philadelphia)' do
        let(:game) { GAMES_BY_TITLE['18Chesapeake'].new(%w[a b c]) }

        # init C&A so it can token in Philly
        let(:c_and_a) do
          corp = game.corporation_by_id('C&A')
          corp.cash = 40
          corp
        end

        subject { game.hex_by_id('J4') }

        # grab some properties form the preprinted OO tile
        let(:old_tile) { subject.tile }
        let(:old_city) { old_tile.cities.find { |c| c.tokenable?(c_and_a) } }
        let(:old_edge) do
          old_path = old_tile.paths.find { |p| p.city == old_city }
          old_path.exits.first
        end

        before(:each) do
          # place C&A's home token
          game.hex_by_id('J6').tile.cities[0].place_token(c_and_a)

          # place token on the preprinted OO tile
          old_city.place_token(c_and_a)
        end

        {
          'X3' => [0, 1, 3, 4],
          'X4' => [0, 3],
          'X5' => [0, 3],
        }.each do |tile_name, rotations|
          rotations.each do |rotation|
            it "correctly lays #{tile_name} with rotation #{rotation}" do
              # get the tile and rotate it
              tile = game.tile_by_id("#{tile_name}-0")
              tile.rotate!(rotation)

              # lay it
              subject.lay(tile)

              # grab the city that C&A's token is on
              cities = tile.cities.select { |c| c.tokened_by?(c_and_a) }
              expect(cities.size).to eq(1)
              city = cities.first

              # expect the connection between the edge and the bottom city
              # from the preprinted OO tile to still be present
              edges = city.exits
              expect(edges.size).to eq(2)
              expect(edges).to include(old_edge)
            end
          end
        end
      end
    end
  end
end
