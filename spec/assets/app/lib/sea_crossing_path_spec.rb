# frozen_string_literal: true

require './spec/spec_helper'
require_relative '../../../lib/engine/game/g_18_oe/helpers'
require 'lib/sea_crossing_path'

describe Lib::SeaCrossingPath do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:crossing) do
    game.sea_crossing(:crossing, ['I50', 5], ['D41', 0],
                      [game.hex_by_id('I50').tile.cities.first, game.hex_by_id('D41').tile.towns.first])
  end
  let(:sea_path) { described_class.for(game) }

  def raw_path(from, to)
    sea_path.path(from, to, crossing)
  end

  def straight(hexes)
    sea_path.straighten(hexes, crossing)
  end

  def routed(from, to)
    straight(raw_path(from, to))
  end

  def distance(hex)
    sea_path.send(:land_distance, hex, crossing)
  end

  def sea_line(from, to)
    sea_path.send(:line_hexes, from, to)
  end

  let(:from_hex) { game.hex_by_id('H49') }

  it 'bends around Jutland on the way to Stavanger, touching only sea hexes between waypoints' do
    to_hex = game.port_marker_hex('D41', 0)
    path = routed(from_hex, to_hex)
    expect(path.first).to eq(from_hex)
    expect(path.last).to eq(to_hex)
    expect(path.size).to be > 2
    path.each_cons(2) do |a, b|
      expect(sea_line(a, b).map { |hex| game.sea_zone(hex.id) }).to all(be)
    end
  end

  it 'keeps mid-route waypoints in open water where the sea is wide' do
    path = routed(from_hex, game.port_marker_hex('N1', 5))
    expect(path[2..-2]).not_to be_empty
    expect(path[2..-2].map { |hex| distance(hex) }).to all(be >= 2)
  end

  it 'has interior waypoints at sea on the Stavanger run, where the water is one hex wide' do
    path = routed(from_hex, game.port_marker_hex('D41', 0))
    expect(path[1..-2]).not_to be_empty
    expect(path[1..-2].map { |hex| distance(hex) }).to all(be >= 1)
  end

  it 'counts the map edge as a coast for sea hexes with only sea neighbours' do
    edge = game.hexes.find do |hex|
      game.sea_zone(hex.id) && hex.all_neighbors.size < 6 && hex.all_neighbors.values.all? { |n| game.sea_zone(n.id) }
    end
    expect(edge).not_to be_nil
    expect(distance(edge)).to eq(1)
  end

  it 'keeps the København to New York line off the map edge' do
    path = routed(from_hex, game.port_marker_hex('N1', 5))
    expect(path[1..-2].map { |hex| hex.all_neighbors.size }).to all(eq(6))
  end

  it 'finds the same raw sea path in either direction' do
    to_hex = game.port_marker_hex('N1', 5)
    expect(raw_path(from_hex, to_hex)).to eq(raw_path(to_hex, from_hex).reverse)
  end

  it 'straightens a hex run the same way in either direction' do
    path = raw_path(from_hex, game.port_marker_hex('N1', 5))
    expect(straight(path).reverse).to eq(straight(path.reverse))
  end

  it 'measures distance to land in hex steps' do
    expect(distance(game.hex_by_id('I50'))).to eq(0)
    expect(distance(from_hex)).to eq(1)
  end

  it 'crosses land once when two seas have no sea-hex link' do
    expect(routed(from_hex, game.hex_by_id('J51'))).to eq([from_hex, game.hex_by_id('J51')])
  end

  it 'returns just the hex for the same hex' do
    expect(routed(from_hex, from_hex)).to eq([from_hex])
  end

  it 'memoises the result' do
    to_hex = game.port_marker_hex('D41', 0)
    expect(raw_path(to_hex, from_hex)).to equal(raw_path(to_hex, from_hex))
  end
end
