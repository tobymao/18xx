# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE lay track (§11.1)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }

  def operating!
    enter_round!(game, game.operating_round(1))
  end

  def cost(hex_id, corp_id)
    hex = game.hex_by_id(hex_id)
    corporation = game.corporation_by_id(corp_id)
    game.upgrade_cost(hex.tile, hex, corporation, corporation)
  end

  def minor_in(minor_id, zone)
    game.minor_floated_regions[minor_id] = zone
    minor_id
  end

  def wien_with_home!(round)
    lay_first_legal!(game, round, 'R55')
    act!(round, Engine::Action::PlaceToken.new(game.corporation_by_id('SB'), city: game.hex_by_id('R55').tile.cities[1], slot: 0))
  end

  it 'budgets tile points by railroad type (§11.1)' do
    budgets = %i[minor regional major national].to_h { |type| [type, game.tile_point_budget(Struct.new(:type).new(type))] }

    expect(budgets).to eq(minor: 3, regional: 3, major: 6, national: 9)
  end

  it 'gives a regional 3 tile points' do
    start_regional!(game, 'LNWR', player)
    round = operating!

    expect(round.active_step.description).to eq('3 track points')
  end

  it 'charges 1 point for a yellow tile' do
    start_regional!(game, 'LNWR', player)
    round = operating!
    lay_first_legal!(game, round, 'J29')

    expect(round.active_step.description).to eq('2 track points')
  end

  it 'charges 2 points for a yellow metropolis and lets SB choose its home station (§11.1.9)' do
    sb = start_regional!(game, 'SB', player)
    round = operating!
    lay_first_legal!(game, round, 'R55')

    expect(round.active_step).to be_a(Engine::Step::HomeToken)

    act!(round, Engine::Action::PlaceToken.new(sb, city: game.hex_by_id('R55').tile.cities[1], slot: 0))

    expect(round.active_step.description).to eq('1 track points')
    expect(game.hex_by_id('R55').tile.cities[1].tokened_by?(sb)).to be(true)
  end

  it 'charges 2 points for an upgrade' do
    game.phase.next!
    start_regional!(game, 'LNWR', player)
    round = operating!
    lay_first_legal!(game, round, 'J27')

    expect(round.active_step.description).to eq('1 track points')
  end

  it 'refuses a lay that costs more points than remain' do
    game.phase.next!
    start_regional!(game, 'SB', player)
    round = operating!
    wien_with_home!(round)
    tile = game.tiles.find { |t| t.name == 'OE12' }
    action = Engine::Action::LayTile.new(game.corporation_by_id('SB'), tile: tile, hex: game.hex_by_id('R55'), rotation: 0)

    expect { round.process_action(action) }.to raise_error(Engine::GameError, /Cannot lay an upgrade now/)
  end

  it 'gives a major 6 tile points' do
    start_major!(game, 'LNWR', player)
    round = operating!

    expect(round.active_step.description).to eq('6 track points')
  end

  it 'keeps a regional inside its track rights zone (§11.1.4)' do
    lnwr = start_regional!(game, 'LNWR', player)
    round = operating!

    expect(round.active_step.tracker_available_hex(lnwr, game.hex_by_id('Q30'))).to be_nil
    expect(game.hex_within_national_region?(lnwr, game.hex_by_id('J29'))).to be(true)
  end

  it 'lets both zones build in a border hex (PB 4.7)' do
    nancy = game.hex_by_id('Q38')

    expect(game.hex_within_national_region?(game.corporation_by_id('KBS'), nancy)).to be(true)
    expect(game.hex_within_national_region?(game.corporation_by_id('PLM'), nancy)).to be(true)
  end

  it 'does not restrict majors to a zone (§11.1.4)' do
    major = start_major!(game, 'LNWR', player)

    expect(game.hex_within_national_region?(major, game.hex_by_id('Q30'))).to be(true)
  end

  it 'charges full terrain cost outside the discount zones (§11.1.5)' do
    expect(cost('M30', 'LNWR')).to eq(45)
    expect(cost('T23', 'PLM')).to eq(60)
  end

  it 'discounts terrain 20% inside Spain, Italy, Scandinavia and Russia (§11.1.5)' do
    expect([cost('X23', 'CHN'), cost('V9', 'CHN'), cost('Z23', 'CHN'), cost('U44', 'SFAI')]).to eq([96, 36, 24, 96])
  end

  it 'does not discount terrain in another zone' do
    expect(cost('R39', 'CHN')).to eq(30)
  end

  it 'discounts a hex that is only partly inside the zone (§11.1.5)' do
    expect(cost('W22', 'CHN')).to eq(96)
  end

  it 'gives a major the zone discount of a merged minor (§10.5, §11.1.4)' do
    major = start_major!(game, 'LNWR', player)
    minor = game.corporation_by_id(minor_in('B', 'SP'))
    game.merged_minors[major] << minor

    expect(cost('X23', 'LNWR')).to eq(96)
  end

  it 'does not stack a merged minor\'s zone with the same home zone (§11.1.5)' do
    major = start_major!(game, 'CHN', player)
    game.merged_minors[major] << game.corporation_by_id(minor_in('B', 'SP'))

    expect(cost('X23', 'CHN')).to eq(96)
  end

  it 'raises the discount to 50% for F on mountains and hills (§11.1.5, §15.6)' do
    f = minor_in('F', 'SP')

    expect([cost('X23', f), cost('V9', f), cost('Z23', f)]).to eq([60, 22, 24])
  end

  it 'raises the discount to 50% for E on water, rivers and lakes (§11.1.5, §15.5)' do
    e = minor_in('E', 'SP')

    expect([cost('Z23', e), cost('X23', e)]).to eq([15, 96])
    expect(cost('E52', minor_in('E', 'SC'))).to eq(22)
  end
end
