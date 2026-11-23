# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Hochberg Mining and Lumber Company (§14.8)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }
  let(:hmlc) { game.company_by_id('HMLC') }
  let(:rr) { start_major!(game, 'LNWR', player) }
  let(:blank) { game.hex_by_id('S38') }
  let(:town_hex) { game.hex_by_id('R51') }

  before { give_company!(player, hmlc) }

  def operating_round_for(entity)
    round = enter_round!(game, game.operating_round(1))
    round.entities = [entity]
    round.instance_variable_set(:@current_operator, entity)
    round
  end

  def assign_step(round)
    round_step(round, Engine::Game::G18OE::Step::Assign)
  end

  def place!(hex)
    assign_step(operating_round_for(rr)).process_assign(Engine::Action::Assign.new(hmlc, target: hex))
  end

  def supply(name)
    game.tiles.find { |tile| tile.name == name }
  end

  def lay!(hex, name, rotation = 0)
    tile = supply(name)
    tile.rotate!(rotation)
    game.update_tile_lists(tile, hex.tile)
    hex.lay(tile)
    tile
  end

  def town_revenue(tile)
    tile.towns.first.revenue[:yellow]
  end

  it "offers assign to the owner's RR during Track" do
    round = operating_round_for(rr)

    expect(round.actions_for(hmlc)).to include('assign')
  end

  it "offers nothing for another player's RR" do
    other = start_major!(game, 'GWR', game.players.last)
    round = operating_round_for(other)

    expect(round.actions_for(hmlc)).to be_empty
  end

  it 'accepts green terrain of at least £45' do
    expect(%w[S38 U38 R51].map { |id| game.hochberg_hex?(game.hex_by_id(id)) }).to all(be(true))
  end

  it 'rejects other hexes' do
    expect(%w[R39 T75 Y14 T37].map { |id| game.hochberg_hex?(game.hex_by_id(id)) }).to all(be(false))
  end

  it 'turns HMLC face down' do
    place!(blank)

    expect(blank.assigned?('HMLC')).to be(true)
    expect(game.face_down_private?(hmlc)).to be(true)
    expect(game.hochberg_token_placeable?(rr)).to be(false)
  end

  it 'rejects an ineligible hex' do
    expect { place!(game.hex_by_id('R39')) }.to raise_error(Engine::GameError)
  end

  it 'zeroes a printed town' do
    place!(town_hex)

    expect(game.hochberg_town).to eq(town_hex.tile.towns.first)
    expect(game.hochberg_town.route_revenue(game.phase, game.depot.upcoming.first)).to eq(0)
  end

  it 'adds a town to a blank hex' do
    place!(blank)

    expect(blank.tile.towns.size).to eq(1)
    expect(town_revenue(blank.tile)).to eq(0)
    expect(game.upgrades_to?(blank.tile, supply('9'))).to be(false)
    expect(game.upgrades_to?(blank.tile, supply('4'))).to be(true)
  end

  it 'swaps a track tile for its town tile' do
    laid_nine = lay!(blank, '9', 1)
    exits = blank.tile.exits.sort

    place!(blank)

    expect(blank.tile.name).to eq('4')
    expect(blank.tile.exits.sort).to eq(exits)
    expect(town_revenue(blank.tile)).to eq(0)
    expect(game.tiles).to include(laid_nine)
  end

  it 'keeps the town at £0 through upgrades' do
    lay!(blank, '9')
    place!(blank)
    game.phase.next! until game.phase.tiles.include?(:green)
    laid_four = blank.tile
    green = supply('141')
    game.update_tile_lists(green, blank.tile)
    green.rotate!(0)
    blank.lay(green)

    expect(town_revenue(green)).to eq(0)
    expect(game.tiles).to include(laid_four)
    expect(town_revenue(laid_four)).to eq(10)
    expect(laid_four.towns.first.revenue_to_render).to eq(10)
  end

  it 'keeps Track open while the token is placeable' do
    round = operating_round_for(rr)
    track = round_step(round, Engine::Game::G18OE::Step::Track)
    allow(game).to receive(:tile_point_budget).and_return(0)

    expect(track.can_lay_tile?(rr)).to be(true)
    expect(track.auto_actions(rr)).to be_nil
  end

  describe 'revenue and other RRs' do
    let(:other) { start_major!(game, 'GWR', game.players.last) }
    let(:city_a) { game.hex_by_id('N31').tile.cities.first }
    let(:city_b) { game.hex_by_id('G26').tile.cities.first }

    before do
      allow(game).to receive(:can_run_route?).and_return(true)
      place!(town_hex)
    end

    def card(name)
      game.depot.upcoming.find { |t| t.name == name }
    end

    def route_for(corporation, name, stops, variant: nil)
      train = card(name)
      game.buy_train(corporation, train, :free)
      train.variant = variant if variant
      route = Engine::Route.new(game, game.phase, train)
      allow(game).to receive(:visited_stops).with(route).and_return(stops)
      allow(route).to receive(:visited_stops).and_return(stops)
      allow(route).to receive(:stops).and_return(stops)
      allow(route).to receive(:hexes).and_return(stops.map(&:hex))
      route
    end

    def enter_phase!(name)
      game.phase.next! until game.phase.name == name
    end

    def revenue(route)
      game.revenue_for(route, game.counted_stops(route))
    end

    {
      '2' => 10, '3' => 20, '5' => 40, '7' => 60
    }.each do |phase, value|
      it "pays the owner £#{value} in phase #{phase}" do
        enter_phase!(phase)
        with_town = route_for(rr, '2+2', [city_a, game.hochberg_town, city_b])
        without = route_for(rr, '2+2', [city_a, city_b])

        expect(revenue(with_town) - revenue(without)).to eq(value)
      end
    end

    it "doesn't count for a 4D" do
      enter_phase!('7')
      route = route_for(rr, '7+7', [city_a, game.hochberg_town, city_b], variant: '4D')
      allow(city_a).to receive(:tokened_by?).and_return(true)

      expect(game.compute_stops(route)).to eq([city_a, city_b])
    end

    it 'counts for a plain 3 train in place of a city' do
      enter_phase!('3')
      route = route_for(rr, '3', [city_a, game.hochberg_town])
      allow(city_a).to receive(:tokened_by?).and_return(true)

      expect(game.compute_stops(route)).to include(game.hochberg_town)
      expect(game.hochberg_bonus(route, game.compute_stops(route))).to eq(20)
    end

    it "doesn't count for other players' RRs" do
      route = route_for(other, '2+2', [city_a, game.hochberg_town, city_b])

      expect(game.counted_stops(route)).to eq([city_a, city_b])
    end

    it "rejects another player's two-stop route through it" do
      route = route_for(other, '2+2', [city_a, game.hochberg_town])
      allow(route).to receive(:connection_data).and_return([{}])
      allow(route).to receive(:paths).and_return([])
      allow(game).to receive(:check_sea_crossing_separation)

      expect { game.check_other(route) }.to raise_error(Engine::GameError)
    end

    it 'accepts the same two-stop route for the owner' do
      route = route_for(rr, '2+2', [city_a, game.hochberg_town])
      allow(route).to receive(:connection_data).and_return([{}])
      allow(route).to receive(:paths).and_return([])
      allow(game).to receive(:check_sea_crossing_separation)

      expect { game.check_other(route) }.not_to raise_error
    end

    it 'is ignored by nationals' do
      game.form_national!(rr)
      national = rr
      allow(game).to receive(:entity_track_rights_zone).and_return(game.region_for_hex(town_hex))
      with_token = Engine::Game::G18OE::NationalRevenue.new(game, national).town_stops

      expect(with_token.map(&:first)).not_to include(town_hex)
    end
  end
end
