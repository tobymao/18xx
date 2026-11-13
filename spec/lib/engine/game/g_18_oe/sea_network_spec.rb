# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE sea network (§11.3.6, §11.3.7)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:dsj) { game.corporation_by_id('DSJ') }

  def network(corporation = dsj)
    Engine::Game::G18OE::SeaNetwork.new(game, corporation)
  end

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

  it 'lets a private port be used only with a token in its city (§11.3.6)' do
    expect(network.usable?('I52', 0)).to be(false)
    token!('I52', dsj)
    expect(network.usable?('I52', 0)).to be(true)
  end

  it 'treats a ferry at a private port as public track (§11.3.7)' do
    expect(network.ferry_links('AA20', 5)).to eq([[['AB27', 1], 1]])
    expect(network.usable?('AA20', 5)).to be(false)
  end

  it 'gives a distance 0 ferry a weight of 0 (§11.3.7)' do
    expect(network.ferry_links('H21', 3)).to eq([[['G24', 1], 0]])
  end

  it 'has no anchor at a dead end' do
    expect(network.anchors).not_to have_key(['E28', 4])
  end

  it 'joins a port to its island only once track reaches the arrow (PB 4.4)' do
    expect(network.anchor_island_ids('K60', 3)).to eq([])
    lay!('K60', '4', 0)
    expect(network.anchor_island_ids('K60', 3).size).to eq(1)
  end

  it 'builds on the UK-France map, skipping ports whose hex is missing' do
    uk_fr = new_game(klass: Engine::Game::G18OEUKFR::Game)
    anchors = Engine::Game::G18OE::SeaNetwork.new(uk_fr, uk_fr.corporation_by_id('LNWR')).anchors
    expect(anchors).to have_key(['M28', :offshore])
    expect(anchors.keys.map(&:first)).to all(satisfy { |id| uk_fr.hex_by_id(id) })
  end

  it 'has nothing reachable for a corporation without tokens' do
    expect(network.landings).to eq({})
    expect(network.hex_cost(game.hex_by_id('K60'))).to be_nil
  end

  it 'starts at an offshore anchor of the token hex but not at an unconnected exit port' do
    token!('I50', dsj)
    expect(network.anchor_costs(game.hex_by_id('I50'))[:offshore]).to eq(0)
    expect(network.anchor_costs(game.hex_by_id('I50'))[5]).to eq(4)
  end

  it 'reaches a public port two zones away at ferry distance 4 and marks only the port edge' do
    token!('I50', dsj)
    expect(network.anchor_costs(game.hex_by_id('K60'))).to eq({ 3 => 4 })
    expect(network.landings[game.hex_by_id('K60')]).to eq({ 3 => true })
    expect(network.landing_nodes).not_to include(game.hex_by_id('K60').tile.towns.first)
    lay!('K60', '4', 0)
    expect(network.landing_nodes).to include(game.hex_by_id('K60').tile.towns.first)
  end

  it 'prices a ferry crossing below the port crossing (§11.1.6)' do
    gswr = game.corporation_by_id('GSWR')
    token!('I20', gswr)
    tile = game.tiles.find { |t| t.name == '4' && !t.hex }.tap { |t| t.rotate!(2) }
    expect(network(gswr).tile_cost(game.hex_by_id('J23'), tile)).to eq(1)
  end

  it 'prices a ferry landing on a hex with no usable port (§11.1.6)' do
    sfr = game.corporation_by_id('SFR')
    token!('Z47', sfr)
    lay!('Z47', '57', 0)
    tile = game.tiles.find { |t| t.name == '9' && !t.hex }.tap { |t| t.rotate!(0) }
    expect(network(sfr).tile_cost(game.hex_by_id('AB41'), tile)).to eq(1)
  end

  it 'connects an offshore city directly at one zone (§11.3.6)' do
    token!('I50', dsj)
    christiania = game.hex_by_id('C48').tile.cities.first
    expect(network.city_cost(christiania)).to eq(2)
    expect(network.landings[game.hex_by_id('C48')].keys.sort).to eq([0, 1, 2, 3, 4, 5])
    expect(network.landing_nodes).to include(christiania)
  end

  it 'keeps overland track on a city in a sea-zone hex part of the land network (§11.3.6)' do
    token!('T87', dsj)
    lay!('S86', '4', 1)
    lay!('S84', '58', 4)
    expect(network.hex_cost(game.hex_by_id('S86'))).to eq(0)
  end

  it 'does not join an offshore anchor to the track of a city it could not run through (§11.3.6)' do
    expect(network.anchor_island_ids('L37', :offshore)).not_to be_empty
    token!('L37', game.corporation_by_id('GSWR'))
    expect(network.anchor_island_ids('L37', :offshore)).to be_empty
  end

  it 'does not land in a city it could not run through (§11.3.6)' do
    token!('I50', dsj)
    lay!('H21', '57', 1)
    token!('H21', game.corporation_by_id('GSWR'))
    expect(network.landing_nodes).not_to include(game.hex_by_id('H21').tile.cities.first)
  end
end
