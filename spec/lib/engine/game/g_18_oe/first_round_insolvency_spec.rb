# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE first-round insolvency (§11.6.5)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }
  let(:lnwr) { start_regional!(game, 'LNWR', player) }

  def president_cash!(amount)
    player.spend(player.cash - amount, game.bank) if player.cash > amount
  end

  before do
    lnwr
    president_cash!(10)
  end

  describe 'spending guard' do
    it 'rejects track spending that leaves too little for the reserved 2+2' do
      expect { game.check_reserved_train_funds!(lnwr, 1) }.to raise_error(
        Engine::GameError,
        "LNWR cannot spend £1: it would leave £79 plus its president's £10, below the £100 for its reserved 2+2 (§11.6.5)"
      )
    end

    it 'allows spending the president can still cover' do
      game.bank.spend(20, player)

      expect { game.check_reserved_train_funds!(lnwr, 10) }.not_to raise_error
    end

    it 'allows a free action even when the funds fall short' do
      expect { game.check_reserved_train_funds!(lnwr, 0) }.not_to raise_error
    end

    it 'skips the check once the reserved 2+2 is bought' do
      game.fulfill_train_obligation!(lnwr)

      expect { game.check_reserved_train_funds!(lnwr, 1) }.not_to raise_error
    end

    it 'skips the check for majors' do
      major = game.corporation_by_id('LNWR')
      Engine::Game::G18OE::Step::BuySellParShares.new(game, []).float_major(major)

      expect(game.reserved_train_due?(major)).to be(false)
      expect { game.check_reserved_train_funds!(major, 1) }.not_to raise_error
    end

    it 'skips the check once Phase 4 ends the obligation' do
      2.times { game.phase.next! }

      expect { game.check_reserved_train_funds!(lnwr, 1) }.not_to raise_error
    end
  end

  describe 'in the steps' do
    it 'rejects a station token that breaks the guard and places none' do
      game.bank.spend(100, lnwr)
      round = station_token_round!(game, lnwr)
      city = game.hex_by_id('B41').tile.cities.first
      cost = lnwr.tokens[1].price + game.cross_water_token_fee(lnwr, city)
      action = Engine::Action::PlaceToken.new(lnwr, city: city, slot: 0, token_index: 1, cost: cost)

      expect { act!(round, action) }.to raise_error(Engine::GameError, /cannot spend £.*reserved 2\+2 \(§11.6.5\)/)
      expect(city.tokens).to all(be_nil)
      expect(lnwr.cash).to eq(180)
    end

    it 'rejects a terrain-cost tile lay that breaks the guard' do
      step = Engine::Game::G18OE::Step::Track.new(game, [])
      hex = game.hex_by_id('R55')
      tile = game.tiles.first

      expect { step.pay_tile_cost!(lnwr, tile, 0, hex, lnwr, 20, 0) }
        .to raise_error(Engine::GameError, /cannot spend £20.*reserved 2\+2 \(§11.6.5\)/)
      expect(lnwr.cash).to eq(80)
    end
  end
end

