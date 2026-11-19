# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Minor D bonus token (§15.4)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }
  let(:private_d) { game.company_by_id('D') }
  let(:minor_d) { start_minor!(game, 'D', player, 'RU') }
  let(:major) { start_major!(game, 'LNWR', player) }
  let(:city_hex) { game.hex_by_id('N31') }
  let(:other_hex) { game.hex_by_id('G26') }

  def float_d!
    give_company!(player, private_d)
    player.companies.delete(private_d)
    private_d.owner = minor_d
    minor_d.companies << private_d
  end

  def merge_d!
    float_d!
    game.add_minor_charter!(minor_d, major)
  end

  def operating_round_for(entity)
    round = enter_round!(game, game.operating_round(1))
    round.entities = [entity]
    round.instance_variable_set(:@current_operator, entity)
    round
  end

  def assign_step(round)
    round_step(round, Engine::Game::G18OE::Step::Assign)
  end

  def assign!(step, entity, hex)
    step.process_assign(Engine::Action::Assign.new(private_d, target: hex))
    entity
  end

  def card(name)
    game.depot.upcoming.find { |t| t.name == name }
  end

  def route_for(train, stops)
    route = Engine::Route.new(game, game.phase, train)
    allow(route).to receive(:visited_stops).and_return(stops)
    allow(route).to receive(:stops).and_return(stops)
    allow(route).to receive(:hexes).and_return(stops.map(&:hex))
    route
  end

  def run_train(corporation, name, variant: nil)
    train = card(name)
    game.buy_train(corporation, train, :free)
    train.variant = variant if variant
    train
  end

  def bonus(route)
    game.minor_d_bonus(route)
  end

  def enter_phase_5!
    game.phase.next! until game.phase.name == '5'
    game.event_minor_d_token!
  end

  def token20
    game.class::MINOR_D_20_TOKEN
  end

  def token40
    game.class::MINOR_D_40_TOKEN
  end

  def stop_at(hex)
    hex.tile.cities.first
  end

  before do
    allow(game).to receive(:can_run_route?).and_return(true)
  end

  it 'has no usable token while the private is held by a player' do
    give_company!(player, private_d)

    expect(game.abilities(private_d, :assign_hexes, time: 'any')).to be_nil
  end

  it 'accepts any non-metropolis city, even one the RR cannot reach' do
    merge_d!
    round = operating_round_for(major)

    assign!(assign_step(round), major, city_hex)

    expect(city_hex.assigned?(token20)).to be(true)
  end

  it 'refuses a metropolis' do
    merge_d!
    step = assign_step(operating_round_for(major))

    expect { assign!(step, major, game.hex_by_id('M28')) }.to raise_error(Engine::GameError)
  end

  it 'refuses a red zone offboard' do
    merge_d!
    step = assign_step(operating_round_for(major))
    offboard = game.hexes.find { |hex| hex.tile.offboards.any? }

    expect { assign!(step, major, offboard) }.to raise_error(Engine::GameError)
  end

  it 'refuses a hex without a city' do
    merge_d!
    step = assign_step(operating_round_for(major))
    plain = game.hexes.find { |hex| hex.tile.cities.empty? && hex.tile.offboards.empty? }

    expect { assign!(step, major, plain) }.to raise_error(Engine::GameError)
  end

  describe 'timing' do
    before { merge_d! }

    it "offers the token during the owner's lay track step" do
      round = operating_round_for(major)

      expect(round.active_step).to be_a(Engine::Game::G18OE::Step::Track)
      expect(assign_step(round).actions(private_d)).to eq(%w[assign])
    end

    it 'does not offer the token outside the lay track step' do
      round = operating_round_for(major)
      round.process_action(Engine::Action::Pass.new(major))

      expect(round.active_step).not_to be_a(Engine::Game::G18OE::Step::Track)
      expect(assign_step(round).actions(private_d)).to be_empty
    end

    it 'does not offer the token to a different RR' do
      other = start_major!(game, 'GWR', player)
      round = operating_round_for(other)

      expect(assign_step(round).actions(private_d)).to be_empty
    end

    it 'keeps lay track open with no track points left while the token is unplaced' do
      round = operating_round_for(major)
      track = round_step(round, Engine::Game::G18OE::Step::Track)
      allow(game).to receive(:tile_point_budget).and_return(0)

      expect(track.can_lay_tile?(major)).to be(true)
      expect(track.auto_actions(major)).to be_nil
    end

    it 'lets lay track end by itself once the token is placed' do
      round = operating_round_for(major)
      track = round_step(round, Engine::Game::G18OE::Step::Track)
      allow(game).to receive(:tile_point_budget).and_return(0)
      assign!(assign_step(round), major, city_hex)

      expect(track.can_lay_tile?(major)).to be(false)
    end

    it 'lets the president delay placing the token to a later OR' do
      round = operating_round_for(major)
      round.process_action(Engine::Action::Pass.new(major))
      later = operating_round_for(major)

      expect(game.abilities(private_d, :assign_hexes, time: 'any')).not_to be_nil
      expect(assign_step(later).actions(private_d)).to eq(%w[assign])
    end
  end

  describe 'revenue' do
    let(:train) { run_train(major, '3') }

    before { merge_d! }

    it 'adds 20 to a route through the city in Phase 2 to 4' do
      assign!(assign_step(operating_round_for(major)), major, city_hex)
      route = route_for(train, [stop_at(other_hex), stop_at(city_hex)])

      expect(bonus(route)).to eq(20)
    end

    it 'adds the bonus once even if the route touches the hex twice' do
      assign!(assign_step(operating_round_for(major)), major, city_hex)
      city = stop_at(city_hex)
      route = route_for(train, [city, stop_at(other_hex), city])

      expect(bonus(route)).to eq(20)
    end

    it 'adds nothing to a route that misses the city' do
      assign!(assign_step(operating_round_for(major)), major, city_hex)
      route = route_for(train, [stop_at(other_hex)])

      expect(bonus(route)).to eq(0)
    end

    it "adds nothing to another RR's route" do
      assign!(assign_step(operating_round_for(major)), major, city_hex)
      other = start_major!(game, 'GWR', player)
      route = route_for(run_train(other, '3'), [stop_at(city_hex)])

      expect(bonus(route)).to eq(0)
    end

    it 'flows through revenue_for' do
      stops = [stop_at(other_hex), stop_at(city_hex)]
      route = route_for(train, stops)
      before_revenue = game.revenue_for(route, stops)
      assign!(assign_step(operating_round_for(major)), major, city_hex)

      expect(game.revenue_for(route, stops) - before_revenue).to eq(20)
    end

    it 'doubles for a D train (§11.3.9)' do
      assign!(assign_step(operating_round_for(major)), major, city_hex)
      route = route_for(run_train(major, '7+7', variant: '4D'), [stop_at(city_hex), stop_at(other_hex)])

      expect(bonus(route)).to eq(40)
    end
  end

  describe 'merging' do
    it 'moves the token to the major so its routes earn the bonus' do
      float_d!
      round = operating_round_for(minor_d)
      assign!(assign_step(round), minor_d, city_hex)
      game.add_minor_charter!(minor_d, major)
      route = route_for(run_train(major, '3'), [stop_at(city_hex)])

      expect(private_d.owner).to eq(major)
      expect(bonus(route)).to eq(20)
    end

    it 'pays the minor before it merges' do
      float_d!
      assign!(assign_step(operating_round_for(minor_d)), minor_d, city_hex)
      route = route_for(run_train(minor_d, '3'), [stop_at(city_hex)])

      expect(bonus(route)).to eq(20)
    end
  end

  describe 'Phase 5' do
    before { merge_d! }

    it 'is triggered by the first level 5 train' do
      events = game.class::TRAINS.find { |train| train[:name] == '5' }[:events]

      expect(events).to include({ 'type' => 'minor_d_token' })
    end

    it 'replaces the +20 ability with a new +40 ability' do
      old_ability = private_d.abilities.first
      enter_phase_5!

      expect(private_d.abilities).not_to include(old_ability)
      expect(game.abilities(private_d, :assign_hexes, time: 'any')).not_to be_nil
    end

    it 'removes the +20 marker and offers a new placeable token' do
      assign!(assign_step(operating_round_for(major)), major, city_hex)
      enter_phase_5!

      expect(city_hex.assigned?(token20)).to be(false)
      expect(game.abilities(private_d, :assign_hexes, time: 'any')).not_to be_nil
    end

    it 'drops an unplaced +20 token and still offers exactly one token' do
      enter_phase_5!

      expect(Array(game.abilities(private_d, :assign_hexes, time: 'any')).size).to eq(1)
    end

    it 'pays 40 for the token placed in Phase 5' do
      enter_phase_5!
      assign!(assign_step(operating_round_for(major)), major, other_hex)
      route = route_for(run_train(major, '5'), [stop_at(other_hex)])

      expect(other_hex.assigned?(token40)).to be(true)
      expect(other_hex.assigned?(token20)).to be(false)
      expect(bonus(route)).to eq(40)
    end

    it 'adds no token when the private is already closed' do
      private_d.close!
      enter_phase_5!

      expect(game.abilities(private_d, :assign_hexes, time: 'any')).to be_nil
    end
  end

  it 'keeps the assignment when the tile on the hex is upgraded' do
    merge_d!
    assign!(assign_step(operating_round_for(major)), major, city_hex)
    tile = game.tiles.find { |t| t.color == :green && t.cities.any? }
    city_hex.lay(tile)

    expect(city_hex.assigned?(token20)).to be(true)
  end

  describe 'abandonment' do
    it 'returns a placed token to the charter and restores a placeable ability' do
      float_d!
      assign!(assign_step(operating_round_for(minor_d)), minor_d, city_hex)

      game.abandon_minor!(minor_d)

      expect(city_hex.assigned?(token20)).to be(false)
      expect(Array(game.abilities(private_d, :assign_hexes, time: 'any')).size).to eq(1)
    end

    it 'does not add a second token when none was placed' do
      float_d!

      game.abandon_minor!(minor_d)

      expect(Array(game.abilities(private_d, :assign_hexes, time: 'any')).size).to eq(1)
    end
  end
end
