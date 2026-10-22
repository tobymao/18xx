# frozen_string_literal: true

require 'spec_helper'
require_relative '../g_18_oe/helpers'

describe 'G18OE UK-France scenario (PB 6.1, 6.1.5)' do
  include G18OESpecHelpers

  let(:klass) { Engine::Game::G18OEUKFR::Game }
  let(:game) { new_game(%w[a b], klass: klass) }
  let(:cards) { game.depot.upcoming.uniq(&:name).to_h { |t| [t.name, t] } }

  def scenario(players)
    new_game(Array.new(players) { |i| "p#{i}" }, klass: klass)
  end

  it 'uses the short scenario starting capital without concessions' do
    expect([scenario(2), scenario(3)].map { |g| g.players.first.cash }).to eq([870, 580])
  end

  it 'uses the short scenario certificate limits' do
    expect([scenario(2), scenario(3)].map(&:cert_limit)).to eq([24, 16])
  end

  it 'holds £18,000 between the bank and the players' do
    expect(game.bank.cash + game.players.sum(&:cash)).to eq(18_000)
  end

  it 'plays the UK and French regionals, minors C, H, K and M, and four privates' do
    expect(game.corporations.select { |c| c.type == :regional }.map(&:id).sort).to eq(%w[BEL GSWR GWR LNWR MIDI OU PLM])
    expect(game.corporations.select { |c| c.type == :minor }.map(&:id).sort).to eq(%w[C H K M])
    expect(game.companies.reject { |c| game.company_becomes_minor?(c) }.map(&:sym)).to eq(%w[PeC SHTC CCTC WCF])
  end

  it 'floats a minor in the United Kingdom' do
    finish_auction!(game)
    minor = game.corporation_by_id(game.current_entity.companies.find { |c| game.company_becomes_minor?(c) }.sym)
    float_minor!(game, minor.id, zone: 'UK')

    expect(game.minor_floated_regions[minor.id]).to eq('UK')
  end

  it 'floats six regionals and removes the seventh' do
    float_everything!(finish_auction!(game), regionals: 6)

    expect(game.round).to be_a(Engine::Round::G18OE::Operating)
    expect(game.corporations.count { |c| c.type == :regional }).to eq(6)
  end

  it 'uses the short scenario train mix (PB 6.1)' do
    expect(game.depot.upcoming.map(&:name).tally)
      .to eq('2+2' => 10, '3' => 7, '4' => 3, '5' => 3, '6' => 2, '7+7' => 4, '8+8' => 3)
    expect(cards.transform_values { |t| t.variants.keys })
      .to eq('2+2' => ['2+2'], '3' => %w[3 3+3], '4' => %w[4 4+4], '5' => %w[5 5+5], '6' => %w[6 6+6],
             '7+7' => %w[7+7 4D], '8+8' => %w[8+8 5D])
  end

  it 'rusts level 3 at phase 6 and level 4 at phase 8' do
    expect(cards['3'].variants.values.map { |v| v[:rusts_on] }.uniq).to eq(['6'])
    expect(cards['4'].variants.values.map { |v| v[:rusts_on] }.uniq).to eq(['8+8'])
  end

  it 'releases level 8 trains after the first level 7 is sold (PB 6.1)' do
    game.depot.upcoming.reject { |t| %w[7+7 8+8].include?(t.name) }.each { |t| game.depot.remove_train(t) }
    game.phase.next! while game.phase.name != '7'
    expect(game.level8_train_available?).to be(false)

    game.depot.remove_train(cards['7+7'])
    expect(game.level8_train_available?).to be(true)
  end
end
