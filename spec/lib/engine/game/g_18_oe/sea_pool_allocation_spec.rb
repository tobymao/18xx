# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE port authority pool shared between trains (§11.3.5)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:corporation) { game.corporation_by_id('DSJ') }
  let(:seas) { game.port_authority_seas }

  def need(cost, amount, north: 0, h: 0)
    Engine::Game::G18OE::SeaPoolNeed.new(cost, amount, seas.to_h { |sea| [sea, 0] }.merge(north_sea: north), h)
  end

  def pool(north: 0, h: 0)
    seas.to_h { |sea| [sea, 0] }.merge(north_sea: north, h: h)
  end

  def trains(count)
    Array.new(count) { |index| double("route #{index}", corporation: corporation, phase: game.phase) }
  end

  def given(routes, needs, available)
    allow(game).to receive(:sea_legs) { |_route| [:leg] }
    allow(game).to receive(:sea_pool_need) { |route, _legs = nil| needs[routes.index(route)] }
    allow(game).to receive(:sea_pool).and_return(available)
  end

  def best_of_all_covered_sets(routes, needs, available, values)
    needy = routes.each_index.select { |index| needs[index].need.positive? }
    return routes.to_h { |route| [route, true] } if needy.empty?
    return routes.to_h { |route| [route, true] } if game.sea_pool_coverable?(needy.map { |i| needs[i] }, available)

    best = (0..needy.size).flat_map { |size| needy.combination(size).to_a }
      .select { |subset| game.sea_pool_coverable?(subset.map { |i| needs[i] }, available) }
      .min_by { |subset| [-subset.sum { |i| values[i] }, -subset.size, subset.map { |i| needy.index(i) }] }
    routes.each_with_index.to_h { |route, index| [route, !needy.include?(index) || best.include?(index)] }
  end

  it 'computes no stops for a single train the pool cannot cover' do
    route = trains(1).first
    given([route], [need(2, 2, north: 1)], pool(north: 1))
    expect(game).not_to receive(:compute_stops)

    expect(game.sea_pool_allocation([route])).to eq(route => false)
  end

  it 'computes no stops when one covered set holds every train the pool can cover' do
    routes = trains(3)
    given(routes, [need(1, 1, north: 1), need(1, 1, north: 1), need(2, 3, north: 2)], pool(north: 2))
    expect(game).not_to receive(:compute_stops)

    expect(game.sea_pool_allocation(routes)).to eq(routes[0] => true, routes[1] => true, routes[2] => false)
  end

  it 'gives the pool to the train earning more when two covered sets compete' do
    rich, poor = routes = trains(2)
    given(routes, [need(2, 2, north: 2), need(2, 2, north: 2)], pool(north: 2))
    values = { rich => 70, poor => 50 }
    allow(game).to receive(:covered_sea_pool_revenue) { |route, _need| values[route] }

    expect(game.sea_pool_allocation([poor, rich])).to eq(poor => false, rich => true)
  end

  it 'allocates as the best of all covered sets with fewer revenue calls for random needs, pools and revenues' do
    rng = Random.new(610)
    calls_all_sets = calls_largest_sets = 0
    300.times do
      routes = trains(rng.rand(1..4))
      needs = routes.map do
        cost = rng.rand(0..3)
        north = rng.rand(0..cost)
        need(cost, rng.rand(0..cost + 1), north: north, h: rng.rand(0..cost))
      end
      available = pool(north: rng.rand(0..3), h: rng.rand(0..1))
      values = routes.map { rng.rand(0..3) * 10 }
      given(routes, needs, available)
      asked = []
      allow(game).to receive(:covered_sea_pool_revenue) do |route, _need|
        asked << route
        values[routes.index(route)]
      end

      expect(game.sea_pool_allocation(routes)).to eq(best_of_all_covered_sets(routes, needs, available, values))
      expect(asked.uniq.size).to eq(asked.size)
      calls_largest_sets += asked.size
      needy = needs.select { |n| n.need.positive? }
      calls_all_sets += needy.size if !needy.empty? && !game.sea_pool_coverable?(needy, available)
    end
    expect(calls_largest_sets).to be < calls_all_sets
  end
end
