# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE floating a major (§9.3)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:round) { stock_round!(game) }
  let(:step) { round.active_step }
  let(:president) { round.current_entity }
  let(:others) { game.players.reject { |p| p == president } }
  let(:regional) { start_regional!(game, 'LNWR', president) }

  before { allow(game).to receive(:major_phase?).and_return(true) }

  it "offers conversion to the regional's president" do
    expect(step.actions(regional)).to eq(%w[convert pass])
  end

  it 'offers conversion to a player holding both 25% shares' do
    take_treasury_shares!(game, others.first, regional, 2)

    expect(step.can_convert?(regional, others.first)).to be(true)
  end

  it 'ends the turn on a share purchase, so no conversion follows it' do
    act!(round, Engine::Action::BuyShares.new(president, shares: regional.ipo_shares.first, percent: 25))

    expect(step.actions(regional)).to eq([])
  end

  it 'moves the par marker to the matching major par value (§2.2.5)' do
    majors = [60, 65, 70, 75, 80, 90].to_h do |par|
      target = game.stock_market.find_relative_share_price(cell(game, par, :par), regional, %i[right right up])
      [par, [target.price, target.type]]
    end

    expect(majors).to eq(60 => [75, :convert_range], 65 => [80, :convert_range], 70 => [90, :convert_range],
                         75 => [100, :convert_range], 80 => [110, :convert_range], 90 => [120, :convert_range])
  end

  it 'becomes a ten share major with the president holding 20% plus the share bought' do
    convert!(round, regional)

    expect(game.shares_for_corporation(regional).map(&:percent).sort).to eq(([10] * 8) + [20])
    expect(regional.ipo_shares.size).to eq(7)
    expect(president.percent_of(regional)).to eq(30)
  end

  it 'gains six more station tokens' do
    convert!(round, regional)

    expect(regional.tokens.size).to eq(8)
  end

  it 'operates as a major by share value' do
    convert!(round, regional)

    expect(regional.type).to eq(:major)
    expect(game.minor_regional_order).not_to include(regional)
    expect(game.operating_order).to include(regional)
  end

  it 'skips the major share purchase when a regional share was bought first' do
    act!(round, Engine::Action::Convert.new(regional))
    act!(round, Engine::Action::BuyShares.new(president, shares: regional.ipo_shares.first, percent: 25))
    act!(round, Engine::Action::Pass.new(president))

    expect(step.actions(president)).not_to include('buy_shares')
  end

  it 'does not let the converting player sell the new major' do
    act!(round, Engine::Action::Convert.new(regional))
    act!(round, Engine::Action::Pass.new(president))

    expect(step.can_sell?(president, president.shares_of(regional).first.to_bundle)).to be(false)
  end

  it "ends the player's turn after the conversion" do
    convert!(round, regional)

    expect(round.current_entity).not_to eq(president)
  end

  it 'gives the converting player another turn before the round can end (§10)' do
    convert!(round, regional)
    pass_until!(round, president)

    expect(step.actions(president)).to include('pass')
  end

  it 'makes a non-president converter buy a share and take the presidency' do
    target = start_regional!(game, 'GWR', others.first)
    take_treasury_shares!(game, president, target, 2)
    act!(round, Engine::Action::Convert.new(target))
    act!(round, Engine::Action::Pass.new(president))

    expect(step.actions(president)).not_to include('pass')

    act!(round, Engine::Action::BuyShares.new(president, shares: target.ipo_shares.first, percent: 10))

    expect(target.president?(president)).to be(true)
  end

  it 'sells treasury shares at par until the stock round ends (§10.2, §10.7)' do
    convert!(round, regional)
    pass_until!(round, president)
    share = president.shares_of(regional).reject(&:president).first
    act!(round, Engine::Action::SellShares.new(president, shares: [share], percent: 10))
    act!(round, Engine::Action::Pass.new(president))
    buyer = fund!(game, round.current_entity)
    cash = buyer.cash
    act!(round, Engine::Action::BuyShares.new(buyer, shares: regional.ipo_shares.first, percent: 10))

    expect(regional.share_price.price).to be < 75
    expect(cash - buyer.cash).to eq(75)
  end

  it 'sells treasury shares at share value once the par marker is removed (§10.7)' do
    convert!(round, regional)
    game.stock_market.move_down(regional)
    game.remove_major_par_markers!

    expect(regional.ipo_shares.first.price).to eq(regional.share_price.price)
  end

  it 'removes major par markers when the stock round ends (§10.7)' do
    round
    expect(game).to receive(:remove_major_par_markers!)

    game.next_round!
  end

  it 'stops players buying beyond 60% of a major (§10.2)' do
    convert!(round, regional)
    take_treasury_shares!(game, president, regional, 3)
    pass_until!(round, president)

    expect(president.percent_of(regional)).to eq(60)
    expect(step.can_buy?(president, regional.ipo_shares.first.to_bundle)).to be(false)
  end
end
