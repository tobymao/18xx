# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../../lib/engine/game/g_18_oe/helpers'
require 'view/game/buy_trains'

describe View::Game::BuyTrains do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }
  let(:lnwr) { fund!(game, start_major!(game, 'LNWR', player), 500) }
  let(:gwr) { fund!(game, start_major!(game, 'GWR', player), 500) }
  let(:nodes) { [] }
  let(:component) { described_class.new(nil, game: game) }
  let(:round) do
    Engine::Round::Operating.new(game, [Engine::Game::G18OE::Step::NationalBuyTrains], round_num: 1)
  end

  def train_named(name)
    game.depot.upcoming.find { |t| t.name == name }
  end

  def strings(node)
    node.is_a?(Array) ? node.flat_map { |part| strings(part) } : [node].select { |part| part.is_a?(String) }
  end

  def exchange_click(label)
    row = nodes.find { |_, props, _| props.is_a?(Array) && strings(props).include?(label) }
    row[1].find { |child| child.is_a?(Array) && child[0] == 'button.no_margin' }[1][:on][:click]
  end

  before do
    owned = train_named('2+2')
    game.buy_train(lnwr, owned, :free)
    owned.rusted = true
    five = train_named('5')
    game.buy_train(gwr, five, :free)
    works = train_named('3')
    works.rusted = true
    game.depot.reclaim_train(works)
    game.phase.next! until game.phase.name == '5'
    game.form_national!(lnwr)
    round.entities = [lnwr]
    round.instance_variable_set(:@current_operator, lnwr)
    enter_round!(game, round)
    allow(component).to receive(:h) do |tag, props = {}, children = nil|
      node = [tag, props, children]
      nodes << node
      node
    end
    allow(component).to receive(:process_action) { |action| round.process_action(action) }
    allow(component).to receive(:store)
    game.singleton_class.send(:public, :president_assisted_buy, :info_train_name, :info_train_price)
  end

  it 'names the selling railroad on an upgrade exchange line' do
    component.render

    expect(nodes.flat_map { |node| strings(node) }).to include('2+2 -> 5 from GWR ')
  end

  it 'names The Discard on a Works swap line and shows no price for a free exchange' do
    component.render

    texts = nodes.flat_map { |node| strings(node) }
    expect(texts).to include('2+2 -> 3 from The Discard ')
    expect(texts.grep(/ -> /).grep(/£/)).to be_empty
  end

  it 'lists the rusted Works train in Available Trains at zero' do
    component.render
    index = nodes.index { |tag, _, children| tag == 'div.nowrap' && children == 'The Discard' }

    expect(nodes[index - 1].last).to eq('3')
    expect(nodes[index + 1].last).to eq('£0')
  end

  it 'processes the upgrade when its Exchange button is clicked' do
    component.render
    exchange_click('2+2 -> 5 from GWR ').call

    expect(lnwr.trains.map(&:name)).to include('5')
  end
end

describe View::Game::BuyTrains, 'an 1822 L to 2 exchange' do
  let(:nodes) { [] }
  let(:component) { described_class.new(nil, game: game) }

  def strings(node)
    node.is_a?(Array) ? node.flat_map { |part| strings(part) } : [node].select { |part| part.is_a?(String) }
  end

  let(:game) { Engine::Game::G1822::Game.new(%w[a b c], seed: 1) }
  let(:corporation) { game.corporations.find { |c| c.type == :major } }
  let(:round) { Engine::Round::Operating.new(game, [Engine::Game::G1822::Step::BuyTrain], round_num: 1) }

  before do
    game.bank.spend(500, corporation)
    game.buy_train(corporation, game.depot.upcoming.find { |t| t.name == 'L' }, :free)
    round.entities = [corporation]
    round.instance_variable_set(:@current_operator, corporation)
    game.instance_variable_set(:@round, round)
    allow(component).to receive(:h) do |tag, props = {}, children = nil|
      node = [tag, props, children]
      nodes << node
      node
    end
    allow(component).to receive(:store)
    game.singleton_class.send(:public, :president_assisted_buy, :info_train_name, :info_train_price)
  end

  it 'names no seller for the corporation own L' do
    component.render

    price = game.format_currency(Engine::Game::G1822::Game::UPGRADE_COST_L_TO_2)
    expect(nodes.flat_map { |node| strings(node) }).to include("L -> 2 #{price} ")
  end
end
