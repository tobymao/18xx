# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE auction (§7)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:step) { game.round.active_step }

  def company(sym)
    game.company_by_id(sym)
  end

  def bid!(sym, price)
    bidder = game.current_entity
    act!(game, Engine::Action::Bid.new(bidder, company: company(sym), price: price))
    bidder
  end

  def pass_all!
    game.players.size.times { act!(game, Engine::Action::Pass.new(game.current_entity)) }
  end

  def clear_rows_through_four!
    buy_top_row!(game) while step.companies.any? { |c| c.auction_row <= 4 }
  end

  it 'only lets the topmost row be bought outright' do
    expect(step.may_purchase?(company('RSC'))).to be(true)
    expect(step.may_purchase?(company('WS'))).to be(false)
  end

  it 'sells a top-row item at its face value' do
    buyer = game.current_entity
    bought = buy_top_row!(game)

    expect(bought.owner).to eq(buyer)
    expect(buyer.cash).to eq(1780)
  end

  it 'requires a lower-row bid of at least face value' do
    expect(step.min_bid(company('B'))).to eq(120)
  end

  it 'requires an outbid to be at least £5 higher' do
    bid!('B', 200)

    expect(step.min_bid(company('B'))).to eq(205)
    game.process_action(Engine::Action::Bid.new(game.current_entity, company: company('B'), price: 204))
    expect(game.exception.message).to match(/Minimum bid is/)
  end

  it 'sets aside the cash of a bid' do
    bidder = bid!('B', 200)

    expect(step.committed_cash(bidder)).to eq(200)
  end

  it 'sells single-bid items to their bidders when their row is exposed' do
    bidders = { 'C' => bid!('C', 200), 'A' => bid!('A', 130), 'B' => bid!('B', 125) }
    clear_rows_through_four!

    expect(%w[C A B].to_h { |sym| [sym, company(sym).owner] }).to eq(bidders)
  end

  it 'caps a minor treasury at £180 and gives the excess to the bank (§7.1)' do
    bank = game.bank.cash
    bid!('C', 200)
    bid!('A', 130)
    bid!('B', 125)
    clear_rows_through_four!

    expect(game.corporation_by_id('C').cash).to eq(180)
    expect(game.corporation_by_id('A').cash).to eq(130)
    expect(game.bank.cash - bank).to eq(600 + 20)
  end

  it 'puts a £180 bid entirely into the minor treasury (§7.1)' do
    bid!('C', 180)
    clear_rows_through_four!

    expect(game.corporation_by_id('C').cash).to eq(180)
  end

  it 'auctions an item with several bids among its bidders only' do
    low = bid!('C', 200)
    bid!('C', 205)
    outsider = game.players.find { |p| step.committed_cash(p).zero? }
    clear_rows_through_four!

    expect(step.pass_description).to eq('Pass (on C)')
    expect(step.actions(outsider)).to eq([])
    expect(game.current_entity).to eq(low)
  end

  it 'sells a single-bid item even when it is not first in the exposed row' do
    bidder = bid!('B', 200)
    clear_rows_through_four!

    expect(company('B').owner).to eq(bidder)
  end

  it 'opens the rows from top to bottom' do
    expect(step.tiered_auction_companies.map { |row| row.first.auction_row }).to eq([1, 2, 3, 4, 5, 6, 7])
  end

  it 'reduces every top-row item by £5 when all players pass' do
    pass_all!

    expect(step.min_bid(company('RSC'))).to eq(15)
    expect(step.min_bid(company('PeC'))).to eq(15)
    expect(game.players.map(&:cash).uniq).to eq([1800])
  end

  it 'pays purchased privates when all players pass' do
    buyer = game.current_entity
    buy_top_row!(game)
    pass_all!

    expect(buyer.cash).to eq(1800 - 20 + 5)
  end

  it 'still reduces the top row after something was bought' do
    bought = buy_top_row!(game)
    pass_all!

    expect(step.min_bid((%w[RSC PeC].map { |sym| company(sym) } - [bought]).first)).to eq(15)
  end

  it 'gives items reduced to £0 to the next player' do
    first = game.current_entity
    4.times { pass_all! }

    expect([company('RSC').owner, company('PeC').owner]).to eq([first, first])
    expect(first.cash).to eq(1800)
  end

  it 'moves to a stock round once the opening packet is sold' do
    finish_auction!(game)

    expect(game.round).to be_a(Engine::Round::Stock)
    expect(game.companies.map(&:owner).all?(&:player?)).to be(true)
  end
end
