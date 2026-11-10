# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE ending the game (§13)' do
  include G18OESpecHelpers

  let(:game) { new_game }

  def reach_level_8_in_or!(or_num)
    start_regional!(game, 'LNWR', game.players.first)
    game.instance_variable_set(:@operating_rounds, 2)
    enter_round!(game, game.operating_round(or_num))
    game.after_phase_change('8')
  end

  it 'gives the final turn three ORs when level 8 arrives in the last OR of a set' do
    reach_level_8_in_or!(2)

    expect(game.final_operating_rounds).to eq(3)
  end

  it 'keeps two final ORs when level 8 arrives in the first OR of a set' do
    reach_level_8_in_or!(1)

    expect(game.final_operating_rounds).to eq(2)
  end

  it 'plays the extended final set before the next stock round' do
    reach_level_8_in_or!(2)
    enter_round!(game, game.stock_round)
    game.instance_variable_set(:@final_turn, game.turn)

    round_nums = Array.new(3) do
      game.next_round!
      expect(game.round).to be_a(Engine::Round::G18OE::Operating)
      game.round.round_num
    end

    expect(round_nums).to eq([1, 2, 3])
  end

  it 'returns to a stock round after two ORs when the final set is not extended' do
    start_regional!(game, 'LNWR', game.players.first)
    game.instance_variable_set(:@operating_rounds, 2)
    enter_round!(game, game.operating_round(2))

    game.next_round!

    expect(game.round).to be_a(Engine::Round::Stock)
  end

  it 'adds the remainder cash once, on the first level 8 train' do
    bank = game.bank.cash
    2.times { game.event_remainder_cash_added! }

    expect(game.bank.cash - bank).to eq(100_000)
    expect(game.depot.upcoming.find { |t| t.name == '8+8' }.events).to eq([{ 'type' => 'remainder_cash_added' }])
  end

  it 'ends after the current OR on a bank break and after the next full OR set on level 8, never on bankruptcy' do
    expect(Engine::Game::G18OE::Game::GAME_END_CHECK).to eq(bank: :current_or, final_phase: :one_more_full_or_set)
  end

  describe 'the abbreviated final OR' do
    let(:president) { game.players.first }
    let(:major) { start_major!(game, 'LNWR', president) }
    let(:step_classes) { Engine::Game::G18OE::Step }

    def final_turn!(operating_rounds: 2, game: self.game)
      game.instance_variable_set(:@turn, 3)
      game.instance_variable_set(:@final_turn, 3)
      game.instance_variable_set(:@operating_rounds, operating_rounds)
    end

    def classes_of(round)
      round.steps.map(&:class)
    end

    def give_train!(game, major)
      game.buy_train(major, game.depot.upcoming.first, :free)
    end

    def record_revenue!(major, revenue, kind, round_num: 1, trains: major.trains)
      action = Engine::Action::Dividend.new(major, kind: kind)
      runs = trains.map { |train| Struct.new(:train, :connection_hexes, :halts, :node_signatures).new(train, [], 0, []) }
      major.operating_history[[3, round_num]] = Engine::OperatingInfo.new(runs, action, revenue, {})
    end

    let(:no_track_or_buying_steps) do
      [step_classes::Track, step_classes::SpecialToken, step_classes::Token,
       step_classes::BuyTrain, step_classes::IssueShares]
    end

    def operate!(game, round_num)
      round = enter_round!(game, game.operating_round(round_num))
      round.setup
      round
    end

    it 'offers no track, token, train buying or share actions in the abbreviated final OR' do
      give_train!(game, major)
      final_turn!
      round = operate!(game, 2)

      no_track_or_buying_steps.each do |klass|
        expect(round_step(round, klass).actions(major)).to eq([]), klass.name
      end
    end

    it 'offers no token action in the abbreviated final OR even with a token ability' do
      give_train!(game, major)
      final_turn!
      allow(game).to receive(:abilities).and_call_original
      allow(game).to receive(:abilities).with(major, :token).and_return(true)
      round = operate!(game, 2)

      expect(round_step(round, step_classes::Token).actions(major)).to eq([])
    end

    it 'offers no abandoned minor purchase in the abbreviated final OR' do
      give_train!(game, major)
      final_turn!
      allow(game).to receive(:abandoned_minors).and_return([game.minors.first])
      round = operate!(game, 2)
      step = round_step(round, step_classes::IssueShares)

      expect(step.can_buy_abandoned_minor?(major)).to be(true)
      expect(step.actions(major)).to eq([])
    end

    it 'does not log skipped track, token, train buying or share steps in the abbreviated final OR' do
      give_train!(game, major)
      final_turn!
      round = operate!(game, 2)
      lines = game.log.size

      no_track_or_buying_steps.each { |klass| round_step(round, klass).log_skip(major) }

      expect(game.log.size).to eq(lines)
    end

    it 'plays the first of the final two ORs in full' do
      give_train!(game, major)
      final_turn!

      expect(round_step(operate!(game, 1), step_classes::Track).actions(major)).to include('lay_tile')
    end

    it 'still offers a token ability in the first of the final two ORs' do
      give_train!(game, major)
      final_turn!
      allow(game).to receive(:abilities).and_call_original
      allow(game).to receive(:abilities).with(major, :token).and_return(true)

      expect(round_step(operate!(game, 1), step_classes::Token).actions(major)).to eq(%w[place_token pass])
    end

    it 'repeats a payout from the previous OR' do
      give_train!(game, major)
      final_turn!
      record_revenue!(major, 100, 'payout')
      cash = president.cash
      price = major.share_price.price

      enter_round!(game, game.operating_round(2)).setup

      expect(president.cash - cash).to eq(president.num_shares_of(major) * 10)
      expect(major.share_price.price).to be > price
      expect(major.operating_history[[3, 2]].revenue).to eq(100)
      expect(major.operating_history[[3, 2]].dividend_kind).to eq('payout')
    end

    it 'repeats a withhold from the previous OR' do
      give_train!(game, major)
      final_turn!
      record_revenue!(major, 100, 'withhold')
      cash = major.cash

      enter_round!(game, game.operating_round(2)).setup

      expect(major.cash - cash).to eq(100)
      expect(major.operating_history[[3, 2]].dividend_kind).to eq('withhold')
    end

    it 'does not re-award the Orient Express bonus when repeating' do
      give_train!(game, major)
      final_turn!
      record_revenue!(major, 100, 'withhold')

      round = enter_round!(game, game.operating_round(2))
      round.setup

      expect(round.orient_express_revenue).to be_nil
      expect(round_step(round, step_classes::OrientExpressBonus).actions(major)).to be_empty
    end

    it 'lets a RR that bought a train run routes and choose its dividend' do
      give_train!(game, major)
      final_turn!
      enter_round!(game, game.operating_round(1))
      record_revenue!(major, 100, 'payout')
      game.buy_train(major, game.depot.upcoming.first, :free)
      round = enter_round!(game, game.operating_round(2))
      round.setup

      expect(game.repeat_last_revenue?(major)).to be(false)
      expect(round_step(round, step_classes::Route).actions(major)).to include('run_routes')

      round.extra_revenue = 50

      expect(round_step(round, step_classes::Dividend).actions(major)).to include('dividend')
    end

    it 'repeats a half payment for a minor' do
      minor = start_minor!(game, 'D', president, 'UK')
      final_turn!
      record_revenue!(minor, 100, 'half')
      cash = president.cash
      treasury = minor.cash

      enter_round!(game, game.operating_round(2)).setup

      expect(president.cash - cash).to eq(50)
      expect(minor.cash - treasury).to eq(50)
    end

    it 'operates normally without a previous-OR record' do
      give_train!(game, major)
      final_turn!
      enter_round!(game, game.operating_round(2))

      expect(game.repeat_last_revenue?(major)).to be(false)
    end

    it 'abbreviates only the third OR of an extended final set' do
      final_turn!(operating_rounds: 3)

      expect(game.abbreviated_operating_round?(2)).to be(false)
      expect(game.abbreviated_operating_round?(3)).to be(true)
    end

    it 'plays the final ORs in full with Long Endgame' do
      long_game = new_game(optional_rules: [:long_endgame])
      long_major = start_major!(long_game, 'LNWR', long_game.players.first)
      give_train!(long_game, long_major)
      final_turn!(game: long_game)
      round = operate!(long_game, 2)

      expect(round_step(round, step_classes::Track).actions(long_major)).to include('lay_tile')
      expect(long_game.abbreviated_operating_round?(2)).to be(false)
      expect(long_game.repeat_last_revenue?(long_major)).to be(false)
    end

    it 'makes a RR that sold a train and a RR that bought it recalculate' do
      seller = major
      buyer = start_major!(game, 'GWR', game.players.last)
      fund!(game, buyer)
      train = game.depot.upcoming.first
      game.buy_train(seller, train, :free)
      final_turn!
      operate!(game, 1)
      record_revenue!(seller, 100, 'payout')
      record_revenue!(buyer, 100, 'payout')
      game.buy_train(buyer, train, 50)
      operate!(game, 2)

      expect(game.repeat_last_revenue?(seller)).to be(false)
      expect(game.repeat_last_revenue?(buyer)).to be(false)
    end

    it 'repeats for a RR whose Orient Express run combined its trains' do
      first, second = game.depot.upcoming.first(2)
      game.buy_train(major, first, :free)
      game.buy_train(major, second, :free)
      combined = Engine::Train.new(name: [first, second].map(&:id).sort.join('_'), distance: first.distance, price: 0)
      final_turn!
      record_revenue!(major, 100, 'payout', trains: [combined])
      operate!(game, 2)

      expect(game.repeat_last_revenue?(major)).to be(true)
    end
  end
end
