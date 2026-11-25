# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE forced conversion (§11.6.4)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }
  let(:lnwr) { start_major!(game, 'LNWR', player) }
  let(:round) do
    Engine::Round::Operating.new(
      game,
      [Engine::Game::G18OE::Step::BuyTrain, Engine::Game::G18OE::Step::NationalBuyTrains],
      round_num: 2,
    )
  end
  let(:step) { round_step(round, Engine::Game::G18OE::Step::BuyTrain) }

  def card(name)
    game.depot.upcoming.find { |t| t.name == name }
  end

  def set_cash!(entity, amount)
    entity.spend(entity.cash, game.bank) if entity.cash.positive?
    game.bank.spend(amount, entity) if amount.positive?
  end

  def prepare!(treasury:, president:, entity: lnwr, fulfill: true)
    set_cash!(entity, treasury)
    set_cash!(entity.owner, president)
    game.fulfill_train_obligation!(entity) if fulfill
    game.instance_variable_set(:@first_or_complete, true)
    game.depot.upcoming.select { |t| t.name == '2+2' }.each { |t| game.depot.remove_train(t) }
    round.entities = [entity]
    round.instance_variable_set(:@current_operator, entity)
    enter_round!(game, round)
    allow(game).to receive(:major_phase?).and_return(true)
    entity
  end

  describe 'the forced price' do
    it 'forces the cheaper side of the cheapest train' do
      prepare!(treasury: 50, president: 500)
      three = card('3')

      expect(game.forced_train_price(lnwr)).to eq(200)
      expect do
        step.process_buy_train(Engine::Action::BuyTrain.new(lnwr, train: three, price: 225, variant: '3+3'))
      end.to raise_error(Engine::GameError)

      cash = player.cash
      step.process_buy_train(Engine::Action::BuyTrain.new(lnwr, train: three, price: 200, variant: '3'))

      expect(lnwr.trains).to include(three)
      expect(cash - player.cash).to eq(150)
    end

    it 'ignores rusted Works trains' do
      rusted = card('2+2')
      prepare!(treasury: 50, president: 500)
      rusted.rusted = true
      game.depot.reclaim_train(rusted)

      expect(game.forced_train_price(lnwr)).to eq(200)
    end

    it 'uses the cheaper side of an Open Market train shown express' do
      prepare!(treasury: 50, president: 500)
      discarded = card('3')
      discarded.variant = '3+3'
      game.depot.reclaim_train(discarded)
      game.depot.upcoming.select { |t| t.name == '3' }.each { |t| game.depot.remove_train(t) }

      expect(game.forced_train_price(lnwr)).to eq(200)
    end

    it "counts Minor J's discount" do
      prepare!(treasury: 50, president: 500)
      j = start_minor!(game, 'J', player, 'IT')
      game.add_minor_charter!(j, lnwr)

      expect(game.forced_train_price(lnwr)).to eq(180)
    end
  end

  describe 'share selling' do
    it 'offers no share selling to a major or its president' do
      prepare!(treasury: 0, president: 0)
      take_treasury_shares!(game, player, lnwr, 1)
      set_cash!(player, 100)
      held = player.shares_of(lnwr).reject(&:president)
      bundle = Engine::ShareBundle.new(held.first(1))
      expect(bundle.shares).not_to be_empty

      expect(round.actions_for(player)).not_to include('sell_shares')
      expect(round.actions_for(lnwr)).not_to include('sell_shares')
      expect(step.can_sell?(player, bundle)).to be(false)
    end

    it 'offers no share selling to a minor' do
      minor = start_minor!(game, 'K', player, 'RU')
      prepare!(treasury: 0, president: 100, entity: minor, fulfill: false)

      expect(step.must_buy_train?(minor)).to be(true)
      expect(round.actions_for(minor)).not_to include('sell_shares')
      expect(round.actions_for(player)).not_to include('sell_shares')
    end
  end

  describe 'offering the conversion' do
    it 'offers it when treasury and president fall short' do
      prepare!(treasury: 100, president: 99)

      expect(round.actions_for(lnwr)).to include('choose')
    end

    it 'does not offer it when treasury and president can pay' do
      prepare!(treasury: 100, president: 100)

      expect(round.actions_for(lnwr)).not_to include('choose')
    end

    it 'does not offer it to a railroad owning a train' do
      prepare!(treasury: 0, president: 0)
      game.buy_train(lnwr, card('3'), :free)

      expect(round.actions_for(lnwr)).not_to include('choose')
    end

    it 'offers it to a railroad owning only a Pullman' do
      prepare!(treasury: 0, president: 0)
      pullman = game.depot.depot_trains.find { |t| game.pullman?(t) } || game.depot.upcoming.find { |t| game.pullman?(t) }
      game.buy_train(lnwr, pullman, :free)

      expect(round.actions_for(lnwr)).to include('choose')
    end

    it "keeps other railroads' trains buyable beside the conversion (R50)" do
      gwr = start_major!(game, 'GWR', player)
      prepare!(treasury: 30, president: 0)
      game.buy_train(gwr, card('3'), :free)

      expect(step.buyable_trains(lnwr).map(&:owner)).to include(gwr)
      expect(round.actions_for(lnwr)).to include('choose')
    end
  end

  describe 'converting' do
    def choose!
      round.process_action(Engine::Action::Choose.new(lnwr, choice: 'national'))
    end

    it 'converts the major and surrenders the president cash' do
      works = card('2+2')
      prepare!(treasury: 60, president: 120)
      works.rusted = true
      game.depot.reclaim_train(works)
      game.phase.next! until game.phase.name == '5'
      token_hex = lnwr.tokens.find(&:used).hex
      price = lnwr.share_price
      bank_cash = game.bank.cash

      choose!

      expect(player.cash).to eq(0)
      expect(game.bank.cash).to eq(bank_cash + 180)
      expect(game.national?(lnwr)).to be(true)
      expect(token_hex.tile.cities.flat_map(&:tokens).compact.map(&:corporation)).not_to include(lnwr)
      expect(lnwr.share_price).to eq(price)
      expect(round.active_step).to be_a(Engine::Game::G18OE::Step::NationalBuyTrains)
      expect(game.log.map(&:message)).to include(
        "#{player.name} cannot fund a train for LNWR and surrenders £120 to the bank"
      )
    end

    it 'converts in any phase (R54)' do
      prepare!(treasury: 60, president: 120)
      game.phase.next! until game.phase.name == '3'

      choose!

      expect(game.national?(lnwr)).to be(true)
    end

    it 'rejects conversion when the president can pay (R55)' do
      prepare!(treasury: 100, president: 100)

      expect { choose! }.to raise_error(Engine::GameError)
      expect(game.national?(lnwr)).to be(false)
    end
  end

  describe 'bankruptcy' do
    it 'never lets a president go bankrupt' do
      minor = start_minor!(game, 'K', player, 'RU')
      prepare!(treasury: 0, president: 0)

      expect(game.can_go_bankrupt?(player, lnwr)).to be(false)
      expect(game.can_go_bankrupt?(player, minor)).to be(false)
    end

    it 'has no Bankrupt step in the operating round' do
      expect(game.operating_round(1).steps.map(&:class)).not_to include(Engine::Step::Bankrupt)
    end
  end
end
