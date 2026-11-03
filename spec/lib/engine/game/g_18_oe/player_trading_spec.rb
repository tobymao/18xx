# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE trading with another player (§10.4, errata 8 and 10)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:round) { stock_round!(game, turn: 1) }
  let(:step) { round.active_step }
  let(:player) { round.current_entity }
  let(:seller) { game.players[1] }
  let(:company) { give_company!(seller, game.company_by_id('WCF')) }
  let(:unfloated) { give_company!(seller, game.company_by_id('A')) }
  let(:minor) { start_minor!(game, 'B', seller, 'SP') }

  def buy_company!(target, price, buyer = player)
    act!(round, Engine::Action::BuyCompany.new(buyer, company: target, price: price))
  end

  def buy_minor!(target, price, buyer = player)
    act!(round, Engine::Action::BuyCorporation.new(buyer, corporation: target, price: price))
  end

  def snapshot(*entities)
    entities.map { |entity| [entity.cash, entity.companies.dup, entity.shares.dup] }
  end

  it 'offers a face-up private and an unfloated minor through buy_company in the opening stock round (§10.4)' do
    company
    unfloated

    expect(step.purchasable_companies(player)).to contain_exactly(company, unfloated)
    expect(step.actions(player)).to include('buy_company')
  end

  it 'offers a floated minor through buy_corporation in the opening stock round (§10.4)' do
    minor

    expect(step.can_buy_corporation?(player, minor)).to be(true)
    expect(step.actions(player)).to include('buy_corporation')
  end

  it 'still offers trades once the Major Railroad Phase has begun in the opening stock round (§10.4, errata 10)' do
    company
    minor
    allow(game).to receive(:major_phase?).and_return(true)

    expect(step.purchasable_companies(player)).to eq([company])
    expect(step.can_buy_corporation?(player, minor)).to be(true)
  end

  it 'offers no trade in the second stock round while the engine phase is still 2 (errata 10)' do
    later_round = stock_round!(game, turn: 2)
    later_step = later_round.active_step
    company
    minor
    later_player = later_round.current_entity

    expect(game.phase.name).to eq('2')
    expect(later_step.purchasable_companies(later_player)).to be_empty
    expect(later_step.can_buy_corporation?(later_player, minor)).to be(false)
    expect(later_step.actions(later_player)).not_to include('buy_company', 'buy_corporation')
  end

  it 'rejects a trade processed outside the opening stock round (errata 10)' do
    later_round = stock_round!(game, turn: 2)
    later_step = later_round.active_step
    company
    later_player = later_round.current_entity
    cash = later_player.cash

    expect do
      later_step.process_buy_company(Engine::Action::BuyCompany.new(later_player, company: company, price: 10))
    end.to raise_error(Engine::GameError)
    expect(company.owner).to eq(seller)
    expect(later_player.cash).to eq(cash)
  end

  it 'offers and processes no trade in a concession turn (§8.1)' do
    company
    minor
    fund!(game, player)
    give_company!(player, game.company_by_id('CON1'))
    game.instance_variable_set(:@concessions, game.concessions.first(1))
    concession_round = enter_round!(game, game.new_concession_round)
    concession_step = concession_round.active_step
    concession_player = concession_round.current_entity
    state = snapshot(concession_player, seller)

    expect(concession_step.actions(concession_player)).not_to include('buy_company', 'buy_corporation')
    expect do
      concession_round.process_action(Engine::Action::BuyCompany.new(concession_player, company: company, price: 5))
    end.to raise_error(Engine::GameError)
    expect do
      concession_round.process_action(Engine::Action::BuyCorporation.new(concession_player, corporation: minor, price: 5))
    end.to raise_error(Engine::GameError)
    expect(snapshot(concession_player, seller)).to eq(state)
    expect(company.owner).to eq(seller)
    expect(minor.owner).to eq(seller)
  end

  it 'moves a face-up private to the buyer and the price to the seller as personal cash (§10.4)' do
    company
    buyer_cash = player.cash
    seller_cash = seller.cash

    buy_company!(company, 35)

    expect(company.owner).to eq(player)
    expect(player.companies).to include(company)
    expect(seller.companies).not_to include(company)
    expect(player.cash).to eq(buyer_cash - 35)
    expect(seller.cash).to eq(seller_cash + 35)
  end

  it 'keeps the private\'s revenue and abilities for the new owner (§10.4)' do
    company
    revenue = company.revenue
    ability_types = company.abilities.map(&:type)

    buy_company!(company, 10)

    expect(company.revenue).to eq(revenue)
    expect(company.abilities.map(&:type)).to eq(ability_types)
    expect(company.owner).to eq(player)
  end

  it 'moves an unfloated minor to the buyer with its treasury and does not float it (§10.4, §9.1)' do
    unfloated
    corporation = game.corporation_by_id('A')
    fund!(game, corporation, 120)

    buy_company!(unfloated, 50)

    expect(unfloated.owner).to eq(player)
    expect(corporation.cash).to eq(120)
    expect(corporation).not_to be_floated
    expect(corporation.owner).to be_nil
  end

  it 'lets the new owner float an acquired minor on a later stock action (§9.1, §10.4)' do
    unfloated
    corporation = game.corporation_by_id('A')
    fund!(game, corporation, 120)
    buyer = player
    buy_company!(unfloated, 50)
    pass_until!(round, buyer)

    price = round.active_step.get_par_prices(buyer, corporation).first
    act!(round, Engine::Action::Par.new(buyer, corporation: corporation, share_price: price))

    expect(corporation).to be_floated
    expect(corporation.owner).to eq(buyer)
    expect(buyer.percent_of(corporation)).to eq(100)
  end

  it 'moves a floated minor\'s share, shareholder records and presidency to the buyer (§10.4)' do
    minor
    buyer_cash = player.cash
    seller_cash = seller.cash

    buy_minor!(minor, 80)

    expect(minor.owner).to eq(player)
    expect(minor.presidents_share.owner).to eq(player)
    expect(player.percent_of(minor)).to eq(100)
    expect(seller.percent_of(minor)).to eq(0)
    expect(minor.share_holders[player]).to eq(100)
    expect(minor.share_holders[seller]).to eq(0)
    expect(player.shares_of(minor).size).to eq(1)
    expect(seller.shares_of(minor)).to be_empty
    expect(player.cash).to eq(buyer_cash - 80)
    expect(seller.cash).to eq(seller_cash + 80)
  end

  it 'keeps a floated minor\'s cash, trains, tokens, rights, obligation and operating position (§10.4)' do
    minor
    game.buy_train(minor, game.depot.upcoming.first, :free)
    game.home_token_locations(minor).first.tile.cities.first.place_token(minor, minor.next_token)
    game.fulfill_train_obligation!(minor)
    before = {
      cash: minor.cash,
      trains: minor.trains.dup,
      used_tokens: minor.tokens.count(&:used),
      rights: game.minor_floated_regions[minor.id],
      obligation: game.fulfilled_train_obligation?(minor),
      order: game.minor_regional_order.index(minor),
    }

    buy_minor!(minor, 20)

    expect(minor.cash).to eq(before[:cash])
    expect(minor.trains).to eq(before[:trains])
    expect(minor.tokens.count(&:used)).to eq(before[:used_tokens])
    expect(game.minor_floated_regions[minor.id]).to eq(before[:rights])
    expect(game.fulfilled_train_obligation?(minor)).to eq(before[:obligation])
    expect(game.minor_regional_order.index(minor)).to eq(before[:order])
  end

  it 'ends the buyer\'s turn, records last_to_act and does not count as a pass (§10)' do
    company
    buyer = player

    buy_company!(company, 35)

    expect(round.current_entity).to eq(seller)
    expect(round.last_to_act).to eq(buyer)
    expect(buyer.passed?).to be(false)
    expect(round.pass_order).not_to include(buyer)
    expect(round.current_actions).to be_empty
  end

  it 'ends the buyer\'s turn after buying a floated minor (§10)' do
    minor
    buyer = player

    buy_minor!(minor, 35)

    expect(round.current_entity).to eq(seller)
    expect(round.last_to_act).to eq(buyer)
    expect(buyer.passed?).to be(false)
  end

  it 'adds the purchase to the round actions only once (§10)' do
    company
    step.process_buy_company(Engine::Action::BuyCompany.new(player, company: company, price: 5))

    expect(round.current_actions.count { |a| a.is_a?(Engine::Action::BuyCompany) }).to eq(1)
  end

  it 'accepts a price of zero (§10.4)' do
    company
    buyer_cash = player.cash

    buy_company!(company, 0)

    expect(company.owner).to eq(player)
    expect(player.cash).to eq(buyer_cash)
  end

  it 'accepts a price of zero for a floated minor and transfers ownership without cash (§10.4)' do
    minor
    buyer_cash = player.cash
    seller_cash = seller.cash
    president_share = minor.presidents_share

    buy_minor!(minor, 0)

    expect(player.cash).to eq(buyer_cash)
    expect(seller.cash).to eq(seller_cash)
    expect(minor.owner).to eq(player)
    expect(president_share.owner).to eq(player)
    expect(player.shares).to include(president_share)
    expect(seller.shares).not_to include(president_share)
    expect(minor.player_share_holders[player]).to eq(100)
    expect(minor.player_share_holders[seller].to_i).to eq(0)
  end

  it 'accepts a price equal to all of the buyer\'s cash (§10.4)' do
    company
    price = player.cash
    buyer = player

    buy_company!(company, price)

    expect(buyer.cash).to eq(0)
    expect(company.owner).to eq(buyer)
  end

  it 'offers a price range from zero to the buyer\'s cash (§10.4)' do
    expect(step.price_range(player, company)).to eq([0, player.cash])
    expect(step.price_range(player, minor)).to eq([0, player.cash])
  end

  [-1, 1.5, :unaffordable].each do |bad|
    it "rejects the price #{bad} for a private before changing anything (§10.4)" do
      company
      price = bad == :unaffordable ? player.cash + 1 : bad
      state = snapshot(player, seller)

      expect do
        step.process_buy_company(Engine::Action::BuyCompany.new(player, company: company, price: price))
      end.to raise_error(Engine::GameError)
      expect(snapshot(player, seller)).to eq(state)
      expect(company.owner).to eq(seller)
      expect(round.current_actions).to be_empty
    end

    it "rejects the price #{bad} for a floated minor before changing anything (§10.4)" do
      minor
      price = bad == :unaffordable ? player.cash + 1 : bad
      state = snapshot(player, seller)

      expect do
        step.process_buy_corporation(Engine::Action::BuyCorporation.new(player, corporation: minor, price: price))
      end.to raise_error(Engine::GameError)
      expect(snapshot(player, seller)).to eq(state)
      expect(minor.owner).to eq(seller)
      expect(round.current_actions).to be_empty
    end
  end

  it 'does not offer a face-down private and rejects buying it (§10.4)' do
    company
    game.flip_private!(company)
    state = snapshot(player, seller)

    expect(step.purchasable_companies(player)).to be_empty
    expect do
      step.process_buy_company(Engine::Action::BuyCompany.new(player, company: company, price: 5))
    end.to raise_error(Engine::GameError)
    expect(snapshot(player, seller)).to eq(state)
  end

  it 'does not offer a closed private (§10.4)' do
    company
    company.close!

    expect(step.purchasable_companies(player)).to be_empty
    expect do
      step.process_buy_company(Engine::Action::BuyCompany.new(player, company: company, price: 5))
    end.to raise_error(Engine::GameError)
  end

  it 'does not offer the buyer\'s own private (§10.4)' do
    own = give_company!(player, game.company_by_id('WCF'))
    state = snapshot(player)

    expect(step.purchasable_companies(player)).to be_empty
    expect do
      step.process_buy_company(Engine::Action::BuyCompany.new(player, company: own, price: 5))
    end.to raise_error(Engine::GameError)
    expect(snapshot(player)).to eq(state)
  end

  it 'does not offer a private held by the bank (§10.4)' do
    company.owner = game.bank
    seller.companies.delete(company)

    expect(step.purchasable_companies(player)).to be_empty
  end

  it 'rejects a bank-owned private bought for a price other than its value (§10.4)' do
    company.owner = game.bank
    seller.companies.delete(company)
    state = snapshot(player)

    expect do
      step.process_buy_company(Engine::Action::BuyCompany.new(player, company: company, price: company.value - 1))
    end.to raise_error(Engine::GameError)
    expect(snapshot(player)).to eq(state)
    expect(company.owner).to eq(game.bank)
  end

  it 'lets a player buy a bank-owned private at its value (§10.4)' do
    company.owner = game.bank
    seller.companies.delete(company)
    cash = player.cash

    step.process_buy_company(Engine::Action::BuyCompany.new(player, company: company, price: company.value))

    expect(company.owner).to eq(player)
    expect(player.cash).to eq(cash - company.value)
  end

  it 'does not offer a concession (§8.1, §10.4)' do
    concession = give_company!(seller, game.company_by_id('CON1'))

    expect(step.purchasable_companies(player)).to be_empty
    expect do
      step.process_buy_company(Engine::Action::BuyCompany.new(player, company: concession, price: 5))
    end.to raise_error(Engine::GameError)
  end

  it 'does not offer a merged minor (§10.4)' do
    minor
    major = game.corporation_by_id('LNWR')
    game.merged_minors[major] << minor
    state = snapshot(player, seller)

    expect(step.can_buy_corporation?(player, minor)).to be(false)
    expect do
      step.process_buy_corporation(Engine::Action::BuyCorporation.new(player, corporation: minor, price: 5))
    end.to raise_error(Engine::GameError)
    expect(snapshot(player, seller)).to eq(state)
  end

  it 'does not offer a closed minor (§10.4)' do
    minor
    minor.spend(minor.cash, game.bank)
    minor.close!

    expect(step.can_buy_corporation?(player, minor)).to be(false)
  end

  it 'does not offer the buyer\'s own minor (§10.4)' do
    own = start_minor!(game, 'B', player, 'SP')

    expect(step.can_buy_corporation?(player, own)).to be(false)
  end

  it 'does not offer an unfloated minor corporation or a non-minor entity as a corporation purchase (§10.4)' do
    start_regional!(game, 'LNWR', seller)
    regional = game.corporation_by_id('LNWR')

    expect(step.can_buy_corporation?(player, game.corporation_by_id('A'))).to be(false)
    expect(step.can_buy_corporation?(player, regional)).to be(false)
    expect(step.can_buy_corporation?(player, nil)).to be(false)
    expect(step.can_buy_corporation?(player, company)).to be(false)
  end

  it 'adds one certificate for the buyer when below the certificate limit (§4.1)' do
    company
    expect { buy_company!(company, 5) }.to change { game.num_certs(player) }.by(1)
  end

  it 'adds one certificate for a floated minor (§4.1)' do
    minor
    expect { buy_minor!(minor, 5) }.to change { game.num_certs(player) }.by(1)
  end

  it 'does not let a buyer at the certificate limit trade (§4.1)' do
    company
    minor
    allow(game).to receive(:cert_limit).and_return(game.num_certs(player))
    cash = player.cash

    expect(step.purchasable_companies(player)).to be_empty
    expect(step.can_buy_corporation?(player, minor)).to be(false)
    expect(step.actions(player)).not_to include('buy_company', 'buy_corporation')
    expect do
      step.process_buy_company(Engine::Action::BuyCompany.new(player, company: company, price: 5))
    end.to raise_error(Engine::GameError)
    expect(player.cash).to eq(cash)
  end

  it 'allows a private pre-action before the purchase (§10)' do
    company
    own = give_company!(player, game.company_by_id('RSC'))
    act!(round, Engine::Action::Choose.new(player, choice: 'flip_private', target: own))

    expect(step.purchasable_companies(player)).to eq([company])
    buy_company!(company, 5)
    expect(company.owner).to eq(player)
  end

  it 'does not allow a purchase after another stock action (§10)' do
    company
    minor
    par = Engine::Action::Par.new(player, corporation: game.corporation_by_id('LNWR'), share_price: cell(game, 60, :par))
    round.current_actions << par

    expect(step.purchasable_companies(player)).to be_empty
    expect(step.can_buy_corporation?(player, minor)).to be(false)
    expect do
      step.process_buy_company(Engine::Action::BuyCompany.new(player, company: company, price: 5))
    end.to raise_error(Engine::GameError)
  end

  it 'does not allow a floated minor purchase after another stock action (§10)' do
    minor
    par = Engine::Action::Par.new(player, corporation: game.corporation_by_id('LNWR'), share_price: cell(game, 60, :par))
    round.current_actions << par
    state = snapshot(player, seller)

    expect do
      step.process_buy_corporation(Engine::Action::BuyCorporation.new(player, corporation: minor, price: 5))
    end.to raise_error(Engine::GameError)
    expect(snapshot(player, seller)).to eq(state)
    expect(minor.owner).to eq(seller)
    expect(minor.presidents_share.owner).to eq(seller)
  end

  it 'lets a player holding an unfloated minor trade but not pass (§8, §10)' do
    company
    give_company!(player, game.company_by_id('C'))

    actions = step.actions(player)
    expect(actions).to include('buy_company')
    expect(actions).not_to include('pass')
  end

  it 'resolves the traded target from a serialized BuyCompany action (replay)' do
    company
    action = Engine::Action::BuyCompany.new(player, company: company, price: 12)

    replayed = Engine::Action::Base.action_from_h(JSON.parse(action.to_h.to_json), game)
    act!(round, replayed)

    expect(company.owner).to eq(player)
  end

  it 'resolves the traded minor from a serialized BuyCorporation action (replay)' do
    minor
    action = Engine::Action::BuyCorporation.new(player, corporation: minor, price: 12)

    replayed = Engine::Action::Base.action_from_h(JSON.parse(action.to_h.to_json), game)
    act!(round, replayed)

    expect(minor.owner).to eq(player)
  end

  context 'in the UK-France scenario' do
    let(:game) { new_game(%w[a b], klass: Engine::Game::G18OEUKFR::Game) }
    let(:minor) { start_minor!(game, 'C', seller, 'UK') }
    let(:company) { give_company!(seller, game.company_by_id('WCF')) }

    it 'trades a private for personal cash' do
      company
      buyer_cash = player.cash

      buy_company!(company, 40)

      expect(company.owner).to eq(player)
      expect(player.cash).to eq(buyer_cash - 40)
    end

    it 'trades a floated minor with its presidency' do
      minor

      buy_minor!(minor, 40)

      expect(minor.owner).to eq(player)
      expect(player.percent_of(minor)).to eq(100)
    end
  end
end
