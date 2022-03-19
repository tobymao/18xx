# frozen_string_literal: true

require './spec/spec_helper'

class SharePoolTest
  def shares_of(_corp)
    []
  end
end

class TranchTest
  include(Engine::Game::Tranches)

  attr_reader :share_pool

  def initialize
    @share_pool = SharePoolTest.new
  end
end

class FakeCorporation
  def initialize(operated, sold_out)
    @operated = operated
    @sold_out = sold_out
  end

  def operated?
    !!@operated
  end

  def shares_of(_corp)
    return [] if @sold_out

    [true]
  end
end

module Engine
  module Game
    describe FakeCorporation do
      describe 'which has operated' do
        let(:c) { FakeCorporation.new(true, false) }
        it 'should respond correctly' do
          expect(c.operated?).to be true
          expect(c.shares_of(c)).to eq([true])
        end
      end

      describe 'which has sold out' do
        let(:c) { FakeCorporation.new(false, true) }
        it 'should respond correctly' do
          expect(c.operated?).to be false
          expect(c.shares_of(c)).to eq([])
        end
      end

      describe 'which has done neither' do
        let(:c) { FakeCorporation.new(false, false) }
        it 'should respond correctly' do
          expect(c.operated?).to be false
          expect(c.shares_of(c)).to eq([true])
        end
      end
    end

    describe Tranches do
      let(:t) { TranchTest.new }
      let(:c) { FakeCorporation.new(false, false) }
      let(:c_operated) { FakeCorporation.new(true, false) }
      let(:c_sold_out) { FakeCorporation.new(false, true) }

      it 'should default to nil tranches' do
        expect(t.tranches).to be nil
        expect(t.current_tranch_index).to be nil
        expect(t.tranches_full?).to be true
        expect(t.current_tranch_open?).to be false
        expect(t.current_tranch_slot_index).to be nil
        expect(t.current_tranch_open?).to be false
        expect(t.previous_tranch_all_sold_out_or_operated?).to be true
        expect(t.tranch_available?).to be false
      end

      describe '#corporation_sold_out?' do
        it 'should correctly show if a corp has sold out' do
          t.init_tranches
          expect(t.corporation_sold_out?(c)).to be false
          expect(t.corporation_sold_out?(c_operated)).to be false
          expect(t.corporation_sold_out?(c_sold_out)).to be true
        end
      end

      describe 'with no initialization' do
        it 'should default to no tranches' do
          t.init_tranches
          expect(t.tranches).to eq([])
          expect(t.current_tranch_index).to be 0
          expect(t.current_tranch_slot_index).to be nil
          expect(t.tranches_full?).to be true
          expect(t.current_tranch_open?).to be false
          expect(t.previous_tranch_all_sold_out_or_operated?).to be true
          expect(t.tranch_available?).to be false
        end
      end

      describe 'with a single tranch' do
        it 'should init properly' do
          t.init_tranches([[nil]])
          expect(t.tranches).to eq([[nil]])
          expect(t.current_tranch_index).to be 0
          expect(t.current_tranch_slot_index).to be 0
          expect(t.tranches_full?).to be false
          expect(t.current_tranch_open?).to be true
          expect(t.previous_tranch_all_sold_out_or_operated?).to be true
          expect(t.tranch_available?).to be true
        end
      end

      describe 'with a simple tranch setup' do
        let(:t) do
          t = TranchTest.new
          t.init_tranches([[nil, nil], [nil, nil]])
          t
        end

        it 'should initialize correctly' do
          expect(t.tranches).to eq([[nil, nil], [nil, nil]])
          expect(t.current_tranch_index).to be 0
          expect(t.current_tranch_slot_index).to be 0
          expect(t.tranches_full?).to be false
          expect(t.current_tranch_open?).to be true
          expect(t.previous_tranch_all_sold_out_or_operated?).to be true
          expect(t.tranch_available?).to be true
        end

        describe 'with one corporation added' do
          before(:each) do
            t.add_corporation_to_tranches(c)
          end

          it 'should behave correctly' do
            expect(t.tranches).to eq([[c, nil], [nil, nil]])
            expect(t.current_tranch_index).to be 0
            expect(t.current_tranch_slot_index).to be 1
            expect(t.tranches_full?).to be false
            expect(t.current_tranch_open?).to be true
            expect(t.previous_tranch_all_sold_out_or_operated?).to be true
            expect(t.tranch_available?).to be true
          end
        end

        describe 'with two corporations added' do
          before(:each) do
            t.add_corporation_to_tranches(c)
            t.add_corporation_to_tranches(c)
          end

          it 'should behave correctly' do
            expect(t.tranches).to eq([[c, c], [nil, nil]])
            expect(t.current_tranch_index).to be 1
            expect(t.current_tranch_slot_index).to be 0
            expect(t.tranches_full?).to be false
            expect(t.current_tranch_open?).to be true
            expect(t.previous_tranch_all_sold_out_or_operated?).to be false
            expect(t.tranch_available?).to be false
          end
        end

        describe 'with two sold out or operated corporations added' do
          before(:each) do
            t.add_corporation_to_tranches(c_operated)
            t.add_corporation_to_tranches(c_sold_out)
          end

          it 'should behave correctly' do
            expect(t.tranches).to eq([[c_operated, c_sold_out], [nil, nil]])
            expect(t.current_tranch_index).to be 1
            expect(t.current_tranch_slot_index).to be 0
            expect(t.tranches_full?).to be false
            expect(t.current_tranch_open?).to be true
            expect(t.previous_tranch_all_sold_out_or_operated?).to be true
            expect(t.tranch_available?).to be true
          end
        end

        describe 'with four corporations added' do
          before(:each) do
            t.add_corporation_to_tranches(c)
            t.add_corporation_to_tranches(c)
            t.add_corporation_to_tranches(c)
            t.add_corporation_to_tranches(c)
          end

          it 'should behave correctly' do
            expect(t.tranches).to eq([[c, c], [c, c]])
            expect(t.current_tranch_index).to be 2
            expect(t.current_tranch_slot_index).to be nil
            expect(t.tranches_full?).to be true
            expect(t.current_tranch_open?).to be false
            expect(t.previous_tranch_all_sold_out_or_operated?).to be false
            expect(t.tranch_available?).to be false
          end
        end
      end
    end
  end
end
