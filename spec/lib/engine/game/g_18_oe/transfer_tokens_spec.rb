# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE transfer tokens (§11.5)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }
  let(:other_player) { game.players[1] }
  let!(:buyer) { start_major!(game, 'LNWR', player) }
  let!(:seller) { start_major!(game, 'GWR', player) }
  let(:christiania) { game.hex_by_id('C48').tile.cities.first }
  let(:liverpool) { game.hex_by_id('J25').tile.cities.first }
  let(:paris) { game.hex_by_id('Q30').tile.cities.first }
  let(:lille) { game.lille_city }

  def place!(corporation, city, price: nil, extra_slot: false)
    token = corporation.tokens.find { |t| !t.used && (price.nil? || t.price == price) }
    city.exchange_token(token, extra_slot: extra_slot)
    token
  end

  it 'charges 20, 40 or 60 by city class' do
    expect(game.token_transfer_fee(christiania)).to eq(20)
    expect(game.token_transfer_fee(liverpool)).to eq(40)
    expect(game.token_transfer_fee(paris)).to eq(60)
  end

  describe 'transferable_token?' do
    it 'accepts a same-president major token that is not the home token' do
      token = place!(seller, christiania, price: 60)
      expect(game.transferable_token?(buyer, token)).to be(true)
    end

    it 'rejects the seller home token' do
      expect(game.transferable_token?(buyer, seller.tokens.first)).to be(false)
    end

    it 'rejects a major owned by another player' do
      stranger = start_major!(game, 'PLM', other_player)
      token = place!(stranger, christiania, price: 60)
      expect(game.transferable_token?(buyer, token)).to be(false)
    end

    it 'rejects a regional token' do
      regional = start_regional!(game, game.corporations.find { |c| c.type == :regional && !c.ipoed }.id, player)
      extra = Engine::Token.new(regional, price: 60)
      regional.tokens << extra
      christiania.exchange_token(extra)
      expect(game.transferable_token?(buyer, extra)).to be(false)
    end

    it 'rejects a minor token' do
      minor = start_minor!(game, 'D', player, 'UK')
      extra = Engine::Token.new(minor, price: 60)
      minor.tokens << extra
      christiania.exchange_token(extra)
      expect(game.transferable_token?(buyer, extra)).to be(false)
    end

    it 'rejects a hex where the buyer already has a token' do
      place!(buyer, paris, price: 20)
      token = place!(seller, game.hex_by_id('Q30').tile.cities.last, price: 60)
      expect(game.transferable_token?(buyer, token)).to be(false)
    end

    it 'rejects a pass-through token' do
      token = Engine::Token.new(seller, price: 0, type: :pass_through)
      liverpool.exchange_token(token, extra_slot: true)
      expect(game.transferable_token?(buyer, token)).to be(false)
    end

    it 'rejects an unplaced token' do
      expect(game.transferable_token?(buyer, seller.tokens.last)).to be(false)
    end
  end

  describe 'transfer_token!' do
    let!(:old_token) { place!(seller, christiania, price: 60) }
    let(:new_token) { buyer.tokens.find { |t| !t.used && t.price == 60 } }

    before { fund!(game, buyer, 500) }

    it 'puts the buyer token in the slot and pays bank and seller' do
      buyer_cash = buyer.cash
      seller_cash = seller.cash
      bank_cash = game.bank.cash
      slot = christiania.tokens.index(old_token)

      game.transfer_token!(buyer, new_token, old_token, 40)

      expect(christiania.tokens[slot]).to eq(new_token)
      expect(old_token.used).to be(false)
      expect(buyer.cash).to eq(buyer_cash - 100)
      expect(game.bank.cash).to eq(bank_cash + 60)
      expect(seller.cash).to eq(seller_cash + 40)
    end

    it 'logs the purchase' do
      game.transfer_token!(buyer, new_token, old_token, 40)
      expect(game.log.last.message).to eq("LNWR buys GWR's token in Christiania (C48) for £60 (bank) + £40 (GWR)")
    end
  end

  it 'returns the token to the seller highest-cost open position' do
    cheap = place!(seller, christiania, price: 20)
    place!(seller, liverpool, price: 60)
    fund!(game, buyer, 500)
    new_token = buyer.tokens.find { |t| !t.used && t.price == 40 }

    game.transfer_token!(buyer, new_token, cheap, 20)

    expect(cheap.used).to be(false)
    expect(cheap.price).to eq(60)
    expect(seller.tokens.select(&:used).map(&:price)).to include(20)
    expect(seller.tokens.select(&:used).map(&:price)).not_to include(60)
  end

  it 'keeps the buyer token in the seller slot when an earlier slot is empty' do
    city = game.hex_by_id('A64').tile.cities.first
    old_token = seller.tokens.find { |t| !t.used && t.price == 60 }
    old_token.place(city)
    city.tokens[1] = old_token
    fund!(game, buyer, 500)
    new_token = buyer.tokens.find { |t| !t.used && t.price == 60 }

    game.transfer_token!(buyer, new_token, old_token, 20)

    expect(city.tokens[1]).to eq(new_token)
    expect(city.tokens[0]).to be_nil
  end

  it 'replaces a token in the Lille extra slot within that slot' do
    old_token = place!(seller, lille, price: 60, extra_slot: true)
    fund!(game, buyer, 500)
    new_token = buyer.tokens.find { |t| !t.used && t.price == 60 }

    game.transfer_token!(buyer, new_token, old_token, 20)

    expect(lille.extra_tokens).to include(new_token)
    expect(lille.extra_tokens).not_to include(old_token)
    expect(new_token.extra).to be_truthy
  end

  describe 'TransferTokens step' do
    let(:step_class) { Engine::Game::G18OE::Step::TransferTokens }
    let(:round) do
      station_token_round!(game, buyer, step_class: step_class)
    end
    let(:step) { round_step(round, step_class) }
    let!(:old_token) { place!(seller, christiania, price: 60) }

    before { fund!(game, buyer, 500) }

    def transfer(token_index: 2, cost: 60, slot: christiania.tokens.index(old_token))
      Engine::Action::PlaceToken.new(buyer, city: christiania, slot: slot, token_index: token_index, cost: cost)
    end

    it 'sits after Orient Express bonus and before Buy Train in the operating round' do
      steps = game.operating_round(1).steps.map(&:class)
      expected = [Engine::Game::G18OE::Step::OrientExpressBonus, step_class, Engine::Game::G18OE::Step::BuyTrain]
      expect(steps.each_cons(3).to_a).to include(expected)
    end

    it 'offers place_token and pass to a major with a same-president seller token' do
      expect(step.actions(buyer)).to eq(%w[place_token pass])
    end

    it 'offers nothing when only another player owns a tokened major' do
      old_token.remove!
      stranger = start_major!(game, 'PLM', other_player)
      place!(stranger, christiania, price: 60)
      expect(step.actions(buyer)).to eq([])
    end

    it 'offers nothing when the buyer has no unused token' do
      buyer.tokens.each { |t| t.used = true unless t.used }
      expect(step.actions(buyer)).to eq([])
    end

    it 'offers nothing when the buyer cannot afford the token and fee' do
      buyer.spend(buyer.cash, game.bank)
      expect(step.actions(buyer)).to eq([])
    end

    it 'offers nothing to a regional' do
      regional = start_regional!(game, game.corporations.find { |c| c.type == :regional && !c.ipoed }.id, player)
      fund!(game, regional, 500)
      expect(step.actions(regional)).to eq([])
    end

    it 'offers nothing in the abbreviated operating round' do
      allow(game).to receive(:abbreviated_operating_round?).and_return(true)
      expect(step.actions(buyer)).to eq([])
    end

    it 'prices each charter token at its cost plus the transfer fee' do
      choices = step.selectable_token_choices(buyer, christiania)
      expect(choices.map { |c| [c[:token].price, c[:cost]] }).to include([60, 80], [40, 60], [20, 40])
    end

    it 'transfers the token, charging charter price to the bank and fee to the seller' do
      buyer_cash = buyer.cash
      seller_cash = seller.cash
      new_token = buyer.tokens[2]

      step.process_place_token(transfer)

      expect(christiania.tokens).to include(new_token)
      expect(old_token.used).to be(false)
      expect(buyer.cash).to eq(buyer_cash - 60)
      expect(seller.cash).to eq(seller_cash + 20)
    end

    it 'still offers further transfers after one transfer' do
      other = place!(seller, liverpool, price: 60)
      step.process_place_token(transfer)
      expect(step.actions(buyer)).to eq(%w[place_token pass])
      expect(other.used).to be(true)
    end

    it 'rejects a wrong quoted cost without changing state' do
      cash = buyer.cash
      expect { step.process_place_token(transfer(cost: 40)) }.to raise_error(Engine::GameError, /Token costs/)
      expect(buyer.cash).to eq(cash)
      expect(christiania.tokens).to include(old_token)
    end

    it "rejects another player's token" do
      stranger = start_major!(game, 'PLM', other_player)
      foreign = place!(stranger, liverpool, price: 60)
      action = Engine::Action::PlaceToken.new(buyer, city: liverpool, slot: liverpool.tokens.index(foreign),
                                                     token_index: 2, cost: 100)
      expect { step.process_place_token(action) }.to raise_error(Engine::GameError, /can be transferred/)
      expect(liverpool.tokens).to include(foreign)
    end

    it "rejects the seller's home token" do
      home_city = seller.tokens.first.city
      action = Engine::Action::PlaceToken.new(buyer, city: home_city, slot: home_city.tokens.index(seller.tokens.first),
                                                     token_index: 2, cost: 60)
      expect { step.process_place_token(action) }.to raise_error(Engine::GameError, /can be transferred/)
    end

    it 'rejects a charter token that is already on the map' do
      used = buyer.tokens.first
      action = Engine::Action::PlaceToken.new(buyer, city: christiania, slot: 0, token_index: 0, cost: 20)
      expect(used.used).to be(true)
      expect { step.process_place_token(action) }.to raise_error(Engine::GameError, /available station token/)
    end

    it 'rejects a transfer the buyer cannot afford' do
      buyer.spend(buyer.cash - 50, game.bank)
      expect { step.process_place_token(transfer) }.to raise_error(Engine::GameError, /cannot afford/)
      expect(christiania.tokens).to include(old_token)
    end

    it 'marks transferable tokens replaceable and their hex available' do
      expect(step.can_replace_token?(buyer, old_token)).to be(true)
      expect(step.can_replace_token?(buyer, seller.tokens.first)).to be(false)
      expect(step.available_hex(buyer, christiania.hex)).to be_truthy
      expect(step.available_hex(buyer, liverpool.hex)).to be_falsey
    end

    it 'charges the action cost while loading instead of recomputing it' do
      allow(game).to receive(:loading).and_return(true)
      buyer_cash = buyer.cash
      seller_cash = seller.cash
      step.process_place_token(transfer(cost: 45))
      expect(buyer.cash).to eq(buyer_cash - 45)
      expect(seller.cash).to eq(seller_cash + 5)
      expect(christiania.tokens).to include(buyer.tokens[2])
    end

    it 'rejects a missing cost without changing state' do
      cash = buyer.cash
      expect { step.process_place_token(transfer(cost: nil)) }.to raise_error(Engine::GameError, /Include the transfer cost/)
      expect(buyer.cash).to eq(cash)
      expect(christiania.tokens).to include(old_token)
    end

    it 'rejects a missing slot' do
      expect { step.process_place_token(transfer(slot: nil)) }.to raise_error(Engine::GameError, /to transfer/)
      expect(christiania.tokens).to include(old_token)
    end

    it 'adds no log line when skipping with nothing to transfer' do
      old_token.remove!
      before_size = game.log.size
      round.skip_steps
      expect(game.log.size).to eq(before_size)
    end

    it 'transfers a token in the Lille extra slot by index into tokens plus extra tokens' do
      old_token.remove!
      extra = place!(seller, lille, price: 60, extra_slot: true)
      slot = (lille.tokens + lille.extra_tokens).index(extra)
      expect(step.available_hex(buyer, lille.hex)).to be_truthy
      action = Engine::Action::PlaceToken.new(buyer, city: lille, slot: slot, token_index: 2,
                                                     cost: 40 + game.token_transfer_fee(lille))
      step.process_place_token(action)
      expect(lille.extra_tokens).to include(buyer.tokens[2])
      expect(extra.used).to be(false)
    end

    it 'replays a processed transfer into a fresh game with identical tokens and cash' do
      action = transfer
      step.process_place_token(action)

      game2 = new_game
      buyer2 = start_major!(game2, 'LNWR', game2.players.first)
      seller2 = start_major!(game2, 'GWR', game2.players.first)
      fund!(game2, buyer2, 500)
      city2 = game2.hex_by_id('C48').tile.cities.first
      city2.exchange_token(seller2.tokens.find { |t| !t.used && t.price == 60 })
      r = station_token_round!(game2, buyer2, step_class: step_class)
      allow(game2).to receive(:loading).and_return(true)
      copy = Engine::Action::Base.action_from_h(JSON.parse(action.to_h.to_json), game2)
      round_step(r, step_class).process_place_token(copy)

      expect(buyer2.cash).to eq(buyer.cash)
      expect(seller2.cash).to eq(seller.cash)
      expect(city2.tokens.map { |t| t&.corporation&.name }).to eq(christiania.tokens.map { |t| t&.corporation&.name })
      expect(seller2.tokens.map(&:price)).to eq(seller.tokens.map(&:price))
    end

    it 'round-trips a transfer action through its hash form' do
      action = transfer
      copy = Engine::Action::Base.action_from_h(action.to_h, game)
      expect([copy.token_index, copy.cost, copy.slot, copy.city]).to eq([2, 60, action.slot, christiania])
    end
  end

  describe 'port authority sales (§11.3.5)' do
    let(:step_class) { Engine::Game::G18OE::Step::TransferTokens }
    let(:round) do
      station_token_round!(game, buyer, step_class: step_class)
    end
    let(:step) { round_step(round, step_class) }
    let(:sea) { game.port_authority_seas.first }
    let(:key) { "#{seller.id}:#{sea}" }

    before do
      fund!(game, buyer, 500)
      fund!(game, seller, 500)
      game.instance_variable_get(:@port_authorities)[seller] << sea
    end

    def choose(choice)
      Engine::Action::Choose.new(buyer, choice: choice)
    end

    it 'lists every other major holding a sea the buyer can buy' do
      expect(game.port_authority_sales(buyer)).to eq([[seller, sea]])
    end

    it 'lists no sale when the buyer already holds that sea' do
      game.instance_variable_get(:@port_authorities)[buyer] << sea
      expect(game.port_authority_sales(buyer)).to eq([])
    end

    it 'lists no sale when the buyer is at the port authority limit' do
      other = game.port_authority_seas.find { |s| s != sea }
      game.instance_variable_get(:@port_authorities)[buyer] << other
      expect(game.port_authority_sales(buyer)).to eq([])
    end

    it 'lists no sale when the buyer cannot pay 125' do
      buyer.spend(buyer.cash - 124, game.bank)
      expect(game.port_authority_sales(buyer)).to eq([])
    end

    it 'lists no sale for a regional buyer' do
      regional = start_regional!(game, game.corporations.find { |c| c.type == :regional && !c.ipoed }.id, player)
      fund!(game, regional, 500)
      expect(game.port_authority_sales(regional)).to eq([])
    end

    it 'moves the marker and 125 from the buyer to the seller' do
      buyer_cash = buyer.cash
      seller_cash = seller.cash
      game.transfer_port_authority!(buyer, seller, sea)
      expect(game.port_authorities(buyer)).to eq([sea])
      expect(game.port_authorities(seller)).to eq([])
      expect(buyer.cash).to eq(buyer_cash - 125)
      expect(seller.cash).to eq(seller_cash + 125)
    end

    it 'offers choose and pass when only a port authority is buyable' do
      buyer.tokens.each { |t| t.used = true unless t.used }
      expect(step.actions(buyer)).to eq(%w[choose pass])
    end

    it 'offers place_token, choose and pass when both are available' do
      place!(seller, christiania, price: 60)
      expect(step.actions(buyer)).to eq(%w[place_token choose pass])
    end

    it 'labels the choice with the sea, seller and price' do
      expect(step.choices).to eq(key => "Buy #{game.port_authority_name(sea)} from #{seller.name} (£125)")
    end

    it 'buys the port authority on choose and stays on the step' do
      buyer_cash = buyer.cash
      seller_cash = seller.cash
      step.process_choose(choose(key))
      expect(game.port_authorities(buyer)).to eq([sea])
      expect(game.port_authorities(seller)).to eq([])
      expect(buyer.cash).to eq(buyer_cash - 125)
      expect(seller.cash).to eq(seller_cash + 125)
      expect(game.log.last.message).to eq("#{buyer.name} buys a #{game.port_authority_name(sea)} from #{seller.name} for £125")
      expect(step.actions(buyer)).not_to include('choose')
    end

    it 'raises on a choice that is not an offered sale' do
      expect { step.process_choose(choose('nonsense')) }.to raise_error(Engine::GameError)
    end

    it 'needs no consenter for a same-president sale' do
      expect(game.consenter_for_choice(buyer, key, 'x')).to be_nil
    end

    it 'asks the seller president to consent to a different-president sale' do
      seller.owner = other_player
      expect(game.consenter_for_choice(buyer, key, 'x')).to eq(other_player)
    end

    it 'needs no consenter for an unrelated choice' do
      expect(game.consenter_for_choice(buyer, 'other', 'x')).to be_nil
    end
  end

  describe 'charter prices after a cross-water placement' do
    let!(:dsj) { start_major!(game, 'DSJ', player) }

    it 'keeps the charter prices of a token placed across water when it is transferred away' do
      fund!(game, dsj, 70)
      charter_prices = dsj.tokens.map(&:price).sort
      round = station_token_round!(game, dsj)
      act!(round, Engine::Action::PlaceToken.new(dsj, city: christiania, slot: 0, token_index: 5, cost: 120))
      placed = dsj.tokens[5]
      fund!(game, buyer, 500)

      game.transfer_token!(buyer, buyer.tokens[2], placed, 20)

      expect(dsj.tokens.map(&:price).sort).to eq(charter_prices)
    end
  end
end
