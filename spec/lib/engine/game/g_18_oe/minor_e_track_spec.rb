# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Minor E blue-terrain tile point (§15.5)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:entity) { game.corporation_by_id('E') }

  def prepare_track!(railroad = entity, points_left: nil, home_hex: 'J27', prepared_game: game, later_steps: [])
    railroad.owner = prepared_game.players.first
    fund!(prepared_game, railroad)
    prepared_game.minor_floated_regions[railroad.id] = 'UK' if railroad.type == :minor
    city = prepared_game.hex_by_id(home_hex).tile.cities.first
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

  def terrain_hex!(terrain = :river, hex_id = 'J29')
    hex = game.hex_by_id(hex_id)
    hex.lay(Engine::Tile.from_code(hex_id, :white, "double_town=revenue:0;upgrade=cost:45,terrain:#{terrain}"))
    game.graph.clear
    hex
  end

  def lay!(step, hex, railroad = entity)
    tile = step.upgradeable_tiles(railroad, hex).first
    raise 'No legal tile' unless tile

    step.process_lay_tile(Engine::Action::LayTile.new(railroad, tile: tile, hex: hex, rotation: tile.legal_rotations.first))
  end

  def next_operation!(railroad = entity)
    round = Engine::Round::Operating.new(game, [Engine::Game::G18OE::Step::Track], round_num: game.round.round_num + 1)
    round.entities = [railroad]
    enter_round!(game, round)
    round.setup
    round.steps.last
  end

  it 'keeps all three ordinary points after a legal yellow lay on printed river terrain' do
    home = game.hex_by_id('M28')
    home.lay(game.tiles.find { |tile| tile.name == '5' })
    home.tile.rotate!(3)
    step = prepare_track!(home_hex: 'M28')
    game.minor_floated_regions['E'] = 'FR'
    cash = entity.cash

    expect(step.help).to include('3 track points')
    lay!(step, game.hex_by_id('M30'))

    expect(step.help).to eq('3 track points')
    expect(cash - entity.cash).to eq(30)
    expect(entity.abilities.first.count_this_or).to eq(1)
    lake = game.hex_by_id('M34')
    expect(game.upgrade_cost(lake.tile, lake, entity, entity)).to eq(40)
  end

  %i[water river lake].each do |terrain|
    it "uses the extra point for a yellow lay on #{terrain} without spending ordinary points" do
      step = prepare_track!
      hex = terrain_hex!(terrain)

      expect(step.description).to eq('Lay Track')
      expect(step.help).to include('3 track points')
      log_size = game.log.size
      lay!(step, hex)

      expect(hex.tile.color).to eq(:yellow)
      expect(step.help).to include('3 track points')
      expect(step.help).not_to include('blue-terrain point')
      expect(entity.abilities.first.count_per_or).to eq(1)
      expect(entity.abilities.first.count_this_or).to eq(1)
      expect(entity.abilities.first).to be_used
      lay_log = game.log.drop(log_size).map(&:message).join
      expect(lay_log).to include('lays tile')
      expect(lay_log).not_to include('point')
    end
  end

  it 'uses only one extra point in an operation' do
    step = prepare_track!
    lay!(step, terrain_hex!)
    lay!(step, terrain_hex!(:water))

    expect(step.help).to eq('2 track points')
    expect(entity.abilities.first.count_this_or).to eq(1)
  end

  it 'allows only eligible one-point lays when ordinary points are exhausted' do
    step = prepare_track!(points_left: 0)
    hex = terrain_hex!

    expect(step.actions(entity)).to eq(%w[lay_tile pass])
    expect(step.tracker_available_hex(entity, hex)).not_to be_nil
    expect(step.tracker_available_hex(entity, game.hex_by_id('J27'))).to be_nil
    plain_hex = game.hex_by_id('K28')
    expect(step.tracker_available_hex(entity, plain_hex)).to be_nil
    tile = game.tiles.find { |candidate| candidate.name == '7' }
    action = Engine::Action::LayTile.new(entity, tile: tile, hex: plain_hex, rotation: 0)
    expect { step.process_lay_tile(action) }.to raise_error(Engine::GameError, 'Cannot lay a yellow now')
    expect(step.help).to eq('0 track points + 1 blue-terrain point (yellow lays only)')
    lay!(step, hex)

    expect(step).to be_passed
  end

  it 'lets the railroad pass with only the restricted point remaining' do
    step = prepare_track!(points_left: 0)
    step.process_pass(Engine::Action::Pass.new(entity))

    expect(step).to be_passed
  end

  it 'uses one ordinary point and the extra point for a yellow metropolis' do
    step = prepare_track!(points_left: 1)
    hex = game.hex_by_id('R55')
    hex.lay(Engine::Tile.from_code('R55', :white, "#{hex.tile.code};upgrade=cost:45,terrain:river"))
    game.hex_by_id('R53').lay(game.tiles.find { |tile| tile.name == '5' })
    game.hex_by_id('R53').tile.rotate!(4)
    game.hex_by_id('R53').tile.cities.first.place_token(entity, entity.tokens.last, free: true)
    game.minor_floated_regions[entity.id] = 'AH'
    game.graph.clear

    step.instance_variable_get(:@round).tile_points_used = 3
    expect(step.tracker_available_hex(entity, hex)).to be_nil
    step.instance_variable_get(:@round).tile_points_used = 2
    expect(step.tracker_available_hex(entity, hex)).not_to be_nil
    lay!(step, hex)

    expect(step.help).to eq('0 track points')
    expect(step).to be_passed
  end

  it 'rejects a yellow metropolis when only the extra point remains' do
    step = prepare_track!(points_left: 0)
    hex = game.hex_by_id('R55')
    hex.lay(Engine::Tile.from_code('R55', :white, "#{hex.tile.code};upgrade=cost:45,terrain:river"))
    tile = game.tiles.find { |candidate| candidate.name == 'OE8' }

    expect { step.process_lay_tile(Engine::Action::LayTile.new(entity, tile: tile, hex: hex, rotation: 0)) }
      .to raise_error(Engine::GameError, 'Cannot lay a yellow now')
    expect(step.help).to include('1 blue-terrain point')
  end

  [nil, :hill, :mountain].each do |terrain|
    it "preserves the extra point on a #{terrain || 'plain'} yellow lay" do
      step = prepare_track!
      hex = terrain ? terrain_hex!(terrain) : game.hex_by_id('J29')
      lay!(step, hex)

      expect(step.help).to eq('2 track points + 1 blue-terrain point (yellow lays only)')
      expect(entity.abilities.first.count_this_or).to eq(0)
      expect(entity.abilities.first).not_to be_used
    end
  end

  it 'does not spend the restricted point on an upgrade of blue terrain' do
    game.phase.next!
    step = prepare_track!
    hex = game.hex_by_id('J29')
    tile = game.tiles.find { |candidate| candidate.name == '7' }
    tile.upgrades.concat(Engine::Tile.from_code('terrain', :white, 'upgrade=cost:45,terrain:river').upgrades)
    hex.lay(tile)
    game.graph.clear
    lay!(step, hex)

    expect(step.help).to eq('1 track points + 1 blue-terrain point (yellow lays only)')
    expect(entity.abilities.first.count_this_or).to eq(0)
  end

  it 'preserves the point when a lay fails validation' do
    step = prepare_track!
    hex = terrain_hex!
    action = Engine::Action::LayTile.new(entity, tile: game.tiles.find { |tile| tile.name == '5' }, hex: hex, rotation: 0)

    expect { step.process_lay_tile(action) }.to raise_error(Engine::GameError)
    expect(entity.abilities.first.count_this_or).to eq(0)
    expect(entity.abilities.first).not_to be_used
    lay!(step, hex)
    expect(step.help).to eq('3 track points')
    expect(entity.abilities.first.count_this_or).to eq(1)
  end

  it 'restores one ability use each OR without step resets restoring or accumulating uses' do
    step = prepare_track!
    ability = entity.abilities.first
    lay!(step, terrain_hex!)
    expect(ability.count_this_or).to eq(1)
    step.setup
    step.setup
    expect(step.help).to eq('3 track points')
    expect(ability.count_this_or).to eq(1)
    next_operation!
    step = next_operation!
    expect(ability.count_this_or).to eq(0)
    expect(ability).to be_used
    expect(step.help).to eq('3 track points + 1 blue-terrain point (yellow lays only)')
    lay!(step, terrain_hex!)
    lay!(step, terrain_hex!)

    expect(step.help).to eq('2 track points')
    expect(ability.count_this_or).to eq(1)
  end

  it 'resets the original inherited ability for its major in the next OR (§6.2)' do
    ability = entity.abilities.first
    major = game.corporation_by_id('LNWR')
    major.type = :major
    game.add_minor_charter!(entity, major)
    step = prepare_track!(major)
    lay!(step, terrain_hex!, major)
    expect(major.abilities).to include(ability)
    expect(ability.count_this_or).to eq(1)
    expect(game.zero_point_tile_lays_available?(major)).to be(false)
    step = next_operation!(major)
    expect(ability.count_this_or).to eq(0)
    expect(game.zero_point_tile_lays_available?(major)).to be(true)
    lay!(step, terrain_hex!, major)

    expect(step.help).to eq('6 track points')
    expect(ability.count_this_or).to eq(1)
  end

  it 'transfers the point with the original ability and removes it from the old holder (§6.2, §10.5)' do
    ability = entity.abilities.first
    major = game.corporation_by_id('LNWR')
    major.type = :major
    game.add_minor_charter!(entity, major)

    expect(game.zero_point_tile_lays_available?(major)).to be(true)
    expect(game.zero_point_tile_lays_available?(entity)).to be(false)
    major.remove_ability(ability)
    expect(game.zero_point_tile_lays_available?(major)).to be(false)
    other = game.corporation_by_id('SB')
    other.type = :major
    other.add_ability(ability)
    expect(game.zero_point_tile_lays_available?(other)).to be(true)
  end

  it "does not transfer E's ability to a national (§9.4, §10.5)" do
    ability = entity.abilities.first
    national = game.corporation_by_id('LNWR')
    national.type = :national
    game.add_minor_charter!(entity, national)

    expect(national.abilities).not_to include(ability)
    expect(game.zero_point_tile_lays_available?(national)).to be(false)
  end

  it 'combines E with B upgrade costs and G ordinary tile points' do
    game.phase.next!
    major = game.corporation_by_id('LNWR')
    major.type = :major
    %w[B E G].each { |id| game.add_minor_charter!(game.corporation_by_id(id), major) }
    step = prepare_track!(major)
    hex = terrain_hex!
    tile = step.upgradeable_tiles(major, hex).first
    step.process_lay_tile(Engine::Action::LayTile.new(major, tile: tile, hex: hex, rotation: tile.legal_rotations.first))
    hex.lay(game.tiles.find { |candidate| candidate.name == '7' })
    game.graph.clear
    tile = step.upgradeable_tiles(major, hex).first
    step.process_lay_tile(Engine::Action::LayTile.new(major, tile: tile, hex: hex, rotation: tile.legal_rotations.first))

    expect(step.help).to eq('7 track points')
  end

  %i[medium_start long_endgame].each do |rule|
    context "with #{rule}" do
      let(:game) { new_game(optional_rules: [rule]) }

      it 'retains the extra blue-terrain point' do
        step = prepare_track!
        lay!(step, terrain_hex!)

        expect(step.help).to eq('3 track points')
      end
    end
  end

  it 'does not grant the point to another railroad or require E in UK–France' do
    expect(game.zero_point_tile_lays_available?(game.corporation_by_id('LNWR'))).to be(false)
    scenario = new_game(%w[a b], klass: Engine::Game::G18OEUKFR::Game)

    expect(scenario.zero_point_tile_lays_available?(scenario.corporation_by_id('LNWR'))).to be(false)
  end
  describe 'automatic passing with only the restricted point remaining' do
    def connected_hexes!(hexes)
      allow(game.graph).to receive(:connected_hexes).with(entity).and_return(hexes.to_h { |hex| [hex, [1]] })
    end

    it 'does not consult the graph while ordinary points remain' do
      step = prepare_track!(points_left: 1)
      expect(game).not_to receive(:graph_for_entity)

      expect(step.auto_actions(entity)).to be_nil
    end

    it 'keeps track active when a connected eligible zero-point hex exists' do
      step = prepare_track!(points_left: 0)
      terrain_hex!

      expect(step.auto_actions(entity)).to be_nil
      expect(step.actions(entity)).to eq(%w[lay_tile pass])
      expect(entity.abilities.first.count_this_or).to eq(0)
    end

    it 'offers an automatic pass when the graph has no candidate without mutating the step or ability' do
      step = prepare_track!(points_left: 0)
      connected_hexes!([])
      actions = step.auto_actions(entity)

      expect(actions.map(&:type)).to eq(['pass'])
      expect(actions.first.entity).to eq(entity)
      expect(step).not_to be_passed
      expect(step.actions(entity)).to eq(%w[lay_tile pass])
      expect(entity.abilities.first.count_this_or).to eq(0)
    end

    it 'ignores an eligible hex outside the connected graph' do
      step = prepare_track!(points_left: 0)
      terrain_hex!
      connected_hexes!([game.hex_by_id('J27')])

      expect(step.auto_actions(entity).map(&:type)).to eq(['pass'])
    end

    it 'ignores a connected eligible hex outside the railroad track rights' do
      step = prepare_track!(points_left: 0)
      hex = terrain_hex!
      game.minor_floated_regions['E'] = 'FR'
      connected_hexes!([hex])

      expect(step.auto_actions(entity).map(&:type)).to eq(['pass'])
    end

    it 'ignores a connected blue-terrain upgrade' do
      step = prepare_track!(points_left: 0)
      hex = game.hex_by_id('J29')
      hex.lay(Engine::Tile.from_code('upgrade', :yellow, 'path=a:1,b:4;upgrade=cost:45,terrain:river'))
      connected_hexes!([hex])

      expect(step.auto_actions(entity).map(&:type)).to eq(['pass'])
    end

    it 'ignores a connected blue-terrain metropolis requiring another ordinary point' do
      step = prepare_track!(points_left: 0)
      hex = game.hex_by_id('R55')
      hex.lay(Engine::Tile.from_code('R55', :white, "#{hex.tile.code};upgrade=cost:45,terrain:river"))
      game.minor_floated_regions['E'] = 'AH'
      connected_hexes!([hex])

      expect(step.auto_actions(entity).map(&:type)).to eq(['pass'])
    end

    %i[spent missing wrong_entity no_tokens].each do |condition|
      it "does not consult the graph when #{condition}" do
        step = prepare_track!(points_left: 0)
        entity.abilities.first.use! if condition == :spent
        entity.remove_ability(entity.abilities.first) if condition == :missing
        entity.tokens.clear if condition == :no_tokens
        acting_entity = condition == :wrong_entity ? game.players.first : entity
        expect(game).not_to receive(:graph_for_entity)

        expect(step.auto_actions(acting_entity)).to be_nil
      end
    end

    it 'keeps actions active while loading without consulting the graph' do
      step = prepare_track!(points_left: 0)
      game.instance_variable_set(:@loading, true)
      expect(game).not_to receive(:graph_for_entity)

      expect(step.actions(entity)).to eq(%w[lay_tile pass])
    end

    it 'records and replays the graph-dependent pass after the last ordinary point is spent' do
      later_steps = [Engine::Game::G18OE::Step::BuyTrain]
      step = prepare_track!(points_left: 1, later_steps: later_steps)
      hex = game.hex_by_id('J29')
      tile = step.upgradeable_tiles(entity, hex).first
      action = Engine::Action::LayTile.new(entity, tile: tile, hex: hex, rotation: tile.legal_rotations.first)
      game.process_action(action, add_auto_actions: true).maybe_raise!
      recorded = JSON.parse(JSON.generate(action.to_h))

      expect(recorded.fetch('auto_actions').map { |auto| auto['type'] }).to eq(['pass'])
      expect(step).to be_passed
      expect(game.round.active_step).to be_a(Engine::Game::G18OE::Step::BuyTrain)
      expect(entity.abilities.first.count_this_or).to eq(0)
      replay = new_game
      replay_entity = replay.corporation_by_id('E')
      replay_step = prepare_track!(replay_entity, points_left: 1, prepared_game: replay, later_steps: later_steps)
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
end
