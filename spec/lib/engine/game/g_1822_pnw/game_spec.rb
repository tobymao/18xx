# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1822PNW::Game do
  describe 165_580 do
    it 'does not include associated minors for majors that were started '\
       'directly as valid choices for P20' do
      game = fixture_at_action(926)

      actual = game.active_step.p20_targets
      expected = [game.corporation_by_id('1')]

      expect(actual).to eq(expected)
    end
  end

  describe 'merger_high_value_minors' do
    it 'can only par at $100' do
      game = fixture_at_action(156)

      m6 = game.corporation_by_id('6')
      m18 = game.corporation_by_id('18')

      expect(m6.owner.value).to eq(1920)
      expect(game.active_step.valid_par_prices(m6, m18)).to eq([100])
    end

    it 'merging 6 and 18 will give the president 6 shares and all their cash' do
      game = fixture_at_action(158)

      m6 = game.corporation_by_id('6')
      m18 = game.corporation_by_id('18')
      ornc = game.corporation_by_id('ORNC')

      expect(m6.owner.value).to eq(1920)
      expect(game.active_step.choice_name).to eq('Choose number of shares to make up minors value of $670')
      expect(game.active_step.choices).to eq({ '6' => 'Player 1 receives 6 shares and $31' })
      expect(m6.cash).to eq(0)
      expect(m18.cash).to eq(0)
      expect(ornc.cash).to eq(31)
    end

    it 'president lost value after merge, the major has no cash left' do
      game = fixture_at_action(160)

      m6 = game.corporation_by_id('6')
      m18 = game.corporation_by_id('18')
      ornc = game.corporation_by_id('ORNC')

      expect(m6.closed?).to eq(true)
      expect(m18.closed?).to eq(true)
      expect(ornc.owner.value).to eq(1881)
      expect(ornc.cash).to eq(0)
    end
  end
end
