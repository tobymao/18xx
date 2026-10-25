# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE setup' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:cards) { game.depot.upcoming.uniq(&:name).to_h { |t| [t.name, t] } }
  let(:market_cells) { game.stock_market.market.flatten.compact }

  it 'splits £5,400 starting capital per player, rounded up to £5 (§3.3, PB 5.4)' do
    cash = (2..7).to_h { |n| [n, new_game(Array.new(n) { |i| "p#{i}" }).players.first.cash] }

    expect(cash).to eq(2 => 2600, 3 => 1800, 4 => 1350, 5 => 1080, 6 => 900, 7 => 775)
  end

  it 'lays the ten concessions in rows 8–11 at £30/£20/£10/£0 (§6.3, PB p.32)' do
    cons = game.companies.select { |c| c.type == :concession }

    expect(cons.map { |c| [c.sym, c.auction_row, c.value] }).to eq(
      [['CON1', 8, 30], ['CON2', 9, 20], ['CON3', 9, 20], ['CON4', 10, 10], ['CON5', 10, 10], ['CON6', 10, 10],
       ['CON7', 11, 0], ['CON8', 11, 0], ['CON9', 11, 0], ['CON10', 11, 0]]
    )
  end

  it 'opens with 10 privates, 12 minors and 10 concessions (§5.1.1)' do
    expect(game.round.active_step.companies.size).to eq(32)
  end

  it 'drops the concessions under Medium Start (PB 5.2)' do
    expect(new_game(optional_rules: [:medium_start]).companies.count { |c| c.type == :concession }).to eq(0)
  end

  it 'drops the concessions with two players (PB 5.4)' do
    expect(new_game(%w[a b]).companies.count { |c| c.type == :concession }).to eq(0)
  end

  it 'splits £5,200 per player with Medium Start (§3.3, PB 5.2)' do
    cash = (2..7).to_h do |n|
      [n, new_game(Array.new(n) { |i| "p#{i}" }, optional_rules: [:medium_start]).players.first.cash]
    end

    expect(cash).to eq(2 => 2600, 3 => 1735, 4 => 1300, 5 => 1040, 6 => 870, 7 => 745)
  end

  it 'offers Medium Start only to three or more players (PB 5.4)' do
    rule = Engine::Game::G18OE::Meta::OPTIONAL_RULES.find { |r| r[:sym] == :medium_start }

    expect(rule[:players]).to eq([3, 4, 5, 6, 7])
  end

  it 'offers Medium Start in the base game but not UK-France' do
    expect(Engine::Game::G18OE::Meta::OPTIONAL_RULES.map { |r| r[:sym] }).to eq([:medium_start])
    expect(Engine::Game::G18OEUKFR::Meta::OPTIONAL_RULES).to eq([])
  end

  it "holds £54,000 between the bank and the players' starting capital (§3.1, §3.3)" do
    expect(game.bank.cash + game.players.sum(&:cash)).to eq(54_000)
  end

  it 'uses the Info Board certificate limits (§4.1)' do
    limits = (2..7).to_h { |n| [n, new_game(Array.new(n) { |i| "p#{i}" }).cert_limit] }

    expect(limits).to eq(2 => 99, 3 => 48, 4 => 36, 5 => 29, 6 => 24, 7 => 20)
  end

  it "reserves each regional's home city at setup (§3.1, PB 1.1)" do
    regionals = game.corporations.select { |c| c.type == :regional }

    regionals.each do |corp|
      expect(game.hex_by_id(corp.coordinates).tile.cities.any? { |c| c.reserved_by?(corp) }).to be(true), corp.id
    end
  end

  it "drops a closed regional's home reservation (PB 1.1)" do
    lnwr = game.corporation_by_id('LNWR')

    game.close_corporation(lnwr)

    expect(game.hex_by_id('J27').tile.cities.any? { |c| c.reserved_by?(lnwr) }).to be(false)
  end

  it 'stocks the Locomotive Works (§3.1)' do
    expect(game.depot.upcoming.map(&:name).tally)
      .to eq('2+2' => 30, '3' => 20, '4' => 10, '5' => 8, '6' => 6, '7+7' => 14, '8+8' => 8)
  end

  it 'pairs local and express sides on each card (§11.3.2)' do
    sides = cards.transform_values { |t| t.variants.keys }

    expect(sides).to eq('2+2' => ['2+2'], '3' => %w[3 3+3], '4' => %w[4 4+4], '5' => %w[5 5+5],
                        '6' => %w[6 6+6], '7+7' => %w[7+7 4D], '8+8' => %w[8+8 5D])
  end

  it 'prices the 3 at £200 and the 3+3 at £225 (§11.6.4)' do
    expect(cards['3'].variants['3'][:price]).to eq(200)
    expect(cards['3'].variants['3+3'][:price]).to eq(225)
  end

  it 'offers the six regional par values (§2.2.5)' do
    expect(game.stock_market.par_prices.map(&:price).sort).to eq([60, 65, 70, 75, 80, 90])
  end

  it 'offers the six major par values (§2.2.5)' do
    expect(market_cells.select { |sp| sp.type == :convert_range }.map(&:price).sort).to eq([75, 80, 90, 100, 110, 120])
  end

  it 'runs the market from £50 to £550 (§4.4)' do
    expect(market_cells.map(&:price).minmax).to eq([50, 550])
  end

  it 'opens with the auction (§7)' do
    expect(game.round).to be_a(Engine::Round::Auction)
  end

  it 'has the ten privates at their face values and revenues (§14)' do
    privates = game.companies.reject { |c| game.company_becomes_minor?(c) || game.concession?(c) }
                    .to_h { |c| [c.sym, [c.value, c.revenue]] }

    expect(privates).to eq('RSC' => [20, 5], 'PeC' => [20, 5], 'WS' => [40, 10], 'BBBT' => [40, 10],
                           'SHTC' => [60, 15], 'CCTC' => [60, 15], 'WCF' => [60, 15], 'HMLC' => [80, 20],
                           'BBE' => [100, 25], 'SML' => [120, 0])
  end

  it 'has twelve £120 minors with two tokens, the second costing £20 (§6.2)' do
    minors = game.corporations.select { |c| c.type == :minor }

    expect(minors.map(&:id).sort).to eq(%w[A B C D E F G H J K L M])
    expect(minors.map { |m| game.company_by_id(m.id).value }.uniq).to eq([120])
    expect(minors.map { |m| m.tokens.map(&:price) }.uniq).to eq([[0, 20]])
  end

  it 'assigns the 24 regionals to their track rights zones (Table 1)' do
    zones = Engine::Game::G18OE::Game::CORPORATIONS_TRACK_RIGHTS.group_by(&:last).transform_values { |v| v.map(&:first).sort }

    expect(zones).to eq('UK' => %w[GSWR GWR LNWR], 'FR' => %w[BEL MIDI OU PLM], 'PHS' => %w[BHB KBS KSS POB],
                        'AH' => %w[MAV SB], 'IT' => %w[SFAI SFR], 'SP' => %w[CHN MZA RCP], 'SC' => %w[BJV DSJ],
                        'RU' => %w[LRZD MKV MSP WW])
    expect(game.corporations.count { |c| c.type == :regional }).to eq(24)
  end

  it 'prices each regional home token by zone, then a £20 token (Table 1, §9.2)' do
    costs = { 'UK' => 40, 'PHS' => 40, 'FR' => 20, 'AH' => 20, 'IT' => 10, 'SP' => 10, 'SC' => 10, 'RU' => 10 }
    zones = Engine::Game::G18OE::Game::CORPORATIONS_TRACK_RIGHTS

    game.corporations.select { |c| c.type == :regional }.each do |regional|
      expect(regional.tokens.map(&:price)).to eq([costs[zones[regional.id]], 20])
    end
  end

  it 'splits regionals into a 50% president share and two 25% shares (§1.3.1)' do
    shares = game.corporations.select { |c| c.type == :regional }.map { |r| r.shares.map(&:percent) }.uniq

    expect(shares).to eq([[50, 25, 25]])
  end

  it 'provides two track rights chits per zone (Table 1)' do
    expect(game.minor_available_regions).to eq('UK' => 2, 'PHS' => 2, 'FR' => 2, 'AH' => 2, 'IT' => 2, 'SP' => 2,
                                               'SC' => 2, 'RU' => 2)
  end

  it 'releases track colours by train phase (§2.3, §5.2)' do
    tiles = game.phase.phases.to_h { |p| [p[:name], p[:tiles]] }

    expect(tiles).to eq('2' => %i[yellow], '3' => %i[yellow green], '4' => %i[yellow green],
                        '5' => %i[yellow green brown], '6' => %i[yellow green brown],
                        '7' => %i[yellow green brown gray], '8' => %i[yellow green brown gray])
  end

  it 'sets train limits by phase (§5.2)' do
    limits = game.phase.phases.to_h { |p| [p[:name], p[:train_limit]] }
    early = { minor: 2, regional: 2, major: 4 }
    middle = { minor: 1, regional: 1, major: 3, national: 4 }
    late = { major: 2, national: 3 }

    expect(limits).to eq('2' => early, '3' => early, '4' => middle, '5' => middle, '6' => late, '7' => late, '8' => late)
  end

  it 'starts each phase with the first train of its level (§5.2)' do
    triggers = game.phase.phases.to_h { |p| [p[:name], p[:on]] }

    expect(triggers).to eq('2' => nil, '3' => '3', '4' => '4', '5' => '5', '6' => '6', '7' => '7+7', '8' => '8+8')
  end

  it 'keeps the card name as the train symbol on either side (§5.2)' do
    train = cards['4']
    train.variant = '4+4'

    expect(train.sym).to eq('4')
  end

  it 'rusts levels 2, 3 and 4 at phases 4, 6 and 8 (§5.2)' do
    rusts = cards.transform_values { |t| t.variants.values.map { |v| v[:rusts_on] }.uniq }

    expect(rusts).to eq('2+2' => ['4'], '3' => ['6'], '4' => ['8+8'], '5' => [nil], '6' => [nil],
                        '7+7' => [nil], '8+8' => [nil])
  end
end
