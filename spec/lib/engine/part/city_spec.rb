# frozen_string_literal: true

require './spec/spec_helper'

module Engine
  module Part
    describe City do
      subject { Tile.for('57', index: 0).cities[0] }

      let(:corporation) { Engine::Corporation.new(sym: 'AS', name: 'Aperture Science', tokens: [0, 40]) }
      let(:corporation2) { Engine::Corporation.new(sym: 'BM', name: 'Black Mesa', tokens: []) }
      let(:corporation3) { Engine::Corporation.new(sym: 'C', name: 'Chell', tokens: [0, 40]) }
      let(:unplaced_token) { corporation.next_token }
      let(:neutral_token) { Engine::Token.new(corporation2, type: :neutral) }

      describe '#initialize' do
        it 'starts with no tokens' do
          expect(subject.tokens).to eq([nil])
        end
      end

      describe '#blocks?' do
        it 'unblocked with no tokens' do
          expect(subject.blocks?(corporation)).to be false
        end
        it 'unblocked with same corporation token' do
          subject.place_token(corporation, unplaced_token, free: true)
          expect(subject.blocks?(corporation)).to be false
        end
        it 'blocked with different corporation token' do
          subject.place_token(corporation, unplaced_token, free: true)
          expect(subject.blocks?(corporation2)).to be true
        end
        it 'unblocked with neutral token' do
          corporation2.tokens << neutral_token
          subject.place_token(corporation2, neutral_token, free: true)
          expect(subject.blocks?(corporation)).to be false
        end
      end

      describe '#tokenable?' do
        subject { Tile.for('14', index: 0).cities[0] }
        it 'disallows two tokens of the same corp' do
          subject.place_token(corporation, unplaced_token, free: true)
          expect(subject.tokenable?(corporation)).to be false
        end
        it 'allows neutral token' do
          corporation.tokens << neutral_token
          subject.place_token(corporation, unplaced_token, free: true)
          expect(subject.tokenable?(corporation)).to be true
        end
        it 'disallows with different corp reservation' do
          subject.add_reservation!(corporation2)
          subject.place_token(corporation3, corporation3.next_token, free: true)
          expect(subject.tokenable?(corporation)).to be false
        end
        it 'allows with same corp reservation' do
          subject.add_reservation!(corporation)
          subject.place_token(corporation3, corporation3.next_token, free: true)
          expect(subject.tokenable?(corporation)).to be true
        end
        context '2 city tile' do
          subject { Tile.for('128', index: 0).cities[0] } # 2 city tile
          it 'disallows with different corp reservation on tile' do
            subject.tile.add_reservation!(corporation2, nil)
            subject.tile.cities[1].place_token(corporation3, corporation3.next_token, free: true)
            expect(subject.tokenable?(corporation)).to be false
          end
          it 'allows with same corp reservation on tile' do
            subject.tile.add_reservation!(corporation, nil)
            subject.tile.cities[1].place_token(corporation3, corporation3.next_token, free: true)
            expect(subject.tokenable?(corporation)).to be true
          end
        end
        context '2 city tile with 1830/1836Jr30 rules' do
          subject { Tile.for('128', index: 0, reservation_blocks: :always).cities[0] } # 2 city tile
          it 'disallows with different corp reservation on tile' do
            subject.tile.add_reservation!(corporation2, nil)
            expect(subject.tokenable?(corporation)).to be false
          end
          it 'allows with same corp reservation on tile' do
            subject.tile.add_reservation!(corporation, nil)
            expect(subject.tokenable?(corporation)).to be true
          end
        end
      end

      describe '#exits' do
        it "returns the correct edges for 18Chesapeake's tile X3" do
          game = Engine.game_by_title('18Chesapeake').new(%w[a b c])
          x3 = game.tile_by_id('X3-0')
          expect(x3.cities[0].exits.sort).to eq([0, 2])
          expect(x3.cities[1].exits.sort).to eq([3, 5])

          x3.rotate!(1)
          expect(x3.cities[0].exits.sort).to eq([1, 3])
          expect(x3.cities[1].exits.sort).to eq([0, 4])
        end
      end
    end
  end
end
