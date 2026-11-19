# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE reserved shares (§8.4)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let!(:round) { enter_round!(game, game.stock_round) }
  let(:step) { round.active_step }
  let(:president) { game.players[1] }
  let(:lnwr) { start_regional!(game, 'LNWR', president) }

  def reserve!(regional = lnwr, entity: round.current_entity)
    act!(round, Engine::Action::Choose.new(entity, choice: 'reserve', target: regional))
  end

  def buy!(player, regional)
    share = regional.ipo_shares.reject(&:president).first
    act!(round, Engine::Action::BuyShares.new(player, shares: share, percent: share.percent))
  end

  def stub_major_phase!
    allow(game).to receive(:major_phase?).and_return(true)
    game.players.each { |player| fund!(game, player) }
  end

  it 'offers the president a reservation in the Initial SR' do
    lnwr
    pass_until!(round, president)

    expect(step.entity_choices(lnwr)).to include('reserve' => 'Reserve share')
    expect(step.actions(president)).to include('choose')
  end

  it 'lets only the regional president reserve' do
    lnwr
    plm = game.corporation_by_id('PLM')
    game.par_corporation(plm, cell(game, 60, :par))
    plm.ipoed = true

    expect(game.can_reserve_regional?(game.players[0], lnwr)).to be(false)
    expect(game.players.map { |player| game.can_reserve_regional?(player, plm) }).to all(be(false))
  end

  it 'allows one reservation per player and fixes it' do
    lnwr
    plm = start_regional!(game, 'PLM', president)
    pass_until!(round, president)
    reserve!

    expect(step.entity_choices(plm)).not_to include('reserve')
    expect { reserve!(plm) }.to raise_error(Engine::GameError, /Cannot reserve/)
  end

  it 'cannot be made once the first secondary share is bought' do
    take_treasury_shares!(game, game.players[2], lnwr, 1)

    expect(game.can_reserve_regional?(president, lnwr)).to be(false)
  end

  it 'is unavailable in the second SR' do
    lnwr
    round = stock_round!(game)
    pass_until!(round, president)

    expect(round.active_step.entity_choices(lnwr)).not_to include('reserve')
  end

  it 'is unavailable with two players' do
    two = new_game(%w[a b])
    regional = start_regional!(two, 'LNWR', two.players[0])

    expect(two.can_reserve_regional?(two.players[0], regional)).to be(false)
  end

  it 'is free on the president\'s own turn' do
    lnwr
    pass_until!(round, president)
    reserve!

    expect(round.current_entity).to eq(president)
    expect(step.actions(president)).to include('par')
  end

  it 'can be made after the stock action' do
    lnwr
    pass_until!(round, president)
    expect(step.pass_description).to eq('Pass (Share)')
    act!(round, Engine::Action::Par.new(president, corporation: game.corporation_by_id('PLM'),
                                                   share_price: cell(game, 60, :par)))

    expect(round.current_entity).to eq(president)
    expect(step.entity_choices(lnwr)).to include('reserve' => 'Reserve share')
    expect(step.pass_description).to eq('Pass (Reserve Share)')
  end

  it 'cannot be made once the president holds one of the secondary shares' do
    lnwr
    stub_major_phase!
    take_treasury_shares!(game, president, lnwr, 1)

    expect(game.can_reserve_regional?(president, lnwr)).to be(false)
    expect(step.entity_choices(lnwr)).not_to include('reserve')
  end

  it 'reserves one secondary share, leaving the other on sale' do
    lnwr
    stub_major_phase!
    game.reserve_share!(lnwr)
    buy!(game.players[0], lnwr)
    pass_until!(round, game.players[2])
    reserved = lnwr.ipo_shares.reject(&:president).last

    expect(step.can_buy?(game.players[2], reserved.to_bundle)).to be(false)
    expect do
      act!(round, Engine::Action::BuyShares.new(game.players[2], shares: reserved, percent: reserved.percent))
    end.to raise_error(Engine::GameError, /Cannot buy/)
  end

  it 'lets another player buy the first secondary share' do
    lnwr
    stub_major_phase!
    game.reserve_share!(lnwr)

    expect(step.can_buy?(game.players[0], lnwr.ipo_shares.reject(&:president).first.to_bundle)).to be(true)
    expect { buy!(game.players[0], lnwr) }.not_to raise_error
  end

  it 'lets the president buy both secondary shares' do
    lnwr
    stub_major_phase!
    game.reserve_share!(lnwr)
    take_treasury_shares!(game, president, lnwr, 1)

    expect(lnwr.ipo_shares.count { |share| !share.president }).to eq(1)
    expect(step.can_buy?(president, lnwr.ipo_shares.reject(&:president).first.to_bundle)).to be(true)
    expect(step.can_buy?(president, lnwr.ipo_shares.reject(&:president).last.to_bundle)).to be(true)
  end

  it 'keeps the remaining share reserved after the president buys the free share' do
    lnwr
    stub_major_phase!
    game.reserve_share!(lnwr)
    take_treasury_shares!(game, president, lnwr, 1)
    remaining = lnwr.ipo_shares.reject(&:president).first.to_bundle

    expect(game.reserved_share(lnwr)).to eq(remaining.shares.first)
    expect(step.can_buy?(game.players[0], remaining)).to be(false)
    expect(step.can_buy?(president, remaining)).to be(true)
  end

  it 'keeps the reserved share out of an Auto buy-shares program' do
    lnwr
    stub_major_phase!
    game.reserve_share!(lnwr)
    take_treasury_shares!(game, game.players[0], lnwr, 1)
    rival = game.players[2]
    pass_until!(round, rival)

    program = Engine::Action::ProgramBuyShares.new(rival, corporation: lnwr, until_condition: 2)
    result = Array(step.activate_program_buy_shares(rival, program))

    expect(result.grep(Engine::Action::BuyShares)).to be_empty
  end

  it 'lets an Auto buy-shares program buy when nothing is reserved' do
    lnwr
    stub_major_phase!
    take_treasury_shares!(game, game.players[0], lnwr, 1)
    rival = game.players[2]
    pass_until!(round, rival)

    program = Engine::Action::ProgramBuyShares.new(rival, corporation: lnwr, until_condition: 2)

    expect(Array(step.activate_program_buy_shares(rival, program)).grep(Engine::Action::BuyShares)).not_to be_empty
  end

  it 'ends with the Initial SR' do
    lnwr
    game.reserve_share!(lnwr)
    game.send(:next_round!)

    expect(game.reserved_share(lnwr)).to be_nil
    expect(game.status_str(lnwr)).to be_nil
  end

  it 'is cancelled when the regional converts to a major' do
    lnwr
    game.reserve_share!(lnwr)
    Engine::Game::G18OE::Step::BuySellParShares.new(game, []).float_major(lnwr)

    expect(game.reserved_share(lnwr)).to be_nil
  end

  it 'labels the corporation with the reserving player' do
    lnwr
    game.reserve_share!(lnwr)

    expect(game.status_str(lnwr)).to eq("Share reserved by #{president.name}")
  end

  describe 'prompt' do
    let(:buyer) { game.players[0] }
    let(:reserve_step) { round_step(round, Engine::Game::G18OE::Step::ReserveShare) }

    def buy_first!(player = buyer)
      act!(round, Engine::Action::BuyShares.new(player, shares: lnwr.ipo_shares.reject(&:president).first, percent: 25))
    end

    before do
      lnwr
      stub_major_phase!
    end

    it 'holds a rival\'s first buy and asks the president' do
      buy_first!

      expect(round.active_step).to be_a(Engine::Game::G18OE::Step::ReserveShare)
      expect(round.active_entities).to eq([president])
      expect(round.active_step.hide_corporations?).to be(true)
      expect(round.active_step.choice_name).to eq("Reserve a share of #{lnwr.name}? #{buyer.name} is buying one")
      expect(buyer.percent_of(lnwr)).to eq(0)
    end

    it 'sends the turn back to the buyer when the president reserves' do
      buy_first!
      act!(round, Engine::Action::Choose.new(president, choice: 'reserve'))

      expect(game.reserved_share(lnwr)).to eq(lnwr.ipo_shares.reject(&:president).last)
      expect(round.active_step).to be_a(Engine::Game::G18OE::Step::BuySellParShares)
      expect(round.current_entity).to eq(buyer)
      expect(game.log.last.message).to eq(
        "#{buyer.name} may buy the other 25% share of #{lnwr.name} or choose a different action"
      )
      expect(round.current_actions).to be_empty
      buy_first!
      expect(buyer.percent_of(lnwr)).to eq(25)
    end

    it 'completes the buy when the president declines' do
      buy_first!
      act!(round, Engine::Action::Pass.new(president))

      expect(game.log.map(&:message)).to include("#{president.name} declines to reserve #{lnwr.name}")
      expect(buyer.percent_of(lnwr)).to eq(25)
      expect(round.active_step).to be_a(Engine::Game::G18OE::Step::BuySellParShares)
      expect(round.pending_share_buy).to be_nil
    end

    it 'does not prompt for the president\'s own buy' do
      pass_until!(round, president)
      buy_first!(president)

      expect(president.percent_of(lnwr)).to eq(75)
      expect(reserve_step.active?).to be(false)
    end

    it 'does not prompt for the second secondary share' do
      take_treasury_shares!(game, game.players[2], lnwr, 1)
      buy_first!

      expect(buyer.percent_of(lnwr)).to eq(25)
      expect(reserve_step.active?).to be(false)
    end

    it 'does not prompt in the second SR' do
      later = stock_round!(game)
      pass_until!(later, buyer)
      act!(later, Engine::Action::BuyShares.new(buyer, shares: lnwr.ipo_shares.reject(&:president).first, percent: 25))

      expect(buyer.percent_of(lnwr)).to eq(25)
      expect(round_step(later, Engine::Game::G18OE::Step::ReserveShare).active?).to be(false)
    end

    it 'does not prompt once the president has reserved elsewhere' do
      plm = start_regional!(game, 'PLM', president)
      game.reserve_share!(plm)
      buy_first!

      expect(buyer.percent_of(lnwr)).to eq(25)
      expect(reserve_step.active?).to be(false)
    end

    it 'does not prompt on a parred regional that has not floated' do
      plm = game.corporation_by_id('PLM')
      game.par_corporation(plm, cell(game, 60, :par))
      plm.ipoed = true
      act!(round, Engine::Action::BuyShares.new(buyer, shares: plm.ipo_shares.first, percent: plm.ipo_shares.first.percent))

      expect(reserve_step.active?).to be(false)
    end

    it 'rejects an illegal held buy' do
      buyer.spend(buyer.cash, game.bank)

      expect { buy_first! }.to raise_error(Engine::GameError)
      expect(round.pending_share_buy).to be_nil
    end
  end
end
