# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE lay track (§11.1)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }

  def operating!
    enter_round!(game, game.operating_round(1))
  end

  def cost(hex_id, corp_id)
    hex = game.hex_by_id(hex_id)
    corporation = game.corporation_by_id(corp_id)
    game.upgrade_cost(hex.tile, hex, corporation, corporation)
  end

  def minor_in(minor_id, zone)
    game.minor_floated_regions[minor_id] = zone
    minor_id
  end

  def wien_with_home!(round)
    lay_first_legal!(game, round, 'R55')
    act!(round, Engine::Action::PlaceToken.new(game.corporation_by_id('SB'), city: game.hex_by_id('R55').tile.cities[1], slot: 0))
  end

  it 'budgets tile points by railroad type (§11.1)' do
    entity = Struct.new(:type, :abilities) { def corporation? = true }
    budgets = %i[minor regional major national].to_h { |type| [type, game.tile_point_budget(entity.new(type, []))] }

    expect(budgets).to eq(minor: 3, regional: 3, major: 6, national: 9)
  end

  it 'gives a regional 3 tile points' do
    start_regional!(game, 'LNWR', player)
    round = operating!

    expect(round.active_step.help).to eq('3 track points')
  end

  it 'charges 1 point for a yellow tile' do
    start_regional!(game, 'LNWR', player)
    round = operating!
    lay_first_legal!(game, round, 'J29')

    expect(round.active_step.help).to eq('2 track points')
  end

  it 'charges 2 points for a yellow metropolis and lets SB choose its home station (§11.1.9)' do
    sb = start_regional!(game, 'SB', player)
    round = operating!
    lay_first_legal!(game, round, 'R55')

    expect(round.active_step).to be_a(Engine::Step::HomeToken)

    act!(round, Engine::Action::PlaceToken.new(sb, city: game.hex_by_id('R55').tile.cities[1], slot: 0))

    expect(round.active_step.help).to eq('1 track points')
    expect(game.hex_by_id('R55').tile.cities[1].tokened_by?(sb)).to be(true)
  end

  it 'charges 2 points for an upgrade' do
    game.phase.next!
    start_regional!(game, 'LNWR', player)
    round = operating!
    lay_first_legal!(game, round, 'J27')

    expect(round.active_step.help).to eq('1 track points')
  end

  it 'refuses a lay that costs more points than remain' do
    game.phase.next!
    start_regional!(game, 'SB', player)
    round = operating!
    wien_with_home!(round)
    tile = game.tiles.find { |t| t.name == 'OE12' }
    action = Engine::Action::LayTile.new(game.corporation_by_id('SB'), tile: tile, hex: game.hex_by_id('R55'), rotation: 0)

    expect { round.process_action(action) }.to raise_error(Engine::GameError, /Cannot lay an upgrade now/)
  end

  it 'gives a major 6 tile points' do
    start_major!(game, 'LNWR', player)
    round = operating!

    expect(round.active_step.help).to eq('6 track points')
  end

  describe 'upgrading to all legally usable sides (§11.1.7)' do
    let!(:operator) { start_major!(game, 'LNWR', player) }
    let(:round) { operating! }

    def tile_named(name)
      game.tiles.find { |tile| tile.name == name }
    end

    def put_tile!(hex, name, rotation)
      tile = tile_named(name)
      tile.rotate!(rotation)
      game.update_tile_lists(tile, hex.tile)
      hex.lay(tile)
      tile
    end

    def place_track_token!(hex)
      hex.tile.cities.first.place_token(operator, operator.next_token, free: true, check_tokenable: false)
    end

    def advance_to_tile_color!(color)
      game.phase.next! until game.phase.tiles.include?(color)
      game.national_formation_done!(game.national_formation_player) while game.national_formation_player
    end

    def offered_tiles(hex, operating_round = round)
      operating_round.active_step.upgradeable_tiles(operator, hex)
    end

    def upgrade_action(hex, name, rotation)
      Engine::Action::LayTile.new(operator, tile: tile_named(name), hex: hex, rotation: rotation)
    end

    context 'at the double town on J77' do
      let(:hex) { game.hex_by_id('J77') }

      before do
        city_hex = game.hex_by_id('I76')
        put_tile!(city_hex, '57', 5)
        place_track_token!(city_hex)
      end

      it 'offers only the brown double town that reaches all six usable sides and rejects a partial lay', :aggregate_failures do
        advance_to_tile_color!(:brown)
        old_tile = put_tile!(hex, 'OE9', 0)

        expect(offered_tiles(hex).map(&:name)).to eq(['OE22'])
        expect { round.process_action(upgrade_action(hex, 'OE21', 0)) }
          .to raise_error(Engine::GameError, /not legally rotated/)
        expect(hex.tile).to equal(old_tile)
      end

      it 'disallows the brown upgrade when the tile that reaches all six sides is unavailable' do
        advance_to_tile_color!(:brown)
        put_tile!(hex, 'OE9', 0)
        game.tiles.reject! { |tile| tile.name == 'OE22' }

        expect(offered_tiles(hex)).to be_empty
      end

      it 'allows a green double town with fewer exits than usable sides' do
        advance_to_tile_color!(:green)
        put_tile!(hex, 'OE1', 2)

        expect(offered_tiles(hex).map(&:name)).to include('OE9')
      end
    end

    it 'requires the brown grand city tile that reaches all six usable sides' do
      advance_to_tile_color!(:brown)
      hex = game.hex_by_id('N35')
      put_tile!(hex, '208', 0)
      place_track_token!(hex)

      expect(offered_tiles(hex).map(&:name)).to eq(['OE33'])

      game.tiles.reject! { |tile| tile.name == 'OE33' }

      expect(offered_tiles(hex)).to be_empty
    end

    it 'rejects a partial gray upgrade at a normal city and accepts the six-sided upgrade' do
      advance_to_tile_color!(:gray)
      hex = game.hex_by_id('J27')
      old_tile = put_tile!(hex, 'OE24', 0)

      expect(offered_tiles(hex).map(&:name)).to eq(['OE36'])
      expect { round.process_action(upgrade_action(hex, 'OE34', 0)) }
        .to raise_error(Engine::GameError, /not legally rotated/)
      expect(hex.tile).to equal(old_tile)

      round.process_action(upgrade_action(hex, 'OE36', 0))

      expect(hex.tile.name).to eq('OE36')
      expect(hex.tile.cities.first.tokened_by?(operator)).to be(true)
    end

    it 'allows brown normal city upgrades with fewer exits than usable sides' do
      advance_to_tile_color!(:brown)
      hex = game.hex_by_id('J27')
      put_tile!(hex, '205', 1)

      expect(offered_tiles(hex).map(&:name)).to include('OE24')
    end

    it 'uses Birmingham’s labeled brown and gray tiles to reach all six sides' do
      advance_to_tile_color!(:brown)
      hex = game.hex_by_id('K26')
      put_tile!(hex, 'OE12', 0)
      place_track_token!(hex)

      expect(offered_tiles(hex).map(&:name)).to eq(['OE26'])
      round.process_action(upgrade_action(hex, 'OE26', 0))
      expect(hex.tile.exits).to match_array(Engine::Tile::ALL_EDGES)

      advance_to_tile_color!(:gray)
      next_round = operating!

      expect(offered_tiles(hex, next_round).map(&:name)).to eq(['OE37'])
      next_round.process_action(upgrade_action(hex, 'OE37', 0))
      expect(hex.tile.exits).to match_array(Engine::Tile::ALL_EDGES)
    end

    { '18OE' => Engine::Game::G18OE::Game, 'UK–France' => Engine::Game::G18OEUKFR::Game }.each do |title, klass|
      context "in #{title}" do
        let(:game) { new_game(klass: klass) }

        it 'preserves the ferry exit when Lille upgrades to brown and gray with four usable sides' do
          advance_to_tile_color!(:brown)
          hex = game.hex_by_id('N31')
          put_tile!(hex, '207', 4)
          place_track_token!(hex)

          expect(offered_tiles(hex).map(&:name)).to eq(['OE31'])
          round.process_action(upgrade_action(hex, 'OE31', 5))
          expect(hex.tile.exits).to match_array([0, 1, 4, 5])

          advance_to_tile_color!(:gray)
          next_round = operating!

          expect(offered_tiles(hex, next_round).map(&:name)).to eq(['OE42'])
          next_round.process_action(upgrade_action(hex, 'OE42', 5))
          expect(hex.tile.exits).to match_array([0, 1, 4, 5])
        end
      end
    end
  end

  it 'keeps a regional inside its track rights zone (§11.1.4)' do
    lnwr = start_regional!(game, 'LNWR', player)
    round = operating!

    expect(round.active_step.tracker_available_hex(lnwr, game.hex_by_id('Q30'))).to be_nil
    expect(game.hex_within_national_region?(lnwr, game.hex_by_id('J29'))).to be(true)
  end

  it 'lets both zones build in a border hex (PB 4.7)' do
    nancy = game.hex_by_id('Q38')

    expect(game.hex_within_national_region?(game.corporation_by_id('KBS'), nancy)).to be(true)
    expect(game.hex_within_national_region?(game.corporation_by_id('PLM'), nancy)).to be(true)
  end

  it 'does not restrict majors to a zone (§11.1.4)' do
    major = start_major!(game, 'LNWR', player)

    expect(game.hex_within_national_region?(major, game.hex_by_id('Q30'))).to be(true)
  end

  it 'charges full terrain cost outside the discount zones (§11.1.5)' do
    expect(cost('M30', 'LNWR')).to eq(45)
    expect(cost('T23', 'PLM')).to eq(60)
  end

  it 'discounts terrain 20% inside Spain, Italy, Scandinavia and Russia (§11.1.5)' do
    expect([cost('X23', 'CHN'), cost('V9', 'CHN'), cost('Z23', 'CHN'), cost('U44', 'SFAI')]).to eq([96, 36, 24, 96])
  end

  it 'does not discount terrain in another zone' do
    expect(cost('R39', 'CHN')).to eq(30)
  end

  it 'discounts a hex that is only partly inside the zone (§11.1.5)' do
    expect(cost('W22', 'CHN')).to eq(96)
  end

  it 'gives a major the zone discount of a merged minor (§10.5, §11.1.4)' do
    major = start_major!(game, 'LNWR', player)
    minor = game.corporation_by_id(minor_in('B', 'SP'))
    game.merged_minors[major] << minor

    expect(cost('X23', 'LNWR')).to eq(96)
  end

  it 'does not stack a merged minor\'s zone with the same home zone (§11.1.5)' do
    major = start_major!(game, 'CHN', player)
    game.merged_minors[major] << game.corporation_by_id(minor_in('B', 'SP'))

    expect(cost('X23', 'CHN')).to eq(96)
  end

  it 'raises the discount to 50% for F on mountains and hills (§11.1.5, §15.6)' do
    f = minor_in('F', 'SP')

    expect([cost('X23', f), cost('V9', f), cost('Z23', f)]).to eq([60, 22, 24])
  end

  it 'raises the discount to 50% for E on water, rivers and lakes (§11.1.5, §15.5)' do
    e = minor_in('E', 'SP')

    expect([cost('Z23', e), cost('X23', e)]).to eq([15, 96])
    expect(cost('E52', minor_in('E', 'SC'))).to eq(22)
  end

  describe 'Minor E/F terrain cash discounts (§15.5–15.6)' do
    def major_with_terrain_minor!(minor_id, zone = 'UK')
      major = game.corporation_by_id('LNWR')
      major.type = :major
      minor = game.corporation_by_id(minor_in(minor_id, zone))
      game.add_minor_charter!(minor, major)
      game.close_corporation(minor, quiet: true)
      major
    end

    it 'discounts E water, river and lake construction by 33%, rounding the cost down' do
      e = minor_in('E', 'UK')

      expect([cost('K42', e), cost('M30', e), cost('M34', e)]).to eq([20, 30, 40])
    end

    it 'discounts F hill and mountain construction by 33%, using the stated 0.67 multiplier' do
      f = minor_in('F', 'UK')

      expect([cost('S38', f), cost('O54', f), cost('U38', f)]).to eq([30, 40, 80])
    end

    it 'keeps exact whole-pound amounts from the printed 0.67 multiplier' do
      e = game.corporation_by_id('E')
      tile = Engine::Tile.from_code('terrain', :white, 'upgrade=cost:100,terrain:river')
      hex = game.hex_by_id('M30')

      expect(game.upgrade_cost(tile, hex, e, e)).to eq(67)
    end

    it 'leaves nonmatching terrain at full cost or the ordinary zone discount' do
      e = minor_in('E', 'SP')
      f = minor_in('F', 'SP')

      expect([cost('O54', e), cost('X23', e), cost('M30', f), cost('Z23', f)]).to eq([60, 96, 45, 24])
    end

    it 'transfers E cash discounts to its acquiring major (§6.2, §10.5)' do
      major_with_terrain_minor!('E', 'SP')

      expect([cost('M30', 'LNWR'), cost('Z23', 'LNWR')]).to eq([30, 15])
    end

    it 'transfers F cash discounts to its acquiring major (§6.2, §10.5)' do
      major_with_terrain_minor!('F', 'SP')

      expect([cost('U38', 'LNWR'), cost('V9', 'LNWR')]).to eq([80, 22])
    end

    it 'keeps both terrain benefits without stacking the discounts (§11.1.5)' do
      major_with_terrain_minor!('E', 'SP')
      major_with_terrain_minor!('F', 'SP')

      expect([cost('M30', 'LNWR'), cost('U38', 'LNWR'), cost('Z23', 'LNWR'), cost('X23', 'LNWR')])
        .to eq([30, 80, 15, 60])
    end

    it 'removes the cash benefit when the transferred ability is removed' do
      ability = game.corporation_by_id('E').abilities.first
      major = major_with_terrain_minor!('E', 'SP')
      major.remove_ability(ability)

      expect([cost('M30', 'LNWR'), cost('Z23', 'LNWR')]).to eq([45, 24])
    end

    it 'moves the cash benefit with the original ability' do
      ability = game.corporation_by_id('E').abilities.first
      major = major_with_terrain_minor!('E')
      other = game.corporation_by_id('SB')
      other.type = :major
      major.remove_ability(ability)
      other.add_ability(ability)

      expect([cost('M30', 'LNWR'), cost('M30', 'SB')]).to eq([45, 30])
    end

    it 'does not leave a cash benefit on the minor after transferring its ability' do
      major_with_terrain_minor!('E', 'SP')

      expect([cost('M30', 'E'), cost('Z23', 'E')]).to eq([45, 24])
    end

    it 'charges nationals no terrain cost despite inherited minor benefits (§11.1.5)' do
      major = major_with_terrain_minor!('E')
      major.type = :national

      expect(cost('M30', 'LNWR')).to eq(0)
    end

    it 'does not charge terrain again when upgrading a laid tile (§11.1.5)' do
      major = major_with_terrain_minor!('E')
      hex = game.hex_by_id('M30')
      tile = game.tiles.find { |candidate| candidate.name == '7' }
      hex.lay(tile)

      expect(game.upgrade_cost(tile, hex, major, major)).to eq(0)
    end

    it 'does not require absent E/F abilities in the UK–France scenario' do
      scenario = new_game(%w[a b], klass: Engine::Game::G18OEUKFR::Game)
      hex = scenario.hex_by_id('M30')
      regional = scenario.corporation_by_id('LNWR')

      expect(scenario.upgrade_cost(hex.tile, hex, regional, regional)).to eq(45)
    end

    it 'lists the terrain and zone discounts separately and explains their combined rate' do
      %w[E F].each do |id|
        description = game.corporation_by_id(id).abilities.first.description

        expect(description).to include('Terrain discount: 33%', 'Track-rights zone discount: 20%',
                                       'combine to give a 50% discount', 'down to whole pounds')
        if id == 'E'
          expect(description).to include('Each OR, 1 extra tile point for a yellow lay on blue terrain')
        else
          expect(description).to include('Each OR, 1 extra tile point for a yellow lay on green terrain')
        end
      end
    end

    %i[medium_start long_endgame].each do |rule|
      it "preserves E/F cash discounts with #{rule}" do
        variant = new_game(optional_rules: [rule])
        major = variant.corporation_by_id('LNWR')
        major.type = :major
        variant.minor_floated_regions['E'] = 'SP'
        variant.add_minor_charter!(variant.corporation_by_id('E'), major)
        river = variant.hex_by_id('M30')
        water = variant.hex_by_id('Z23')

        expect(variant.upgrade_cost(river.tile, river, major, major)).to eq(30)
        expect(variant.upgrade_cost(water.tile, water, major, major)).to eq(15)
      end
    end
  end

  describe 'Minor B upgrade discount (§15.2, §10.5)' do
    def major_with_b!
      major = start_major!(game, 'LNWR', player)
      game.add_minor_charter!(game.corporation_by_id('B'), major)
      major
    end

    def prepared_step(entity, hex_id, tile_name, points_left)
      game.phase.next!
      hex = game.hex_by_id(hex_id)
      hex.lay(game.tiles.find { |t| t.name == tile_name }) if tile_name
      round = operating!
      step = round.active_step
      step.instance_variable_set(:@points_used, game.tile_point_budget(entity) - points_left)
      [round, step, hex]
    end

    def upgrade!(round, entity, hex, tile_name)
      round.active_step.upgradeable_tiles(entity, hex)
      tile = game.tiles.find { |t| t.name == tile_name }
      round.process_action(Engine::Action::LayTile.new(entity, tile: tile, hex: hex, rotation: tile.legal_rotations.first))
    end

    it 'charges B one point for a plain track upgrade' do
      major = major_with_b!
      round, step, hex = prepared_step(major, 'J29', '7', 3)
      upgrade!(round, major, hex, '80')

      expect(step.help).to eq('2 track points')
    end

    it 'charges B one point for a town upgrade' do
      major = major_with_b!
      round, step, hex = prepared_step(major, 'J29', '3', 3)
      upgrade!(round, major, hex, '143')

      expect(step.help).to eq('2 track points')
    end

    it 'lets B upgrade plain track with one tile point left' do
      major = major_with_b!
      round, step, hex = prepared_step(major, 'J29', '7', 1)

      expect(step.tracker_available_hex(major, hex)).not_to be_nil
      upgrade!(round, major, hex, '80')
      expect(game.hex_by_id('J29').tile.name).to eq('80')
    end

    it 'does not let B upgrade with no tile points left' do
      major = major_with_b!
      _round, step, hex = prepared_step(major, 'J29', '7', 0)

      expect(step.tracker_available_hex(major, hex)).to be_nil
    end

    it 'keeps candidate tile rotations when checking hex availability' do
      major = major_with_b!
      round, step, hex = prepared_step(major, 'J29', '7', 3)
      step.upgradeable_tiles(major, hex)
      tile = game.tiles.find { |t| t.name == '80' }
      rotations = tile.legal_rotations
      expect(rotations.size).to be > 1
      tile.rotate!(rotations.last)

      round.active_step.available_hex(major, hex)

      expect(tile.rotation).to eq(rotations.last)
    end

    it 'keeps the two point upgrade cost for a railroad without B' do
      major = start_major!(game, 'LNWR', player)
      round, step, hex = prepared_step(major, 'J29', '7', 1)

      expect(step.tracker_available_hex(major, hex)).to be_nil
      step.instance_variable_set(:@points_used, 3)
      upgrade!(round, major, hex, '80')
      expect(step.help).to eq('1 track points')
    end

    it 'keeps the two point cost for B on a city upgrade' do
      major = major_with_b!
      round, step, hex = prepared_step(major, 'J27', nil, 1)

      expect(step.tracker_available_hex(major, hex)).to be_nil
      step.instance_variable_set(:@points_used, 3)
      upgrade!(round, major, hex, '205')
      expect(step.help).to eq('1 track points')
    end

    it 'keeps the four point cost for B on a metropolis upgrade' do
      major = major_with_b!
      _round, step, hex = prepared_step(major, 'R55', nil, 3)
      hex.lay(game.tiles.find { |t| t.name == 'OE4' })

      expect(step.tracker_available_hex(major, hex)).to be_nil
    end

    it 'charges B one point for a yellow tile' do
      major = major_with_b!
      round, step, = prepared_step(major, 'J29', nil, 6)
      lay_first_legal!(game, round, 'J29')

      expect(step.help).to eq('5 track points')
    end

    it 'gives the discount only to the major that received B (§10.5)' do
      major = major_with_b!
      other = start_major!(game, 'SB', player)
      _round, step, hex = prepared_step(major, 'J29', '7', 1)

      expect(step.tracker_available_hex(major, hex)).not_to be_nil
      step.instance_variable_set(:@points_used, game.tile_point_budget(other) - 1)
      expect(step.tracker_available_hex(other, hex)).to be_nil
    end
  end
end
