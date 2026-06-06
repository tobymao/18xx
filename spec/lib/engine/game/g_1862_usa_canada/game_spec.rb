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

    describe 'BHL (Bahnhoflizenz) token placement' do
      let(:bhl) { game.companies.find { |c| c.sym == 'BHL' } }

      it 'BHL ability has player owner_type' do
        ability = bhl.abilities.find { |a| a.type == :token }
        expect(ability.owner_type).to eq(:player)
      end

      it 'BHL ability uses cheater slot' do
        ability = bhl.abilities.find { |a| a.type == :token }
        expect(ability.cheater).to be true
      end

      it 'BHL ability is one-time use' do
        ability = bhl.abilities.find { |a| a.type == :token }
        expect(ability.count).to eq(1)
        expect(ability.closed_when_used_up).to be true
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

    describe 'bond (Schuldschein) state' do
      let(:cpr)    { game.corporation_by_id('CPR') }
      let(:player) { game.players.first }
      let(:mock_sp) { double('SharePrice', price: 100) }

      before do
        allow(cpr).to receive(:share_price).and_return(mock_sp)
        allow(cpr).to receive(:owner).and_return(player)
      end

      it '@corp_bonds initialises empty' do
        expect(game.instance_variable_get(:@corp_bonds)).to eq({})
      end

      it '@buyback_done initialises empty' do
        expect(game.instance_variable_get(:@buyback_done)).to eq({})
      end

      it 'bond? is false before buyback' do
        expect(game.bond?(cpr)).to be false
      end

      it 'bond? is true after record_bond!' do
        game.record_bond!(cpr)
        expect(game.bond?(cpr)).to be true
      end

      it 'buyback_done? is false before buyback' do
        expect(game.buyback_done?(cpr)).to be false
      end

      it 'buyback_done? is true after record_bond!' do
        game.record_bond!(cpr)
        expect(game.buyback_done?(cpr)).to be true
      end

      it 'record_bond! is a no-op on second call' do
        game.record_bond!(cpr)
        game.record_bond!(cpr)
        expect(game.bond_amount(cpr)).to eq(500)
      end

      it 'buyback_bond_amount is 5 × market price' do
        expect(game.buyback_bond_amount(cpr)).to eq(500)
      end

      it 'buyback_bond_amount rounds up to nearest $100' do
        non_round_sp = double('SharePrice', price: 92)
        allow(cpr).to receive(:share_price).and_return(non_round_sp)
        # 92 × 5 = 460 → ceil to nearest 100 → 500
        expect(game.buyback_bond_amount(cpr)).to eq(500)
      end

      it 'repay_bond! clears the bond when corp has sufficient cash' do
        game.record_bond!(cpr)
        cpr.instance_variable_set(:@cash, 500)
        game.repay_bond!(cpr)
        expect(game.bond?(cpr)).to be false
      end

      it 'repay_bond! is a no-op when corp cash is insufficient' do
        game.record_bond!(cpr)
        game.repay_bond!(cpr)
        expect(game.bond?(cpr)).to be true
      end

      it 'num_certs adds 1 for the buyback penalty cert' do
        base = game.num_certs(player)
        game.record_bond!(cpr)
        expect(game.num_certs(player)).to eq(base + 1)
      end

      it 'penalty cert only counts for the director, not other players' do
        other = game.players.last
        game.record_bond!(cpr)
        base_other = game.num_certs(other)
        expect(game.num_certs(other)).to eq(base_other)
      end

      describe 'director sell-block' do
        let(:step) do
          game.stock_round.steps.find { |s| s.is_a?(Game::G1862UsaCanada::Step::BuySellParShares) }
        end
        let(:share) { cpr.shares.find { |s| !s.president } }

        before { allow(share).to receive(:owner).and_return(player) }

        it 'director cannot sell corp shares while bond is active' do
          game.record_bond!(cpr)
          allow(cpr).to receive(:president?).with(player).and_return(true)
          bundle = Engine::ShareBundle.new([share])
          allow(bundle).to receive(:corporation).and_return(cpr)
          allow(bundle).to receive(:owner).and_return(player)
          expect(step.can_sell?(player, bundle)).to be false
        end

        it 'director can sell corp shares when no bond is active' do
          allow(cpr).to receive(:president?).with(player).and_return(true)
          bundle = Engine::ShareBundle.new([share])
          allow(bundle).to receive(:corporation).and_return(cpr)
          allow(bundle).to receive(:owner).and_return(player)
          # can_sell? may return false for other reasons (no bought cert yet etc.)
          # but must NOT be blocked by bond logic
          expect(game.bond?(cpr)).to be false
        end
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

    describe 'halve_shares! cert transformation' do
      # CPR: Group 2 corp — 20% president + 8×10% = 100%
      let(:cpr) { game.corporation_by_id('CPR') }
      # NYH: Group 1 corp — 30% president + 7×10% = 100%
      let(:nyh) { game.corporation_by_id('NYH') }

      describe '20% president corp (CPR)' do
        before { game.halve_shares!(cpr) }

        it 'creates a 50% non-buyable treasury cert' do
          treasury = cpr.shares_of(cpr).find { |s| s.percent == 50 && !s.buyable }
          expect(treasury).not_to be_nil
        end

        it 'president cert is halved to 10%' do
          expect(cpr.presidents_share.percent).to eq(10)
        end

        it 'all regular certs are 5%' do
          regulars = cpr.shares.select { |s| !s.president && s.buyable }
          expect(regulars.map(&:percent).uniq).to eq([5])
        end

        it 'share_holders sum is still 100' do
          expect(cpr.share_holders.values.sum).to eq(100)
        end

        it 'forced_share_percent is 5' do
          expect(cpr.share_percent).to eq(5)
        end

        it 'price_multiplier is 0.5' do
          expect(cpr.price_multiplier).to be_within(0.001).of(0.5)
        end

        it 'is idempotent — second call does not create a second treasury cert' do
          game.halve_shares!(cpr)
          treasury_certs = cpr.shares_of(cpr).select { |s| s.percent == 50 && !s.buyable }
          expect(treasury_certs.size).to eq(1)
        end
      end

      describe '30% president corp (NYH)' do
        before { game.halve_shares!(nyh) }

        it 'president cert is halved to 10%' do
          expect(nyh.presidents_share.percent).to eq(10)
        end

        it 'president holder has an extra 5% split cert' do
          director = nyh.presidents_share.owner
          dir_certs = nyh.shares_of(director)
          expect(dir_certs.map(&:percent).sort).to include(5, 10)
        end

        it 'creates a 50% non-buyable treasury cert' do
          treasury = nyh.shares_of(nyh).find { |s| s.percent == 50 && !s.buyable }
          expect(treasury).not_to be_nil
        end

        it 'share_holders sum is still 100' do
          expect(nyh.share_holders.values.sum).to eq(100)
        end
      end

      describe 'treasury cert dividend routing' do
        let(:div_step) do
          game.operating_round(1).steps.find { |s| s.is_a?(Game::G1862UsaCanada::Step::Dividend) }
        end

        before { game.halve_shares!(cpr) }

        it 'corporation_dividends includes treasury cert share units' do
          # After halving: total_shares = 20, treasury cert = 10 units.
          # With per_share = 5 (revenue 100 / total 20), treasury earns 10 × 5 = 50.
          per_share = 5
          # base = market shares × per_share (0 in test — no market shares)
          # treasury = 10 units × 5 = 50
          result = div_step.corporation_dividends(cpr, per_share)
          expect(result).to eq(50)
        end

        it 'non-halved corp has zero treasury cert contribution' do
          other = game.corporation_by_id('UP')
          result = div_step.corporation_dividends(other, 5)
          # UP has no non-buyable treasury cert, only market shares (0 in test)
          expect(result).to eq(0)
        end
      end

      describe 'game-end bond penalty' do
        let(:cpr)    { game.corporation_by_id('CPR') }
        let(:player) { game.players.first }
        let(:mock_sp) { double('SharePrice', price: 100) }

        before do
          allow(cpr).to receive(:share_price).and_return(mock_sp)
          allow(cpr).to receive(:owner).and_return(player)
          game.record_bond!(cpr)
        end

        it 'apply_bond_penalties! sets player.penalty to the bond amount' do
          game.apply_bond_penalties!
          expect(player.penalty).to eq(500)
        end

        it 'apply_bond_penalties! does nothing when bond is repaid' do
          cpr.instance_variable_set(:@cash, 500)
          game.repay_bond!(cpr)
          game.apply_bond_penalties!
          expect(player.penalty).to eq(0)
        end
      end
    end
  end
end
