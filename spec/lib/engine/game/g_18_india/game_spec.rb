# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G18India::Game do
  describe '18India_game_end_bank' do
    # Action 403: Player 1 is in buying phase, holds EIR (share) in hand
    # EIR par=100, market=126 (market is above IPO price)
    context 'market price above IPO price' do
      it 'hand_price returns IPO price, not market price' do
        game = fixture_at_action(403)
        player = game.current_entity
        step = game.active_step
        cert = player.hand.find { |c| c.name == 'EIR' && c.type == :share }
        corp = cert.treasury.corporation

        expect(corp.share_price.price).to be > corp.par_price.price
        expect(step.hand_price(cert)).to eq(corp.par_price.price)
      end

      it 'player can buy from hand when cash equals IPO price even though market is higher' do
        game = fixture_at_action(403, clear_cache: true)
        player = game.current_entity
        step = game.active_step
        cert = player.hand.find { |c| c.name == 'EIR' && c.type == :share }
        corp = cert.treasury.corporation

        player.instance_variable_set(:@cash, corp.par_price.price)
        expect(step.can_buy_from_hand?(player, cert)).to eq(true)
      end
    end

    # Action 276: Player 2 is in buying phase, holds WIP (share) in hand
    # WIP par=76, market=67 (market is below IPO price)
    context 'market price below IPO price' do
      it 'hand_price returns IPO price, not market price' do
        game = fixture_at_action(276)
        player = game.current_entity
        step = game.active_step
        cert = player.hand.find { |c| c.name == 'WIP' && c.type == :share }
        corp = cert.treasury.corporation

        expect(corp.share_price.price).to be < corp.par_price.price
        expect(step.hand_price(cert)).to eq(corp.par_price.price)
      end

      it 'player must have IPO price cash to buy from hand even though market price is lower' do
        game = fixture_at_action(276, clear_cache: true)
        player = game.current_entity
        step = game.active_step
        cert = player.hand.find { |c| c.name == 'WIP' && c.type == :share }
        corp = cert.treasury.corporation

        player.instance_variable_set(:@cash, corp.par_price.price)
        expect(step.can_buy_from_hand?(player, cert)).to eq(true)

        player.instance_variable_set(:@cash, corp.share_price.price)
        expect(step.can_buy_from_hand?(player, cert)).to eq(false)
      end
    end
  end
end
