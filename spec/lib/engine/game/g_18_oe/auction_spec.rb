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

  def buy!(sym)
    buyer = game.current_entity
    act!(game, Engine::Action::Bid.new(buyer, company: company(sym), price: step.min_bid(company(sym))))
    buyer
  end

  def pass_all!
    game.players.size.times { act!(game, Engine::Action::Pass.new(game.current_entity)) }
  end

  def hand_out_all_but!(last_sym, through_row: 7)
    holder = game.players.last
    step.companies.select { |c| c.auction_row <= through_row && c.sym != last_sym }.each do |c|
      step.companies.delete(c)
      give_company!(holder, c)
    end
  end

  it 'only lets the topmost row be bought outright' do
    expect(step.may_purchase?(company('RSC'))).to be(true)
    expect(step.may_purchase?(company('WS'))).to be(false)
  end

  it 'sells a top-row item at its face value' do
    buyer = buy!('RSC')

    expect(company('RSC').owner).to eq(buyer)
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
    hand_out_all_but!('SML', through_row: 4)
    buy!('SML')

    expect(%w[C A B].to_h { |sym| [sym, company(sym).owner] }).to eq(bidders)
  end

  it 'caps a minor treasury at £180 and gives the excess to the bank (§7.1)' do
    bid!('C', 200)
    bid!('A', 130)
    hand_out_all_but!('SML', through_row: 4)
    bank = game.bank.cash
    buy!('SML')

    expect(game.corporation_by_id('C').cash).to eq(180)
    expect(game.corporation_by_id('A').cash).to eq(130)
    expect(game.bank.cash - bank).to eq(120 + 20)
  end

  it 'puts a £180 bid entirely into the minor treasury (§7.1)' do
    bid!('C', 180)
    hand_out_all_but!('SML', through_row: 4)
    buy!('SML')

    expect(game.corporation_by_id('C').cash).to eq(180)
  end

  it 'auctions an item with several bids among its bidders only' do
    low = bid!('C', 200)
    bid!('C', 205)
    outsider = game.players.find { |p| step.committed_cash(p).zero? }
    hand_out_all_but!('SML', through_row: 4)
    act!(game, Engine::Action::Bid.new(outsider, company: company('SML'), price: 120))

    expect(step.pass_description).to eq('Pass (on C)')
    expect(step.actions(outsider)).to eq([])
    expect(game.current_entity).to eq(low)
  end

  it 'sells a single-bid item even when it is not first in the exposed row' do
    bidder = bid!('B', 200)
    hand_out_all_but!('SML', through_row: 4)
    buy!('SML')

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
    buyer = buy!('RSC')
    pass_all!

    expect(buyer.cash).to eq(1800 - 20 + 5)
  end

  it 'still reduces the top row after something was bought' do
    buy!('RSC')
    pass_all!

    expect(step.min_bid(company('PeC'))).to eq(15)
  end

  it 'gives items reduced to £0 to the next player' do
    first = game.current_entity
    %w[RSC PeC].each { |sym| company(sym).discount = 15 }
    pass_all!

    expect([company('RSC').owner, company('PeC').owner]).to eq([first, first])
    expect(first.cash).to eq(1800)
  end

  it 'moves to a stock round once the opening packet is sold' do
    hand_out_all_but!('M')
    buy!('M')

    expect(game.round).to be_a(Engine::Round::Stock)
  end
end
