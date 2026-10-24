# frozen_string_literal: true

require 'spec_helper'
require_relative '../g_18_oe/helpers'

describe 'G18OE UK-France scenario (PB 6.1, 6.1.5)' do
  include G18OESpecHelpers

  let(:klass) { Engine::Game::G18OEUKFR::Game }
  let(:game) { new_game(%w[a b], klass: klass) }
  let(:cards) { game.depot.upcoming.uniq(&:name).to_h { |train| [train.name, train] } }

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
    round = enter_round!(game, game.stock_round)
    player = round.current_entity
    minor = game.corporation_by_id('C')
    give_company!(player, game.company_by_id('C'))
    fund!(game, minor, 120)
    price = round.active_step.get_par_prices(player, minor).first
    act!(round, Engine::Action::Par.new(player, corporation: minor, share_price: price))
    hex = game.home_token_locations(minor).find { |h| game.region_for_hex(h) == 'UK' }
    act!(round, Engine::Action::PlaceToken.new(minor, city: hex.tile.cities.first, slot: 0))

    expect(game.minor_floated_regions['C']).to eq('UK')
  end

  it 'removes the remaining regionals when the sixth floats' do
    round = enter_round!(game, game.stock_round)
    player = round.current_entity
    plm = game.corporation_by_id('PLM')
    float_regionals!(game, 5, except: ['PLM'])
    fund!(game, player)
    act!(round, Engine::Action::Par.new(player, corporation: plm, share_price: cell(game, 60, :par)))

    expect(game.corporations.count { |c| c.type == :regional }).to eq(6)
    expect(game.corporations.select { |c| c.type == :regional && !c.ipoed }).to be_empty
  end

  it 'deals ten level 2, seven level 3, three each of levels 4 and 5, two level 6, four level 7 and three level 8 trains' do
    expect(game.depot.upcoming.map(&:name).tally)
      .to eq('2+2' => 10, '3' => 7, '4' => 3, '5' => 3, '6' => 2, '7+7' => 4, '8+8' => 3)
  end

  it 'gives each train card its variants' do
    expect(cards.transform_values { |train| train.variants.keys })
      .to eq('2+2' => ['2+2'], '3' => %w[3 3+3], '4' => %w[4 4+4], '5' => %w[5 5+5], '6' => %w[6 6+6],
             '7+7' => %w[7+7 4D], '8+8' => %w[8+8 5D])
  end

  it 'rusts level 3 trains on 6 and level 4 trains on 8+8' do
    expect(cards['3'].variants.values.map { |v| v[:rusts_on] }.uniq).to eq(['6'])
    expect(cards['4'].variants.values.map { |v| v[:rusts_on] }.uniq).to eq(['8+8'])
  end

  it 'puts the level 8 card under the first level 7 train (PB 6.1)' do
    level_7s = game.depot.upcoming.select { |t| t.name == '7+7' }
    expected = Array.new(level_7s.size) { |i| i.zero? ? ['level_8_available'] : [] }

    expect(level_7s.map { |t| t.events.map { |e| e['type'] } }).to eq(expected)
  end
end
