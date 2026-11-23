# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE National Track' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }
  let(:national) do
    major = start_major!(game, 'LNWR', player)
    game.phase.next! until game.phase.name == '5'
    game.national_formation_done!(game.national_formation_player) while game.national_formation_player
    game.form_national!(major)
    major
  end

  def city_at(hex_id)
    game.hex_by_id(hex_id).tile.cities.first
  end

  def national_round!
    round = enter_round!(game, game.operating_round(1))
    act!(round, Engine::Action::Pass.new(round.current_entity)) until round.current_entity == national
    round
  end

  describe 'virtual tokens (§11.3.10)' do
    it 'counts every home-zone city as tokened' do
      expect(game.city_tokened_by?(city_at('G26'), national)).to be true
      expect(game.city_tokened_by?(city_at('J25'), national)).to be true
    end

    it 'counts a zone city full of other tokens' do
      other = start_major!(game, 'GWR', game.players[1])
      city = city_at('J25')
      national
      city.slots.times do |index|
        other.tokens[index + 1] = Engine::Token.new(other) if other.tokens[index + 1].nil?
      end
      tokens = other.tokens.reject(&:used)
      tokens.first(city.available_slots).each { |token| city.place_token(other, token, free: true, check_tokenable: false) }
      expect(city.available_slots).to eq(0)
      expect(game.city_tokened_by?(city, national)).to be true
    end

    it 'does not count cities outside the home zone' do
      hex = game.hexes.find { |h| !h.tile.cities.empty? && game.region_for_hex(h) != 'UK' }
      expect(game.city_tokened_by?(hex.tile.cities.first, national)).to be false
    end

    it 'gives majors no virtual tokens' do
      national
      major = start_major!(game, 'GWR', game.players[1])
      expect(game.city_tokened_by?(city_at('G26'), major)).to be false
    end

    it 'does not block other railroads' do
      other = start_major!(game, 'GWR', game.players[1])
      third = start_major!(game, 'PLM', game.players[2])
      national
      city = city_at('J25')
      city.slots.times do
        token = Engine::Token.new(other)
        other.tokens << token
        city.place_token(other, token, free: true, check_tokenable: false)
      end
      expect(third).not_to eq(national)
      expect(city.available_slots).to eq(0)
      expect(game.city_tokened_by?(city, national)).to be true
      expect(city.blocks?(third)).to be true
      expect(city.tokens.compact.map(&:corporation).uniq).to eq([other])
    end

    it 'does not raise for entities that are not corporations' do
      expect { game.city_tokened_by?(city_at('J25'), nil) }.not_to raise_error
      expect { game.city_tokened_by?(city_at('J25'), game.companies.first) }.not_to raise_error
    end

    it 'lets a national use a private port in a zone city' do
      other = start_major!(game, 'GWR', game.players[1])
      expect(game.port_usable?('I20', 4, national)).to be true
      expect(game.port_usable?('I20', 4, other)).to be false
    end
  end

  describe 'laying track (§11.1.3–11.1.4)' do
    let(:round) do
      fund!(game, national, 100)
      national.tokens.clear
      national_round!
    end

    it 'offers a tokenless national the Track step with 9 points' do
      step = round.active_step
      expect(step).to be_a(Engine::Game::G18OE::Step::Track)
      expect(step.actions(national)).to include('lay_tile')
      expect(step.help).to eq('9 track points')
    end

    it 'lays a tile in a zone city' do
      expect { lay_first_legal!(game, round, 'G26') }.not_to raise_error
    end

    it 'rejects an unconnected zone hex' do
      hex = game.hex_by_id('G18')
      expect(round.active_step.available_hex(national, hex)).to be_falsy
      tile = game.tile_by_id('7-0')
      action = Engine::Action::LayTile.new(national, tile: tile, hex: hex, rotation: 0)
      expect { round.process_action(action) }.to raise_error(Engine::GameError)
    end

    it 'rejects a hex outside the home zone' do
      hex = game.graph.connected_hexes(national).keys.find { |h| !game.hex_within_national_region?(national, h) }
      expect(hex).not_to be_nil
      expect(round.active_step.available_hex(national, hex)).to be_falsy
    end
  end

  describe 'no tile placement expenses (§11.1.5–11.1.6)' do
    it 'charges a national no terrain cost' do
      g26 = game.hex_by_id('G26')
      major = start_major!(game, 'GWR', game.players[1])
      expect(game.upgrade_cost(g26.tile, g26, national, national)).to eq(0)
      expect(game.upgrade_cost(g26.tile, g26, major, major)).to eq(30)
    end

    it 'lays on terrain with no cash' do
      national.tokens.clear
      national.spend(national.cash, game.bank) if national.cash.positive?
      round = national_round!
      expect(national.cash).to eq(0)
      expect { lay_first_legal!(game, round, 'G26') }.not_to raise_error
      expect(national.cash).to eq(0)
      expect(game.log.map(&:message).grep(/discount/)).to be_empty
    end

    it 'charges a national no cross-water fee' do
      hex = game.hex_by_id('G26')
      tile = hex.tile
      major = start_major!(game, 'GWR', game.players[1])
      allow(game.graph.sea_connectivity(national)).to receive(:tile_cost).and_return(2)
      allow(game.graph.sea_connectivity(major)).to receive(:tile_cost).and_return(2)
      expect(game.cross_water_tile_fee(national, hex, tile)).to eq(0)
      expect(game.cross_water_tile_fee(major, hex, tile)).to eq(10)
    end
  end

  describe 'region_for_hex' do
    [Engine::Game::G18OE::Game, Engine::Game::G18OEUKFR::Game].each do |klass|
      it "keeps region_for_hex results for #{klass}" do
        game = new_game(klass: klass)
        ids = klass::NATIONAL_REGION_HEXES.values.flatten.uniq + klass::CITY_TOWN_NATIONAL_ZONE.keys
        ids.each do |id|
          hex = game.hex_by_id(id)
          next unless hex

          expected = klass::CITY_TOWN_NATIONAL_ZONE[id] ||
            klass::NATIONAL_REGION_HEXES.find { |_, hex_ids| hex_ids.include?(id) }&.first
          expect(game.region_for_hex(hex)).to eq(expected)
        end
      end
    end
  end
end
