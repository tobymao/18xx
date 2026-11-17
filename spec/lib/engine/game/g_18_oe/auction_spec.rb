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

  def expose_minor_row!
    holder = game.players.last
    step.companies.select { |c| c.auction_row <= 4 }.each do |c|
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

  it 'requires a raise of £5 over the high bid when a topmost private has several bids (§7)' do
    a, b = game.players
    act!(game, Engine::Action::Bid.new(a, company: company('WS'), price: 45))
    act!(game, Engine::Action::Bid.new(b, company: company('WS'), price: 50))
    buy!('RSC')
    buy!('PeC')

    expect(step.auctioning).to eq(company('WS'))
    expect(step.may_purchase?(company('WS'))).to be(false)
    expect(step.min_bid(company('WS'))).to eq(55)
    game.process_action(Engine::Action::Bid.new(game.current_entity, company: company('WS'), price: 40))
    expect(game.exception.message).to match(/Minimum bid is/)
  end

  it 'sells a single-bid item even when it is not first in the exposed row' do
    bidder = bid!('B', 200)
    hand_out_all_but!('SML', through_row: 4)
    buy!('SML')

    expect(company('B').owner).to eq(bidder)
  end

  it 'opens the eleven rows from top to bottom (§6.3, PB p.32)' do
    expect(step.tiered_auction_companies.map { |row| row.first.auction_row }).to eq((1..11).to_a)
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
    medium = new_game(optional_rules: [:medium_start])
    holder = medium.players.last
    medium.round.active_step.companies.reject { |c| c.sym == 'M' }.each do |c|
      medium.round.active_step.companies.delete(c)
      give_company!(holder, c)
    end
    buyer = medium.current_entity
    act!(medium, Engine::Action::Bid.new(buyer, company: medium.company_by_id('M'), price: 120))

    expect(medium.round).to be_a(Engine::Round::Stock)
  end

  it 'moves to the Concession RR Phase once the opening packet is sold (§8)' do
    hand_out_all_but!('CON10', through_row: 11)
    buy!('CON10')

    expect(game.round).to be_a(Engine::Round::G18OE::Concession)
  end

  it 'leaves the priority deal announcement to the end of the Concession RR Phase (§8)' do
    hand_out_all_but!('CON10', through_row: 11)
    buy!('CON10')

    expect(game.log.map(&:message).grep(/has priority deal/)).to be_empty
  end

  it 'orders the concessions 1st to 10th within their rows' do
    expect(step.companies.last(10).map(&:sym)).to eq(%w[CON1 CON2 CON3 CON4 CON5 CON6 CON7 CON8 CON9 CON10])
  end

  it 'does not count concessions toward the certificate limit' do
    player = game.players.first
    give_company!(player, company('CON1'))
    give_company!(player, company('RSC'))

    expect(game.num_certs(player)).to eq(1)
  end

  it 'sells a £0 concession for nothing when it is topmost' do
    hand_out_all_but!('CON7', through_row: 11)
    buyer = buy!('CON7')

    expect([company('CON7').owner, buyer.cash]).to eq([buyer, 1800])
  end

  it 'keeps £0 items at £0 when the top row is reduced' do
    hand_out_all_but!('CON7', through_row: 11)
    first = game.current_entity
    pass_all!

    expect([company('CON7').owner, company('CON7').min_bid]).to eq([first, 0])
  end

  it 'refuses a top-row private bid above face value' do
    game.process_action(Engine::Action::Bid.new(game.current_entity, company: company('RSC'), price: 25))

    expect(game.exception).to be_a(Engine::GameError)
  end

  it 'sells a top-row minor at its face value without an auction' do
    expose_minor_row!
    buyer = buy!('A')

    expect([company('A').owner, game.corporation_by_id('A').cash]).to eq([buyer, 120])
  end

  it 'opens a top-row minor bid above face value to all players (§7.1)' do
    expose_minor_row!
    _, b, = game.players
    bid!('A', 150)

    expect(company('A').owner).to be_nil
    expect(step.auctioning).to eq(company('A'))
    expect(game.current_entity).to eq(b)
  end

  it 'does not offer a direct purchase of a top-row minor (§7.1)' do
    expose_minor_row!

    expect(step.may_purchase?(company('A'))).to be(false)
    expect(step.bid_str(company('A'))).to eq('Buy / Bid')
    expect(step.bid_str(company('H'))).to eq('Place Bid')
  end

  it 'labels the action Place Bid during an open auction (§7.1)' do
    expose_minor_row!
    bid!('A', 150)

    expect(step.bid_str(company('A'))).to eq('Place Bid')
  end

  it "runs the open auction from the bidder's left and drops passers (§7.1)" do
    expose_minor_row!
    a, b, c = game.players
    bid!('A', 150)
    act!(game, Engine::Action::Bid.new(b, company: company('A'), price: 155))
    act!(game, Engine::Action::Pass.new(c))
    act!(game, Engine::Action::Pass.new(a))

    expect(company('A').owner).to eq(b)
  end

  it 'awards the open auction to the high bidder once the others have passed (§7.1)' do
    expose_minor_row!
    a, b, c = game.players
    bid!('A', 150)
    act!(game, Engine::Action::Bid.new(b, company: company('A'), price: 155))
    act!(game, Engine::Action::Bid.new(c, company: company('A'), price: 160))
    act!(game, Engine::Action::Pass.new(a))
    expect(game.current_entity).to eq(b)
    act!(game, Engine::Action::Pass.new(b))

    expect([company('A').owner, a.cash, c.cash]).to eq([c, 1800, 1640])
  end

  it 'requires an open-auction bid to be £5 above the high bid (§7.1)' do
    expose_minor_row!
    bid!('A', 150)

    expect(step.min_bid(company('A'))).to eq(155)
    game.process_action(Engine::Action::Bid.new(game.current_entity, company: company('A'), price: 154))
    expect(game.exception.message).to match(/Minimum bid is/)
  end

  it 'puts the open-auction price into the minor treasury, capped at £180 (§7.1)' do
    expose_minor_row!
    bid!('A', 200)
    2.times { act!(game, Engine::Action::Pass.new(game.current_entity)) }

    expect(game.corporation_by_id('A').cash).to eq(180)
  end

  it 'resumes with the player after the bidder once the open auction ends' do
    expose_minor_row!
    _, b, = game.players
    bid!('A', 150)
    2.times { act!(game, Engine::Action::Pass.new(game.current_entity)) }

    expect(game.current_entity).to eq(b)
  end

  it 'drops players who cannot reach the next bid from the open auction (§7.1)' do
    expose_minor_row!
    a, b, c = game.players
    [b, c].each { |p| p.spend(p.cash - 100, game.bank) }
    bid!('A', 150)

    expect(company('A').owner).to eq(a)
  end
end
