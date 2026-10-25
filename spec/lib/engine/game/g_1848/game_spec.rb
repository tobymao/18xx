# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1848::Game do
  describe 101 do
    it '2nd receivership removes the next permanent and triggers phase change' do
      game = fixture_at_action(483)

      expect(game.phase.name).to eq('5')
      expect(game.depot.upcoming.count { |train| train.name == '5' }).to eq(2)
    end
  end

  describe 270_178 do
    it 'stops at buy trains when a loan would fund a train' do
      game = fixture_at_action(530)
      sar = game.corporation_by_id('SAR')

      expect(sar.cash).to eq(0)
      expect(game.round.active_step).to be_a(Engine::Game::G1848::Step::BuyTrain)
      expect(game.round.actions_for(sar)).to include('take_loan', 'buy_train', 'pass')

      game.process_action(Engine::Action::TakeLoan.new(sar, loan: game.loans.first))
      ghan_train = game.depot.depot_trains.find { |t| t.name == '2E' }
      game.process_action(Engine::Action::BuyTrain.new(game.ghan, train: ghan_train, price: 100))

      expect(game.exception).to be_nil
      expect(sar.trains.map(&:name)).to include('2E')
    end
  end
end
