# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE graph across water (§11.1.3, §11.3.6)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:dsj) { game.corporation_by_id('DSJ') }

  def token!(hex_id, corporation)
    city = game.hex_by_id(hex_id).tile.cities.first
    city.place_token(corporation, corporation.next_token, free: true, check_tokenable: false)
  end

  def lay!(hex_id, name, rotation)
    tile = game.tiles.find { |t| t.name == name && !t.hex }
    tile.rotate!(rotation)
    game.hex_by_id(hex_id).lay(tile)
    tile
  end

  it 'lands at a public port with only the port edge, then walks on once track meets the arrow (§11.3.6, §11.1.3)' do
    token!('I50', dsj)
    game.graph.clear
    expect(game.graph.connected_hexes(dsj)[game.hex_by_id('K60')]).to eq([3])
    expect(game.graph.connected_nodes(dsj)).not_to have_key(game.hex_by_id('K60').tile.towns.first)
    lay!('K60', '4', 0)
    game.clear_graph
    expect(game.graph.connected_nodes(dsj)).to have_key(game.hex_by_id('K60').tile.towns.first)
    expect(game.graph.connected_hexes(dsj)).to have_key(game.hex_by_id('L59'))
  end

  it 'does not enter a private port without a token there (§11.3.6)' do
    token!('I50', dsj)
    game.graph.clear
    expect(game.graph.connected_hexes(dsj)).not_to have_key(game.hex_by_id('I52'))
  end

  it 'connects an offshore city with every edge and offers it for a token (§11.3.6)' do
    token!('I50', dsj)
    game.graph.clear
    christiania = game.hex_by_id('C48').tile.cities.first
    expect(game.graph.connected_nodes(dsj)).to have_key(christiania)
    expect(game.graph.connected_hexes(dsj)[game.hex_by_id('C48')].sort).to eq([0, 1, 2, 3, 4, 5])
    expect(game.graph.reachable_hexes(dsj)).to have_key(game.hex_by_id('C48'))
    expect(game.graph.can_token?(dsj)).to be(true)
    expect(game.graph.tokenable_cities(dsj)).to include(christiania)
  end

  it 'does not connect a full city reached only by sea (§11.3.6)' do
    token!('I50', dsj)
    lay!('H21', '57', 1)
    token!('H21', game.corporation_by_id('GSWR'))
    game.clear_graph
    expect(game.graph.connected_nodes(dsj)).not_to have_key(game.hex_by_id('H21').tile.cities.first)
  end

  it 'keeps ports out of the merge graph (§10.5)' do
    gswr = game.corporation_by_id('GSWR')
    token!('I50', dsj)
    lay!('H21', '57', 1)
    game.clear_graph
    expect(game.graph.connected_nodes(dsj)).to have_key(game.hex_by_id('H21').tile.cities.first)
    token!('H21', gswr)
    game.clear_graph
    expect(game.merge_connected?(gswr, dsj)).to be(false)
  end

  it 'sees a private port once the corporation tokens its city' do
    token!('I50', dsj)
    game.clear_graph
    expect(game.sea_network(dsj).usable?('I52', 0)).to be(false)
    token!('I52', dsj)
    game.clear_graph_for_entity(dsj)
    expect(game.sea_network(dsj).usable?('I52', 0)).to be(true)
  end

  it 'drops every network when any entity clears the graph' do
    token!('I50', dsj)
    before = game.sea_network(dsj)
    game.clear_graph_for_entity(game.corporation_by_id('GSWR'))
    expect(game.sea_network(dsj)).not_to equal(before)
  end
end
