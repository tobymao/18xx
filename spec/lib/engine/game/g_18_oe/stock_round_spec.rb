# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE stock round (§4, §10)' do
  include G18OESpecHelpers

  let(:game) { game_at_sr2 }
  let(:step) { game.round.active_step }
  let(:president) { game.current_entity }
  let(:regional) { game.corporations.find { |c| c.type == :regional && c.president?(president) } }
  let(:others) { game.players.reject { |p| p == president } }
  let(:market) { game.stock_market }

  def major!
    convert!(game, regional)
    pass_until!(game, president)
    regional
  end

  def fund!(player, amount = 1000)
    game.bank.spend(amount, player)
  end

  def take_treasury_shares!(player, corporation, count)
    fund!(player)
    count.times { game.share_pool.buy_shares(player, corporation.ipo_shares.first) }
  end

  def to_pool!(corporation, count)
    shares = corporation.ipo_shares.first(count)
    game.share_pool.transfer_shares(Engine::ShareBundle.new(shares), game.share_pool)
  end

  def sell!(player, corporation)
    share = player.shares_of(corporation).reject(&:president).first
    act!(game, Engine::Action::SellShares.new(player, shares: [share], percent: share.percent))
  end

  def move(direction, coordinates)
    market.share_price(market.send(direction, regional, coordinates)).price
  end

  it 'moves a major DOWN for a share sold (§4.4)' do
    major = major!
    sell!(president, major)

    expect(major.share_price.price).to eq(70)
  end

  it 'keeps the Open Market at 50% or less (§10.1)' do
    major = major!
    to_pool!(major, 5)

    expect(step.can_sell?(president, president.shares_of(major).reject(&:president).first.to_bundle)).to be(false)
  end

  it 'forbids buying back a major sold this round (§10.2)' do
    major = major!
    sell!(president, major)

    expect(step.can_buy?(president, game.share_pool.shares_of(major).first.to_bundle)).to be(false)
  end

  it 'charges a president at 60% double share value from the Open Market (§10.2)' do
    major = major!
    take_treasury_shares!(president, major, 3)
    to_pool!(major, 1)
    bundle = game.share_pool.shares_of(major).first.to_bundle

    expect(step.can_gain?(president, bundle)).to be(true)
    expect(step.modify_purchase_price(bundle)).to eq(major.share_price.price * 2)
  end

  it 'moves a sold out major UP at the end of the round (§4.4, §10.7)' do
    major = major!
    take_treasury_shares!(others[0], major, 3)
    take_treasury_shares!(others[1], major, 4)
    finish_sr!(game)

    expect(major.share_price.price).to eq(80)
  end

  it 'never moves a sold out regional' do
    other = game.corporations.find { |c| c.type == :regional && c != regional }
    take_treasury_shares!(other.owner == others[0] ? others[1] : others[0], other, 2)
    finish_sr!(game)

    expect(other.share_price.price).to eq(60)
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
