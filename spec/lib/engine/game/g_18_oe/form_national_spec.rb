# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE national formation (§9.4)' do
  include G18OESpecHelpers

  let(:game) { new_game(%w[a b c]) }
  let(:alice) { game.players[0] }
  let(:bob) { game.players[1] }
  let(:carol) { game.players[2] }
  let(:round) { enter_round!(game, game.operating_round(1)) }
  let(:formation) { round_step(round, Engine::Game::G18OE::Step::FormNational) }

  def operating!(corporation)
    round.instance_variable_set(:@current_operator, corporation)
  end

  def choose!(player, choice)
    act!(round, Engine::Action::Choose.new(player, choice: choice))
  end

  def begin_formation!(buyer_corporation)
    operating!(buyer_corporation)
    game.start_national_formation!(buyer_corporation.owner)
  end

  [['4', true], ['5', false], ['6', true], ['7', false], ['8', true]].each do |phase, starts|
    it "#{starts ? 'starts' : 'does not start'} formation when Phase #{phase} begins" do
      major = start_major!(game, 'LNWR', alice)
      round
      operating!(major)

      game.after_phase_change(phase)

      expect(game.national_formation_player).to(starts ? eq(alice) : be_nil)
    end
  end

  it 'does not start formation outside an operating round' do
    start_major!(game, 'LNWR', alice)
    stock_round!(game)

    game.after_phase_change('4')

    expect(game.national_formation_player).to be_nil
  end

  it 'orders players from the buyer and skips players without a major' do
    start_major!(game, 'LNWR', alice)
    buyer = start_major!(game, 'GWR', carol)
    start_regional!(game, 'PLM', bob)
    round

    begin_formation!(buyer)

    expect(game.national_formation_player).to eq(carol)
    game.national_formation_done!(carol)
    expect(game.national_formation_player).to eq(alice)
  end

  it 'converts the chosen major and keeps the player active while they have majors left' do
    first = start_major!(game, 'LNWR', alice)
    second = start_major!(game, 'GWR', alice)
    round
    begin_formation!(first)

    expect(formation.actions(alice)).to eq(['choose'])
    expect(formation.choices).to eq('LNWR' => 'Convert LNWR', 'GWR' => 'Convert GWR', 'done' => 'Done')

    choose!(alice, 'LNWR')

    expect(first.type).to eq(:national)
    expect(game.national_formation_player).to eq(alice)
    expect(formation.choices.keys).to eq(%w[GWR done])
    expect(second.type).to eq(:major)
  end

  it 'finishes the player when their last major converts' do
    major = start_major!(game, 'LNWR', alice)
    round
    begin_formation!(major)

    choose!(alice, 'LNWR')

    expect(game.national_formation_player).to be_nil
  end

  it 'done passes to the next player; formation ends after the last' do
    first = start_major!(game, 'LNWR', alice)
    start_major!(game, 'GWR', bob)
    round
    begin_formation!(first)
    train = game.depot.upcoming.first
    game.buy_train(first, train, :free)
    game.phase.next! until game.phase.name == '4'
    game.rust_trains!(game.depot.upcoming.find { |t| t.name == '4' }, first)
    expect(game.rusted_at_phase_change(first)).to eq([train])

    choose!(alice, 'done')
    expect(game.national_formation_player).to eq(bob)
    expect(formation.actions(alice)).to eq([])
    expect(game.rusted_at_phase_change(first)).not_to be_empty

    choose!(bob, 'done')
    expect(game.national_formation_player).to be_nil
    expect(game.rusted_at_phase_change(first)).to be_empty
  end

  it 'rejects converting a major the player does not preside' do
    first = start_major!(game, 'LNWR', alice)
    start_major!(game, 'GWR', bob)
    round
    begin_formation!(first)

    expect { choose!(alice, 'GWR') }.to raise_error(Engine::GameError)
  end

  it 'rejects an action from a player who is not forming' do
    first = start_major!(game, 'LNWR', alice)
    start_major!(game, 'GWR', bob)
    round
    begin_formation!(first)

    expect { choose!(bob, 'done') }.to raise_error(Engine::GameError)
  end

  it 'runs before the train-limit discard' do
    steps = round.steps
    index = ->(klass) { steps.index { |s| s.is_a?(klass) } }

    expect(index.call(Engine::Game::G18OE::Step::FormNational)).to be < index.call(Engine::Step::DiscardTrain)
  end

  it 'never makes a national buy a train' do
    major = start_major!(game, 'LNWR', alice)
    game.fulfill_train_obligation!(major)
    buy_train = round_step(round, Engine::Game::G18OE::Step::BuyTrain)
    expect(buy_train.must_buy_train?(major)).to be(true)

    game.form_national!(major)

    expect(buy_train.must_buy_train?(major)).to be(false)
  end

  it 'lets the buying major convert itself and the OR continues' do
    lnwr = fund!(game, start_major!(game, 'LNWR', alice), 1000)
    game.fulfill_train_obligation!(lnwr)
    allow(game).to receive(:non_starter_trains_available?).and_return(true)
    game.depot.upcoming.shift until game.depot.upcoming.first.name == '4'
    game.phase.next!
    game.depot.depot_trains(clear: true)
    train = game.depot.upcoming.first
    round.entities.replace([lnwr])
    round.instance_variable_set(:@entity_index, 0)
    operating!(lnwr)
    buy_train = round_step(round, Engine::Game::G18OE::Step::BuyTrain)

    buy_train.process_buy_train(Engine::Action::BuyTrain.new(lnwr, train: train, price: train.price, variant: train.name))
    round.send(:clear_cache!)

    expect(game.phase.name).to eq('4')
    expect(round.active_step).to be_a(Engine::Game::G18OE::Step::FormNational)
    expect(round.active_step.current_entity).to eq(alice)

    choose!(alice, 'LNWR')
    expect(lnwr.type).to eq(:national)
    expect(round.active_step).not_to be_a(Engine::Game::G18OE::Step::FormNational)
    expect(buy_train.must_buy_train?(lnwr)).to be(false)
  end
end
