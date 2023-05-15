# frozen_string_literal: true

require 'find'
require './spec/spec_helper'

module Engine
  describe Game::G18ZOO::Game do
    def par(game, player, corporation, share_price)
      game.round.process_action(Action::Par.new(player, corporation: corporation, share_price: share_price))
      game.round.process_action(Action::Pass.new(corporation))
      game.round.process_action(Action::Pass.new(player))
    end

    def pass_until_player(game, player)
      3.times do |_|
        game.round.process_action(Engine::Action::Pass.new(game.current_entity)) if game.current_entity != player
      end
    end

    shared_examples 'a purchasable power' do
      it 'is inside available_companies' do
        expect(power).to be_truthy
      end
    end

    shared_examples 'power not implemented' do
      it 'cannot be purchased yet' do
        expect do
          first_player_buy_power_on_isr(power).maybe_raise!
        end.to raise_error(Engine::GameError, 'Power logic not yet implemented')
      end
    end

    shared_examples 'with choice' do
      it 'should have a choice' do
        expect(game.round.active_step.actions(game.current_entity)).to include 'choose'
        expect(game.round.active_step.choices).to include choice
      end
    end

    shared_examples 'without choice' do
      it 'should not have any choice' do
        expect(game.round.active_step.choices).to be_empty
      end
    end

    shared_context 'when player 1 buys it' do
      before do
        first_player_buy_power_on_isr(power)
        next_sr!
      end
    end

    shared_context 'when player 1 sell a company' do
      before do
        company = player_1.companies.find { |c| c.name.start_with?('ZOOTicket') }
        game.round.process_action(Action::SellCompany.new(player_1, company: company, price: 4))
      end
    end

    shared_context 'when player X par corporation Y' do
      let(:share_price) { game.stock_market.par_prices.find { |par_price| par_price.price == 5 } }
      let(:skip_action) { true }
      let(:skip_after) { 2 }

      before do
        2.times do |_|
          game.round.process_action(Engine::Action::Pass.new(game.current_entity)) if game.current_entity != player
        end

        game.round.process_action(Action::Par.new(player, corporation: corporation, share_price: share_price))
        game.round.process_action(Action::Pass.new(corporation))
        game.round.process_action(Action::Pass.new(player)) if skip_action

        skip_after.times { |_| game.round.process_action(Engine::Action::Pass.new(game.current_entity)) }
        expect(game.round.current_entity).to be(player_1)
      end
    end

    shared_context 'when player 1 par corporation 1' do
      include_context 'when player X par corporation Y' do
        let(:player) { player_1 }
        let(:corporation) { game.corporations.first }
      end
    end

    shared_context 'when player 2 par corporation 1' do
      include_context 'when player X par corporation Y' do
        let(:player) { game.players[1] }
        let(:corporation) { game.corporations.first }
        let(:skip_after) { 1 }
      end
    end

    shared_context 'when player 1 uses choice' do
      before do
        game.round.process_action(Engine::Action::Choose.new(game.current_entity, choice: choice))
      end
    end

    shared_context 'when player 1 (pars, then-)buys share of corporation 1' do
      let(:share_price) { game.stock_market.par_prices.find { |par_price| par_price.price == 5 } }
      let(:corporation) { game.corporations.first }

      before do
        game.stock_market.set_par(corporation, share_price)
        game.share_pool.buy_shares(player_1, corporation.shares[0])
        game.round.process_action(Action::BuyShares.new(player_1, shares: corporation.shares[0]))
      end
    end

    shared_context 'when player 1 sells share of corporation 1' do
      let(:share_price) { game.stock_market.par_prices.find { |par_price| par_price.price == 5 } }
      let(:corporation) { game.corporations.first }

      before do
        game.stock_market.set_par(corporation, share_price)
        2.times { game.share_pool.buy_shares(player_1, corporation.shares[0]) }
        game.round.process_action(Action::SellShares.new(player_1, shares: player_1.shares[1]))
      end
    end

    def next_round!
      loop do
        game.send(:next_round!)
        game.round.setup
        break if yield
      end
      game.round
    end

    def next_or!
      next_round! { game.round.is_a?(Engine::Round::Operating) }
    end

    def next_sr!
      next_round! { game.round.is_a?(Engine::Round::Stock) }
    end

    def first_player_buy_power_on_isr(company)
      2.times { |_| game.round.process_action(Engine::Action::Pass.new(game.current_entity)) }
      game.round.process_action(Engine::Action::Bid.new(game.current_entity, price: company.value, company: company))
    end

    describe 'starting values' do
      max_players = { map_a_d: 5, map_b: 5, map_c: 5, map_d: 5, map_e: 5, map_f: 5 }
      game_by_variant = {
        map_a_d: Engine::Game::G18ZOO::Game,
        map_a: Engine::Game::G18ZOOMapA::Game,
        map_b: Engine::Game::G18ZOOMapB::Game,
        map_c: Engine::Game::G18ZOOMapC::Game,
        map_d: Engine::Game::G18ZOOMapD::Game,
        map_e: Engine::Game::G18ZOOMapE::Game,
        map_f: Engine::Game::G18ZOOMapF::Game,
      }
      expected_cash = {
        map_a_d: { 2 => 40, 3 => 28, 4 => 27, 5 => 22 },
        map_a: { 2 => 40, 3 => 28, 4 => 23, 5 => 22 },
        map_b: { 2 => 40, 3 => 28, 4 => 23, 5 => 22 },
        map_c: { 2 => 40, 3 => 28, 4 => 23, 5 => 22 },
        map_d: { 2 => 48, 3 => 32, 4 => 27, 5 => 22 },
        map_e: { 2 => 48, 3 => 32, 4 => 27, 5 => 22 },
        map_f: { 2 => 48, 3 => 32, 4 => 27, 5 => 22 },
      }
      expected_cert_limit = {
        map_a_d: { 2 => 10, 3 => 7, 4 => 7, 5 => 6 },
        map_a: { 2 => 10, 3 => 7, 4 => 5, 5 => 6 },
        map_b: { 2 => 10, 3 => 7, 4 => 5, 5 => 6 },
        map_c: { 2 => 10, 3 => 7, 4 => 5, 5 => 6 },
        map_d: { 2 => 12, 3 => 9, 4 => 7, 5 => 6 },
        map_e: { 2 => 12, 3 => 9, 4 => 7, 5 => 6 },
        map_f: { 2 => 12, 3 => 9, 4 => 7, 5 => 6 },
      }
      expected_ticket_zoo = { 2 => 3, 3 => 3, 4 => 3, 5 => 2 }
      expected_corporations = { map_a: 5, map_b: 5, map_c: 5, map_d: 7, map_e: 7, map_f: 7 }
      expected_available_companies = { 2 => 4, 3 => 4, 4 => 4, 5 => 6 }
      expected_future_companies = { 2 => 4, 3 => 4, 4 => 4, 5 => 4 }

      max_players.each do |variant, max_players_for_map|
        (2..max_players_for_map).each do |num_players|
          current_players = %w[a b c d e].first(num_players)

          context "#{num_players} Players, #{variant}" do
            let(:game) { game_by_variant[variant].new(current_players, optional_rules: [variant.to_sym]) }
            let(:player_1) { game.players.first }

            it "should start with #{expected_cash[variant][num_players]}$N" do
              expect(player_1.cash).to eq(expected_cash[variant][num_players])
            end

            it "should have #{expected_cert_limit[variant][num_players]} cert limit" do
              expect(game.cert_limit).to eq(expected_cert_limit[variant][num_players])
            end

            it "should start with #{expected_ticket_zoo[num_players]} ticket zoo" do
              expect(player_1.companies.count do |c|
                c.name.start_with?('ZOOTicket')
              end).to eq(expected_ticket_zoo[num_players])
            end

            if expected_corporations[variant]
              it "should have #{expected_corporations[variant]} corporation in game" do
                expect(game.corporations.size).to eq(expected_corporations[variant])
              end
            end

            it "should contains #{expected_available_companies[num_players]} available companies for isr" do
              expect(game.available_companies.size).to eq(expected_available_companies[num_players])
            end

            it "should contains #{expected_future_companies[num_players]} future companies for isr" do
              expect(game.future_companies.size).to eq(expected_future_companies[num_players])
            end

            it 'should have only valid corporation coordinates' do
              game.game_corporation_coordinates.each do |_id, coordinate|
                expect(game.hexes.map(&:coordinates)).to include(coordinate.to_s)
              end
            end

            it 'should have only valid location names' do
              game.game_location_names.each do |coordinate, _name|
                expect(game.hexes.map(&:coordinates)).to include(coordinate)
              end
            end
          end
        end
      end
    end

    describe 'phases' do
      let(:players) { %w[a b c] }
      let(:game) { Engine::Game::G18ZOO::Game.new(players) }
      let(:player_1) { game.players.first }
      let(:player_2) { game.players[1] }
      let(:player_3) { game.players[2] }
      let(:corporation) { game.corporations.first }
      let(:stock_market) { game.stock_market }
      let(:phase) { game.phase }
      let(:par_prices) { game.round.active_step.get_par_prices(player_1, corporation).sort_by(&:price).map(&:price) }

      before do
        next_sr!
      end

      describe 'certificate limit' do
        let(:share_price) { stock_market.par_prices.find { |par_price| par_price.price == 5 } }

        it 'can\'t buy over 80%' do
          player_1.cash = 10_000
          stock_market.set_par(corporation, stock_market.par_prices.find { |price| price.price == 5 })
          3.times { game.share_pool.buy_shares(player_1, corporation.shares[0]) }

          expect(game.active_step.can_buy?(player_1, corporation.shares[0])).to be_falsy
        end

        it 'should be able to get 100% buying from market' do
          player_1.cash = 10_000
          stock_market.set_par(corporation, stock_market.par_prices.find { |price| price.price == 5 })
          3.times { game.share_pool.buy_shares(player_1, corporation.shares[0]) }

          player_2.cash = 10_000
          game.share_pool.buy_shares(player_2, corporation.shares[0])
          game.share_pool.sell_shares(ShareBundle.new(player_2.shares))

          share = game.share_pool.shares_of(corporation)[0]
          expect(game.active_step.can_buy?(player_1, share)).to be_truthy
          game.share_pool.buy_shares(player_1, share)

          expect(game.active_step.can_buy?(player_1, game.share_pool.shares_of(corporation)[1])).to be_falsy
        end

        it 'can buy 120% only on third sr' do
          next_sr!
          next_sr!

          player_1.cash = 10_000
          stock_market.set_par(corporation, stock_market.par_prices.find { |price| price.price == 5 })
          3.times { game.share_pool.buy_shares(player_1, corporation.shares[0]) }

          player_2.cash = 10_000
          2.times do
            game.share_pool.buy_shares(player_2, corporation.shares[0])
            game.share_pool.sell_shares(ShareBundle.new(player_2.shares))

            share = game.share_pool.shares_of(corporation)[0]
            expect(game.active_step.can_buy?(player_1, share)).to be_truthy
            game.share_pool.buy_shares(player_1, share)
          end

          expect(player_1.shares_of(corporation).size).to eq(5)
        end
      end

      [
        { phase: :yellow, price: 5, expected_par_prices: [5, 6, 7], gain: 0, trains: [] },
        { phase: :yellow, price: 6, expected_par_prices: [5, 6, 7], gain: 0, trains: [] },
        { phase: :yellow, price: 7, expected_par_prices: [5, 6, 7], gain: 0, trains: [] },
        { phase: :green, price: 9, expected_par_prices: [5, 6, 7, 9], gain: 5, trains: ['3S'] },
        { phase: :brown, price: 12, expected_par_prices: [5, 6, 7, 9, 12], gain: 10, trains: ['3S', '4S', '4S Perm'] },
      ].each do |data|
        describe (data[:phase]).to_s do
          let(:share_price) { stock_market.par_prices.find { |par_price| par_price.price == data[:price] } }

          it "should have only #{data[:expected_par_prices]} as valid par value" do
            next_or!
            data[:trains].each do |train|
              train_found = game.trains.find { |t| t.name == train }
              phase.buying_train!(corporation, train_found, train_found.owner)
            end
            next_sr!

            expect(par_prices).to eq(data[:expected_par_prices])
          end

          it "should gain #{data[:gain] || 'nothing'} when par #{data[:price]}" do
            game.round.process_action(Action::Par.new(player_1, corporation: corporation, share_price: share_price))

            expect(corporation.cash).to eq((data[:price] * 2) + data[:gain])
          end
        end
      end

      describe 'home track' do
        [
          {
            phase: 'yellow',
            share: 5,
            trains: [],
            track_for_invalid: [
              { lay: nil, tiles: %w[5-0 5-1 6-0 6-1 57-0 57-1] },
              { lay: '57-0', tiles: [] },
            ],
            track_for_valid: [
              { color: nil, tiles: %w[57-0] },
            ],
          },
          {
            phase: 'green',
            share: 9,
            trains: %w[3S],
            track_for_invalid: [
              { lay: nil, tiles: %w[5-0 5-1 6-0 6-1 57-0 57-1 14-0 14-1 15-0 15-1] },
              { lay: '57-0', tiles: %w[14-0 14-1 15-0 15-1] },
              { lay: '14-0', tiles: [] },
            ],
            track_for_valid: [
              { color: nil, lay: nil, tiles: %w[14-0 57-0] },
              { color: 'yellow', lay: '57-0', tiles: %w[14-0] },
            ],
          },
          {
            phase: 'brown',
            share: 12,
            trains: %w[3S 4S 5S],
            track_for_invalid: [
              { lay: nil, tiles: %w[5-0 5-1 6-0 6-1 57-0 57-1 14-0 14-1 15-0 15-1 611-0 611-1 611-2] },
              { lay: '57-0', tiles: %w[14-0 14-1 15-0 15-1 611-0 611-1 611-2] },
              { lay: '14-0', tiles: %w[611-0 611-1 611-2] },
              { lay: '611-0', tiles: [] },
            ],
            track_for_valid: [
              { color: nil, lay: nil, tiles: %w[14-0 57-0 611-0] },
              { color: 'yellow', lay: '57-0', tiles: %w[14-0 611-0] },
              { color: 'green', lay: '14-0', tiles: %w[611-0] },
            ],
          },
        ].each do |item|
          describe "when on #{item[:phase]} phase" do
            let(:share_price) { game.stock_market.par_prices.find { |par_price| par_price.price == item[:share] } }

            before do
              item[:trains].each do |train|
                train_found = game.trains.find { |t| t.name == train }
                phase.buying_train!(corporation, train_found, train_found.owner)
              end
            end

            item[:track_for_valid].each do |track_for_valid|
              describe "when hex tile is #{track_for_valid[:color] || 'empty'}" do
                before do
                  game.hex_by_id(corporation.coordinates).lay(game.tile_by_id(track_for_valid[:lay])) if track_for_valid[:lay]

                  game.round.process_action(Action::Par.new(player_1, corporation: corporation,
                                                                      share_price: share_price))

                  expect(game.round.active_step).to be_instance_of(Engine::Game::G18ZOO::Step::HomeTrack)
                end
              end
            end
          end
        end
      end
    end

    describe '"family near"' do
      let(:players) { %w[a b c] }
      let(:game) { Engine::Game::G18ZOO::Game.new(players) }
      let(:player_1) { game.players.first }
      let(:player_2) { game.players[1] }
      let(:corporation) { game.corporations.first }
      let(:second_corporation) { game.corporations[1] }
      let(:last_corporation) { game.corporations.last }
      let(:share_price) { game.stock_market.par_prices.find { |par_price| par_price.price == 5 } }

      before do
        next_sr!
      end

      it 'each corporation is available at the beginning' do
        game.corporations.each { |corporation| expect(game.corporation_available?(corporation)).to be_truthy }
      end

      it 'only previous corporation and following corporation are available after first par' do
        game.round.process_action(Action::Par.new(player_1, corporation: corporation, share_price: share_price))

        [1, 4].each { |index| expect(game.corporation_available?(game.corporations[index])).to be_truthy }
        [2, 3].each { |index| expect(game.corporation_available?(game.corporations[index])).to be_falsy }
      end

      it 'only following corporation is available after first par and following par ' do
        game.round.process_action(Action::Par.new(player_1, corporation: corporation, share_price: share_price))
        game.round.process_action(Action::LayTile.new(corporation, tile: game.tile_by_id('6-0'),
                                                                   hex: game.hex_by_id('K9'), rotation: 1))
        game.round.process_action(Engine::Action::Pass.new(player_1))
        game.round.process_action(Action::Par.new(player_2, corporation: second_corporation, share_price: share_price))

        [2].each { |index| expect(game.corporation_available?(game.corporations[index])).to be_truthy }
        [3, 4].each { |index| expect(game.corporation_available?(game.corporations[index])).to be_falsy }
      end

      it 'only previous corporation is available after first par and previous par' do
        game.round.process_action(Action::Par.new(player_1, corporation: corporation, share_price: share_price))
        game.round.process_action(Action::LayTile.new(corporation, tile: game.tile_by_id('6-0'),
                                                                   hex: game.hex_by_id('K9'), rotation: 1))
        game.round.process_action(Engine::Action::Pass.new(player_1))
        game.round.process_action(Action::Par.new(player_2, corporation: last_corporation, share_price: share_price))

        [3].each { |index| expect(game.corporation_available?(game.corporations[index])).to be_truthy }
        [1, 2].each { |index| expect(game.corporation_available?(game.corporations[index])).to be_falsy }
      end
    end

    describe 'Powers' do
      let(:game_file) do
        Find.find(FIXTURES_DIR).find { |f| File.basename(f) == "#{game_file_name}.json" }
      end

      describe 'That is mine!' do
        context 'corporation already put a token' do
          let(:game_file_name) { 'or_power.that_s_mine.cannot_convert_if_already_tokened' }

          it 'cannot convert' do
            game = Engine::Game.load(game_file, at_action: 33)
            action = {
              'type' => 'place_token',
              'entity' => 'THAT_S_MINE',
              'entity_type' => 'company',
              'city' => '619-0-0',
              'slot' => 1,
            }
            expect(game.exception).to be_nil
            expect(game.process_action(action).exception).to be_a(GameError)
          end
        end

        context 'corporation has no token' do
          let(:game_file_name) { 'or_power.that_s_mine.cannot_convert_if_no_token' }

          it 'cannot convert' do
            game = Engine::Game.load(game_file, at_action: 17)
            action = {
              'type' => 'place_token',
              'entity' => 'THAT_S_MINE',
              'entity_type' => 'company',
              'city' => '201-0-0',
              'slot' => 0,
            }
            expect(game.exception).to be_nil
            expect(game.process_action(action).exception).to be_a(GameError)
          end
        end

        context 'corporation has no money' do
          let(:game_file_name) { 'or_power.that_s_mine.cannot_convert_if_no_money' }

          it 'cannot convert' do
            game = Engine::Game.load(game_file, at_action: 16)
            action = {
              'type' => 'place_token',
              'entity' => 'THAT_S_MINE',
              'entity_type' => 'company',
              'city' => '201-0-0',
              'slot' => 0,
            }
            expect(game.exception).to be_nil
            expect(game.process_action(action).exception).to be_a(GameError)
          end
        end

        context 'reserved hex is not reachable' do
          let(:game_file_name) { 'or_power.that_s_mine' }

          it 'cannot convert' do
            game = Engine::Game.load(game_file, at_action: 10)
            action = {
              'type' => 'place_token',
              'entity' => 'THAT_S_MINE',
              'entity_type' => 'company',
              'city' => 'L4-3-1',
              'slot' => 0,
            }
            expect(game.exception).to be_nil
            expect(game.process_action(action).exception).to be_a(GameError)
          end
        end
      end

      describe 'A tip of sugar' do
        context 'when used on two train' do
          let(:game_file_name) { 'or_power.a_tip_of_sugar' }

          it 'must fail' do
            game = Engine::Game.load(game_file, at_action: 33)
            action = {
              'type' => 'run_routes',
              'entity' => 'PE',
              'entity_type' => 'corporation',
              'routes' => [
                {
                  'train' => '2S-0',
                  'connections' => [
                    %w[K17 J18 I19],
                    %w[K17 L16 M17 N18],
                  ],
                  'hexes' => %w[I19 K17 N18],
                },
                {
                  'train' => '2S-1',
                  'connections' => [
                    %w[K15 K17],
                    %w[K15 J16 I17 I19],
                  ],
                  'hexes' => %w[K17 K15 I19],
                },
              ],
            }
            expect do
              game.process_action(action).maybe_raise!
            end.to raise_error(Engine::GameError, 'Only one train can use "A tip of sugar"')
          end
        end

        context 'two different train use wings' do
          let(:game_file_name) { 'or_power.wings' }

          it 'is not possible' do
            game = Engine::Game.load(game_file, at_action: 59)
            action = {
              'type' => 'run_routes',
              'entity' => 'GI',
              'entity_type' => 'corporation',
              'routes' => [
                {
                  'train' => '2S-1',
                  'connections' => [
                    %w[L4 M5],
                    %w[K9 K7 L6 L4],
                  ],
                  'hexes' => %w[M5 L4 K9],
                },
                {
                  'train' => '3S-0',
                  'connections' => [
                    %w[K15 K13 K11 K9],
                    %w[K15 K17],
                    %w[K17 L16 M15 N14],
                    %w[N14 N12],
                  ],
                  'hexes' => %w[K15 K17 N14 N12],
                },
              ],
            }
            expect do
              game.process_action(action).maybe_raise!
            end.to raise_error(Engine::GameError, 'Only one train can bypass a tokened-out city')
          end
        end

        context 'City with "Work in progress"' do
          let(:game_file_name) { 'or_power.work_in_progress.cannot_ignore_with_wings' }

          it 'cannot be pass-through' do
            game = Engine::Game.load(game_file, at_action: 17)
            action = {
              'type' => 'run_routes',
              'entity' => 'GI',
              'entity_type' => 'corporation',
              'routes' => [
                {
                  'train' => '2S-0',
                  'connections' => [
                    %w[L4 M5],
                    %w[K9 K7 L6 L4],
                  ],
                  'hexes' => %w[M5 L4 K9],
                },
              ],
            }
            expect do
              game.process_action(action).maybe_raise!
            end.to raise_error(Engine::GameError,
                               'City with only \'Work in progress\' slot cannot be bypassed')
          end
        end
      end

      describe 'Wings' do
        context 'fly over two cities' do
          let(:game_file_name) { 'or_power.wings' }

          it 'is not possible' do
            game = Engine::Game.load(game_file, at_action: 59)
            action = {
              'type' => 'run_routes',
              'entity' => 'GI',
              'entity_type' => 'corporation',
              'routes' => [
                {
                  'train' => '3S-0',
                  'connections' => [
                    %w[L4 M5],
                    %w[K9 K7 L6 L4],
                    %w[K15 K13 K11 K9],
                    %w[K15 K17],
                    %w[K17 L16 M15 N14],
                    %w[N14 N12],
                  ],
                  'hexes' => %w[M5 L4 K9 K15 K17 N14 N12],
                },
              ],
            }
            expect do
              game.process_action(action).maybe_raise!
            end.to raise_error(Engine::GameError, 'Route can only bypass one tokened-out city')
          end
        end

        context 'two different train use wings' do
          let(:game_file_name) { 'or_power.wings' }

          it 'is not possible' do
            game = Engine::Game.load(game_file, at_action: 59)
            action = {
              'type' => 'run_routes',
              'entity' => 'GI',
              'entity_type' => 'corporation',
              'routes' => [
                {
                  'train' => '2S-1',
                  'connections' => [
                    %w[L4 M5],
                    %w[K9 K7 L6 L4],
                  ],
                  'hexes' => %w[M5 L4 K9],
                },
                {
                  'train' => '3S-0',
                  'connections' => [
                    %w[K15 K13 K11 K9],
                    %w[K15 K17],
                    %w[K17 L16 M15 N14],
                    %w[N14 N12],
                  ],
                  'hexes' => %w[K15 K17 N14 N12],
                },
              ],
            }
            expect do
              game.process_action(action).maybe_raise!
            end.to raise_error(Engine::GameError, 'Only one train can bypass a tokened-out city')
          end
        end

        context 'City with "Work in progress"' do
          let(:game_file_name) { 'or_power.work_in_progress.cannot_ignore_with_wings' }

          it 'cannot be pass-through' do
            game = Engine::Game.load(game_file, at_action: 17)
            action = {
              'type' => 'run_routes',
              'entity' => 'GI',
              'entity_type' => 'corporation',
              'routes' => [
                {
                  'train' => '2S-0',
                  'connections' => [
                    %w[L4 M5],
                    %w[K9 K7 L6 L4],
                  ],
                  'hexes' => %w[M5 L4 K9],
                },
              ],
            }
            expect do
              game.process_action(action).maybe_raise!
            end.to raise_error(Engine::GameError,
                               'City with only \'Work in progress\' slot cannot be bypassed')
          end
        end
      end

      describe 'Work in progress' do
        context 'token on single-slot city' do
          let(:game_file_name) { 'or_power.work_in_progress' }

          it 'block path' do
            game = Engine::Game.load(game_file, at_action: 15)
            action = {
              'type' => 'lay_tile',
              'entity' => 'PB',
              'entity_type' => 'corporation',
              'hex' => 'J4',
              'tile' => '9-0',
              'rotation' => 1,
            }
            expect { game.process_action(action).maybe_raise! }.to raise_error(TypeError)
          end
        end
      end

      describe 'Ancient Maps' do
        let(:game_file_name) { 'or_power.ancient_maps' }

        it 'can be used for M' do
          game = Engine::Game.load(game_file, at_action: 21)
          action = {
            'type' => 'lay_tile',
            'entity' => 'ANCIENT_MAPS',
            'entity_type' => 'company',
            'hex' => 'J14',
            'tile' => '8-0',
            'rotation' => 3,
          }

          game.process_action(action).maybe_raise!

          hex = game.hex_by_id('J14')
          expect(hex.tile.label.to_s).to eq('M')
          expect(hex.tile.upgrades).to be_empty

          icon = hex.tile.icons[0]
          expect(icon.image).to eq('/icons/18_zoo/mountain.svg')
          expect(icon.sticky).to be_truthy
          expect(icon.blocks_lay?).to be_truthy
        end

        it 'can be used for MM' do
          game = Engine::Game.load(game_file, at_action: 21)
          action = {
            'type' => 'lay_tile',
            'entity' => 'ANCIENT_MAPS',
            'entity_type' => 'company',
            'hex' => 'L18',
            'tile' => '8-0',
            'rotation' => 2,
          }
          game.process_action(action).maybe_raise!

          hex = game.hex_by_id('L18')
          expect(hex.tile.label.to_s).to eq('MM')
          expect(hex.tile.upgrades).to be_empty

          icon = hex.tile.icons[0]
          expect(icon.image).to eq('/icons/18_zoo/mountain.svg')
          expect(icon.sticky).to be_truthy
          expect(icon.blocks_lay?).to be_truthy
        end

        it 'can be used for Y' do
          game = Engine::Game.load(game_file, at_action: 20)
          action = {
            'type' => 'lay_tile',
            'entity' => 'ANCIENT_MAPS',
            'entity_type' => 'company',
            'hex' => 'K15',
            'tile' => '202-0',
            'rotation' => 0,
          }
          game.process_action(action)

          hex = game.hex_by_id('K15')
          expect(hex.tile.label.to_s).to eq('Y')
        end
      end

      describe 'Holes' do
        let(:game_file_name) { 'or_power.hole.no_reuse' }

        it 'cannot be used twice as terminal' do
          game = Engine::Game.load(game_file, at_action: 50).maybe_raise!

          action = {
            'type' => 'run_routes',
            'entity' => 'TI',
            'entity_type' => 'corporation',
            'routes' => [{
              'train' => '3S Long-0',
              'connections' => [
                             %w[I19 I17 H16 H14],
                             %w[H14 G15 F16 E15],
                             %w[E15 D16 C17],
                           ],
              'hexes' => %w[I19 H14 E15 C17],
            }],
          }

          expect(game.exception).to be_nil
          expect do
            game.process_action(action).maybe_raise!
          end.to raise_error(Engine::GameError, 'Route cannot use holes as terminal more than once')
        end

        it 'cannot enter and exit from a single hole' do
          game = Engine::Game.load(game_file, at_action: 50).maybe_raise!

          action = {
            'type' => 'run_routes',
            'entity' => 'TI',
            'entity_type' => 'corporation',
            'routes' => [{
              'train' => '3S Long-0',
              'connections' => [
                             %w[C13 C15 C17],
                             %w[C17 D16 E15],
                           ],
              'hexes' => %w[C13 C17 E15],
            }],
          }

          expect(game.exception).to be_nil
          expect do
            game.process_action(action).maybe_raise!
          end.to raise_error(Engine::GameError, 'Route cannot go in and out from the same hex of one of the two R AREA')
        end
      end

      describe 'Moles' do
        let(:game_file_name) { 'or_power.moles' }

        it 'can be used for M' do
          game = Engine::Game.load(game_file, at_action: 18)

          hex = game.hex_by_id('E17')
          expect(hex.tile.label.to_s).to eq('M')
          expect(hex.tile.color).to eq(:green)
          expect(hex.tile.upgrades).to be_empty

          icon = hex.tile.icons[0]
          expect(icon.image).to eq('/icons/18_zoo/mountain.svg')
          expect(icon.sticky).to be_truthy
          expect(icon.blocks_lay?).to be_truthy
        end

        it 'can be used for MM' do
          game = Engine::Game.load(game_file, at_action: 26)

          hex = game.hex_by_id('G17')
          expect(hex.tile.label.to_s).to eq('MM')
          expect(hex.tile.color).to eq(:green)
          expect(hex.tile.upgrades).to be_empty

          icon = hex.tile.icons[0]
          expect(icon.image).to eq('/icons/18_zoo/mountain.svg')
          expect(icon.sticky).to be_truthy
          expect(icon.blocks_lay?).to be_truthy
        end

        it 'can be used for O' do
          game = Engine::Game.load(game_file, at_action: 17)

          hex = game.hex_by_id('F18')
          expect(hex.tile.label.to_s).to eq('O')
          expect(hex.tile.color).to eq(:green)

          icon = hex.tile.icons[0]
          expect(icon.image).to eq('/icons/river.svg')
          expect(icon.sticky).to be_truthy
          expect(icon.blocks_lay?).to be_falsy
        end
      end

      describe 'Rabbits' do
        let(:game_file_name) { 'or_power.rabbits.cannot_upgrade' }

        [
          { 'tile_1' => 'X8-0', 'rotation_1' => 0, 'tile_2' => 'X25-0', 'rotation_2' => 4 },
          { 'tile_1' => 'X8-0', 'rotation_1' => 0, 'tile_2' => 'X19-0', 'rotation_2' => 0 },
          { 'tile_1' => 'X8-0', 'rotation_1' => 0, 'tile_2' => 'X19-0', 'rotation_2' => 2 },
          { 'tile_1' => 'X7-1', 'rotation_1' => 0, 'tile_2' => 'X28-0', 'rotation_2' => 2 },
          { 'tile_1' => 'X7-1', 'rotation_1' => 0, 'tile_2' => 'X29-0', 'rotation_2' => 5 },
        ].each do |invalid_action|
          it "must not update invalid track (#{invalid_action['tile_2']}) on #{invalid_action['tile_1']}" do
            game = Engine::Game.load(game_file, at_action: 19)
            game.process_action({
                                  'type' => 'lay_tile',
                                  'entity' => 'GI',
                                  'entity_type' => 'corporation',
                                  'hex' => 'I9',
                                  'tile' => invalid_action['tile_1'],
                                  'rotation' => invalid_action['rotation_1'],
                                })

            action = {
              'type' => 'lay_tile',
              'entity' => 'RABBITS',
              'entity_type' => 'company',
              'hex' => 'I9',
              'tile' => invalid_action['tile_2'],
              'rotation' => invalid_action['rotation_2'],
            }

            expect(game.exception).to be_nil
            expect do
              game.process_action(action).maybe_raise!
            end.to raise_error(Engine::GameError, 'New track must override old one')
          end
        end
      end
    end
  end
end
