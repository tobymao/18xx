# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE dividends (§11.4, §4.4)' do
  include G18OESpecHelpers

  let(:game) { game_at_sr2 }
  let(:step) { Engine::Game::G18OE::Step::Dividend.new(game, game.round) }
  let(:president) { game.current_entity }
  let(:regional) { game.corporations.find { |c| c.type == :regional && c.president?(president) } }
  let(:other) { game.players.find { |p| p != president } }
  let(:minor) { game.corporation_by_id('K') }

  def split_regional!
    game.bank.spend(500, other)
    game.share_pool.buy_shares(other, regional.ipo_shares.first)
    regional
  end

  def major_at(price)
    convert!(game, regional)
    game.stock_market.move(regional, cell(game, price).coordinates)
    regional
  end

  def types_for(entity)
    allow(step).to receive(:current_entity).and_return(entity)
    step.dividend_types
  end

  it 'gives each railroad type its own dividend choices (§11.4)' do
    national = regional.dup.tap { |c| c.type = :national }

    expect(types_for(minor)).to eq(%i[half withhold])
    expect(types_for(regional)).to eq(%i[withhold half payout])
    expect(types_for(major_at(75))).to eq(%i[withhold half payout])
    expect(types_for(national)).to eq(%i[payout withhold])
  end

  it 'never asks a minor to choose' do
    expect(step.actions(minor)).to eq([])
  end

  it 'pays out the §11.4 GWR example: £70 to 50%, 25% and a treasury 25%' do
    split_regional!
    per_share = step.payout(regional, 70)[:per_share]

    expect(step.dividends_for_entity(regional, president, per_share)).to eq(35)
    expect(step.dividends_for_entity(regional, other, per_share)).to eq(18)
    expect(step.dividends_for_entity(regional, regional, per_share)).to eq(18)
  end

  it 'half pays the §11.4 KSS example: treasury £44, £18 and £9' do
    split_regional!
    half = step.half(regional, 70)

    expect(half[:corporation] + step.dividends_for_entity(regional, regional, half[:per_share])).to eq(44)
    expect(step.dividends_for_entity(regional, president, half[:per_share])).to eq(18)
    expect(step.dividends_for_entity(regional, other, half[:per_share])).to eq(9)
  end

  it 'half pays the §11.4 Minor K example: £25 each' do
    half = step.half(minor, 50)

    expect(half[:corporation]).to eq(25)
    expect(step.dividends_for_entity(minor, minor.owner, half[:per_share])).to eq(25)
  end

  it 'never moves minors or regionals on the market' do
    expect(step.share_price_change(regional, 500)).to eq({})
    expect(step.share_price_change(minor, 500)).to eq({})
  end

  it 'moves a major LEFT when it pays nothing (§4.4)' do
    expect(step.share_price_change(major_at(75), 0)).to eq(share_direction: :left, share_times: 1)
  end

  it 'moves a major RIGHT when it pays exactly its share value (§4.4)' do
    expect(step.share_price_change(major_at(75), 75)).to eq(share_direction: :right, share_times: 1)
  end

  it 'leaves a major in place when it pays less than its share value (§4.4)' do
    expect(step.share_price_change(major_at(75), 74)).to eq({})
  end

  it 'moves a £150 major RIGHT on a £160 half payout of £320 (§4.4 example)' do
    major = major_at(150)
    paid = 320 - step.half(major, 320)[:corporation]

    expect(step.share_price_change(major, paid)).to eq(share_direction: :right, share_times: 1)
  end

  it 'leaves a £165 major in place on a £160 payout (§4.4 example)' do
    expect(step.share_price_change(major_at(165), 160)).to eq({})
  end

  it 'withholds automatically for a minor that earned nothing' do
    game = finish_or!(game_at_or1)
    minor = game.minor_regional_order.first

    expect(minor.operating_history[[1, 1]].dividend.kind).to eq('withhold')
  end
end
