# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Brandt & Brandau, Engineers (§14.9)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }
  let(:bbe) { game.company_by_id('BBE') }
  let(:lnwr) { start_major!(game, 'LNWR', player) }
  let(:hex) { game.hex_by_id('J23') }

  before { give_company!(player, bbe) }

  def operating_round_for(entity)
    round = enter_round!(game, game.operating_round(1))
    round.entities = [entity]
    round.instance_variable_set(:@current_operator, entity)
    round
  end

  def brandt_step(round)
    round_step(round, Engine::Game::G18OE::Step::BrandtTrack)
  end

  def track_step(round)
    round_step(round, Engine::Game::G18OE::Step::Track)
  end

  def brandt_lay!(target, round: @round)
    tile = brandt_step(round).upgradeable_tiles(bbe, target).first
    action = Engine::Action::LayTile.new(bbe, tile: tile, hex: target, rotation: tile.legal_rotations.first)
    brandt_step(round).process_lay_tile(action)
    action
  end

  context 'with LNWR operating' do
    before do
      @round = operating_round_for(lnwr)
      allow(game).to receive(:cross_water_tile_fee).and_return(0)
    end

    it "offers lay_tile to the owner's RR during Track" do
      expect(@round.actions_for(bbe)).to include('lay_tile')
    end

    it "offers nothing for another player's RR" do
      other = start_major!(game, 'GWR', game.players.last)
      round = operating_round_for(other)

      expect(round.actions_for(bbe)).to be_empty
    end

    it 'places the token and lays a yellow tile with no terrain cost, spending a tile point' do
      cash = lnwr.cash
      brandt_lay!(hex)

      expect(hex.tile.color).to eq(:yellow)
      expect(hex.assigned?('BBE')).to be(true)
      expect(lnwr.cash).to eq(cash)
      expect(track_step(@round).help).to eq('5 track points')
    end

    it 'rejects a hex without rough terrain' do
      flat = game.hex_by_id('X77')

      expect(flat.tile.color).to eq(:white)
      expect(flat.original_tile.terrain).to be_empty
      expect(track_step(@round).tracker_available_hex(lnwr, flat)).not_to be_nil
      expect(game.brandt_hex?(flat)).to be(false)
      action = Engine::Action::LayTile.new(bbe, tile: game.tiles.find { |t| t.color == :yellow }, hex: flat, rotation: 0)
      expect { brandt_step(@round).process_lay_tile(action) }
        .to raise_error(Engine::GameError, /cannot hold a Brandt & Brandau token/)
    end

    it 'rejects a hex that already holds a tile' do
      brandt_lay!(hex)

      expect(game.brandt_hex?(hex)).to be(false)
      expect(brandt_step(@round).available_hex(bbe, hex)).to be_nil
    end

    it 'rejects a hex not connected to the operating RR' do
      far = game.hex_by_id('U36')

      expect(game.brandt_hex?(far)).to be(true)
      expect(brandt_step(@round).available_hex(bbe, far)).to be_nil
    end

    it 'keeps the token when the yellow tile is upgraded to green' do
      game.phase.next!
      brandt_lay!(hex)
      cash = lnwr.cash
      green = track_step(@round).upgradeable_tiles(lnwr, hex).first
      action = Engine::Action::LayTile.new(lnwr, tile: green, hex: hex, rotation: green.legal_rotations.first)
      track_step(@round).process_lay_tile(action)

      expect(hex.tile.color).to eq(:green)
      expect(hex.assigned?('BBE')).to be(true)
      expect(lnwr.cash).to eq(cash)
    end

    it 'allows two lays in one OR across two RRs and refuses a third' do
      gwr = start_major!(game, 'GWR', player)
      brandt_lay!(hex)
      expect(@round.actions_for(bbe)).to include('lay_tile')

      brandt_lay!(game.hex_by_id('I26'))
      expect(@round.actions_for(bbe)).to be_empty

      second = operating_round_for(gwr)
      expect(second.actions_for(bbe)).to be_empty
    end

    it 'allows lays again in a new operating round' do
      brandt_lay!(hex)
      brandt_lay!(game.hex_by_id('I26'))
      bbe.reset_ability_count_this_or!

      expect(operating_round_for(lnwr).actions_for(bbe)).to include('lay_tile')
    end

    it 'pays 25 after the third placement and turns face down with no revenue after the fourth' do
      [hex, game.hex_by_id('I26'), game.hex_by_id('B43')].each do |target|
        bbe.reset_ability_count_this_or!
        game.abilities(bbe, :tile_lay, time: 'owning_player_track').use!
        game.place_brandt_token!(target)
      end
      expect(game.face_down_private?(bbe)).to be(false)
      expect(bbe.revenue).to eq(25)

      bbe.reset_ability_count_this_or!
      game.abilities(bbe, :tile_lay, time: 'owning_player_track').use!
      game.place_brandt_token!(game.hex_by_id('U36'))

      expect(game.face_down_private?(bbe)).to be(true)
      expect(bbe.revenue).to eq(0)
      expect(game.brandt_hexes.map(&:name)).to contain_exactly('J23', 'I26', 'B43', 'U36')
    end

    it 'charges the cross-water fee to the operating RR' do
      allow(game).to receive(:cross_water_tile_fee).and_call_original
      target = game.hex_by_id('I26')
      cash = lnwr.cash
      action = brandt_lay!(target)

      expect(action.extra_cost).to be_positive
      expect(cash - lnwr.cash).to eq(action.extra_cost)
    end

    it 'replays a recorded lay using the recorded cross-water fee' do
      target = game.hex_by_id('I26')
      tile = brandt_step(@round).upgradeable_tiles(bbe, target).first
      action = Engine::Action::LayTile.new(bbe, tile: tile, hex: target, rotation: tile.legal_rotations.first, extra_cost: 10)
      cash = lnwr.cash
      allow(game).to receive(:loading).and_return(true)
      brandt_step(@round).process_lay_tile(action)

      expect(target.assigned?('BBE')).to be(true)
      expect(cash - lnwr.cash).to eq(10)
    end
  end

  context 'with Minor F operating' do
    let(:minor_f) { game.corporation_by_id('F') }

    before do
      minor_f.owner = player
      fund!(game, minor_f)
      game.minor_floated_regions['F'] = 'UK'
      city = game.hex_by_id('J27').tile.cities.first
      city.remove_all_reservations!
      city.place_token(minor_f, minor_f.tokens.first, free: true)
      @round = operating_round_for(minor_f)
    end

    it "costs no tile point because of Minor F's green-terrain point" do
      brandt_lay!(hex)

      expect(hex.assigned?('BBE')).to be(true)
      expect(track_step(@round).help).to eq('3 track points')
      expect(minor_f.abilities.first.count_this_or).to eq(1)
    end
  end

  describe 'exclusive use' do
    let(:liverpool_hex) { game.hex_by_id('J25') }
    let(:other_owner) { game.players.last }
    let(:mover) { start_major!(game, 'GWR', other_owner) }

    before do
      lnwr
      mover
      liverpool_hex.assign!('BBE')
      game.clear_graph
    end

    def reachable_hexes(corporation)
      game.graph.connected_paths(corporation).keys.map { |path| path.hex.id }.uniq
    end

    it "lets the owner's railroad trace through the token hex" do
      expect(game.brandt_blocked?(lnwr, liverpool_hex)).to be(false)
      expect(reachable_hexes(lnwr)).to include('J25', 'I20')
    end

    def give_bbe_to!(new_owner)
      bbe.owner.companies.delete(bbe)
      give_company!(new_owner, bbe)
      game.clear_graph
    end

    it "stops another player's railroad tracing through the token hex" do
      give_bbe_to!(other_owner)

      expect(game.brandt_blocked?(lnwr, liverpool_hex)).to be(true)
      expect(game.graph_skip_paths(lnwr).keys.map(&:hex).uniq).to eq([liverpool_hex])
      expect(reachable_hexes(lnwr)).not_to include('J25', 'I20')
    end

    it 'offers the token hex city to the owner but not to another railroad' do
      liverpool = liverpool_hex.tile.cities.first

      expect(game.graph.tokenable_cities(lnwr)).to include(liverpool)
      give_bbe_to!(other_owner)
      expect(game.graph.tokenable_cities(lnwr)).not_to include(liverpool)
    end

    it 'does not block hexes without a token' do
      expect(game.brandt_blocked?(mover, game.hex_by_id('J27'))).to be(false)
      expect(game.graph_skip_paths(lnwr)).to be_nil
    end

    it "refuses another railroad's track lay on the token hex but not the owner's" do
      step = track_step(operating_round_for(lnwr))

      expect(step.tracker_available_hex(lnwr, liverpool_hex)).not_to be_nil
      give_bbe_to!(other_owner)
      expect(step.tracker_available_hex(lnwr, liverpool_hex)).to be_nil
    end

    context 'with routes' do
      let(:manchester) { game.hex_by_id('J27').tile.cities.first }
      let(:liverpool) { liverpool_hex.tile.cities.first }

      def route_for(corporation)
        train = game.trains.find { |t| t.name == '3' && !t.owner.is_a?(Engine::Corporation) }
        game.buy_train(corporation, train, :free)
        route = Engine::Route.new(game, game.phase, train, routes: [])
        route.routes = [route]
        route.touch_node(manchester)
        route.touch_node(liverpool)
        route
      end

      it "raises for another player's railroad running through the hex" do
        route = route_for(mover)

        expect { game.check_other(route) }.to raise_error(Engine::GameError, /Brandt & Brandau/)
      end

      it "accepts the owner's railroad running through the hex" do
        route = route_for(lnwr)

        expect { game.check_other(route) }.not_to raise_error
      end
    end

    it 'flips the block when the private changes hands and the graph is cleared' do
      expect(reachable_hexes(lnwr)).to include('J25')

      bbe.owner.companies.delete(bbe)
      give_company!(other_owner, bbe)
      game.clear_graph

      expect(game.brandt_blocked?(lnwr, liverpool_hex)).to be(true)
      expect(reachable_hexes(lnwr)).not_to include('J25')
    end

    it 'clears the graph when the private is sold to another player' do
      expect(reachable_hexes(lnwr)).to include('J25')
      step = round_step(stock_round!(game), Engine::Game::G18OE::Step::BuySellParShares)
      allow(step).to receive(:purchasable_companies).and_return([bbe])
      allow(step).to receive(:validate_trade_price!)
      fund!(game, other_owner)
      step.process_buy_company(Engine::Action::BuyCompany.new(other_owner, company: bbe, price: 10))

      expect(bbe.owner).to eq(other_owner)
      expect(reachable_hexes(lnwr)).not_to include('J25')
    end

    it 'flips the block when a presidency change and a new operating round occur without an explicit clear' do
      expect(reachable_hexes(lnwr)).to include('J25')
      game.share_pool.transfer_shares(lnwr.presidents_share.to_bundle, other_owner)
      expect(lnwr.owner).to eq(other_owner)
      expect(reachable_hexes(lnwr)).to include('J25')

      game.new_operating_round

      expect(game.brandt_blocked?(lnwr, liverpool_hex)).to be(true)
      expect(reachable_hexes(lnwr)).not_to include('J25')
    end
  end
end
