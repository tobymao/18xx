# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1862UsaCanada::Game do
    let(:players) { %w[Alice Bob Charlie] }
    let(:game) { Game::G1862UsaCanada::Game.new(players) }

    it 'initialises without error' do
      expect(game).to be_a(described_class)
    end

    it 'has the correct number of corporations' do
      expect(game.corporations.size).to eq(13)
    end

    it 'has the correct number of private companies' do
      expect(game.companies.size).to eq(8)
    end

    it 'starts in phase 2' do
      expect(game.phase.name).to eq('2')
    end

    it 'uses full capitalisation' do
      expect(described_class::CAPITALIZATION).to eq(:full)
    end

    it 'uses sell_buy order' do
      expect(described_class::SELL_BUY_ORDER).to eq(:sell_buy)
    end

    describe 'private close triggers' do
      let(:soc)  { game.companies.find { |c| c.sym == 'SOC' } }
      let(:nhsc) { game.companies.find { |c| c.sym == 'NHSC' } }
      let(:psc)  { game.companies.find { |c| c.sym == 'PSC' } }
      let(:fny)  { game.companies.find { |c| c.sym == 'FNY' } }
      let(:cpr)  { game.corporation_by_id('CPR') }
      let(:up)   { game.corporation_by_id('UP') }
      let(:nyh)  { game.corporation_by_id('NYH') }
      let(:wp)   { game.corporation_by_id('WP') }
      let(:nyc)  { game.corporation_by_id('NYC') }

      it 'SOC closes when CPR floats' do
        game.on_corporation_floated!(cpr)
        expect(soc.closed?).to be true
      end

      it 'SOC closes when UP floats' do
        game.on_corporation_floated!(up)
        expect(soc.closed?).to be true
      end

      it 'NHSC closes when NYH floats' do
        game.on_corporation_floated!(nyh)
        expect(nhsc.closed?).to be true
      end

      it 'SOC does not close when NYH floats' do
        game.on_corporation_floated!(nyh)
        expect(soc.closed?).to be false
      end

      it 'PSC closes on first WP payout' do
        game.on_first_payout!(wp)
        expect(psc.closed?).to be true
      end

      it 'FNY closes on first NYC payout' do
        game.on_first_payout!(nyc)
        expect(fny.closed?).to be true
      end

      it 'FNY does not close when WP pays first dividend' do
        game.on_first_payout!(wp)
        expect(fny.closed?).to be false
      end
    end

    describe 'GHU token discount' do
      let(:ghu) { game.companies.find { |c| c.sym == 'GHU' } }

      it 'GHU ability has player owner_type' do
        ability = ghu.abilities.find { |a| a.type == :tile_discount }
        expect(ability.owner_type).to eq(:player)
      end

      it 'GHU discount is $80' do
        ability = ghu.abilities.find { |a| a.type == :tile_discount }
        expect(ability.discount).to eq(80)
      end
    end

    describe 'NYH par price restriction' do
      let(:nyh) { game.corporation_by_id('NYH') }
      let(:step) { game.stock_round.active_step }

      it 'NYH par is restricted to $100' do
        game.companies.each { |c| c.owner = game.players.first }
        prices = step.get_par_prices(game.players.first, nyh).map(&:price)
        expect(prices).to eq([100])
      end

      it 'other corps have multiple par prices available' do
        game.companies.each { |c| c.owner = game.players.first }
        [game.corporation_by_id('NYC'), game.corporation_by_id('CP')].each do |corp|
          prices = step.get_par_prices(game.players.first, corp)
          expect(prices.size).to be > 1
        end
      end
    end

    describe 'tile-lay budget' do
      it 'phase 2: single yellow tile only' do
        lays = game.tile_lays(game.corporations.first)
        expect(lays.size).to eq(1)
        expect(lays.first[:upgrade]).to be false
      end

      it 'phase 3+: two entries, second blocked after upgrade' do
        game.phase.next!
        lays = game.tile_lays(game.corporations.first)
        expect(lays.size).to eq(2)
        expect(lays.first[:upgrade]).to be true
        expect(lays.last[:lay]).to eq(:not_if_upgraded)
        expect(lays.last[:upgrade]).to be false
      end

      it 'phase 3 status includes two_tile_lays flag' do
        game.phase.next!
        expect(game.phase.status).to include('two_tile_lays')
      end
    end

    describe 'E-train variants' do
      it 'every base train 2–7 has exactly one E-train variant' do
        base_trains = game.depot.trains.map(&:name).uniq.reject { |n| n == '8' }
        base_trains.each do |name|
          proto = game.depot.trains.find { |t| t.name == name }
          expect(proto.variants.keys).to include("#{name}E"), "#{name}-train missing #{name}E variant"
        end
      end

      it 'E-train distance uses string keys and visit 999' do
        %w[2E 3E 4E 5E 6E 7E].each do |variant_name|
          base = variant_name.chomp('E')
          proto = game.depot.trains.find { |t| t.name == base }
          dist = proto.variants[variant_name][:distance]
          expect(dist).to be_an(Array), "#{variant_name} distance should be an array"
          expect(dist.first['visit']).to eq(999), "#{variant_name} should visit 999 nodes"
          expect(dist.first['nodes']).to include('city'), "#{variant_name} nodes should include city"
        end
      end

      it '2 and 2E trains rust on the 4-train sym' do
        two_train = game.depot.trains.find { |t| t.name == '2' }
        expect(two_train.rusts_on).to eq('4')
      end

      it '3 and 3E trains rust on the 6-train sym' do
        three_train = game.depot.trains.find { |t| t.name == '3' }
        expect(three_train.rusts_on).to eq('6')
      end

      it '4 and 4E trains rust on the 8-train sym' do
        four_train = game.depot.trains.find { |t| t.name == '4' }
        expect(four_train.rusts_on).to eq('8')
      end

      it '5E and later trains never rust' do
        %w[5 6 7 8].each do |name|
          train = game.depot.trains.find { |t| t.name == name }
          expect(train.rusts_on).to be_nil, "#{name}-train should not rust"
        end
      end
    end

    def stub_route(*hex_ids)
      stops = hex_ids.map { |id| double('Stop', hex: double('Hex', id: id)) }
      double('Route', visited_stops: stops)
    end

    describe 'bonus markers' do
      let(:cp)  { game.corporation_by_id('CP') }
      let(:nyc) { game.corporation_by_id('NYC') }

      it 'initialises all bonus states to :unactivated' do
        described_class::CORP_BONUSES.each do |sym, bonuses|
          bonuses.each_index do |i|
            expect(game.instance_variable_get(:@bonus_state)[[sym, i]]).to eq(:unactivated)
          end
        end
      end

      it 'corp_bonus_revenue returns 0 with empty routes' do
        expect(game.corp_bonus_revenue(cp, [])).to eq(0)
      end

      it 'corp_bonus_revenue returns 0 for corp without CORP_BONUSES entry' do
        expect(game.corp_bonus_revenue(nyc, [])).to eq(0)
      end

      it 'corp_bonus_revenue includes bonus when route visits home AND bonus hex' do
        route = stub_route(cp.coordinates, 'E25')
        expect(game.corp_bonus_revenue(cp, [route])).to eq(30)
      end

      it 'corp_bonus_revenue returns 0 when route misses home hex' do
        route = stub_route('E25', 'F20')
        expect(game.corp_bonus_revenue(cp, [route])).to eq(0)
      end

      it 'activate_new_bonuses! transitions state to :permanent' do
        route = stub_route(cp.coordinates, 'E25')
        game.activate_new_bonuses!(cp, [route])
        expect(game.instance_variable_get(:@bonus_state)[['CP', 0]]).to eq(:permanent)
      end

      it 'permanent bonus applies without home hex on route' do
        route = stub_route(cp.coordinates, 'E25')
        game.activate_new_bonuses!(cp, [route])
        route2 = stub_route('E25', 'F20')
        expect(game.corp_bonus_revenue(cp, [route2])).to eq(30)
      end

      it 'activate_new_bonuses! is idempotent — does not re-activate' do
        route = stub_route(cp.coordinates, 'E25')
        game.activate_new_bonuses!(cp, [route])
        game.activate_new_bonuses!(cp, [route])
        expect(game.instance_variable_get(:@bonus_state)[['CP', 0]]).to eq(:permanent)
      end
    end

    describe 'SLC transcontinental bonus + Golden Spike' do
      let(:cpr) { game.corporation_by_id('CPR') }
      let(:up)  { game.corporation_by_id('UP') }
      let(:nyc) { game.corporation_by_id('NYC') }
      let(:slc_hex) { described_class::SLC_HEX }
      let(:soc) { game.companies.find { |c| c.sym == 'SOC' } }

      it 'initialises @slc_connected as empty hash' do
        expect(game.instance_variable_get(:@slc_connected)).to eq({})
      end

      it 'initialises @slc_bonus_paid as false' do
        expect(game.instance_variable_get(:@slc_bonus_paid)).to be false
      end

      it 'SLC bonus is 0 for non-SLC corp' do
        route = stub_route(slc_hex)
        expect(game.send(:slc_route_bonus, nyc, [route])).to eq(0)
      end

      it 'SLC bonus is 0 when route does not visit SLC hex' do
        route = stub_route('F14', 'K19')
        expect(game.send(:slc_route_bonus, cpr, [route])).to eq(0)
      end

      it 'SLC bonus is 15 while SOC is open' do
        route = stub_route(slc_hex)
        expect(game.send(:slc_route_bonus, cpr, [route])).to eq(15)
      end

      it 'SLC bonus is 30 after SOC closes' do
        soc.close!
        route = stub_route(slc_hex)
        expect(game.send(:slc_route_bonus, cpr, [route])).to eq(30)
      end

      it 'SLC bonus applies to UP as well' do
        soc.close!
        route = stub_route(slc_hex)
        expect(game.send(:slc_route_bonus, up, [route])).to eq(30)
      end

      it 'check_golden_spike! marks CPR as connected' do
        game.check_golden_spike!(cpr, [stub_route(slc_hex)])
        expect(game.instance_variable_get(:@slc_connected)['CPR']).to be true
      end

      it 'Golden Spike does not fire when only CPR connects' do
        game.check_golden_spike!(cpr, [stub_route(slc_hex)])
        expect(game.instance_variable_get(:@slc_bonus_paid)).to be false
      end

      it 'Golden Spike fires when both CPR and UP connect' do
        game.check_golden_spike!(cpr, [stub_route(slc_hex)])
        game.check_golden_spike!(up, [stub_route(slc_hex)])
        expect(game.instance_variable_get(:@slc_bonus_paid)).to be true
      end

      it 'check_golden_spike! is idempotent for already-connected corp' do
        game.check_golden_spike!(cpr, [stub_route(slc_hex)])
        log_size = game.log.size
        game.check_golden_spike!(cpr, [stub_route(slc_hex)])
        expect(game.log.size).to eq(log_size)
      end

      it 'non-SLC corp does not mark connection' do
        game.check_golden_spike!(nyc, [stub_route(slc_hex)])
        expect(game.instance_variable_get(:@slc_connected)).to eq({})
      end
    end

    describe 'home token timing' do
      it 'uses :operate timing' do
        expect(described_class::HOME_TOKEN_TIMING).to eq(:operate)
      end

      it 'clears the graph after placing the home token' do
        corp = game.corporations.first
        graph = game.send(:graph_for_entity, corp)
        expect(graph).to receive(:clear).at_least(:once)
        game.place_home_token(corp)
      end
    end

    describe 'corporation group unlock' do
      let(:nyh) { game.corporation_by_id('NYH') }
      let(:nyc) { game.corporation_by_id('NYC') }
      let(:cp)  { game.corporation_by_id('CP') }
      let(:cpr) { game.corporation_by_id('CPR') }
      let(:np)  { game.corporation_by_id('NP') }

      it 'Group 1 is locked while privates are unsold' do
        expect(game.can_par?(nyh, nil)).to be false
      end

      it 'Group 1 unlocks when all privates are sold' do
        game.companies.each { |c| c.owner = game.players.first }
        expect(game.can_par?(nyh, nil)).to be true
      end

      it 'Group 2 is locked even after all privates are sold' do
        game.companies.each { |c| c.owner = game.players.first }
        expect(game.can_par?(cpr, nil)).to be false
      end

      it 'Group 2 unlocks when all Group 1 IPO shares are sold' do
        game.companies.each { |c| c.owner = game.players.first }
        [nyh, nyc, cp].each { |corp| allow(corp).to receive(:num_ipo_shares).and_return(0) }
        expect(game.can_par?(cpr, nil)).to be true
      end

      it 'Group 3 is locked while any Group 2 corp is unfloated' do
        game.companies.each { |c| c.owner = game.players.first }
        expect(game.can_par?(np, nil)).to be false
      end
    end
  end
end
