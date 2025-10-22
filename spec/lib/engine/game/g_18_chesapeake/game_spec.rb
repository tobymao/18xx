# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G18Chesapeake::Game do
  describe 1277 do
    it 'closes Cornelius Vanderbilt when SRR buys a train' do
      game = fixture_at_action(171)

      expect(game.cornelius.closed?).to eq(false)

      srr = game.corporation_by_id('SRR')
      expect(game.abilities(game.cornelius, :shares).shares.first.corporation).to eq(srr)

      game.process_to_action(172)
      expect(game.cornelius.closed?).to eq(true)
    end
  end

  describe 14_377 do
    it 'closes Cornelius Vanderbilt when the first 5-train is bought' do
      game = fixture_at_action(199)

      expect(game.cornelius.closed?).to eq(false)

      ca = game.corporation_by_id('C&A')
      expect(game.abilities(game.cornelius, :shares).shares.first.corporation).to eq(ca)
      expect(ca.trains).to eq([])

      game.process_to_action(200)
      expect(game.cornelius.closed?).to eq(true)
    end
  end

  describe 22_383 do
    it '2p: when one share is in the market for an unfloated corporation, the '\
       'non-president may do a "buy" action, but then the share is owned by the bank' do
      game = fixture_at_action(104, clear_cache: true)

      share_id = 'LV_1'
      share = game.share_by_id(share_id)

      action = {
        'type' => 'buy_shares',
        'entity' => 4985,
        'entity_type' => 'player',
        'shares' => [
          share_id,
        ],
        'percent' => 10,
      }

      expect(share.owner).to eq(game.share_pool)

      game.process_action(action)

      expect(share.owner).to eq(game.bank)
    end
  end
end
