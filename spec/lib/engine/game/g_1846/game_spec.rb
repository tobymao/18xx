# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1846::Game do
  describe '10264' do
    it 'does not block the track and token step for an unused company tile-lay ability' do
      game = fixture_at_action(260)

      expect(game.current_entity).to eq(game.illinois_central)
      expect(game.michigan_central.owner).to eq(game.illinois_central)
      expect(game.abilities(game.michigan_central, :tile_lay).count).to eq(2)
      expect(game.active_step).to be_a(Engine::Step::Dividend)
    end
  end

  describe '19962' do
    it 'has a cert limit of 12 at the start of a 4p game' do
      game = fixture_at_action(0)

      expect(game.cert_limit).to be(12)
    end

    it 'IC can lay a tile on J4 for free' do
      game = fixture_at_action(64)

      expect(game.illinois_central.cash).to be(280)

      game.process_to_action(65)

      expect(game.illinois_central.cash).to be(280)
    end

    it 'removes the reservation when a token is placed' do
      game = fixture_at_action(114)

      city = game.hex_by_id('D20').tile.cities.first
      corp = game.corporation_by_id('ERIE')
      expect(city.reserved_by?(corp)).to be(false)
    end

    it 'has a cert limit of 10 after a corporation closes' do
      game = fixture_at_action(122)

      expect(game.cert_limit).to be(10)
    end

    it 'has correct reservations and tokens after NYC closes' do
      game = fixture_at_action(162)

      city = game.hex_by_id('D20').tile.cities.first
      erie = game.corporation_by_id('ERIE')

      expect(city.reservations).to eq([nil, nil])
      expect(city.tokens.map { |t| t&.corporation }).to eq([nil, erie])
    end

    it 'has a cert limit of 10 after a corporation closes and then a player is bankrupt' do
      game = fixture_at_action(300)

      expect(game.cert_limit).to be(10)
    end

    it 'has a cert limit of 8 after a corporation closes, then a player is '\
       'bankrupt, and then another corporation closes' do
      game = fixture_at_action(328)

      expect(game.cert_limit).to be(8)
    end
  end

  describe '20381' do
    it 'cannot go bankrupt when shares can be emergency issued' do
      game = fixture_at_action(308)

      prr = game.corporation_by_id('PRR')
      expect(game.can_go_bankrupt?(prr.player, prr)).to be(false)
      expect(game.emergency_issuable_cash(prr)).to eq(10)
    end
  end

  describe '222264' do
    it 'cannot acquire an Independent Railroad after emergency issuing shares' do
      game = fixture_at_action(96)

      gt = game.corporation_by_id('GT')
      big4 = game.company_by_id('BIG4')

      expect(gt.trains.size).to eq(0)
      expect(gt.trains.count(&:obsolete)).to eq(0)
      expect(gt.owner).to eq(big4.owner)
      expect(game.round.actions_for(gt).sort).to eq(%w[bankrupt buy_train end_game])
    end

    it 'can acquire an Independent Railroad after emergency issuing shares and buying a train' do
      game = fixture_at_action(97)

      gt = game.corporation_by_id('GT')
      big4 = game.company_by_id('BIG4')

      expect(gt.trains.size).to eq(1)
      expect(gt.trains.count(&:obsolete)).to eq(0)
      expect(gt.owner).to eq(big4.owner)
      expect(game.round.actions_for(gt).sort).to eq(%w[bankrupt buy_company buy_train end_game pass])
    end
  end
end
