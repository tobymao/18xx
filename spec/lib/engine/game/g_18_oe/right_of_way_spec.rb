# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Right-of-Way (§11.1.9)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:entity) { game.corporation_by_id('D') }
  let(:green_81) { game.tiles.find { |tile| tile.name == '81' } }
  let(:green_82) { game.tiles.find { |tile| tile.name == '82' } }

  def lay!(hex_id, color, code, target = game)
    hex = target.hex_by_id(hex_id)
    hex.lay(Engine::Tile.from_code(hex_id, color, code))
    target.graph.clear
    hex
  end

  def place_token!(railroad, hex)
    city = hex.tile.cities.first
    city.remove_all_reservations!
    city.place_token(railroad, railroad.tokens.first, free: true)
  end

  def place_home!(hex_id, exit, railroad = entity, region: 'SC', target: game)
    target.minor_floated_regions[railroad.id] = region
    place_token!(railroad, lay!(hex_id, :yellow, "city=revenue:10;path=a:_0,b:#{exit}", target))
  end

  def track_step!(railroad = entity, points_left: 2, target: game)
    railroad.owner = target.players.first
    fund!(target, railroad)
    round = Engine::Round::Operating.new(target, [Engine::Game::G18OE::Step::Track], round_num: 1)
    round.entities = [railroad]
    round.instance_variable_set(:@current_operator, railroad)
    enter_round!(target, round)
    step = round_step(round, Engine::Game::G18OE::Step::Track)
    step.instance_variable_get(:@round).tile_points_used = target.tile_point_budget(railroad) - points_left if points_left
    step
  end

  def blocked_home!(railroad = entity, target: game)
    place_home!('B45', 4, railroad, target: target)
    lay!('B47', :yellow, 'path=a:1,b:3', target)
    lay!('C48', :yellow, 'town=revenue:10;path=a:_0,b:2', target)
  end

  def lay_green!(step, tile, rotation, hex_id = 'B47')
    hex = game.hex_by_id(hex_id)
    step.process_lay_tile(Engine::Action::LayTile.new(entity, tile: tile, hex: hex, rotation: rotation))
  end

  describe 'home_connectable?' do
    let(:step) { track_step! }

    it 'follows existing track to another town' do
      place_home!('B45', 4)
      lay!('B47', :yellow, 'path=a:1,b:4')
      lay!('B49', :yellow, 'town=revenue:10;path=a:_0,b:1')

      expect(step.home_connectable?(entity, 0)).to be(true)
    end

    it 'counts a route that is only the home station and a single adjacent town' do
      place_home!('B45', 4)
      lay!('B47', :yellow, 'town=revenue:10;path=a:_0,b:1')

      expect(step.home_connectable?(entity, 0)).to be(true)
    end

    it 'does not cross the sea' do
      place_home!('AC6', 1)
      lay!('AC4', :yellow, 'town=revenue:10;path=a:_0,b:4')

      expect(step.home_connectable?(entity, 3)).to be(false)
    end

    it 'follows a ferry link to a town' do
      place_home!('AA22', 1)
      lay!('AA20', :yellow, 'path=a:4,b:5')
      lay!('AB27', :yellow, 'town=revenue:10;path=a:_0,b:1')

      expect(step.home_connectable?(entity, 0)).to be(true)
    end

    it 'lays yellow on an adjacent blank hex holding a town for one point' do
      place_home!('B45', 4)
      lay!('B47', :white, 'town=revenue:0')

      expect(step.home_connectable?(entity, 0)).to be(false)
      expect(step.home_connectable?(entity, 1)).to be(true)
    end

    it 'chains yellow lays across blank hexes' do
      place_home!('B45', 4)
      lay!('B49', :white, 'town=revenue:0')

      expect(step.home_connectable?(entity, 1)).to be(false)
      expect(step.home_connectable?(entity, 2)).to be(true)
    end

    it 'does not lay outside the track rights' do
      place_home!('B45', 4, region: 'UK')
      lay!('B47', :white, 'town=revenue:0')

      expect(step.home_connectable?(entity, 3)).to be(false)
    end

    it 'lays the home yellow tile when the home city is printed on a blank hex' do
      game.minor_floated_regions[entity.id] = 'SC'
      place_token!(entity, lay!('B45', :white, 'city=revenue:0'))
      lay!('B47', :white, 'town=revenue:0')

      expect(step.home_connectable?(entity, 1)).to be(false)
      expect(step.home_connectable?(entity, 2)).to be(true)
    end

    it 'lays the home yellow tile when the blank home hex has a printed track stub' do
      game.minor_floated_regions[entity.id] = 'SC'
      place_token!(entity, lay!('B45', :white, 'city=revenue:0;path=a:0,b:_0'))
      lay!('C44', :blue, '')
      lay!('B47', :white, 'town=revenue:0')

      expect(step.home_connectable?(entity, 2)).to be(true)
    end

    it 'lays yellow on a blank hex entered along a printed track stub' do
      place_home!('B45', 4)
      lay!('B47', :white, 'path=a:1,b:2')
      lay!('A46', :blue, '')
      lay!('C48', :white, 'town=revenue:0')

      expect(step.home_connectable?(entity, 2)).to be(true)
    end

    it 'finds Barcelona a yellow route to the town next to it and to Palma' do
      barcelona = game.corporation_by_id('CHN')
      place_token!(barcelona, game.hex_by_id('Z27'))

      expect(step.home_connectable?(barcelona, 1)).to be(true)
      expect(step.home_connectable?(barcelona, 2)).to be(true)
    end

    it 'checks a tile that has not been laid yet' do
      place_home!('B45', 4)
      green = Engine::Tile.from_code('B47', :green, 'town=revenue:10;path=a:_0,b:1')

      expect(step.home_connectable?(entity, 0)).to be(false)
      expect(step.home_connectable?(entity, 0, game.hex_by_id('B47') => green)).to be(true)
    end

    it 'is false without a placed home token' do
      expect(step.home_connectable?(entity, 3)).to be(false)
    end
  end

  describe 'green lay' do
    it 'is offered on a yellow hex without a city, only in rotations that connect home' do
      blocked_home!
      step = track_step!
      hex = game.hex_by_id('B47')

      expect(step.potential_tile_colors(entity, hex)).to include(:green)
      tiles = step.upgradeable_tiles(entity, hex)
      expect(tiles.find { |tile| tile.name == '81' }.legal_rotations).to eq([1, 3, 5])
      expect(tiles.map(&:name)).not_to include('82')
    end

    it 'spends all remaining tile points' do
      blocked_home!
      step = track_step!

      lay_green!(step, green_81, 1)

      expect(game.hex_by_id('B47').tile.color).to eq(:green)
      expect(step.help).to eq('0 track points')
    end

    it 'can be laid with a single remaining tile point' do
      blocked_home!
      step = track_step!(points_left: 1)

      expect(step.available_hex(entity, game.hex_by_id('B47'))).to be_truthy
      lay_green!(step, green_81, 1)
      expect(game.hex_by_id('B47').tile.color).to eq(:green)
    end

    it 'rejects a rotation that does not connect home to another town or city' do
      blocked_home!
      step = track_step!

      expect { lay_green!(step, green_82, 0) }.to raise_error(Engine::GameError, /not legally rotated/)
      expect(game.hex_by_id('B47').tile.color).to eq(:yellow)
    end

    it 'costs the normal 2 tile points once Train Phase 3 has begun' do
      blocked_home!
      step = track_step!(points_left: nil)
      game.phase.next!

      lay_green!(step, green_81, 1)

      expect(step.help).to eq('1 track points')
    end

    it 'is not available without a remaining tile point' do
      blocked_home!
      step = track_step!(points_left: 0)

      expect(step.potential_tile_colors(entity, game.hex_by_id('B47'))).not_to include(:green)
      expect { lay_green!(step, green_81, 1) }.to raise_error(Engine::GameError, /Right-of-Way is not available/)
    end

    it 'is not available on a hex with a city' do
      blocked_home!
      step = track_step!

      expect(step.potential_tile_colors(entity, game.hex_by_id('B45'))).not_to include(:green)
    end

    it 'is not available when a route to another town already exists' do
      blocked_home!
      lay!('B47', :yellow, 'path=a:1,b:5')
      step = track_step!

      expect(step.potential_tile_colors(entity, game.hex_by_id('B47'))).not_to include(:green)
    end

    it 'is not available when yellow track within the remaining points could connect' do
      blocked_home!
      lay!('C48', :white, 'town=revenue:0')
      lay!('B47', :white, '')
      lay!('C46', :yellow, 'path=a:0,b:2')
      step = track_step!

      expect(step.potential_tile_colors(entity, game.hex_by_id('C46'))).not_to include(:green)
      expect { lay_green!(step, green_81, 0, 'C46') }.to raise_error(Engine::GameError, /Right-of-Way is not available/)
    end

    it 'is not available after the railroad has operated, even while loading' do
      blocked_home!
      step = track_step!
      entity.operating_history[[1, 1]] = Engine::OperatingInfo.new([], nil, 0, 0)

      expect(step.potential_tile_colors(entity, game.hex_by_id('B47'))).not_to include(:green)
      game.instance_variable_set(:@loading, true)
      expect { lay_green!(step, green_81, 1) }.to raise_error(Engine::GameError, /Right-of-Way is not available/)
    end

    it 'is not available in a two-player game' do
      two_player = new_game(%w[a b])
      railroad = two_player.corporation_by_id('D')
      blocked_home!(railroad, target: two_player)
      step = track_step!(railroad, target: two_player)

      expect(step.potential_tile_colors(railroad, two_player.hex_by_id('B47'))).not_to include(:green)
    end

    context 'in an Aggressive Game' do
      let(:game) { new_game(optional_rules: [:aggressive_game]) }

      it 'bars early green lays in the tile picker and on submission or replay' do
        blocked_home!
        step = track_step!
        hex = game.hex_by_id('B47')

        expect(step.potential_tile_colors(entity, hex)).not_to include(:green)
        expect { lay_green!(step, green_81, 1) }.to raise_error(Engine::GameError, /Right-of-Way is not available/)
        game.instance_variable_set(:@loading, true)
        expect { lay_green!(step, green_81, 1) }.to raise_error(Engine::GameError, /Right-of-Way is not available/)
        expect(hex.tile.color).to eq(:yellow)
      end

      it 'allows a normal green upgrade when Train Phase 3 begins' do
        blocked_home!
        step = track_step!(points_left: nil)
        game.phase.next!
        hex = game.hex_by_id('B47')

        expect(step.potential_tile_colors(entity, hex)).to include(:green)
        lay_green!(step, green_81, 1)
        expect(hex.tile.color).to eq(:green)
        expect(step.help).to eq('1 track points')
      end
    end
  end
end
