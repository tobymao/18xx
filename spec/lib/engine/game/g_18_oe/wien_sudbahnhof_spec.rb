# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Wien Südbahnhof (§14.3)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:owner) { game.players[0] }
  let(:other) { game.players[1] }
  let(:ws) { give_company!(owner, game.company_by_id('WS')) }
  let(:liverpool) { game.hex_by_id('J25').tile.cities.first }
  let(:christiania) { game.hex_by_id('C48').tile.cities.first }
  let(:le_havre) { game.hex_by_id('O28').tile.cities.first }
  let(:unconnected) { game.hex_by_id('Q30').tile.cities.first }

  def token_round!(operator)
    ws
    round = enter_round!(game, game.operating_round(1))
    round.setup
    round_step(round, Engine::Step::Track).pass!
    expect(round.current_operator).to eq(operator)
    round
  end

  def special_token(round)
    round_step(round, Engine::Step::SpecialToken)
  end

  def place!(round, operator, city, **args)
    act!(round, Engine::Action::PlaceToken.new(ws, city: city, tokener: operator, **args))
  end

  context 'with a major' do
    let!(:lnwr) { start_major!(game, 'LNWR', owner) }

    it "offers WS a place token action in a controlled RR's Place Token step" do
      round = token_round!(lnwr)
      expect(special_token(round).actions(ws)).to eq(['place_token'])
    end

    it 'offers nothing for a RR another player controls (§6.1)' do
      lnwr.owner = other
      round = token_round!(lnwr)
      expect(special_token(round).actions(ws)).to eq([])
    end

    it 'places the token for free' do
      round = token_round!(lnwr)
      cash = lnwr.cash
      place!(round, lnwr, liverpool)
      expect(lnwr.cash).to eq(cash)
      expect(liverpool.tokened_by?(lnwr)).to be(true)
    end

    it 'places the most expensive unused token' do
      round = token_round!(lnwr)
      place!(round, lnwr, liverpool)
      expect(lnwr.tokens.reject(&:used).map(&:price)).to eq([20, 40, 60, 60, 80, 80])
    end

    it 'offers only reachable cities' do
      round = token_round!(lnwr)
      expect(special_token(round).available_hex(ws, unconnected.hex)).to be_falsy
    end

    it 'rejects an unconnected city' do
      round = token_round!(lnwr)
      expect { place!(round, lnwr, unconnected) }.to raise_error(Engine::GameError, /not connected/)
    end

    it "uses the RR's token placement for the OR (R1)" do
      round = token_round!(lnwr)
      place!(round, lnwr, liverpool)
      expect(round.tokened).to be(true)
      expect(round_step(round, Engine::Game::G18OE::Step::Token).actions(lnwr)).to eq([])
    end

    it 'closes the private once used (R3)' do
      round = token_round!(lnwr)
      place!(round, lnwr, liverpool)
      expect(ws.closed?).to be(true)
      expect(owner.companies).not_to include(ws)
    end

    it 'keeps the Place Token step closed when the RR has no unused tokens' do
      round = token_round!(lnwr)
      lnwr.tokens.each { |t| t.used = true }
      expect(round_step(round, Engine::Game::G18OE::Step::Token).actions(lnwr)).to eq([])
    end

    it 'keeps the Place Token step closed when the RR can reach no city' do
      round = token_round!(lnwr)
      allow(game.token_graph_for_entity(lnwr)).to receive(:can_token?).and_return(false)
      expect(round_step(round, Engine::Game::G18OE::Step::Token).actions(lnwr)).to eq([])
    end

    it 'opens the Place Token step for a RR with no cash' do
      round = token_round!(lnwr)
      lnwr.spend(lnwr.cash, game.bank)
      expect(round_step(round, Engine::Game::G18OE::Step::Token).actions(lnwr)).to eq(%w[place_token pass])
    end

    it 'places only for the operating RR when the player controls two RRs' do
      dsj = start_regional!(game, 'DSJ', owner)
      game.minor_regional_order.delete(lnwr)
      game.minor_regional_order.unshift(lnwr)
      round = token_round!(lnwr)
      lnwr_cash = lnwr.cash
      dsj_cash = dsj.cash
      dsj_tokens = dsj.tokens.count(&:used)
      place!(round, lnwr, liverpool)
      expect(liverpool.tokened_by?(lnwr)).to be(true)
      expect(liverpool.tokened_by?(dsj)).to be(false)
      expect(lnwr.cash).to eq(lnwr_cash)
      expect(dsj.cash).to eq(dsj_cash)
      expect(dsj.tokens.count(&:used)).to eq(dsj_tokens)
    end

    it 'leaves White Cliffs Ferry without actions and open after a WS placement (R1)' do
      game.phase.next! until game.phase.name == '5'
      wcf = give_company!(owner, game.company_by_id('WCF'))
      round = token_round!(lnwr)
      expect(special_token(round).actions(ws)).to eq(['place_token'])
      expect(special_token(round).actions(wcf)).to eq(['place_token'])
      place!(round, lnwr, liverpool)
      expect(special_token(round).actions(wcf)).to eq([])
      expect(wcf.closed?).to be(false)
    end
  end

  context 'with a regional' do
    let!(:dsj) { start_regional!(game, 'DSJ', owner) }

    it "offers only cities in the RR's track rights" do
      round = token_round!(dsj)
      expect(special_token(round).available_hex(ws, christiania.hex)).to be_truthy
      expect(special_token(round).available_hex(ws, le_havre.hex)).to be_falsy
    end

    it 'rejects a city outside track rights' do
      round = token_round!(dsj)
      expect { place!(round, dsj, le_havre) }.to raise_error(Engine::GameError, /outside .* track rights zone/)
    end

    it 'charges the cross-water fee (§11.2.1)' do
      round = token_round!(dsj)
      cash = dsj.cash
      action = Engine::Action::PlaceToken.new(ws, city: christiania, tokener: dsj)
      act!(round, action)
      expect(cash - dsj.cash).to eq(40)
      expect(action.cost).to eq(40)
    end

    it 'rejects the placement when the treasury cannot pay the fee' do
      round = token_round!(dsj)
      dsj.spend(80, game.bank)
      expect { place!(round, dsj, christiania) }.to raise_error(Engine::GameError, /cannot afford/)
      expect(christiania.tokened_by?(dsj)).to be(false)
      expect(ws.closed?).to be(false)
    end

    it 'trusts the recorded fee on replay without building a sea network' do
      round = token_round!(dsj)
      game.instance_variable_set(:@loading, true)
      expect(Engine::Game::G18OE::SeaConnectivity).not_to receive(:new)
      cash = dsj.cash
      round_step(round, Engine::Step::SpecialToken)
        .process_place_token(Engine::Action::PlaceToken.new(ws, city: christiania, tokener: dsj, cost: 40))
      expect(cash - dsj.cash).to eq(40)
      expect(christiania.tokened_by?(dsj)).to be(true)
    end

    it 'rejects a recorded fee that differs' do
      round = token_round!(dsj)
      expect { place!(round, dsj, christiania, cost: 0) }.to raise_error(Engine::GameError, /Token costs £40, not £0/)
    end
  end
end
