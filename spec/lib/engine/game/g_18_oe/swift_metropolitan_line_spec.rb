# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Swift Metropolitan Line (§14.10)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }
  let(:sml) { game.company_by_id('SML') }
  let(:major) { start_major!(game, 'LNWR', player) }
  let(:minor) { start_minor!(game, 'K', player, 'RU') }

  def card(name)
    game.depot.upcoming.find { |t| t.name == name }
  end

  def rust_two_plus_twos!
    2.times { game.buy_train(minor, card('2+2'), :free) }
    game.rust_trains!(card('4'), minor)
  end

  def operate!(corporation)
    round = enter_round!(game, game.operating_round(1))
    round.instance_variable_set(:@current_operator, corporation)
    round
  end

  def advance_to_phase_4!
    game.phase.next! until game.phase.available?('4')
  end

  def use_sml!(corporation)
    act!(operate!(corporation), Engine::Action::ChooseAbility.new(sml, choice: 'preserve'))
    corporation.trains.find(&:extra)
  end

  def record_revenue!(corporation, trains)
    action = Engine::Action::Dividend.new(corporation, kind: 'withhold')
    runs = trains.map { |train| Struct.new(:train, :connection_hexes, :halts, :node_signatures).new(train, [], 0, []) }
    corporation.operating_history[[3, 1]] = Engine::OperatingInfo.new(runs, action, 100, {})
  end

  def abbreviated_final_or!
    game.instance_variable_set(:@turn, 3)
    game.instance_variable_set(:@final_turn, 3)
    game.instance_variable_set(:@operating_rounds, 2)
    enter_round!(game, game.operating_round(2))
  end

  before { give_company!(player, sml) }

  it "isn't usable before Phase 4" do
    rust_two_plus_twos!

    expect(operate!(major).actions_for(sml)).not_to include('choose_ability')
  end

  it "is usable during a controlled RR's OR turn from Phase 4" do
    advance_to_phase_4!

    expect(operate!(major).actions_for(sml)).to include('choose_ability')
  end

  context 'when used' do
    let!(:works) do
      advance_to_phase_4!
      rust_two_plus_twos!
      game.depot.rusted_trains.count { |t| t.name == '2+2' }
    end
    let!(:train) { use_sml!(major) }

    it 'gives the RR an extra 2+2 from the Locomotive Works and closes SML' do
      expect(train.name).to eq('2+2')
      expect(train.rusted).to be(false)
      expect(game.depot.rusted_trains.count { |t| t.name == '2+2' }).to eq(works - 1)
      expect(sml.closed?).to be(true)
    end

    it "doesn't count toward the train limit or the must-own-a-train rule (§11.6)" do
      expect(game.num_corp_trains(major)).to eq(0)
      expect(game.trainless?(major)).to be(true)
    end

    it 'runs in the turn it is acquired' do
      expect(game.route_trains(major)).to include(train)
    end

    it "doesn't rust on a later level 4 purchase" do
      game.rust_trains!(card('4'), major)

      expect(train.rusted).to be(false)
      expect(major.trains).to include(train)
    end

    it "can't be combined for an Orient Express run (§12.1)" do
      expect(game.double_head_candidates(major)).not_to include(train)
    end

    it "counts toward a national's limit after formation" do
      game.form_national!(major)

      expect(train.extra).to be(false)
      expect(game.num_corp_trains(major)).to eq(1)
    end
  end

  it 'runs again even if it ran before it rusted' do
    advance_to_phase_4!
    rust_two_plus_twos!
    game.depot.rusted_trains.each { |t| t.operated = true }
    train = use_sml!(major)

    expect(game.route_trains(major)).to include(train)
  end

  it "isn't taken back by a forming national that owned it before it rusted" do
    advance_to_phase_4!
    owned = card('2+2')
    game.buy_train(major, owned, :free)
    game.rust_trains!(card('4'), major)
    game.depot.rusted_trains.reject { |t| t == owned }.each { |t| game.depot.remove_train(t) }
    other_major = start_major!(game, 'GWR', player)
    use_sml!(other_major)

    game.form_national!(major)

    expect(owned.owner).to eq(other_major)
    expect(major.trains).not_to include(owned)
  end

  describe 'merging a minor that holds it' do
    before do
      advance_to_phase_4!
      rust_two_plus_twos!
      major
      allow(game).to receive(:major_phase?).and_return(true)
    end

    def merge!(target)
      stock = stock_round!(game)
      act!(stock, Engine::Action::Choose.new(stock.current_entity, choice: minor.id))
      act!(stock, Engine::Action::Merge.new(minor, corporation: target))
      token_step = Engine::Game::G18OE::Step::MergeToken
      act!(stock, Engine::Action::Pass.new(stock.current_entity)) while stock.active_step.is_a?(token_step)
      stock
    end

    it 'moves it to the major without offering it for discard (§14.10)' do
      train = use_sml!(minor)
      stock = merge!(major)
      discard_step = stock.steps.find { |s| s.is_a?(Engine::Game::G18OE::Step::MergeDiscardTrain) }

      expect(train.owner).to eq(major)
      expect(train.extra).to be(true)
      expect(discard_step.trains(major)).not_to include(train)
      expect(discard_step.active?).to be(false)
    end

    it 'makes it an ordinary train of a national' do
      game.form_national!(major)
      train = use_sml!(minor)
      merge!(major)

      expect(train.owner).to eq(major)
      expect(train.extra).to be(false)
    end
  end

  describe 'repeating revenue in the abbreviated final OR (§13)' do
    before do
      advance_to_phase_4!
      rust_two_plus_twos!
      game.buy_train(major, card('3'), :free)
    end

    it 'repeats when the previous OR ran every train including the extra 2+2' do
      use_sml!(major)
      record_revenue!(major, major.trains)
      abbreviated_final_or!

      expect(game.repeat_last_revenue?(major)).to be(true)
    end

    it "doesn't repeat when the extra 2+2 was acquired after the last run" do
      ran = major.trains.dup
      use_sml!(major)
      record_revenue!(major, ran)
      abbreviated_final_or!

      expect(game.repeat_last_revenue?(major)).to be(false)
    end
  end
end
