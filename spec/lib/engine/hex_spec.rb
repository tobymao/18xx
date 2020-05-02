# frozen_string_literal: true

require './spec/spec_helper'

require 'engine'

module Engine
  describe Hex do
    let(:game) { GAMES_BY_TITLE['1889'].new(['a', 'b']) }
    subject { game.hex_by_id('H7') }
#
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
    end
  end
end
