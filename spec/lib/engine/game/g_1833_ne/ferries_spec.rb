# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1833NE::Game do
    let(:game) { Game::G1833NE::Game.new(%w[a b c]) }
    let(:bp) { game.corporation_by_id('B&P') }
    let(:hr) { game.corporation_by_id('HR') }
    let(:providence) { game.hex_by_id('F25') }
    let(:kingston) { game.hex_by_id('F27') }
    let(:fall_river) { game.hex_by_id('G26') }
    let(:route_struct) { Struct.new(:phase, :train, :corporation, :visited_stops, :hexes) }

    def start(corporation)
      game.share_pool.transfer_shares(corporation.presidents_share.to_bundle, game.players.first)
      share_price = game.stock_market.par_prices.find { |price| price.price == 100 }
      corporation.share_price = share_price
      share_price.corporations << corporation
      game.place_home_token(corporation)
      game.bank.spend(300, corporation)
    end

    def lay(hex_id, tile_name, edges)
      tile = game.tiles.find { |t| t.name == tile_name }
      raise "no #{tile_name} rotation for #{edges}" unless (0..5).find do |rotation|
        tile.rotate!(rotation)
        tile.exits.sort == edges.sort
      end

      game.hex_by_id(hex_id).lay(tile)
      game.graph.clear
    end

    def route(corporation, *hexes)
      train = game.depot.trains.find { |t| t.name == '2' }
      stops = hexes.map { |hex| hex.tile.city_towns.first }
      route_struct.new(game.phase, train, corporation, stops, hexes)
    end

    def operate(corporation)
      game.instance_variable_set(:@round, game.send(:new_operating_round))
      game.round.after_setup
      game.process_action(Action::Pass.new(corporation)) until game.round.current_entity == corporation
    end

    before do
      start(bp)
      lay('F27', '3', [2, 3])
    end

    describe '#buyable_ferries' do
      it 'needs the ferry to connect to Boston' do
        expect(game.buyable_ferries(bp)).to be_empty
      end

      it 'offers each connected ferry once track reaches Boston' do
        lay('G24', '58', [1, 3])

        expect(game.buyable_ferries(bp)).to contain_exactly(providence, kingston)
      end

      it 'needs the corporation to have the cost in its treasury' do
        lay('G24', '58', [1, 3])
        bp.spend(bp.cash - game.ferry_cost + 1, game.bank)

        expect(game.buyable_ferries(bp)).to be_empty
      end

      it 'is empty once the ferries are removed in phase IV' do
        lay('G24', '58', [1, 3])
        game.phase.next! until game.phase.name == 'IV'

        expect(game.buyable_ferries(bp)).to be_empty
      end
    end

    describe 'buying a ferry' do
      before { lay('G24', '58', [1, 3]) }

      it 'is offered after track and token, and only one ferry per turn' do
        operate(bp)
        game.process_action(Action::Pass.new(bp))

        step = game.round.active_step
        expect(step).to be_a(Game::G1833NE::Step::BuyFerry)
        item = step.buyable_items(bp).find { |i| i.description.include?('F27') }
        game.process_action(Action::SpecialBuy.new(bp, item: item))

        expect(bp.cash).to eq(260)
        expect(game.ferry_owner(kingston)).to eq(bp)
        expect(kingston.assigned?('new_ferry')).to be(true)
        expect(kingston.tile.icons.map(&:name)).to eq(['kingston_ferry_token'])
        expect(game.round.active_step).not_to be_a(Game::G1833NE::Step::BuyFerry)
      end

      it 'moves the New ferry bonus to the latest ferry bought' do
        game.buy_ferry!(bp, kingston)
        game.buy_ferry!(bp, providence)

        expect(kingston.assigned?('new_ferry')).to be(false)
        expect(providence.assigned?('new_ferry')).to be(true)
      end

      it 'keeps the New bonus while ferries remain unsold' do
        game.buy_ferry!(bp, kingston)
        game.flip_last_ferry_bonus!(bp)

        expect(kingston.assigned?('new_ferry')).to be(true)
      end

      it 'rejects a ferry the corporation cannot buy' do
        operate(bp)
        game.process_action(Action::Pass.new(bp))
        item = Item.new(description: 'Fall River ferry (G26)', cost: game.ferry_cost)

        expect { game.process_action(Action::SpecialBuy.new(bp, item: item)).maybe_raise! }
          .to raise_error(GameError, /cannot buy/)
      end

      it 'flips the bonus to Last once the buyer of the last ferry runs' do
        start(hr)
        (game.ferry_hexes - [kingston]).each { |hex| game.buy_ferry!(hr, hex) }
        game.buy_ferry!(bp, kingston)

        game.flip_last_ferry_bonus!(hr)
        game.flip_last_ferry_bonus!(nil)
        expect(kingston.assigned?('new_ferry')).to be(true)

        game.flip_last_ferry_bonus!(bp)
        expect(kingston.assigned?('new_ferry')).to be(false)
        expect(kingston.assigned?('last_ferry')).to be(true)
        expect(game.ferry_revenue(kingston)).to eq(30)
      end
    end

    describe 'ferry revenue' do
      before { lay('G24', '58', [1, 3]) }

      it 'matches the rulebook example: Providence (New) and Kingston on a 2 train' do
        game.buy_ferry!(bp, kingston)
        game.buy_ferry!(bp, providence)
        run = route(bp, providence, kingston)

        expect(game.revenue_for(run, run.visited_stops)).to eq(80)
        expect(game.revenue_str(run)).to include('Providence ferry $30', 'Kingston ferry $20')
      end

      it 'only pays the corporation that owns the ferry' do
        start(hr)
        game.buy_ferry!(hr, kingston)
        run = route(bp, providence, kingston)

        expect(game.revenue_for(run, run.visited_stops)).to eq(30)
      end
    end

    describe 'Luxury Ferry Service' do
      let(:luxury) { game.luxury_ferry_service }
      let(:assign_step) { game.round.step_for(luxury, 'assign') }

      before do
        lay('G24', '58', [1, 3])
        luxury.owner = bp
        bp.companies << luxury
        game.buy_ferry!(bp, kingston)
        operate(bp)
      end

      it 'can only be assigned to a ferry its corporation owns' do
        expect(assign_step.available_hex(luxury, kingston)).to be_truthy
        expect(assign_step.available_hex(luxury, fall_river)).to be_nil
        expect { game.process_action(Action::Assign.new(luxury, target: fall_river)).maybe_raise! }
          .to raise_error(GameError, /only be assigned to a ferry/)
      end

      it 'doubles the ferry and its bonus' do
        game.process_action(Action::Assign.new(luxury, target: kingston))

        expect(game.ferry_revenue(kingston)).to eq(80)
        expect(game.abilities(luxury, :assign_hexes)).to be_nil
      end
    end

    describe 'removing the ferries' do
      it 'clears ferry ownership, markers and icons' do
        lay('G24', '58', [1, 3])
        game.buy_ferry!(bp, kingston)
        game.send(:event_remove_ferries!)

        expect(game.ferry_owner(kingston)).to be_nil
        expect(kingston.assignments).to be_empty
        expect(game.ferry_hexes.flat_map { |hex| hex.tile.icons.map(&:name) }.grep(/ferry/)).to be_empty
        expect(game.route_ferries(route(bp, providence, kingston))).to be_empty
      end
    end
  end
end
