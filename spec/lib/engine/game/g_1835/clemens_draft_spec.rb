# frozen_string_literal: true

require 'spec_helper'
require_relative 'spec_helper_1835'

describe Engine::Game::G1835::Game do
  let(:game) { Engine::Game::G1835::Game.new(players, optional_rules: [:clemens]) }
  let(:by) { game.corporation_by_id('BY') }
  let(:sx) { game.corporation_by_id('SX') }
  let(:ba) { game.corporation_by_id('BA') }
  let(:wt) { game.corporation_by_id('WT') }
  let(:he) { game.corporation_by_id('HE') }
  let(:pr) { game.corporation_by_id('PR') }
  let(:ms) { game.corporation_by_id('MS') }
  let(:ol) { game.corporation_by_id('OL') }
  let(:player_1) { game.players.find { |player| player.id == 'a' } }
  let(:player_2) { game.players.find { |player| player.id == 'b' } }
  let(:player_3) { game.players.find { |player| player.id == 'c' } }
  let(:player_4) { game.players.find { |player| player.id == 'd' } }
  let(:player_5) { game.players.find { |player| player.id == 'e' } }
  let(:player_6) { game.players.find { |player| player.id == 'f' } }
  let(:player_7) { game.players.find { |player| player.id == 'g' } }

  describe 'clemens_draft' do
    let(:players) { %w[a b c] }

    it 'should be possible to buy any paper' do
      # put the companies in an order that makes no player run out of money, but is otherwise arbitrary
      companies = %w[LD 1 NF BY_D HB 5 2 3 4 BB 6 PB OBB]
      companies.each do |company_id|
        buy(game.round.current_entity, company_id)
      end
    end

    it 'should reverse the first round and then go in order' do
      buy(player_3, '1')
      buy(player_2, '2')
      buy(player_1, '3')

      buy(player_1, '4')
      buy(player_2, '5')
      buy(player_3, '6')

      buy(player_1, 'NF')
      buy(player_2, 'PB')
      buy(player_3, 'OBB')

      pass(player_1)
      pass(player_2)
      pass(player_3)

      expect(game.players.first).to eq(player_1)
    end

    it 'should skip minors but pay privates if BY does not float in draft' do
      # sell all minors and 40% of BY
      buy(player_3, '1')
      buy(player_2, '2')
      buy(player_1, '3')
      buy(player_1, '4')
      buy(player_2, '5')
      buy(player_3, '6')
      buy(player_1, 'BY_D')
      buy(player_2, 'OBB')
      buy(player_3, 'PB')

      player_2_cash_at_end_of_draft = player_2.cash
      player_3_cash_at_end_of_draft = player_3.cash
      pass(game.round.current_entity)
      pass(game.round.current_entity)
      pass(game.round.current_entity)

      # did the minors pay out?
      expect(player_2.cash).to eq(player_2_cash_at_end_of_draft + 10)
      expect(player_3.cash).to eq(player_3_cash_at_end_of_draft + 15)

      # are we in a draft again?
      expect(game.active_step.class).to eq(Engine::Game::G1835::Step::Draft)

      # were the minors skipped?
      game.minors.each do |minor|
        expect(minor.operated?).to be(false)
      end
    end

    it 'should let the minors operate if BY floats' do
      # sell only the first minor and 50% of BY to let it float
      buy(player_3, '1')
      buy(player_2, 'BY_D')
      buy(player_1, 'OBB')
      buy(player_1, 'PB')
      buy(player_2, 'NF')

      pass(game.round.current_entity)
      pass(game.round.current_entity)
      pass(game.round.current_entity)

      expect(game.round.current_entity).to eq(game.minor_by_id('1'))
    end

    it 'should properly move the PD' do
      buy(player_3, '1')
      buy(player_2, 'BY_D')
      buy(player_1, 'OBB')
      buy(player_1, 'PB')
      buy(player_2, 'NF')

      pass(game.round.current_entity)
      pass(game.round.current_entity)
      pass(game.round.current_entity)

      expect(game.players.first).to eq(player_3)
    end

    it 'should proceed in regular player order in the second draft round' do
      buy(player_3, '1')
      buy(player_2, 'BY_D')
      buy(player_1, 'OBB')
      buy(player_1, 'PB')

      pass(game.round.current_entity)
      pass(game.round.current_entity)
      pass(game.round.current_entity)

      # everyone passed, first draft round over
      buy(player_2, 'NF')
      buy(player_3, '3')
      buy(player_1, '5')
      buy(player_2, '6')
      buy(player_3, 'BB')
    end
  end
end
