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
end
