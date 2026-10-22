# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE floating a major (§9.3)' do
  include G18OESpecHelpers

  let(:game) { game_at_sr2 }
  let(:step) { game.round.active_step }
  let(:president) { game.current_entity }
  let(:regional) { game.corporations.find { |c| c.type == :regional && c.president?(president) } }

  def fund!(player, amount = 1000)
    game.bank.spend(amount, player)
  end

  def take_treasury_shares!(player, corporation, count)
    count.times { game.share_pool.buy_shares(player, corporation.ipo_shares.first) }
  end

  it "offers conversion to the regional's president" do
    expect(step.actions(regional)).to eq(%w[convert pass])
  end

  it 'offers conversion to a player holding both 25% shares' do
    other = game.players.find { |p| p != president }
    fund!(other)
    take_treasury_shares!(other, regional, 2)

    expect(step.can_convert?(regional, other)).to be(true)
  end

  it 'ends the turn on a share purchase, so no conversion follows it' do
    act!(game, Engine::Action::BuyShares.new(president, shares: regional.ipo_shares.first, percent: 25))

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
    convert!(game, regional)

    expect(game.shares_for_corporation(regional).map(&:percent).sort).to eq(([10] * 8) + [20])
    expect(regional.ipo_shares.size).to eq(7)
    expect(president.percent_of(regional)).to eq(30)
  end

  it 'gains six more station tokens' do
    convert!(game, regional)

    expect(regional.tokens.size).to eq(8)
  end

  it 'operates as a major by share value' do
    convert!(game, regional)

    expect(regional.type).to eq(:major)
    expect(game.minor_regional_order).not_to include(regional)
    expect(game.operating_order).to include(regional)
  end

  it 'skips the major share purchase when a regional share was bought first' do
    act!(game, Engine::Action::Convert.new(regional))
    act!(game, Engine::Action::BuyShares.new(president, shares: regional.ipo_shares.first, percent: 25))
    act!(game, Engine::Action::Pass.new(president))

    expect(step.actions(president)).not_to include('buy_shares')
  end

  it 'does not let the converting player sell the new major' do
    act!(game, Engine::Action::Convert.new(regional))
    act!(game, Engine::Action::Pass.new(president))

    expect(step.can_sell?(president, president.shares_of(regional).first.to_bundle)).to be(false)
  end

  it "ends the player's turn after the conversion" do
    convert!(game, regional)

    expect(game.current_entity).not_to eq(president)
  end

  it 'gives the converting player another turn before the round can end (§10)' do
    convert!(game, regional)
    pass_until!(game, president)

    expect(game.round).to be_a(Engine::Round::Stock)
    expect(game.round.active_step.actions(president)).to include('pass')
  end

  it 'makes a non-president converter buy a share and take the presidency' do
    other = president
    target = game.corporations.find { |c| c.type == :regional && !c.president?(other) }
    fund!(other)
    take_treasury_shares!(other, target, 2)
    act!(game, Engine::Action::Convert.new(target))
    act!(game, Engine::Action::Pass.new(other))

    expect(step.actions(other)).not_to include('pass')

    act!(game, Engine::Action::BuyShares.new(other, shares: target.ipo_shares.first, percent: 10))

    expect(target.president?(other)).to be(true)
  end

  it 'sells treasury shares at par until the stock round ends (§10.2, §10.7)' do
    convert!(game, regional)
    pass_until!(game, president)
    act!(game, Engine::Action::SellShares.new(president, shares: [president.shares_of(regional).reject(&:president).first],
                                                         percent: 10))
    act!(game, Engine::Action::Pass.new(president))
    buyer = game.current_entity
    fund!(buyer)
    cash = buyer.cash
    act!(game, Engine::Action::BuyShares.new(buyer, shares: regional.ipo_shares.first, percent: 10))

    expect(regional.share_price.price).to be < 75
    expect(cash - buyer.cash).to eq(75)
  end

  it 'sells treasury shares at share value after the stock round ends (§10.7)' do
    convert!(game, regional)
    finish_sr!(game)

    expect(regional.ipo_shares.first.price).to eq(regional.share_price.price)
    expect(regional.always_market_price).to be(true)
  end

  it 'stops players buying beyond 60% of a major (§10.2)' do
    convert!(game, regional)
    fund!(president)
    take_treasury_shares!(president, regional, 3)
    pass_until!(game, president)

    expect(president.percent_of(regional)).to eq(60)
    expect(step.can_buy?(president, regional.ipo_shares.first.to_bundle)).to be(false)
  end
end
