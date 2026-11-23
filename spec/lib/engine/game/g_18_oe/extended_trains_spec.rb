# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Extended Full Game trains (Playbook §5.6)' do
  include G18OESpecHelpers

  let(:game) { new_game(optional_rules: [:extended_full_game]) }
  let(:player) { game.players.first }
  let(:starters) { game.trains.select { |train| train.sym == '2+2' } }

  def buy_first_four!(buyer)
    four = game.train_by_id('4-0')
    game.phase.next! until game.phase.name == '3'
    game.buy_train(buyer, four, :free)
    game.phase.buying_train!(buyer, four, game.depot)
  end

  it 'supplies one reserved 2+2 for each of the 36 railroads' do
    expect(starters.size).to eq(36)
  end

  it 'keeps the remaining sides of the 2+2 cards unavailable as train variants' do
    expect(starters.map { |train| train.variants.keys }.uniq).to eq([['2+2']])
  end

  it 'opens 14 Pullmans at Phase 4, including the one free car for Minor M' do
    minor = start_minor!(game, 'M', player, 'RU')
    buyer = start_major!(game, 'LNWR', player)

    expect(game.depot.depot_trains.none? { |train| game.pullman?(train) }).to be(true)

    buy_first_four!(buyer)

    expect(game.phase.name).to eq('4')
    expect(minor.trains.count { |train| game.pullman?(train) }).to eq(1)
    expect(game.depot.upcoming.count { |train| game.pullman?(train) }).to eq(13)
    expect(game.depot.depot_trains.any? { |train| game.pullman?(train) }).to be(true)
  end

  it 'removes four rusted 2+2s from the Locomotive Works when Pullmans become available' do
    buyer = start_major!(game, 'LNWR', player)
    starters.each { |train| game.buy_train(buyer, train, :free) }

    buy_first_four!(buyer)

    expect(game.rusted_trains.size).to eq(32)
    expect(starters.count { |train| train.rusted && train.owner.nil? }).to eq(4)
  end
end
