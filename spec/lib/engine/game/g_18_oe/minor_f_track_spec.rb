# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Minor F green-terrain tile point (§15.6)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:entity) { game.corporation_by_id('F') }

  def prepare_track!(railroad = entity, points_left: nil, prepared_game: game, later_steps: [])
    railroad.owner = prepared_game.players.first
    fund!(prepared_game, railroad)
    prepared_game.minor_floated_regions[railroad.id] = 'UK' if railroad.type == :minor
    city = prepared_game.hex_by_id('J27').tile.cities.first
    city.remove_all_reservations!
    city.place_token(railroad, railroad.tokens.first, free: true)
    round = Engine::Round::Operating.new(prepared_game, [Engine::Game::G18OE::Step::Track, *later_steps], round_num: 1)
    round.entities = [railroad]
    round.instance_variable_set(:@current_operator, railroad)
    enter_round!(prepared_game, round)
    step = round_step(round, Engine::Game::G18OE::Step::Track)
    step.instance_variable_get(:@round).tile_points_used = prepared_game.tile_point_budget(railroad) - points_left if points_left
    step
  end

  def terrain_hex!(terrain = :mountain)
    hex = game.hex_by_id('J29')
    hex.lay(Engine::Tile.from_code('J29', :white, "double_town=revenue:0;upgrade=cost:45,terrain:#{terrain}"))
    game.graph.clear
    hex
  end

  def lay!(step, hex, railroad = entity)
    tile = step.upgradeable_tiles(railroad, hex).first
    raise 'No legal tile' unless tile

    step.process_lay_tile(Engine::Action::LayTile.new(railroad, tile: tile, hex: hex, rotation: tile.legal_rotations.first))
  end

  it 'lays on printed hill terrain with the terrain discount and cross-water fee' do
    step = prepare_track!
    hex = game.hex_by_id('I26')
    cash = entity.cash

    expect(hex.tile.terrain).to eq([:hill])
    expect(game.upgrade_cost(hex.tile, hex, entity, entity)).to eq(20)
    lay!(step, hex)

    expect(hex.tile.color).to eq(:yellow)
    expect(step.help).to eq('3 track points')
    expect(cash - entity.cash).to eq(30)
    expect(entity.abilities.first.count_this_or).to eq(1)
  end

  %i[mountain hill].each do |terrain|
    it "spends its additional point on a yellow #{terrain} lay while retaining regular points and cash discounts" do
      step = prepare_track!
      hex = terrain_hex!(terrain)
      cash = entity.cash
      lay!(step, hex)

      expect(hex.tile.color).to eq(:yellow)
      expect(step.help).to eq('3 track points')
      expect(entity.abilities.first.count_this_or).to eq(1)
      expect(cash - entity.cash).to eq(30)
      next_hex = terrain_hex!(terrain)
      expect(game.upgrade_cost(next_hex.tile, next_hex, entity, entity)).to eq(30)
      lay!(step, next_hex)
      expect(step.help).to eq('2 track points')
      expect(entity.abilities.first.count_this_or).to eq(1)
    end
  end

  it 'allows an eligible yellow lay after all regular points are spent' do
    step = prepare_track!(points_left: 0)
    hex = terrain_hex!

    expect(step.actions(entity)).to eq(%w[lay_tile pass])
    expect(step.tracker_available_hex(entity, hex)).not_to be_nil
    expect(step.tracker_available_hex(entity, game.hex_by_id('K28'))).to be_nil
    expect(step.help).to eq('0 track points + 1 green-terrain point (yellow lays only)')
    lay!(step, hex)

    expect(step).to be_passed
    expect(entity.abilities.first.count_this_or).to eq(1)
  end

  it 'requires one regular point alongside the additional point for a yellow metropolis' do
    step = prepare_track!(points_left: 0)
    hex = game.hex_by_id('R55')
    hex.lay(Engine::Tile.from_code('R55', :white, "#{hex.tile.code};upgrade=cost:45,terrain:mountain"))
    game.hex_by_id('R53').lay(game.tiles.find { |tile| tile.name == '5' })
    game.hex_by_id('R53').tile.rotate!(4)
    game.hex_by_id('R53').tile.cities.first.place_token(entity, entity.tokens.last, free: true)
    game.minor_floated_regions['F'] = 'AH'
    game.graph.clear
    tile = game.tiles.find { |candidate| candidate.name == 'OE8' }

    expect(step.tracker_available_hex(entity, hex)).to be_nil
    expect { step.process_lay_tile(Engine::Action::LayTile.new(entity, tile: tile, hex: hex, rotation: 0)) }
      .to raise_error(Engine::GameError, 'Cannot lay a yellow now')
    step.instance_variable_get(:@round).tile_points_used = 2
    expect(step.tracker_available_hex(entity, hex)).not_to be_nil
    lay!(step, hex)

    expect(step.help).to eq('0 track points')
    expect(entity.abilities.first.count_this_or).to eq(1)
    expect(step).to be_passed
  end

  [nil, :river].each do |terrain|
    it "preserves its additional point when laying on #{terrain || 'plain'} terrain" do
      step = prepare_track!
      hex = terrain ? terrain_hex!(terrain) : game.hex_by_id('J29')
      lay!(step, hex)

      expect(step.help).to eq('2 track points + 1 green-terrain point (yellow lays only)')
      expect(entity.abilities.first.count_this_or).to eq(0)
    end
  end

  it 'preserves its additional point on an upgrade even if green terrain remains on the tile' do
    game.phase.next!
    step = prepare_track!
    hex = game.hex_by_id('J29')
    tile = game.tiles.find { |candidate| candidate.name == '7' }
    tile.upgrades.concat(Engine::Tile.from_code('terrain', :white, 'upgrade=cost:45,terrain:mountain').upgrades)
    hex.lay(tile)
    game.graph.clear
    lay!(step, hex)

    expect(step.help).to eq('1 track points + 1 green-terrain point (yellow lays only)')
    expect(entity.abilities.first.count_this_or).to eq(0)
  end

  it 'preserves its additional point when placement fails' do
    step = prepare_track!
    hex = terrain_hex!
    action = Engine::Action::LayTile.new(entity, tile: game.tiles.find { |tile| tile.name == '5' }, hex: hex, rotation: 0)

    expect { step.process_lay_tile(action) }.to raise_error(Engine::GameError)
    expect(entity.abilities.first.count_this_or).to eq(0)
    lay!(step, hex)
    expect(step.help).to eq('3 track points')
  end

  it 'restores one additional point per OR without resetting on step setup or accumulating unused points' do
    step = prepare_track!
    ability = entity.abilities.first
    lay!(step, terrain_hex!)
    step.setup
    expect(ability.count_this_or).to eq(1)
    expect(game.zero_point_tile_lays_available?(entity)).to be(false)
    2.times do
      round = Engine::Round::Operating.new(game, [Engine::Game::G18OE::Step::Track], round_num: 2)
      round.entities = [entity]
      enter_round!(game, round)
      round.setup
      step = round.steps.last
    end
    expect(ability.count_this_or).to eq(0)
    lay!(step, terrain_hex!)
    lay!(step, terrain_hex!)

    expect(step.help).to eq('2 track points')
    expect(ability.count_this_or).to eq(1)
  end

  it 'gives a major independent inherited blue and green points, resetting both each OR' do
    blue_minor = game.corporation_by_id('E')
    blue_ability = blue_minor.abilities.first
    green_ability = entity.abilities.first
    major = game.corporation_by_id('LNWR')
    major.type = :major
    game.add_minor_charter!(blue_minor, major)
    game.add_minor_charter!(entity, major)
    step = prepare_track!(major)

    expect(game.zero_point_tile_lays_available?(entity)).to be(false)
    expect(step.help).to eq('6 track points + 1 blue-terrain point + 1 green-terrain point (yellow lays only)')
    lay!(step, terrain_hex!, major)
    expect(green_ability.count_this_or).to eq(1)
    expect(blue_ability.count_this_or).to eq(0)
    expect(step.help).to eq('6 track points + 1 blue-terrain point (yellow lays only)')
    lay!(step, terrain_hex!(:river), major)
    expect(step.help).to eq('6 track points')
    expect(blue_ability.count_this_or).to eq(1)
    round = Engine::Round::Operating.new(game, [Engine::Game::G18OE::Step::Track], round_num: 2)
    round.entities = [major]
    enter_round!(game, round)
    round.setup

    expect(green_ability.count_this_or).to eq(0)
    expect(blue_ability.count_this_or).to eq(0)
    expect(round.steps.last.help).to include('1 blue-terrain point + 1 green-terrain point')
  end

  it 'does not transfer the green point to a national' do
    national = game.corporation_by_id('LNWR')
    national.type = :national
    ability = entity.abilities.first
    game.add_minor_charter!(entity, national)

    expect(national.abilities).not_to include(ability)
    expect(game.zero_point_tile_lays_available?(national)).to be(false)
  end

  %i[medium_start long_endgame].each do |rule|
    context "with #{rule}" do
      let(:game) { new_game(optional_rules: [rule]) }

      it 'retains the green-terrain point' do
        step = prepare_track!
        lay!(step, terrain_hex!)

        expect(step.help).to eq('3 track points')
      end
    end
  end

  it 'keeps track active with a connected green candidate and offers Pass when only blue terrain remains' do
    step = prepare_track!(points_left: 0)
    terrain_hex!
    expect(step.auto_actions(entity)).to be_nil
    terrain_hex!(:river)
    %w[I26 J23].each { |id| game.hex_by_id(id).tile.upgrades.clear }
    game.graph.clear
    actions = step.auto_actions(entity)

    expect(actions.map(&:type)).to eq(['pass'])
    expect(actions.first.entity).to eq(entity)
    expect(step).not_to be_passed
    expect(entity.abilities.first.count_this_or).to eq(0)
  end

  it 'records and replays an automatic Pass without graph discovery after spending the last regular point' do
    later_steps = [Engine::Game::G18OE::Step::BuyTrain]
    step = prepare_track!(points_left: 1, later_steps: later_steps)
    %w[I26 J23].each { |id| game.hex_by_id(id).tile.upgrades.clear }
    game.graph.clear
    hex = game.hex_by_id('J29')
    tile = step.upgradeable_tiles(entity, hex).first
    action = Engine::Action::LayTile.new(entity, tile: tile, hex: hex, rotation: tile.legal_rotations.first)
    game.process_action(action, add_auto_actions: true).maybe_raise!
    recorded = JSON.parse(JSON.generate(action.to_h))

    expect(recorded.fetch('auto_actions').map { |auto| auto['type'] }).to eq(['pass'])
    expect(step).to be_passed
    expect(entity.abilities.first.count_this_or).to eq(0)
    replay = new_game
    replay_entity = replay.corporation_by_id('F')
    replay_step = prepare_track!(replay_entity, points_left: 1, prepared_game: replay, later_steps: later_steps)
    %w[I26 J23].each { |id| replay.hex_by_id(id).tile.upgrades.clear }
    replay.instance_variable_set(:@loading, true)
    expect(replay_step).not_to receive(:auto_actions)
    expect(replay.graph).not_to receive(:compute)
    expect(replay.graph).not_to receive(:connected_hexes)
    expect(replay.graph).not_to receive(:reachable_hexes)
    replay.process_action(recorded).maybe_raise!

    expect(replay_step).to be_passed
    expect(replay.round.active_step).to be_a(Engine::Game::G18OE::Step::BuyTrain)
    expect(replay_entity.abilities.first.count_this_or).to eq(0)
    expect(replay_step.help).to eq(step.help)
    expect(replay.hex_by_id('J29').tile.name).to eq(hex.tile.name)
    expect(replay_entity.cash).to eq(entity.cash)
  end
end