describe 'G18OE declaring first-round insolvency (§11.6.5)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }
  let(:lnwr) { start_regional!(game, 'LNWR', player) }
  let(:round) do
    lnwr
    enter_round!(game, game.operating_round(1))
  end
  let(:step) { round_step(round, Engine::Game::G18OE::Step::BuyTrain) }

  def set_cash!(entity, amount)
    entity.spend(entity.cash, game.bank) if entity.cash.positive?
    game.bank.spend(amount, entity) if amount.positive?
  end

  def prepare!(entity, treasury:, president:)
    set_cash!(entity, treasury)
    set_cash!(entity.owner, president)
    round.entities = [entity]
    round.instance_variable_set(:@current_operator, entity)
    entity
  end

  def declare!(entity)
    step.process_choose(Engine::Action::Choose.new(entity, choice: game.first_round_insolvency_choice))
  end

  describe 'offering the choice' do
    it 'offers the insolvency choice when the treasury and president cannot cover the reserved 2+2' do
      prepare!(lnwr, treasury: 80, president: 10)

      expect(game.first_round_insolvency?(lnwr)).to be(true)
      expect(step.actions(lnwr)).to include('choose')
      expect(step.choices).to eq(game.first_round_insolvency_choice => 'Declare first-round insolvency')
      expect(step.choice_name).to eq("#{player.name} cannot cover LNWR's £10 shortfall for its reserved 2+2")
      expect(step.show_president_contributions?(lnwr)).to be(false)
    end

    it 'does not offer it when the president can contribute the shortfall' do
      prepare!(lnwr, treasury: 80, president: 20)

      expect(game.first_round_insolvency?(lnwr)).to be(false)
      expect(step.actions(lnwr)).not_to include('choose')
    end

    it 'rejects the choice when the railroad is solvent' do
      prepare!(lnwr, treasury: 80, president: 20)

      expect { declare!(lnwr) }.to raise_error(Engine::GameError, /cannot declare first-round insolvency/)
    end
  end

  describe 'declaring' do
    before { prepare!(lnwr, treasury: 80, president: 10) }

    it 'moves the president cash in, buys the reserved 2+2 with the treasury and records the debt' do
      declare!(lnwr)

      expect(lnwr.trains.map(&:name)).to eq(['2+2'])
      expect(lnwr.cash).to eq(0)
      expect(game.insolvency_debt(lnwr)).to eq(10)
      expect(game.fulfilled_train_obligation?(lnwr)).to be(true)
      expect(game.insolvent?(lnwr)).to be(true)
    end

    it 'puts the president certificate in the Open Market and pays the president its face value' do
      declare!(lnwr)

      expect(lnwr.presidents_share.owner).to eq(game.share_pool)
      expect(lnwr.owner).to be_nil
      expect(game.insolvency_face_value(lnwr)).to eq(120)
      expect(player.cash).to eq(120)
    end

    it 'logs each step' do
      declare!(lnwr)

      log = game.log.map(&:message)
      expect(log).to include(/#{player.name} .* £10 .*LNWR/)
      expect(log).to include(/LNWR receives a 2\+2 for £100 with £10 unpaid/)
      expect(log).to include(/LNWR's president's certificate .* Open Market/)
      expect(log).to include(/#{player.name} receives £120/)
      expect(log).to include(/LNWR is dormant until a player buys it/)
    end

    it 'leaves the insolvent railroad out of the operating order but in the minor/regional order' do
      declare!(lnwr)

      expect(game.operating_order).not_to include(lnwr)
      expect(game.minor_regional_order).to include(lnwr)
    end
  end

  describe 'a minor' do
    let(:minor) { start_minor!(game, 'K', player, 'RU') }
    let(:round) do
      minor
      enter_round!(game, game.operating_round(1))
    end

    it 'pays the president the face value of its private company' do
      game.company_by_id('K').close!
      prepare!(minor, treasury: 60, president: 10)
      bank_before = game.bank.cash

      expect(game.first_round_insolvency?(minor)).to be(true)
      declare!(minor)

      expect(game.insolvency_debt(minor)).to eq(30)
      expect(game.insolvency_face_value(minor)).to eq(120)
      expect(player.cash).to eq(120)
      expect(game.bank.cash).to eq(bank_before + 70 - 120)
      expect(minor.owner).to be_nil
      expect(game.log.map(&:message)).to include(/K's charter .* Open Market/, /#{player.name} receives £120 for the charter/)
    end
  end

  describe 'in the operating round' do
    it 'moves on to the next railroad after the declaration' do
      other = start_regional!(game, 'GWR', player)
      round
      prepare!(lnwr, treasury: 80, president: 10)
      round.entities = [lnwr, other]
      round.instance_variable_set(:@current_operator, lnwr)
      round.instance_variable_set(:@entity_index, 0)

      round.steps.take_while { |s| !s.is_a?(Engine::Game::G18OE::Step::BuyTrain) }.each(&:pass!)
      act!(round, Engine::Action::Choose.new(lnwr, choice: game.first_round_insolvency_choice))

      expect(round.current_operator).to eq(other)
    end
  end
end

describe 'G18OE buying back an insolvent railroad (§11.6.5)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:former) { game.players.first }
  let(:buyer) { game.players[1] }
  let(:lnwr) { start_regional!(game, 'LNWR', former) }

  def set_cash!(entity, amount)
    entity.spend(entity.cash, game.bank) if entity.cash.positive?
    game.bank.spend(amount, entity) if amount.positive?
  end

  def declare!(corporation)
    set_cash!(corporation, 80) if corporation.type == :regional
    set_cash!(corporation, 60) if corporation.type == :minor
    set_cash!(former, 10)
    game.declare_first_round_insolvency!(corporation)
  end

  def stock_round_for(player)
    round = stock_round!(game)
    round.instance_variable_set(:@entity_index, round.entities.index(player))
    round
  end

  def pool_bundle(corporation)
    game.share_pool.shares_of(corporation).find(&:president).to_bundle
  end

  def buy_action(player, corporation, total = nil)
    bundle = pool_bundle(corporation)
    share_price = total && (total.to_f / bundle.num_shares)
    Engine::Action::BuyShares.new(player, shares: bundle.shares, share_price: share_price, percent: bundle.percent)
  end

  describe 'a regional' do
    before do
      lnwr
      declare!(lnwr)
      set_cash!(buyer, 500)
    end

    it 'sells the president certificate for its face value plus the unpaid debt' do
      round = stock_round_for(buyer)
      bank_before = game.bank.cash

      act!(round, buy_action(buyer, lnwr, 130))

      expect(buyer.cash).to eq(370)
      expect(game.bank.cash).to eq(bank_before + 130)
      expect(lnwr.owner).to eq(buyer)
      expect(lnwr.presidents_share.owner).to eq(buyer)
    end

    it 'restores the railroad to the operating order and clears the debt' do
      round = stock_round_for(buyer)

      act!(round, buy_action(buyer, lnwr, 130))

      expect(game.insolvent?(lnwr)).to be(false)
      expect(game.operating_order).to include(lnwr)
      expect(lnwr.share_price.price).to eq(60)
      expect(lnwr.par_price.price).to eq(60)
    end

    it 'charges the face value plus the debt whatever share price the client sends' do
      round = stock_round_for(buyer)

      act!(round, buy_action(buyer, lnwr, 60))

      expect(buyer.cash).to eq(370)
      expect(game.insolvent?(lnwr)).to be(false)
    end

    it 'does not offer the certificate to a player who cannot afford the face value plus the debt' do
      set_cash!(buyer, 129)
      round = stock_round_for(buyer)

      expect(round.active_step.can_buy?(buyer, pool_bundle(lnwr))).to be(false)
    end

    it 'lets the former president buy it back' do
      set_cash!(former, 300)
      round = stock_round_for(former)

      act!(round, buy_action(former, lnwr, 130))

      expect(lnwr.owner).to eq(former)
      expect(former.cash).to eq(170)
      expect(game.insolvent?(lnwr)).to be(false)
    end

    it 'offers the president certificate at the face value plus the debt through the stock round step' do
      round = stock_round_for(buyer)

      expect(round.active_step.can_buy?(buyer, pool_bundle(lnwr))).to be(true)
      expect(round.active_step.modify_purchase_price(pool_bundle(lnwr))).to eq(130)
    end

    it 'keeps the debt when the reserved train rusts' do
      lnwr.trains.first.rusted = true

      expect(game.insolvent_purchase_price(lnwr)).to eq(130)
    end
  end

  describe 'an odd total' do
    before do
      lnwr
      set_cash!(lnwr, 85)
      set_cash!(former, 0)
      game.declare_first_round_insolvency!(lnwr)
      set_cash!(buyer, 500)
    end

    it 'charges exactly the total when the browser sends a half share price' do
      round = stock_round_for(buyer)

      act!(round, buy_action(buyer, lnwr, 135))

      expect(game.insolvency_debt(lnwr)).to be_nil
      expect(buyer.cash).to eq(365)
      expect(buyer.cash).to be_a(Integer)
      expect(lnwr.owner).to eq(buyer)
    end

    it 'charges the same total when no share price is sent' do
      round = stock_round_for(buyer)

      act!(round, buy_action(buyer, lnwr))

      expect(buyer.cash).to eq(365)
      expect(buyer.cash).to be_a(Integer)
    end
  end

  describe 'declaring with an empty treasury' do
    it 'receives the reserved train free and owes its whole price' do
      lnwr
      set_cash!(lnwr, 0)
      set_cash!(former, 0)

      game.declare_first_round_insolvency!(lnwr)

      expect(lnwr.trains.map(&:name)).to eq(['2+2'])
      expect(game.insolvency_debt(lnwr)).to eq(100)
    end
  end

  describe 'a minor' do
    let(:minor) { start_minor!(game, 'K', former, 'RU') }

    before do
      minor
      game.company_by_id('K').close!
      declare!(minor)
      set_cash!(buyer, 500)
    end

    it 'sells the charter for its face value plus the unpaid debt' do
      round = stock_round_for(buyer)
      bank_before = game.bank.cash

      act!(round, buy_action(buyer, minor, 150))

      expect(buyer.cash).to eq(350)
      expect(game.bank.cash).to eq(bank_before + 150)
      expect(minor.owner).to eq(buyer)
      expect(game.insolvent?(minor)).to be(false)
    end

    it 'charges the same total when no share price is sent' do
      round = stock_round_for(buyer)

      act!(round, buy_action(buyer, minor))

      expect(buyer.cash).to eq(350)
      expect(minor.owner).to eq(buyer)
    end
  end
end

describe 'G18OE Consolidation cleanup of insolvent railroads (§11.6.5)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:former) { game.players.first }
  let(:buyer) { game.players[1] }

  def set_cash!(entity, amount)
    entity.spend(entity.cash, game.bank) if entity.cash.positive?
    game.bank.spend(amount, entity) if amount.positive?
  end

  def declare!(corporation, treasury)
    set_cash!(corporation, treasury)
    set_cash!(former, 10)
    game.declare_first_round_insolvency!(corporation)
  end

  it 'abandons an insolvent minor still unowned when Consolidation ends' do
    minor = start_minor!(game, 'K', former, 'RU')
    game.company_by_id('K').close!
    declare!(minor, 60)

    game.consolidation_round_finished!

    expect(game.abandoned_minor?(minor)).to be(true)
    expect(minor.presidents_share.owner).to eq(minor.ipo_owner)
    expect(game.insolvent?(minor)).to be(false)
    expect(game.minor_regional_order).not_to include(minor)
  end

  it 'closes an insolvent regional still unowned when Consolidation ends' do
    lnwr = start_regional!(game, 'LNWR', former)
    declare!(lnwr, 80)

    game.consolidation_round_finished!

    expect(lnwr.closed?).to be(true)
    expect(game.insolvent?(lnwr)).to be(false)
    expect(game.minor_regional_order).not_to include(lnwr)
    expect(game.operating_order).not_to include(lnwr)
    expect(game.log.map(&:message)).to include(/LNWR closes/)
  end

  it 'leaves an insolvent railroad that was bought back untouched' do
    lnwr = start_regional!(game, 'LNWR', former)
    declare!(lnwr, 80)
    set_cash!(buyer, 500)
    game.share_pool.transfer_shares(lnwr.presidents_share.to_bundle, buyer, allow_president_change: false)
    lnwr.owner = buyer
    game.restore_insolvent!(lnwr)

    game.consolidation_round_finished!

    expect(lnwr.closed?).to be(false)
    expect(lnwr.owner).to eq(buyer)
  end
end

describe 'G18OE final-review fixes for insolvent railroads (§11.6.5)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:former) { game.players.first }
  let(:buyer) { game.players[1] }

  def set_cash!(entity, amount)
    entity.spend(entity.cash, game.bank) if entity.cash.positive?
    game.bank.spend(amount, entity) if amount.positive?
  end

  def declare!(corporation, treasury)
    set_cash!(corporation, treasury)
    set_cash!(former, 10)
    game.declare_first_round_insolvency!(corporation)
  end

  def stock_round_for(player)
    round = stock_round!(game)
    round.instance_variable_set(:@entity_index, round.entities.index(player))
    round
  end

  def pool_bundle(corporation)
    game.share_pool.shares_of(corporation).find(&:president).to_bundle
  end

  describe 'an insolvent minor is not abandoned' do
    let(:minor) { start_minor!(game, 'K', former, 'RU') }
    let!(:major) { start_major!(game, 'LNWR', buyer) }

    before do
      minor
      game.company_by_id('K').close!
      declare!(minor, 60)
    end

    it 'is not an abandoned minor and keeps its shares visible' do
      expect(game.abandoned_minor?(minor)).to be(false)
      expect(game.abandoned_minors).not_to include(minor)
      expect(game.corporation_show_shares?(minor)).to be(true)
    end

    it 'is not offered to a major in Issue Shares' do
      round = enter_round!(game, game.operating_round(1))
      step = round_step(round, Engine::Game::G18OE::Step::IssueShares)
      set_cash!(major, 300)
      round.instance_variable_set(:@current_operator, major)
      step.setup

      expect(step.choice_corporations(major)).not_to include(minor)
    end
  end

  describe 'buying a non-president share of an insolvent regional' do
    it 'is not allowed in the major phase' do
      lnwr = start_regional!(game, 'LNWR', former)
      declare!(lnwr, 80)
      allow(game).to receive(:major_phase?).and_return(true)
      set_cash!(buyer, 500)
      round = stock_round_for(buyer)
      treasury_share = lnwr.ipo_shares.reject(&:president).first
      expect(treasury_share).not_to be_nil

      expect(round.active_step.can_buy?(buyer, treasury_share.to_bundle)).to be(false)
      expect(round.active_step.can_buy?(buyer, pool_bundle(lnwr))).to be(true)
    end
  end

  describe 'buying back a minor parred above its face value' do
    let(:minor) { start_minor!(game, 'K', former, 'RU') }

    before do
      minor
      game.company_by_id('K').close!
      game.par_corporation(minor, cell(game, 90, :par)) unless minor.par_price
      minor.share_price = cell(game, 90)
      declare!(minor, 60)
    end

    it 'charges exactly the face value plus the debt' do
      set_cash!(buyer, 500)
      round = stock_round_for(buyer)
      bundle = pool_bundle(minor)
      action = Engine::Action::BuyShares.new(buyer, shares: bundle.shares, share_price: 90, percent: bundle.percent)

      act!(round, action)

      expect(game.insolvency_debt(minor)).to be_nil
      expect(buyer.cash).to eq(500 - 150)
      expect(minor.owner).to eq(buyer)
    end

    it 'is not offered to a buyer one pound short of the total' do
      set_cash!(buyer, 149)
      round = stock_round_for(buyer)

      expect(round.active_step.can_buy?(buyer, pool_bundle(minor))).to be(false)
    end

    it 'is offered to a buyer holding exactly the total' do
      set_cash!(buyer, 150)
      round = stock_round_for(buyer)

      expect(round.active_step.can_buy?(buyer, pool_bundle(minor))).to be(true)
    end

    it 'logs one payment line' do
      set_cash!(buyer, 500)
      round = stock_round_for(buyer)
      bundle = pool_bundle(minor)

      act!(round, Engine::Action::BuyShares.new(buyer, shares: bundle.shares, percent: bundle.percent))

      lines = game.log.map(&:message).grep(/#{buyer.name} .*(takes over|buys) K/)
      expect(lines.size).to eq(1)
      expect(lines.first).to include('£150')
    end
  end

  describe 'charter status' do
    it 'shows the amount due for an insolvent regional' do
      lnwr = start_regional!(game, 'LNWR', former)
      declare!(lnwr, 80)

      expect(game.status_array(lnwr)).to include(['Insolvent: £130 due'])
    end

    it 'shows nothing once bought back' do
      lnwr = start_regional!(game, 'LNWR', former)
      declare!(lnwr, 80)
      lnwr.owner = buyer
      game.restore_insolvent!(lnwr)

      expect(game.status_array(lnwr)).to be_nil
    end
  end

  describe 'closing at the end of Consolidation' do
    it 'logs the closing only once for a regional' do
      lnwr = start_regional!(game, 'LNWR', former)
      declare!(lnwr, 80)

      game.consolidation_round_finished!

      expect(game.log.map(&:message).grep(/LNWR closes/).size).to eq(1)
    end

    it 'leaves an owned railroad alone even if the debt entry lingers' do
      lnwr = start_regional!(game, 'LNWR', former)
      declare!(lnwr, 80)
      lnwr.owner = buyer

      game.close_unowned_insolvents!

      expect(lnwr.closed?).to be(false)
    end

    it 'removes the closed regional tokens' do
      lnwr = start_regional!(game, 'LNWR', former)
      declare!(lnwr, 80)
      home = lnwr.tokens.find(&:city)

      game.consolidation_round_finished!

      expect(home.city).to be_nil
    end
  end

  describe 'reserved_train' do
    it 'is the depot train named for the reservation' do
      expect(game.reserved_train.name).to eq('2+2')
      expect(game.reserved_train_price).to eq(game.reserved_train.price)
    end
  end
end
