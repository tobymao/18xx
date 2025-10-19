# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1836Jr30::Game do
  describe 2809 do
    it 'CFLV blocks I3 and J4' do
      game = fixture_at_action(34)

      i3 = game.hex_by_id('I3')
      j4 = game.hex_by_id('J4')
      cflv = game.company_by_id('CFLV')
      blocking_ability = game.abilities(cflv, :blocks_hexes)

      expect(i3.tile.blockers).to eq([cflv])
      expect(j4.tile.blockers).to eq([cflv])
      expect(blocking_ability.hexes).to eq([j4, i3])
    end

    it 'CFLV no longer blocks I3 and J4 after the Nord buys a train' do
      game = fixture_at_action(35)

      i3 = game.hex_by_id('I3')
      j4 = game.hex_by_id('J4')
      cflv = game.company_by_id('CFLV')
      blocking_ability = game.abilities(cflv, :blocks_hexes)

      expect(i3.tile.blockers).to eq([])
      expect(j4.tile.blockers).to eq([])
      expect(blocking_ability).to be_nil
    end
  end
end
