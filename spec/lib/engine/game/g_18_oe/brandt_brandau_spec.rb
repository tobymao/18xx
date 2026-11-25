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

  before do
    game.minor_merged
    give_company!(player, bbe)
  end

  def operating_round_for(entity)
    round = enter_round!(game, game.operating_round(1))
    round.entities = [entity]
    round.instance_variable_set(:@current_operator, entity)
    round
  end

  def brandt_step(round)
    round_step(round, Engine::Game::G18OE::Step::SpecialTrack)
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

    it 'computes potential tile colors for the private in phase 2 without raising' do
      expect(game.phase.name).to eq('2')
      expect { brandt_step(@round).potential_tile_colors(bbe, hex) }.not_to raise_error
    end

    it 'offers only legal yellow upgrades for the hex it is laid on' do
      names = brandt_step(@round).upgradeable_tiles(bbe, hex).map(&:name)

      expect(names).to contain_exactly('4', '58')
    end

    it 'shows the printed terrain on the B&B tile (§14.9)' do
      brandt_lay!(hex)

      expect(hex.tile.upgrades.map(&:cost)).to eq([45])
      expect(hex.tile.upgrades.map(&:tile).uniq).to eq([hex.tile])
    end

    it 'carries the terrain to the upgraded tile without charging it (§14.9)' do
      game.phase.next!
      brandt_lay!(hex)
      yellow = hex.tile
      expect(game.upgrade_cost(yellow, hex, lnwr, lnwr)).to eq(0)
      green = track_step(@round).upgradeable_tiles(lnwr, hex).first
      cash = lnwr.cash
      action = Engine::Action::LayTile.new(lnwr, tile: green, hex: hex, rotation: green.legal_rotations.first)
      track_step(@round).process_lay_tile(action)

      expect(hex.tile).to eq(green)
      expect(hex.tile.upgrades.map(&:cost)).to eq([45])
      expect(yellow.upgrades).to be_empty
      expect(lnwr.cash).to eq(cash)
    end

    it 'clears the terrain from the tile once the token is removed (§14.9)' do
      brandt_lay!(hex)
      expect(hex.tile.upgrades).not_to be_empty
      game.remove_brandt_token!(lnwr, hex)

      expect(hex.tile.upgrades).to be_empty
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

      @round.instance_variable_set(:@current_operator, gwr)
      game.clear_graph
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
  describe 'removal' do
    let(:other_owner) { game.players.last }
    let(:token_hex) { game.hex_by_id('J23') }

    def setup_blocked_token!
      @round = operating_round_for(lnwr)
      allow(game).to receive(:cross_water_tile_fee).and_return(0)
      brandt_lay!(token_hex)
      bbe.owner.companies.delete(bbe)
      give_company!(other_owner, bbe)
      game.clear_graph
    end

    def removal_step
      track_step(@round)
    end

    def choose!(corporation, hex_id)
      @round.process_action(Engine::Action::Choose.new(corporation, choice: hex_id))
    end

    before { setup_blocked_token! }

    it "offers another player's connected RR the removal with its cost and points" do
      expect(@round.actions_for(lnwr)).to include('choose')
      expect(removal_step.choice_name).to eq('Brandt & Brandau tokens')
      expect(removal_step.choices).to eq('J23' => 'Remove B&B token on J23 (£45, 1 pt)')
    end

    it 'refuses a removal that breaks the first-round insolvency guard (§11.6.5)' do
      allow(game).to receive(:check_reserved_train_funds!).and_call_original
      allow(game).to receive(:reserved_train_due?).with(lnwr).and_return(true)
      lnwr.spend(lnwr.cash - 50, game.bank)
      lnwr.owner.spend(lnwr.owner.cash, game.bank)

      expect { choose!(lnwr, 'J23') }.to raise_error(Engine::GameError, /cannot spend £45.*reserved/)
      expect(token_hex.assigned?('BBE')).to be(true)
    end

    it 'charges the printed terrain cost to the bank and one tile point, then frees the hex' do
      cash = lnwr.cash
      bank_cash = game.bank.cash
      choose!(lnwr, 'J23')

      expect(token_hex.assigned?('BBE')).to be(false)
      expect(cash - lnwr.cash).to eq(45)
      expect(game.bank.cash - bank_cash).to eq(45)
      expect(removal_step.help).to eq('4 track points')
      expect(game.brandt_blocked?(lnwr, token_hex)).to be(false)
      expect(removal_step.tracker_available_hex(lnwr, token_hex)).not_to be_nil
    end

    it 'lets routes use the hex after removal' do
      choose!(lnwr, 'J23')

      expect(game.graph_skip_paths(lnwr)).to be_nil
      expect(game.graph.connected_paths(lnwr).keys.map { |path| path.hex.id }).to include('J23')
    end

    it "does not offer removal to the owner's RRs" do
      bbe.owner.companies.delete(bbe)
      give_company!(lnwr.owner, bbe)
      game.clear_graph

      expect(removal_step.choices).to be_empty
      expect(@round.actions_for(lnwr)).not_to include('choose')
    end

    it 'does not offer removal to an RR not connected to the hex' do
      third = game.players[1]
      expect(third).not_to eq(other_owner)
      midi = start_major!(game, 'MIDI', third)
      far = game.hex_by_id('R39')
      far.assign!('BBE')
      game.clear_graph
      round = operating_round_for(midi)

      expect(game.brandt_blocked?(midi, far)).to be(true)
      expect(game.graph_for_entity(midi).connected_hexes(midi)[far]).to be_nil
      expect(track_step(round).choices).not_to have_key('R39')
    end

    it 'does not offer removal without enough cash for the terrain cost' do
      lnwr.spend(lnwr.cash - 44, game.bank)

      expect(removal_step.choices).to be_empty
    end

    it 'does not offer removal without a tile point left' do
      @round.tile_points_used = removal_step.get_tile_lay(lnwr)

      expect(removal_step.choices).to be_empty
    end

    it 'refuses a choose for a hex without a removable token' do
      expect { choose!(lnwr, 'I26') }.to raise_error(Engine::GameError, /No Brandt & Brandau token/)
    end

    it 'never offers or processes choose from the Brandt step' do
      step = brandt_step(@round)

      expect(step.actions(lnwr)).to be_empty
    end

    it 'does not block or offer removal in the abbreviated final operating round' do
      allow(game).to receive(:abbreviated_operating_round?).and_return(true)

      expect(removal_step.choices).not_to be_empty
      expect(removal_step.actions(lnwr)).to be_empty
    end

    it 'round-trips the choose action and accepts it unchanged while loading' do
      action = Engine::Action::Choose.new(lnwr, choice: 'J23')
      rebuilt = Engine::Action::Base.action_from_h(action.to_h, game)
      game.instance_variable_set(:@loading, true)
      removal_step.process_choose(rebuilt)

      expect(rebuilt.choice).to eq('J23')
      expect(token_hex.assigned?('BBE')).to be(false)
      expect(@round.tile_points_used).to eq(2)
    end

    context 'with a metropolis hex' do
      let(:madrid) { game.hex_by_id('Y14') }

      before do
        madrid.assign!('BBE')
        game.clear_graph
        allow(removal_step).to receive(:hex_neighbors).and_return(true)
      end

      it 'costs two tile points and is offered only with two left' do
        expect(game.brandt_removal_points(madrid)).to eq(2)
        expect(removal_step.choices).to include('Y14' => 'Remove B&B token on Y14 (£45, 2 pt)')

        @round.tile_points_used = removal_step.get_tile_lay(lnwr) - 1

        expect(removal_step.choices).not_to have_key('Y14')
      end

      it 'charges two tile points when removed' do
        choose!(lnwr, 'Y14')

        expect(@round.tile_points_used).to eq(3)
      end
    end

    context 'with a national' do
      it 'pays no terrain cost' do
        allow(game).to receive(:national?).and_call_original
        allow(game).to receive(:national?).with(lnwr).and_return(true)

        expect(game.brandt_removal_cost(lnwr, token_hex)).to eq(0)
        cash = lnwr.cash
        game.remove_brandt_token!(lnwr, token_hex)

        expect(lnwr.cash).to eq(cash)
        expect(game.brandt_removal_points(token_hex)).to eq(1)
      end
    end

    context 'with Minor F operating' do
      let(:minor_f) { game.corporation_by_id('F') }

      before do
        minor_f.owner = player
        fund!(game, minor_f)
        game.minor_floated_regions['F'] = 'UK'
        @round = operating_round_for(minor_f)
        allow(removal_step).to receive(:hex_neighbors).and_return(true)
      end

      it 'does not auto-pass Track with no regular points left while only a removal is possible' do
        @round.tile_points_used = removal_step.get_tile_lay(minor_f)

        expect(removal_step.choices).to have_key('J23')
        expect(removal_step.actions(minor_f)).to include('lay_tile', 'choose')
        expect(removal_step.auto_actions(minor_f)).to be_nil
      end

      it "pays one removal point with Minor F's unused green-terrain point" do
        points = removal_step.get_tile_lay(minor_f)
        expect(removal_step.choices).to have_key('J23')
        choose!(minor_f, 'J23')

        expect(@round.tile_points_used).to eq(0)
        expect(removal_step.get_tile_lay(minor_f)).to eq(points)
        expect(minor_f.abilities.first.count_this_or).to eq(1)
        expect(token_hex.assigned?('BBE')).to be(false)
      end
    end

    describe 'closing' do
      before { fund!(game, lnwr) }

      def place_all!
        %w[I26 B43 U36].each do |id|
          bbe.abilities.first.use!
          game.place_brandt_token!(game.hex_by_id(id))
          bbe.reset_ability_count_this_or!
        end
      end

      it 'closes the face-down private when the last token is removed' do
        place_all!
        expect(game.face_down_private?(bbe)).to be(true)

        game.brandt_hexes.dup.each { |hex| game.remove_brandt_token!(lnwr, hex) }

        expect(bbe.closed?).to be(true)
        expect(game.brandt_hexes).to be_empty
        expect(game.brandt_private).to eq(bbe)
      end

      it 'does not close while a token is still unplaced' do
        game.remove_brandt_token!(lnwr, token_hex)

        expect(bbe.closed?).to be(false)
      end

      it 'does not close when tokens remain on the map' do
        place_all!
        game.remove_brandt_token!(lnwr, token_hex)

        expect(bbe.closed?).to be(false)
      end

      it 'still pays 25 with two placed and both removed' do
        bbe.abilities.first.use!
        game.place_brandt_token!(game.hex_by_id('I26'))
        game.brandt_hexes.dup.each { |hex| game.remove_brandt_token!(lnwr, hex) }

        expect(bbe.closed?).to be(false)
        expect(bbe.revenue).to eq(25)
      end

      it 'tolerates graph and route checks after closing' do
        place_all!
        game.brandt_hexes.dup.each { |hex| game.remove_brandt_token!(lnwr, hex) }

        expect(game.brandt_blocked?(lnwr, token_hex)).to be(false)
        expect(game.graph_skip_paths(lnwr)).to be_nil
        expect(game.brandt_token_placeable?(lnwr)).to be(false)
      end
    end
  end
end
