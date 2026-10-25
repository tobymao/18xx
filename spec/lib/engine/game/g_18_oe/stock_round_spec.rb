# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE stock round (§4, §10)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:round) { stock_round!(game) }
  let(:step) { round.active_step }
  let(:president) { round.current_entity }
  let(:major) { start_major!(game, 'LNWR', president) }
  let(:market) { game.stock_market }

  before { allow(game).to receive(:major_phase?).and_return(true) }

  def to_pool!(corporation, count)
    game.share_pool.transfer_shares(Engine::ShareBundle.new(corporation.ipo_shares.first(count)), game.share_pool)
  end

  def sell_one!(player, corporation)
    share = player.shares_of(corporation).reject(&:president).first
    act!(round, Engine::Action::SellShares.new(player, shares: [share], percent: share.percent))
  end

  def move(direction, coordinates)
    market.share_price(market.send(direction, major, coordinates)).price
  end

  it 'moves a major DOWN for a share sold (§4.4)' do
    take_treasury_shares!(game, president, major, 1)
    sell_one!(president, major)

    expect(major.share_price.price).to eq(70)
  end

  it 'keeps the Open Market at 50% or less (§10.1)' do
    take_treasury_shares!(game, president, major, 1)
    to_pool!(major, 5)

    expect(step.can_sell?(president, president.shares_of(major).reject(&:president).first.to_bundle)).to be(false)
  end

  it 'forbids buying back a major sold this round (§10.2)' do
    take_treasury_shares!(game, president, major, 1)
    sell_one!(president, major)

    expect(step.can_buy?(president, game.share_pool.shares_of(major).first.to_bundle)).to be(false)
  end

  it 'charges a president at 60% double share value from the Open Market (§10.2)' do
    take_treasury_shares!(game, president, major, 4)
    to_pool!(major, 1)
    bundle = game.share_pool.shares_of(major).first.to_bundle

    expect(step.can_gain?(president, bundle)).to be(true)
    expect(step.modify_purchase_price(bundle)).to eq(major.share_price.price * 2)
  end

  it 'raises sold out majors and nationals but not regionals or minors at the end of the round (§4.4)' do
    regional = start_regional!(game, 'PLM', president)
    minor = game.corporation_by_id('K')

    expect([major, regional, minor].map { |c| game.sold_out_increase?(c) }).to eq([true, false, false])
  end

  it 'moves UP on the top row to the RIGHT (§4.4)' do
    expect(move(:up, [0, 5])).to eq(180)
  end

  it 'does not move UP or RIGHT from £550 (§4.4)' do
    expect(move(:up, [0, 16])).to eq(550)
    expect(move(:right, [0, 16])).to eq(550)
  end

  it 'moves RIGHT off the end of a row UP (§4.4)' do
    expect(move(:right, [2, 13])).to eq(350)
  end

  it 'moves LEFT off the start of a row DOWN (§4.4)' do
    expect(move(:left, [6, 0])).to eq(50)
  end

  it 'does not move LEFT from £50 (§4.4)' do
    expect(move(:left, [7, 0])).to eq(50)
  end

  it 'does not move DOWN from the bottom row (§4.4)' do
    expect(move(:down, [7, 2])).to eq(65)
  end
end
