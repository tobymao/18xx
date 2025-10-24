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

  describe '1822PNW_game_end_stock_market' do
    it ':stock market ending takes precedence, even when triggered after :bank ending was triggered' do
      game = fixture_at_action(1414)

      expect(game.finished).to eq(false)
      expect(game.bank.broken?).to eq(false)
      expect(game.stock_market.max_reached?).to be_nil
      expect(game.game_ending_description).to be_nil

      game.process_to_action(1415)
      expect(game.finished).to eq(false)
      expect(game.bank.broken?).to eq(true)
      expect(game.stock_market.max_reached?).to be_nil
      expect(game.game_ending_description).to eq('Bank Broken : Game Ends at conclusion of OR 10.2')

      game.process_to_action(1419)
      expect(game.finished).to eq(false)
      expect(game.bank.broken?).to eq(true)
      expect(game.stock_market.max_reached?).to eq(true)
      expect(game.game_ending_description).to eq('Company hit max stock value : Game Ends at conclusion of this OR (10.1)')

      game.process_to_action(1445)
      expect(game.finished).to eq(true)
      expect(game.bank.broken?).to eq(true)
      expect(game.stock_market.max_reached?).to eq(true)
      expect(game.game_ending_description).to eq('Company hit max stock value')
      expect(game.round.round_num).to eq(1)
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

  describe 'mill_ski_coal' do
    it 'does not allow mill or ski companies to use the coal hex' do
      # https://boardgamegeek.com/thread/3533826/article/46291488#46291488
      game = fixture_at_action(592)

      mill = game.company_by_id('P15')
      ski = game.company_by_id('P17')
      coal_hex = game.hex_by_id('J17')

      # coal tile is on the hex
      expect(coal_hex.tile.name).to eq('PNW4')

      assign_step = game.round.step_for(mill, 'assign')
      expect(assign_step.available_hex_mill(mill, coal_hex)).to eq(false)
      expect(assign_step.available_hex_ski(ski, coal_hex)).to eq(false)
    end
  end
end
