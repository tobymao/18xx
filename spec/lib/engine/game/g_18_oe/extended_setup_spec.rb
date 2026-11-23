# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe '18OE Extended Full Game setup (PB 5.6)' do
  include G18OESpecHelpers

  let(:meta) { Engine::Game::G18OE::Meta }

  def players(count)
    Array.new(count) { |index| "p#{index}" }
  end

  [
    [3, 64, 2160, 2095],
    [4, 48, 1620, 1570],
    [5, 39, 1300, 1260],
    [6, 32, 1080, 1050],
    [7, 27, 930, 900],
    [8, 24, 810, 785],
  ].each do |count, cert_limit, with_concessions, without_concessions|
    it "uses the printed limits and starting capital for #{count} players" do
      standard_start = new_game(players(count), optional_rules: [:extended_full_game])
      medium_start = new_game(players(count), optional_rules: %i[extended_full_game medium_start])

      expect([standard_start.cert_limit, medium_start.cert_limit]).to eq([cert_limit, cert_limit])
      expect(standard_start.players.map(&:cash)).to eq([with_concessions] * count)
      expect(medium_start.players.map(&:cash)).to eq([without_concessions] * count)
      expect(standard_start.companies.count { |company| standard_start.concession?(company) }).to eq(10)
      expect(medium_start.companies.none? { |company| medium_start.concession?(company) }).to be(true)
    end
  end

  it 'starts with £64,800 split between the bank and players' do
    game = new_game(optional_rules: [:extended_full_game])

    expect(game.bank.cash + game.players.sum(&:cash)).to eq(64_800)
  end

  it 'requires Extended Full Game for eight players' do
    expect { new_game(players(8)) }.to raise_error(Engine::GameError, /does not support 8 players/)
    expect(meta.check_options([], 3, 8)).to include(error: /8 players requires Extended Full Game/)
  end

  it 'offers Extended Full Game only for three to eight players' do
    game = new_game(players(2), optional_rules: [:extended_full_game])
    rule = meta::OPTIONAL_RULES.find { |option| option[:sym] == :extended_full_game }

    expect(rule[:players]).to eq([3, 4, 5, 6, 7, 8])
    expect(game.optional_rules).not_to include(:extended_full_game)
    expect(meta.check_options(['extended_full_game'], 2, 2)).to include(error: /3–8 players/)
    expect(meta.check_options(['extended_full_game'], 3, 8)).to be_nil
  end

  it 'allows Aggressive Game and Long Endgame at eight players' do
    game = new_game(players(8), optional_rules: %i[extended_full_game aggressive_game long_endgame])

    expect(game.aggressive_game?).to be(true)
    expect(game.long_endgame?).to be(true)
  end

  it 'excludes Fast Start and Extended Full Game from the same game' do
    expect(meta::MUTEX_RULES).to include(%i[fast_start extended_full_game])
    expect { new_game(optional_rules: %i[extended_full_game fast_start]) }
      .to raise_error(Engine::OptionError, /Fast Start and Extended Full Game/)
  end

  it 'limits the option to the full map' do
    game = new_game(klass: Engine::Game::G18OEUKFR::Game, optional_rules: [:extended_full_game])

    expect(game.cert_limit).to eq(16)
    expect(game.players.map(&:cash)).to eq([580] * 3)
    expect(game.bank.cash + game.players.sum(&:cash)).to eq(18_000)
  end
end
