# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE sea zones (§11.3.4, §11.3.5)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:zones) { Engine::Game::G18OE::Map::SEA_ZONES }

  def zones_of(game, sea)
    zones.select { |name, _| game.sea(name) == sea }.keys
  end

  it 'puts exactly the ten light blue zones in the North Sea water area (§11.3.5)' do
    expect(zones_of(game, :north_sea)).to contain_exactly(
      'North Atlantic Ocean', 'North Atlantic (Silver Coast)', 'Celtic Sea', 'Bay of Biscay', 'English Channel',
      'North Sea', 'German Bight', 'Skagerrak', 'Baltic Sea', 'Gulf of Finland'
    )
  end

  it 'puts exactly the nine sea green zones in the Mediterranean water area (§11.3.5)' do
    expect(zones_of(game, :mediterranean)).to contain_exactly(
      'Strait of Gibraltar', 'Balearic Sea', 'Sea of Sardinia', 'Tyrrhenian Sea', 'Adriatic Sea', 'Aegean Sea',
      'Levantine Sea', 'Black Sea', 'Karkinitsky Bay'
    )
  end

  it 'gives every zone a sea of :north_sea or :mediterranean' do
    expect(zones.values.map { |z| z[:sea] }.uniq).to contain_exactly(:north_sea, :mediterranean)
  end

  it 'finds the zone of a sea hex' do
    expect(game.sea_zone('K6')).to eq('Celtic Sea')
  end

  it 'finds the zone of a hidden port offboard in the sea' do
    expect(game.sea_zone('H49')).to eq('Skagerrak')
  end

  it 'finds the zone of a red offboard listed in a sea zone' do
    expect(game.sea_zone('N1')).to eq('North Atlantic Ocean')
  end

  it 'has no zone for a land hex' do
    expect(game.sea_zone('B43')).to be_nil
  end

  it 'opens Kobenhavn offshore port into Skagerrak' do
    expect(game.port_sea_zone('I50', :offshore)).to eq('Skagerrak')
  end

  it 'opens Kobenhavn exit 5 port into the Baltic Sea' do
    expect(game.port_sea_zone('I50', 5)).to eq('Baltic Sea')
  end

  it 'opens Constantinople exit 3 port into the Black Sea' do
    expect(game.port_sea_zone('AA82', 3)).to eq('Black Sea')
  end

  it 'opens Constantinople exit 0 port into the Aegean Sea' do
    expect(game.port_sea_zone('AA82', 0)).to eq('Aegean Sea')
  end

  it 'resolves every port and ferry exit that is not a dead end to a sea zone' do
    ports = game.class::PORTS.flat_map do |hex_id, exits|
      exits.reject { |_, data| data[:dead_end] }.keys.map { |exit| [hex_id, exit] }
    end
    unresolved = ports.select { |hex_id, exit| game.port_sea_zone(hex_id, exit).nil? }

    expect(unresolved).to eq([])
  end

  it 'makes Skagerrak and the Baltic Sea adjacent through the channel passage (§11.3.4)' do
    expect(game.sea_zone_neighbors['Skagerrak']).to include('Baltic Sea')
    expect(game.sea_zone_neighbors['Baltic Sea']).to include('Skagerrak')
  end

  it 'makes the Black Sea and the Aegean Sea adjacent through the channel passage (§11.3.4)' do
    expect(game.sea_zone_neighbors['Black Sea']).to include('Aegean Sea')
    expect(game.sea_zone_neighbors['Aegean Sea']).to include('Black Sea')
  end

  it 'makes the Silver Coast adjacent to the Strait of Gibraltar (§11.3.4)' do
    expect(game.sea_zone_neighbors['North Atlantic (Silver Coast)']).to include('Strait of Gibraltar')
    expect(game.sea_zone_neighbors['Strait of Gibraltar']).to include('North Atlantic (Silver Coast)')
  end

  it 'makes zones that share a dashed line adjacent' do
    expect(game.sea_zone_neighbors['Celtic Sea']).to include('Bay of Biscay')
  end

  it 'does not make the Black Sea adjacent to the Adriatic Sea' do
    expect(game.sea_zone_neighbors['Black Sea']).not_to include('Adriatic Sea')
  end

  it 'counts one sea zone for a crossing within a single zone (§11.3.4)' do
    expect(game.sea_zone_distance('Baltic Sea', 'Baltic Sea')).to eq(1)
  end

  it 'counts every sea zone traveled from the North Sea to the Baltic Sea (§11.3.4)' do
    expect(game.sea_zone_distance('North Sea', 'Baltic Sea')).to eq(3)
  end

  it 'counts one sea zone from Kobenhavn to Malmo' do
    expect(game.port_distance(['I50', 5], ['I52', 0])).to eq(1)
  end
end
