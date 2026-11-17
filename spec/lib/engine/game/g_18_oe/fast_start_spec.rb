# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Fast Start' do
  include G18OESpecHelpers

  let(:packets) { Engine::Game::G18OE::Game::FAST_START_PACKETS }

  def fast_game(count)
    new_game(Array.new(count) { |i| "p#{i}" }, optional_rules: [:fast_start])
  end

  it 'deals every private and minor once and pays packet cash (PB 5.1.1–5.1.5)' do
    (3..7).each do |count|
      game = fast_game(count)
      dealt = game.players.map { |p| { companies: p.companies.map(&:sym).sort, cash: p.cash } }
      expected = packets[count].map { |pk| { companies: pk[:companies].sort, cash: pk[:cash] } }

      expect(dealt).to match_array(expected)
    end
  end

  it 'opens with the Fast Start round instead of the auction and concessions (PB 5.1)' do
    game = fast_game(3)

    expect(game.round).to be_a(Engine::Round::G18OE::FastStart)
    expect(game.companies.none? { |c| c.type == :concession }).to be(true)
  end

  it 'places £120 in every minor treasury (PB 5.1)' do
    game = fast_game(4)
    minors = game.corporations.select { |c| c.type == :minor }

    expect(minors).not_to be_empty
    expect(minors.map(&:cash).uniq).to eq([120])
    expect(game.fast_start_minors).to match_array(minors)
  end

  it 'lists minors in player order then packet order' do
    game = fast_game(3)
    expected = game.players.flat_map do |player|
      player.companies.select { |c| game.company_becomes_minor?(c) }.map { |c| game.corporation_by_id(c.sym) }
    end

    expect(game.fast_start_minors).to eq(expected)
  end

  it 'deals packets at random' do
    firsts = (1..10).map do |seed|
      game = Engine::Game::G18OE::Game.new(%w[a b c], seed: seed, optional_rules: [:fast_start])
      game.players.first.companies.map(&:sym).sort
    end

    expect(firsts.uniq.size).to be > 1
  end

  it 'keeps seating order' do
    game = Engine::Game::G18OE::Game.new(%w[a b c], seed: 3, optional_rules: [:fast_start])

    expect(game.players.map(&:name)).to eq(%w[a b c])
  end

  it 'logs the packets before the Fast Start round header' do
    game = fast_game(3)
    texts = game.log.map(&:message)
    packet_line = texts.index { |m| m.include?(game.company_by_id(packets[3].first[:companies].first).name) }

    expect(packet_line).not_to be_nil
    expect(texts.index('-- Fast Start Round --')).to be > packet_line
  end

  describe 'Fast Start round (PB 5.1)' do
    let(:game) { fast_game(3) }
    let(:step) { game.round.active_step }
    let(:charter) { game.round.current_entity }
    let(:minor) { game.corporation_by_id(charter.sym) }
    let(:holder) { charter.owner }

    def choose(amount, entity = charter)
      act!(game, Engine::Action::Choose.new(entity, choice: amount))
    end

    def choose_all!
      choose(0, game.round.current_entity) while game.round.is_a?(Engine::Round::G18OE::FastStart)
    end

    it 'lists every minor charter in player order then packet order' do
      expect(game.round.entities).to eq(game.fast_start_minors.map { |m| game.company_by_id(m.id) })
    end

    it 'asks about the first minor for up to 60, and only its owner may act' do
      expect(step).to be_a(Engine::Game::G18OE::Step::FastStartCapital)
      expect(charter.sym).to eq(game.fast_start_minors.first.id)
      expect(step.choices).to eq([0, 60])
      expect(step.choice_is_amount?).to be(true)
      expect(game.active_players).to eq([holder])
    end

    it 'moves the chosen amount from the player to the minor' do
      cash = holder.cash
      choose(60)

      expect(minor.cash).to eq(180)
      expect(holder.cash).to eq(cash - 60)
    end

    it 'rejects more than 60' do
      expect { step.process_choose(Engine::Action::Choose.new(charter, choice: 61)) }.to raise_error(Engine::GameError)
    end

    it 'caps the amount at the player cash' do
      holder.spend(holder.cash - 30, game.bank)

      expect(step.choices).to eq([0, 30])
      expect { step.process_choose(Engine::Action::Choose.new(charter, choice: 31)) }.to raise_error(Engine::GameError)
    end

    it 'accepts zero and moves to the next minor while keeping every charter listed' do
      first = minor
      charters = game.round.entities.dup
      choose(0)

      expect(first.cash).to eq(120)
      expect(game.round.entities).to eq(charters)
      expect(game.round.current_entity).to eq(charters[1])
    end

    it 'starts Stock Round 1 with the first player after the last minor' do
      choose_all!

      expect(game.round).to be_a(Engine::Round::Stock)
      expect(game.round.active_step).to be_a(Engine::Game::G18OE::Step::BuySellParShares)
      expect(game.round.current_entity).to eq(game.players.first)
      expect(game.log.map(&:message)).to include('-- Stock Round 1 --')
    end

    it 'lets a packet minor float in the first stock round' do
      choose_all!
      player = game.round.current_entity
      mine = player.companies.find { |c| game.company_becomes_minor?(c) }

      expect(mine).not_to be_nil
      expect(game.round.active_step.ipo_type(game.corporation_by_id(mine.sym))).to eq(:form)
      expect(game.round.actions_for(player)).to include('par')
    end

    it 'keeps the step out of stock rounds' do
      expect(game.stock_round.steps.map(&:class)).not_to include(Engine::Game::G18OE::Step::FastStartCapital)
    end
  end
end
