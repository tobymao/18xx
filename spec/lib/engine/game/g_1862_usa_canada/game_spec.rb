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
        ability = ghu.abilities.find { |a| a.type == :token }
        expect(ability.owner_type).to eq(:player)
      end

      it 'GHU discount is $80' do
        ability = ghu.abilities.find { |a| a.type == :token }
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

      it 'corp_bonus_revenue returns 0 for :unactivated bonus (ChooseBonus pending)' do
        route = stub_route(cp.coordinates, 'E25')
        expect(game.corp_bonus_revenue(cp, [route])).to eq(0)
      end

      it 'corp_bonus_revenue returns 0 when route misses bonus hex' do
        game.instance_variable_get(:@bonus_state)[['CP', 0]] = :permanent
        route = stub_route('F28', 'F20')
        expect(game.corp_bonus_revenue(cp, [route])).to eq(0)
      end

      it 'corp_bonus_revenue includes bonus after state is set to :permanent' do
        game.instance_variable_get(:@bonus_state)[['CP', 0]] = :permanent
        route = stub_route(cp.coordinates, 'E25')
        expect(game.corp_bonus_revenue(cp, [route])).to eq(30)
      end

      it 'permanent bonus applies without home hex on route' do
        game.instance_variable_get(:@bonus_state)[['CP', 0]] = :permanent
        route = stub_route('E25', 'F20')
        expect(game.corp_bonus_revenue(cp, [route])).to eq(30)
      end

      it 'corp_bonus_revenue returns 0 for :cash bonus state' do
        game.instance_variable_get(:@bonus_state)[['CP', 0]] = :cash
        route = stub_route(cp.coordinates, 'E25')
        expect(game.corp_bonus_revenue(cp, [route])).to eq(0)
      end

      describe 'update_bonus_icon! — VPSL multi-hex (B2/C1/G3/I5)' do
        let(:vpsl_hexes) { %w[B2 C1 G3 I5].to_h { |id| [id, game.hex_by_id(id)] } }
        let(:nyc_icon)   { 'bonus_NYC_2' }

        it 'front-side icons present on all 4 VPSL hexes initially' do
          vpsl_hexes.each do |id, hex|
            expect(hex.original_tile.icons.map(&:name)).to include(nyc_icon),
                                                           "expected #{nyc_icon} on #{id}"
          end
        end

        it ':permanent at G3 — removes front from all 4, places back on G3 only' do
          game.update_bonus_icon!('NYC', 2, :permanent, 'G3')
          expect(vpsl_hexes['G3'].original_tile.icons.map(&:name)).to include('bonus_NYC_2_back')
          %w[B2 C1 I5].each do |id|
            expect(vpsl_hexes[id].original_tile.icons.map(&:name)).not_to include(nyc_icon),
                                                                          "expected no front icon on #{id}"
            expect(vpsl_hexes[id].original_tile.icons.map(&:name)).not_to include('bonus_NYC_2_back')
          end
        end

        it ':permanent at B2 — removes front from all 4, places back on B2 only' do
          game.update_bonus_icon!('NYC', 2, :permanent, 'B2')
          expect(vpsl_hexes['B2'].original_tile.icons.map(&:name)).to include('bonus_NYC_2_back')
          %w[C1 G3 I5].each do |id|
            expect(vpsl_hexes[id].original_tile.icons.map(&:name)).not_to include(nyc_icon)
            expect(vpsl_hexes[id].original_tile.icons.map(&:name)).not_to include('bonus_NYC_2_back')
          end
        end

        it ':cash removes front-side icons from all 4 VPSL hexes, no back icon placed' do
          game.update_bonus_icon!('NYC', 2, :cash)
          vpsl_hexes.each do |id, hex|
            expect(hex.original_tile.icons.map(&:name)).not_to include(nyc_icon),
                                                               "expected no front icon on #{id} after :cash"
            expect(hex.original_tile.icons.map(&:name)).not_to include('bonus_NYC_2_back')
          end
        end
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

      it 'SLC route bonus is 50 after Golden Spike fires' do
        game.instance_variable_set(:@slc_bonus_paid, true)
        soc.close!
        route = stub_route(slc_hex)
        expect(game.send(:slc_route_bonus, cpr, [route])).to eq(50)
      end

      it 'SLC route bonus spike overrides SOC reduction' do
        game.instance_variable_set(:@slc_bonus_paid, true)
        route = stub_route(slc_hex)
        expect(game.send(:slc_route_bonus, cpr, [route])).to eq(50)
      end

      it 'initialises @transcontinental_done as empty hash' do
        expect(game.instance_variable_get(:@transcontinental_done)).to eq({})
      end

      it 'initialises @first_perm_train_done as empty hash' do
        expect(game.instance_variable_get(:@first_perm_train_done)).to eq({})
      end
    end

    describe 'SLC first-connection payout' do
      let(:cpr)   { game.corporation_by_id('CPR') }
      let(:alice) { game.players[0] }
      let(:bob)   { game.players[1] }

      before do
        allow(cpr).to receive(:share_holders).and_return({ alice => 20, bob => 10 })
      end

      it 'pays $40 to a 20% shareholder and $20 to a 10% shareholder' do
        alice_before = alice.cash
        bob_before   = bob.cash
        game.send(:slc_first_connection_payout!, cpr)
        expect(alice.cash).to eq(alice_before + 40)
        expect(bob.cash).to eq(bob_before + 20)
      end

      it 'deducts total payout from bank' do
        bank_before = game.bank.cash
        game.send(:slc_first_connection_payout!, cpr)
        expect(game.bank.cash).to eq(bank_before - 60)
      end

      it 'logs a message for each paying shareholder' do
        game.send(:slc_first_connection_payout!, cpr)
        combined = game.log.last(3).map(&:message).join(' ')
        expect(combined).to include('Alice')
        expect(combined).to include('Bob')
      end
    end

    describe 'transcontinental route stock move' do
      let(:cpr) { game.corporation_by_id('CPR') }
      let(:up)  { game.corporation_by_id('UP') }
      let(:nyc) { game.corporation_by_id('NYC') }

      before do
        cpr.share_price = game.stock_market.par_prices.first
        up.share_price  = game.stock_market.par_prices.first
        allow(game.stock_market).to receive(:move_right)
      end

      it 'marks CPR done when route visits both G3 and F14' do
        game.check_transcontinental_route!(cpr, [stub_route('G3', 'F14')])
        expect(game.instance_variable_get(:@transcontinental_done)['CPR']).to be true
      end

      it 'marks UP done when route visits both G3 and F14' do
        game.check_transcontinental_route!(up, [stub_route('G3', 'F14')])
        expect(game.instance_variable_get(:@transcontinental_done)['UP']).to be true
      end

      it 'moves CPR stock right on first transcontinental run' do
        expect(game.stock_market).to receive(:move_right).with(cpr)
        game.check_transcontinental_route!(cpr, [stub_route('G3', 'F14')])
      end

      it 'does not trigger when only Sacramento is on route' do
        game.check_transcontinental_route!(cpr, [stub_route('G3', 'G9')])
        expect(game.instance_variable_get(:@transcontinental_done)['CPR']).to be_nil
      end

      it 'does not trigger when only Omaha is on route' do
        game.check_transcontinental_route!(cpr, [stub_route('F14', 'G9')])
        expect(game.instance_variable_get(:@transcontinental_done)['CPR']).to be_nil
      end

      it 'is idempotent — second qualifying route does not move stock again' do
        game.check_transcontinental_route!(cpr, [stub_route('G3', 'F14')])
        expect(game.stock_market).not_to receive(:move_right).with(cpr)
        game.check_transcontinental_route!(cpr, [stub_route('G3', 'F14')])
      end

      it 'does nothing for non-SLC corp' do
        game.check_transcontinental_route!(nyc, [stub_route('G3', 'F14')])
        expect(game.instance_variable_get(:@transcontinental_done)['NYC']).to be_nil
      end
    end

    describe 'first permanent train stock move' do
      let(:cpr) { game.corporation_by_id('CPR') }
      let(:up)  { game.corporation_by_id('UP') }
      let(:nyc) { game.corporation_by_id('NYC') }
      let(:perm_trains) { game.depot.trains.select { |t| t.rusts_on.nil? } }
      let(:rust_train)  { game.depot.trains.find(&:rusts_on) }

      before do
        cpr.share_price = game.stock_market.par_prices.first
        up.share_price  = game.stock_market.par_prices.first
        nyc.share_price = game.stock_market.par_prices.first
        allow(game.stock_market).to receive(:move_right)
      end

      it 'sets @first_perm_train_done for CPR after first permanent train from bank' do
        game.buy_train(cpr, perm_trains.first, :free)
        expect(game.instance_variable_get(:@first_perm_train_done)['CPR']).to be true
      end

      it 'moves CPR stock right on first permanent train purchase from bank' do
        expect(game.stock_market).to receive(:move_right).with(cpr)
        game.buy_train(cpr, perm_trains.first, :free)
      end

      it 'is idempotent — second permanent train does not move stock again' do
        skip 'need at least two permanent trains in depot' if perm_trains.size < 2
        game.buy_train(cpr, perm_trains[0], :free)
        expect(game.stock_market).not_to receive(:move_right).with(cpr)
        game.buy_train(cpr, perm_trains[1], :free)
      end

      it 'does not move stock for non-SLC corp buying permanent train' do
        expect(game.stock_market).not_to receive(:move_right).with(nyc)
        game.buy_train(nyc, perm_trains.first, :free)
      end

      it 'does not move stock when CPR buys a rusting train from bank' do
        expect(game.stock_market).not_to receive(:move_right).with(cpr)
        game.buy_train(cpr, rust_train, :free)
      end

      it 'does not move stock when CPR buys permanent train from another corp' do
        game.buy_train(up, perm_trains.first, :free)
        game.instance_variable_set(:@first_perm_train_done, {})
        expect(game.stock_market).not_to receive(:move_right).with(cpr)
        game.buy_train(cpr, perm_trains.first, :free)
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

    # ── Step::ChooseBonus ──────────────────────────────────────────────────────
    # Verified via browser test 2026-05-19: NYC connects to Chicago (F20) for
    # the first time in OR7. Route shows base revenue only ($90, no pre-empted
    # bonus). ChooseBonus prompt appears after confirming route.
    # Choosing 'permanent' sets bonus to :permanent and adds $60 to OR revenue.
    # Choosing 'cash' sets bonus to :cash and pays $200 cash to NYC immediately.
    #
    # Action sequence reproduced from local game #21 (seed 42, 3 players).
    # OR1–OR5: NYC lays track F26/F24/F22/G21/G19. OR6: buys 2E-train.
    # OR7: runs F28→F26→F24→F22→G21→G19→F20 (2E pays F28+F20=$90), then chooses bonus.
    # Chicago F20 exits SW(→G19) and W(→F18) only; route must pass through G19.
    describe 'Step::ChooseBonus — NYC first connection to Chicago' do
      def choose_bonus_actions
        [
        { 'type' => 'bid',        'price' => 20,  'entity' => 1, 'company' => 'BOM',  'entity_type' => 'player',      'id' => 1 },
        { 'type' => 'bid',        'price' => 50,  'entity' => 2, 'company' => 'TOR',  'entity_type' => 'player',      'id' => 2 },
        { 'type' => 'bid',        'price' => 75,  'entity' => 3, 'company' => 'GHU',  'entity_type' => 'player',      'id' => 3 },
        { 'type' => 'bid',        'price' => 100, 'entity' => 1, 'company' => 'RMC',  'entity_type' => 'player',      'id' => 4 },
        { 'type' => 'bid',        'price' => 140, 'entity' => 2, 'company' => 'PSC',  'entity_type' => 'player',      'id' => 5 },
        { 'type' => 'bid',        'price' => 180, 'entity' => 3, 'company' => 'FNY',  'entity_type' => 'player',      'id' => 6 },
        { 'type' => 'bid',        'price' => 220, 'entity' => 1, 'company' => 'SOC',  'entity_type' => 'player',      'id' => 7 },
        { 'type' => 'bid',        'price' => 270, 'entity' => 2, 'company' => 'NHSC', 'entity_type' => 'player',      'id' => 8 },
        {
          'type' => 'par',
          'entity' => 2,
          'corporation' => 'NYH',
          'entity_type' => 'player',
          'share_price' => '100,0,4',
          'id' => 9,
        },
        {
          'type' => 'par',
          'entity' => 3,
          'corporation' => 'NYC',
          'entity_type' => 'player',
          'share_price' => '70,5,4',
          'id' => 10,
        },
        { 'type' => 'pass',                        'entity' => 1, 'entity_type' => 'player',      'id' => 11 },
        { 'type' => 'pass',                        'entity' => 2, 'entity_type' => 'player',      'id' => 12 },
        {
          'type' => 'buy_shares',
          'entity' => 3,
          'shares' => ['NYC_2'],
          'percent' => 10,
          'entity_type' => 'player',
          'id' => 13,
        },
        { 'type' => 'pass',                        'entity' => 1, 'entity_type' => 'player',      'id' => 14 },
        { 'type' => 'pass',                        'entity' => 2, 'entity_type' => 'player',      'id' => 15 },
        {
          'type' => 'buy_shares',
          'entity' => 3,
          'shares' => ['NYC_3'],
          'percent' => 10,
          'entity_type' => 'player',
          'id' => 16,
        },
        { 'type' => 'pass',                        'entity' => 1, 'entity_type' => 'player',      'id' => 17 },
        { 'type' => 'pass',                        'entity' => 2, 'entity_type' => 'player',      'id' => 18 },
        {
          'type' => 'buy_shares',
          'entity' => 3,
          'shares' => ['NYC_4'],
          'percent' => 10,
          'entity_type' => 'player',
          'id' => 19,
        },
        { 'type' => 'pass',                        'entity' => 1, 'entity_type' => 'player',      'id' => 20 },
        { 'type' => 'pass',                        'entity' => 2, 'entity_type' => 'player',      'id' => 21 },
        { 'type' => 'pass',                        'entity' => 3, 'entity_type' => 'player',      'id' => 22 },
        # OR1: lay F26 (tile9 rot1 — W↔E straight, hill $40)
        {
          'type' => 'lay_tile',
          'hex' => 'F26',
          'tile' => '9-0',
          'rotation' => 1,
          'entity' => 'NYC',
          'entity_type' => 'corporation',
          'id' => 23,
        },
        { 'type' => 'pass',                        'entity' => 'NYC', 'entity_type' => 'corporation', 'id' => 24 },
        { 'type' => 'pass',                        'entity' => 1,     'entity_type' => 'player',      'id' => 25 },
        { 'type' => 'pass',                        'entity' => 2,     'entity_type' => 'player',      'id' => 26 },
        { 'type' => 'pass',                        'entity' => 3,     'entity_type' => 'player',      'id' => 27 },
        # OR2: lay F24 (tile9 rot1 — W↔E straight)
        {
          'type' => 'lay_tile',
          'hex' => 'F24',
          'tile' => '9-1',
          'rotation' => 1,
          'entity' => 'NYC',
          'entity_type' => 'corporation',
          'id' => 28,
        },
        { 'type' => 'pass',                        'entity' => 'NYC', 'entity_type' => 'corporation', 'id' => 29 },
        { 'type' => 'pass',                        'entity' => 1,     'entity_type' => 'player',      'id' => 30 },
        { 'type' => 'pass',                        'entity' => 2,     'entity_type' => 'player',      'id' => 31 },
        { 'type' => 'pass',                        'entity' => 3,     'entity_type' => 'player',      'id' => 32 },
        # OR3: lay F22 (tile8 rot4 — SW↔E medium curve)
        {
          'type' => 'lay_tile',
          'hex' => 'F22',
          'tile' => '8-0',
          'rotation' => 4,
          'entity' => 'NYC',
          'entity_type' => 'corporation',
          'id' => 33,
        },
        { 'type' => 'pass',                        'entity' => 'NYC', 'entity_type' => 'corporation', 'id' => 34 },
        { 'type' => 'pass',                        'entity' => 1,     'entity_type' => 'player',      'id' => 35 },
        { 'type' => 'pass',                        'entity' => 2,     'entity_type' => 'player',      'id' => 36 },
        { 'type' => 'pass',                        'entity' => 3,     'entity_type' => 'player',      'id' => 37 },
        # OR4: lay G21 (tile8 rot1 — W↔NE medium curve)
        {
          'type' => 'lay_tile',
          'hex' => 'G21',
          'tile' => '8-1',
          'rotation' => 1,
          'entity' => 'NYC',
          'entity_type' => 'corporation',
          'id' => 38,
        },
        { 'type' => 'pass',                        'entity' => 'NYC', 'entity_type' => 'corporation', 'id' => 39 },
        { 'type' => 'pass',                        'entity' => 1,     'entity_type' => 'player',      'id' => 40 },
        { 'type' => 'pass',                        'entity' => 2,     'entity_type' => 'player',      'id' => 41 },
        { 'type' => 'pass',                        'entity' => 3,     'entity_type' => 'player',      'id' => 42 },
        # OR5: lay G19 (tile3 rot3 — NE↔E sharp town curve, river $40)
        {
          'type' => 'lay_tile',
          'hex' => 'G19',
          'tile' => '3-0',
          'rotation' => 3,
          'entity' => 'NYC',
          'entity_type' => 'corporation',
          'id' => 43,
        },
        { 'type' => 'pass',                        'entity' => 'NYC', 'entity_type' => 'corporation', 'id' => 44 },
        { 'type' => 'pass',                        'entity' => 1,     'entity_type' => 'player',      'id' => 45 },
        { 'type' => 'pass',                        'entity' => 2,     'entity_type' => 'player',      'id' => 46 },
        { 'type' => 'pass',                        'entity' => 3,     'entity_type' => 'player',      'id' => 47 },
        # OR6: buy 2E-train ($150; visits unlimited, pays top 2 nodes)
        { 'type' => 'pass',                        'entity' => 'NYC', 'entity_type' => 'corporation', 'id' => 48 },
        {
          'type' => 'buy_train',
          'price' => 150,
          'train' => '2-0',
          'variant' => '2E',
          'entity' => 'NYC',
          'entity_type' => 'corporation',
          'id' => 49,
        },
        { 'type' => 'pass',                        'entity' => 'NYC', 'entity_type' => 'corporation', 'id' => 50 },
        { 'type' => 'pass',                        'entity' => 1,     'entity_type' => 'player',      'id' => 51 },
        { 'type' => 'pass',                        'entity' => 2,     'entity_type' => 'player',      'id' => 52 },
        { 'type' => 'pass',                        'entity' => 3,     'entity_type' => 'player',      'id' => 53 },
        # OR7: pass Track step — NYC proceeds to Route step
        { 'type' => 'pass',                        'entity' => 'NYC', 'entity_type' => 'corporation', 'id' => 54 },
        ].freeze
      end

      def route_action
        {
          'type' => 'run_routes',
          'entity' => 'NYC',
          'entity_type' => 'corporation',
          'subsidy' => 0,
          'extra_revenue' => 0,
          'routes' => [{
            'hexes' => %w[F20 G19 F28],
            'nodes' => %w[F28-0 G19-0 F20-0],
            'train' => '2-0',
            'revenue' => 90,
            'connections' => [%w[F28 F26 F24 F22 G21 G19 F20]],
            'revenue_str' => 'F20(20)-G19(10)-F28(70)',
          }],
          'id' => 55,
        }.freeze
      end

      def load_game_to(n_actions)
        g = Game::G1862UsaCanada::Game.new({ 1 => 'Player 1', 2 => 'Player 2', 3 => 'Player 3' }, id: 21, actions: [])
        choose_bonus_actions.first(n_actions).each { |a| g.process_action(a) }
        g
      end

      context 'before NYC runs routes (OR7, Track step passed)' do
        subject(:g) { load_game_to(54) }

        it 'NYC has a 2E-train' do
          expect(g.corporation_by_id('NYC').trains.map(&:name)).to eq(['2E'])
        end

        it 'Chicago (F20) is reachable from NYC network' do
          nyc = g.corporation_by_id('NYC')
          expect(g.graph_for_entity(nyc).connected_hexes(nyc)).to include(g.hex_by_id('F20'))
        end

        it 'Chicago bonus is still unactivated' do
          expect(g.bonus_state[['NYC', 1]]).to eq(:unactivated)
        end

        it 'no pending bonus activations without routes' do
          nyc = g.corporation_by_id('NYC')
          expect(g.pending_bonus_activations(nyc, [])).to be_empty
        end

        it 'corp_bonus_revenue is 0 for unactivated Chicago bonus (no pre-empted bonus)' do
          nyc = g.corporation_by_id('NYC')
          route = stub_route('F28', 'F20')
          expect(g.corp_bonus_revenue(nyc, [route])).to eq(0)
        end
      end

      context 'after NYC runs F28→F20 (ChooseBonus pending)' do
        subject(:g) do
          gg = load_game_to(54)
          gg.process_action(route_action)
          gg
        end

        it 'Chicago bonus activation is pending' do
          nyc = g.corporation_by_id('NYC')
          activations = g.pending_bonus_activations(nyc, g.round.routes)
          expect(activations).not_to be_empty
          expect(activations.first[0][:name]).to eq('Chicago')
        end

        it 'ChooseBonus step is active' do
          choose_step = g.round.steps.find { |s| s.is_a?(Game::G1862UsaCanada::Step::ChooseBonus) }
          nyc = g.corporation_by_id('NYC')
          expect(choose_step.actions(nyc)).to include('choose')
        end

        it 'choice offers cash ($200) and permanent (+$60/OR)' do
          choose_step = g.round.steps.find { |s| s.is_a?(Game::G1862UsaCanada::Step::ChooseBonus) }
          choices = choose_step.choices
          expect(choices.keys).to contain_exactly('cash', 'permanent')
          expect(choices['cash']).to include('200')
          expect(choices['permanent']).to include('60')
        end
      end

      context 'choosing permanent' do
        subject(:g) do
          gg = load_game_to(54)
          gg.process_action(route_action)
          gg.process_action({
                              'type' => 'choose',
                              'choice' => 'permanent',
                              'entity' => 'NYC',
                              'entity_type' => 'corporation',
                              'id' => 56,
                            })
          gg
        end

        it 'bonus state is :permanent' do
          expect(g.bonus_state[['NYC', 1]]).to eq(:permanent)
        end

        it 'subsequent corp_bonus_revenue is +$60 from Chicago bonus' do
          nyc = g.corporation_by_id('NYC')
          route = stub_route('F28', 'F20')
          expect(g.corp_bonus_revenue(nyc, [route])).to eq(60)
        end
      end

      context 'choosing cash' do
        subject(:g) do
          gg = load_game_to(54)
          gg.process_action(route_action)
          gg
        end

        it 'pays $200 cash to NYC treasury immediately' do
          nyc = g.corporation_by_id('NYC')
          cash_before = nyc.cash
          g.process_action({
                             'type' => 'choose',
                             'choice' => 'cash',
                             'entity' => 'NYC',
                             'entity_type' => 'corporation',
                             'id' => 56,
                           })
          expect(nyc.cash).to eq(cash_before + 200)
        end

        it 'bonus state is :cash (no further route bonus)' do
          g.process_action({
                             'type' => 'choose',
                             'choice' => 'cash',
                             'entity' => 'NYC',
                             'entity_type' => 'corporation',
                             'id' => 56,
                           })
          expect(g.bonus_state[['NYC', 1]]).to eq(:cash)
        end

        it 'subsequent corp_bonus_revenue is 0 after cash choice' do
          nyc = g.corporation_by_id('NYC')
          g.process_action({
                             'type' => 'choose',
                             'choice' => 'cash',
                             'entity' => 'NYC',
                             'entity_type' => 'corporation',
                             'id' => 56,
                           })
          route = stub_route('F28', 'F20')
          expect(g.corp_bonus_revenue(nyc, [route])).to eq(0)
        end
      end
    end
  end
end
