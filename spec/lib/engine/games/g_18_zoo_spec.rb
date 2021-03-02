# frozen_string_literal: true

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
          first_player_buy_power_on_isr(power)
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
        company = player_1.companies.select { |c| c.name.start_with?('ZOOTicket') }.first
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
      max_players = { map_a: 4, map_b: 4, map_c: 4, map_d: 5, map_e: 5, map_f: 5 }
      expected_cash = {
        map_a: { 2 => 40, 3 => 28, 4 => 23 },
        map_b: { 2 => 40, 3 => 28, 4 => 23 },
        map_c: { 2 => 40, 3 => 28, 4 => 23 },
        map_d: { 2 => 48, 3 => 32, 4 => 27, 5 => 22 },
        map_e: { 2 => 48, 3 => 32, 4 => 27, 5 => 22 },
        map_f: { 2 => 48, 3 => 32, 4 => 27, 5 => 22 },
      }
      expected_cert_limit = {
        map_a: { 2 => 10, 3 => 7, 4 => 5 },
        map_b: { 2 => 10, 3 => 7, 4 => 5 },
        map_c: { 2 => 10, 3 => 7, 4 => 5 },
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
            let(:game) { Engine::Game::G18ZOO::Game.new(current_players, optional_rules: [variant.to_sym]) }
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

            it "should have #{expected_corporations[variant]} corporation in game" do
              expect(game.corporations.size).to eq(expected_corporations[variant])
            end

            it "should contains #{expected_available_companies[num_players]} available companies for isr" do
              expect(game.available_companies.size).to eq(expected_available_companies[num_players])
            end

            it "should contains #{expected_future_companies[num_players]} future companies for isr" do
              expect(game.future_companies.size).to eq(expected_future_companies[num_players])
            end

            it 'should have only valid corporation coordinates' do
              game.class::CORPORATION_COORDINATES_BY_MAP[variant.to_sym].each do |_id, coordinate|
                expect(game.hexes.map(&:coordinates)).to include(coordinate.to_s)
              end
            end

            it 'should have only valid location names' do
              game.class::LOCATION_NAMES_BY_MAP[variant.to_sym].each do |coordinate, _name|
                expect(game.hexes.map(&:coordinates)).to include(coordinate.to_s)
              end
            end
          end
        end
      end
    end

    describe 'Power' do
      let(:players) { %w[a b c] }
      let(:game) { Engine::Game::G18ZOO::Game.new(players, id: game_id) }
      let(:player_1) { game.players.first }
      let(:power) { game.available_companies.find { |c| c.sym.to_sym == power_sym } }

      describe 'Holiday' do
        let(:game_id) { 'hs_mqzfamvd_1612649245' }
        let(:power_sym) { :HOLIDAY }
        let(:price) { 3 }

        include_examples 'a purchasable power'

        context 'when player 1 buys it' do
          include_context 'when player 1 buys it'

          include_examples 'without choice'

          context 'when player par' do
            include_context 'when player 1 par corporation 1'

            include_examples 'with choice' do
              let(:choice) { "holiday:#{corporation.name}" }
            end

            context 'when player uses power' do
              include_context 'when player 1 uses choice' do
                let(:choice) { "holiday:#{corporation.name}" }
              end

              it 'power should close' do
                expect(power.closed?).to be_truthy
              end

              it 'corporation should change price' do
                expect(corporation.shares[0].price).to eq(6)
              end

              include_examples 'without choice'
            end
          end

          context 'when another player par' do
            include_context 'when player 2 par corporation 1'

            include_examples 'with choice' do
              let(:choice) { "holiday:#{corporation.name}" }
            end

            context 'when player uses power' do
              include_context 'when player 1 uses choice' do
                let(:choice) { "holiday:#{corporation.name}" }
              end

              it 'power should close' do
                expect(power.closed?).to be_truthy
              end

              it 'corporation should change price' do
                expect(corporation.shares[0].price).to eq(6)
              end

              include_examples 'without choice'
            end
          end

          context 'when all companies par' do
            let(:share_price) { game.stock_market.par_prices.find { |par_price| par_price.price == 5 } }

            before do
              game.corporations.each do |corporation|
                par(game, game.current_entity, corporation, share_price)
              end
              pass_until_player(game, player_1)
            end

            it 'should add a choice for each corporation' do
              game.corporations.each do |corporation|
                expect(game.round.active_step.actions(game.current_entity)).to include 'choose'
                expect(game.round.active_step.choices).to include "holiday:#{corporation.name}"
              end
            end

            context 'when player uses power' do
              let(:corporation) { game.corporations.first }
              include_context 'when player 1 uses choice' do
                let(:choice) { "holiday:#{corporation.name}" }
              end

              it 'power should close' do
                expect(power.closed?).to be_truthy
              end

              it 'corporation should change price' do
                expect(corporation.shares[0].price).to eq(6)
              end

              include_examples 'without choice'
            end
          end
        end
      end

      describe 'Midas' do
        let(:game_id) { 'hs_mqzfamvd_1612649245' }
        let(:power_sym) { :MIDAS }
        let(:price) { 2 }

        include_examples 'a purchasable power'

        context 'when player buys it' do
          include_context 'when player 1 buys it'

          include_examples 'with choice' do
            let(:choice) { :midas }
          end

          context 'when player uses power' do
            include_context 'when player 1 uses choice' do
              let(:choice) { 'midas' }
            end

            it 'power should not be immediately closed' do
              expect(power.closed?).to be_falsy
            end

            it 'player should have priority in the following sr ' do
              next_sr!

              expect(game.round.current_entity).to be(player_1)
            end

            it 'power should close when sr ends' do
              next_or!

              expect(power.closed?).to be_truthy
            end
          end
        end
      end

      describe 'Too much responsibility' do
        let(:game_id) { 'hs_sazxgyzi_1612654581' }
        let(:power_sym) { :TOO_MUCH_RESPONSIBILITY }
        let(:price) { -2 }
        let!(:starting_money) { player_1.cash }

        include_examples 'a purchasable power'

        context 'when player buys it' do
          include_context 'when player 1 buys it'

          it 'should close the company' do
            expect(power.closed?).to be_truthy
          end

          it 'should gain money' do
            expect(player_1.cash).to eq(starting_money + 2)
          end
        end
      end

      describe 'Leprechaun pot of gold' do
        let(:game_id) { 'hs_qttengzm_1612655076' }
        let(:power_sym) { :LEPRECHAUN_POT_OF_GOLD }
        let(:price) { -2 }
        let!(:starting_money) { player_1.cash }

        include_examples 'a purchasable power'

        context 'when player buys it on ISR' do
          before do
            first_player_buy_power_on_isr(power)
          end

          it 'should costs 2$N and earns 2$N on current ISR and 2$N on each SR' do
            expected_money = starting_money - 2 + 2
            expect(player_1.cash).to eq(expected_money)

            3.times do |_|
              next_sr!
              expect(player_1.cash).to eq(expected_money += 2)
            end
          end
        end

        [{ phase: 'Monday', skip: 1, test: 3 },
         { phase: 'Tuesday', skip: 2, test: 2 },
         { phase: 'Wednesday', skip: 3, test: 1 }]
          .each do |item|
          context "when player buys it on #{item[:phase]} SR" do
            let!(:starting_money) { player_1.cash }

            before do
              item[:skip].times { |_| next_sr! }
              game.round.process_action(Engine::Action::BuyCompany.new(game.current_entity, price: power.value,
                                                                                            company: power))
            end

            it 'should costs 2$N but earns 2$N on each SR' do
              expected_money = starting_money - 2 + 2
              expect(player_1.cash).to eq(expected_money)

              item[:test].times do |_|
                next_sr!
                expect(player_1.cash).to eq(expected_money += 2)
              end
            end
          end
        end
      end

      describe 'It’s all greek to me' do
        let(:game_id) { 'hs_yylreptp_1612654521' }
        let(:power_sym) { :IT_S_ALL_GREEK_TO_ME }
        let(:price) { 2 }

        include_examples 'a purchasable power'

        context 'when player buys it' do
          include_context 'when player 1 buys it'

          context 'when no action' do
            include_examples 'without choice'
          end

          context 'when sell a company' do
            include_context 'when player 1 sell a company'

            include_examples 'without choice'
          end

          context 'when uses a power' do
            before do
              game.round.process_action(Action::BuyCompany.new(player_1, company: game.leprechaun_pot_of_gold,
                                                                         price: game.leprechaun_pot_of_gold.max_price))
              3.times { |_| game.round.process_action(Engine::Action::Pass.new(game.current_entity)) }
            end

            include_examples 'without choice'
          end

          context 'when par' do
            include_context 'when player 1 par corporation 1' do
              let(:skip_action) { false }
              let(:skip_after) { 0 }
            end

            include_examples 'with choice' do
              let(:choice) { :greek_to_me }
            end
          end

          context 'when sell a share' do
            include_context 'when player 1 sells share of corporation 1'

            include_examples 'with choice' do
              let(:choice) { :greek_to_me }
            end
          end

          context 'when buys a company' do
            before do
              game.round.process_action(Action::BuyCompany.new(player_1, company: game.holiday,
                                                                         price: game.holiday.max_price))
            end

            include_examples 'with choice' do
              let(:choice) { :greek_to_me }
            end

            context 'when player uses power' do
              before do
                game.round.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'greek_to_me'))
                game.round.process_action(Engine::Action::Pass.new(game.current_entity))
              end

              it 'power should close' do
                expect(power.closed?).to be_truthy
              end

              it 'player 1 should be the current player' do
                expect(game.round.current_entity).to be(player_1)
              end

              include_examples 'without choice'
            end
          end

          context 'when buys a share' do
            include_context 'when player 1 (pars, then-)buys share of corporation 1'

            include_examples 'with choice' do
              let(:choice) { :greek_to_me }
            end
          end
        end
      end

      describe 'Whatsup' do
        let(:game_id) { 'hs_gpptfzdv_1612649034' }
        let(:power_sym) { :WHATSUP }
        let(:price) { 3 }

        include_examples 'a purchasable power'

        context 'when player 1 buys it' do
          include_context 'when player 1 buys it'

          include_examples 'without choice'

          context 'when player par' do
            include_context 'when player 1 par corporation 1'

            let(:corporation) { game.corporations.first }
            include_examples 'with choice' do
              let(:choice) { "whatsup:#{corporation.name}:2S-0" }
            end

            context 'when player uses power' do
              include_context 'when player 1 uses choice' do
                let(:choice) { "whatsup:#{corporation.name}:2S-0" }
              end

              it 'power closes' do
                expect(power.closed?).to be_truthy
              end

              it 'corporation pays for a train' do
                expect(corporation.cash).to eq(3)
              end

              it 'corporation gets a train' do
                expect(corporation.trains[0].id).to eq('2S-0')
              end

              it 'new train is disabled' do
                next_or!

                expect(corporation.trains[0].operated).to be_truthy
              end

              include_examples 'without choice'
            end
          end

          context 'when player par multiple companies' do
            let(:share_price) { game.stock_market.par_prices.find { |par_price| par_price.price == 5 } }
            let(:corporation_1) { game.corporations.first }
            let(:corporation_2) { game.corporations[1] }

            before do
              par(game, player_1, corporation_1, share_price)
              pass_until_player(game, player_1)
              par(game, player_1, corporation_2, share_price)
              pass_until_player(game, player_1)
            end

            include_examples 'with choice' do
              let(:choice) { "whatsup:#{corporation_1.name}:2S-0" }
            end

            include_examples 'with choice' do
              let(:choice) { "whatsup:#{corporation_2.name}:2S-0" }
            end
          end
        end
      end

      describe 'Rabbits' do
        let(:game_id) { 'hs_tsquafuj_1612655713' }
        let(:power_sym) { :RABBITS }
        let(:price) { 3 }

        include_examples 'a purchasable power'
        include_examples 'power not implemented'
      end

      describe 'Moles' do
        let(:game_id) { 'hs_tsquafuj_1612655713' }
        let(:power_sym) { :MOLES }
        let(:price) { 3 }

        include_examples 'a purchasable power'
        include_examples 'power not implemented'
      end

      describe 'Ancient maps' do
        let(:game_id) { 'hs_yylreptp_1612654521' }
        let(:power_sym) { :ANCIENT_MAPS }

        include_examples 'a purchasable power'
        include_examples 'power not implemented'
      end

      describe 'Hole' do
        let(:game_id) { 'hs_yylreptp_1612654521' }
        let(:power_sym) { :HOLE }

        include_examples 'a purchasable power'
        include_examples 'power not implemented'
      end

      describe 'On diet' do
        let(:game_id) { 'hs_iwznzqfy_1612655316' }
        let(:power_sym) { :ON_DIET }

        include_examples 'a purchasable power'
        include_examples 'power not implemented'
      end

      describe 'Sparkling gold' do
        let(:game_id) { 'hs_sazxgyzi_1612654581' }
        let(:power_sym) { :SPARKLING_GOLD }

        include_examples 'a purchasable power'
        include_examples 'power not implemented'
      end

      describe "That's mine!" do
        let(:game_id) { 'hs_mqzfamvd_1612649245' }
        let(:power_sym) { :THAT_S_MINE }

        include_examples 'a purchasable power'
        include_examples 'power not implemented'
      end

      describe 'Work in progress' do
        let(:game_id) { 'hs_gpptfzdv_1612649034' }
        let(:power_sym) { :WORK_IN_PROGRESS }

        include_examples 'a purchasable power'
        include_examples 'power not implemented'
      end

      describe 'Corn' do
        let(:game_id) { 'hs_qttengzm_1612655076' }
        let(:power_sym) { :CORN }

        include_examples 'a purchasable power'
        include_examples 'power not implemented'
      end

      describe 'Two barrels' do
        let(:game_id) { 'hs_mqzfamvd_1612649245' }
        let(:power_sym) { :TWO_BARRELS }

        include_examples 'a purchasable power'
        include_examples 'power not implemented'
      end

      describe 'A squeeze' do
        let(:game_id) { 'hs_gpptfzdv_1612649034' }
        let(:power_sym) { :A_SQUEEZE }

        include_examples 'a purchasable power'
        include_examples 'power not implemented'
      end

      describe 'Bandage' do
        let(:game_id) { 'hs_yylreptp_1612654521' }
        let(:power_sym) { :BANDAGE }

        include_examples 'a purchasable power'
        include_examples 'power not implemented'
      end

      describe 'Wings' do
        let(:game_id) { 'hs_walbtakv_1612655500' }
        let(:power_sym) { :WINGS }

        include_examples 'a purchasable power'
        include_examples 'power not implemented'
      end

      describe 'A spoonful of sugar' do
        let(:game_id) { 'hs_rykjpksq_1612654725' }
        let(:power_sym) { :A_SPOONFUL_OF_SUGAR }

        include_examples 'a purchasable power'
        include_examples 'power not implemented'
      end

      describe 'addition to available' do
        let(:game) { Engine::Game::G18ZOO::Game.new(players) }

        it 'should be added to available list (4 powers) on each SR' do
          expect(game.available_companies.size).to eq(4)
          next_sr!
          expect(game.available_companies.size).to eq(8)
          next_sr!
          expect(game.available_companies.size).to eq(12)
          next_sr!
          expect(game.available_companies.size).to eq(16)
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
        { phase: :brown, price: 12, expected_par_prices: [5, 6, 7, 9, 12], gain: 10, trains: %w[3S 4S 5S] },
      ].each do |data|
        describe (data[:phase]).to_s do
          let(:share_price) { stock_market.par_prices.find { |par_price| par_price.price == data[:price] } }

          it "should have only #{data[:expected_par_prices]} as valid par value" do
            next_or!
            data[:trains].each { |train| phase.buying_train!(corporation, game.trains.find { |t| t.name == train }) }
            next_sr!

            expect(par_prices).to eq(data[:expected_par_prices])
          end

          it "should gain #{data[:gain] || 'nothing'} when par #{data[:price]}" do
            game.round.process_action(Action::Par.new(player_1, corporation: corporation, share_price: share_price))

            expect(corporation.cash).to eq(data[:price] * 2 + data[:gain])
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
              item[:trains].each { |train| phase.buying_train!(corporation, game.trains.find { |t| t.name == train }) }
            end

            item[:track_for_invalid].each do |track_for_invalid|
              # TODO: fix later
              # it "should auto-skip when tile is..." do
              # end
            end

            item[:track_for_valid].each do |track_for_valid|
              describe "when hex tile is #{track_for_valid[:color] || 'empty'}" do
                before do
                  if track_for_valid[:lay]
                    game.hex_by_id(corporation.coordinates).lay(game.tile_by_id(track_for_valid[:lay]))
                  end

                  game.round.process_action(Action::Par.new(player_1, corporation: corporation,
                                                                      share_price: share_price))

                  expect(game.round.active_step).to be_instance_of(Engine::Game::G18ZOO::Step::HomeTrack)
                end

                # TODO: fix later
                # it 'could pass' do
                #   expect(game.round.active_step.actions(game.current_entity)).to include 'pass'
                #
                #   game.round.process_action(Action::Pass.new(corporation))
                #
                #   expect(game.round.active_step).to be_instance_of(Engine::Game::G18ZOO::Step::FreeActionsOnSr)
                # end

                track_for_valid[:tiles].each do |tile|
                  # TODO: fix later
                  #   it "could put the track #{tile}" do
                  #     expect(game.round.active_step.actions(game.current_entity)).to include 'lay_tile'
                  #
                  #     game.round.process_action(Action::LayTile.new(corporation,
                  #                                                   tile: game.tile_by_id(tile),
                  #                                                   hex: game.hex_by_id(corporation.coordinates),
                  #                                                   rotation: 0))
                  #
                  #     expect(game.round.active_step).to be_instance_of(Engine::Game::G18ZOO::Step::FreeActionsOnSr)
                  #   end
                end
              end
            end
          end
        end
      end
    end

    describe 'sell company' do
      let(:players) { %w[a b c] }
      let(:game) { Engine::Game::G18ZOO::Game.new(players) }
      let(:player_1) { game.players.first }
      let(:companies) { player_1.companies.select { |c| c.name.start_with?('ZOOTicket') } }
      let(:company) { companies.first }
      let(:corporation) { game.corporations.first }
      let(:share_price) { game.stock_market.par_prices.find { |par_price| par_price.price == 5 } }

      before do
        next_sr!
      end

      describe 'player could sell a TicketZOO to gain the current value' do
        it 'should gain the current value' do
          starting_money = player_1.cash

          game.round.process_action(Action::SellCompany.new(player_1, company: company, price: 4))

          expect(player_1.cash).to eq(starting_money + 4)
        end

        it 'before any action in SR' do
          expect(game.round.active_step).to be_instance_of(Engine::Game::G18ZOO::Step::BuySellParShares)
          expect(game.round.active_step.actions(game.current_entity)).to include 'sell_company'

          game.round.process_action(Action::SellCompany.new(player_1, company: company, price: 4))

          expect(game.round.active_step).to be_instance_of(Engine::Game::G18ZOO::Step::BuySellParShares)
        end

        it 'after selling a share' do
          game.stock_market.set_par(corporation, game.stock_market.par_prices.find { |price| price.price == 5 })
          2.times { game.share_pool.buy_shares(player_1, corporation.shares[0]) }

          expect(game.round.active_step).to be_instance_of(Engine::Game::G18ZOO::Step::BuySellParShares)
          game.round.process_action(Action::SellShares.new(player_1, shares: player_1.shares[1]))

          expect(game.round.active_step.actions(game.current_entity)).to include 'sell_company'

          game.round.process_action(Action::SellCompany.new(player_1, company: company, price: 4))

          expect(game.round.active_step).to be_instance_of(Engine::Game::G18ZOO::Step::BuySellParShares)
        end
        it 'after buying a company' do
          game.round.process_action(Action::BuyCompany.new(player_1, company: game.available_companies.first,
                                                                     price: game.available_companies.first.max_price))

          expect(game.round.active_step).to be_instance_of(Engine::Game::G18ZOO::Step::BuySellParShares)
          expect(game.round.active_step.actions(game.current_entity)).to include 'sell_company'

          game.round.process_action(Action::SellCompany.new(player_1, company: company, price: 4))

          expect(game.round.active_step).to be_instance_of(Engine::Game::G18ZOO::Step::BuySellParShares)
        end

        it 'after buying a share' do
          game.stock_market.set_par(corporation, game.stock_market.par_prices.find { |price| price.price == 5 })
          game.share_pool.buy_shares(player_1, corporation.shares[0])

          expect(game.round.active_step).to be_instance_of(Engine::Game::G18ZOO::Step::BuySellParShares)
          game.round.process_action(Action::BuyShares.new(player_1, shares: corporation.shares[0]))

          expect(game.round.active_step.actions(game.current_entity)).to include 'sell_company'

          game.round.process_action(Action::SellCompany.new(player_1, company: company, price: 4))

          expect(game.round.active_step).to be_instance_of(Engine::Game::G18ZOO::Step::BuySellParShares)
        end

        # TODO: add after updating Step::G18ZOO::ChoosePower with any real power
        # it 'after using a power' do
        # end

        it 'after the par and lay of home track' do
          game.round.process_action(Action::Par.new(player_1, corporation: corporation, share_price: share_price))
          game.round.process_action(Action::Pass.new(corporation))
          expect(game.round.active_step).to be_instance_of(Engine::Game::G18ZOO::Step::FreeActionsOnSr)

          expect(game.round.active_step.actions(game.current_entity)).to include 'sell_company'

          game.round.process_action(Action::SellCompany.new(player_1, company: company, price: 4))

          expect(game.round.active_step).to be_instance_of(Engine::Game::G18ZOO::Step::FreeActionsOnSr)
        end

        # TODO: add later
        # it 'after the par and lay of home track and additional track' do
        # end
      end

      it 'player turn should end after par if no ticket zoo are available' do
        companies.each do |company|
          game.round.process_action(Action::SellCompany.new(player_1, company: company, price: 4))
        end
        expect(game.round.active_step.actions(game.current_entity)).to_not include 'sell_company'

        game.round.process_action(Action::Par.new(player_1, corporation: corporation, share_price: share_price))
        game.round.process_action(Action::Pass.new(corporation))

        expect(game.round.active_step).to be_instance_of(Engine::Game::G18ZOO::Step::BuySellParShares)
        expect(game.round.current_entity).to_not be(player_1)
      end

      # TODO: add later
      #   it 'selling a company is not an action' do
      #   end

      # TODO: add later
      #   it 'corporation can buy a TicketZOO to gain at least 1' do
      #   end

      # TODO: add later
      #   it 'corporation can buy a TicketZOO to gain at most the ticket zoo value' do
      #
      #   end
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
        game.round.process_action(Engine::Action::Pass.new(corporation))
        game.round.process_action(Engine::Action::Pass.new(player_1))
        game.round.process_action(Action::Par.new(player_2, corporation: second_corporation, share_price: share_price))

        [2].each { |index| expect(game.corporation_available?(game.corporations[index])).to be_truthy }
        [3, 4].each { |index| expect(game.corporation_available?(game.corporations[index])).to be_falsy }
      end

      it 'only previous corporation is available after first par and previous par' do
        game.round.process_action(Action::Par.new(player_1, corporation: corporation, share_price: share_price))
        game.round.process_action(Engine::Action::Pass.new(corporation))
        game.round.process_action(Engine::Action::Pass.new(player_1))
        game.round.process_action(Action::Par.new(player_2, corporation: last_corporation, share_price: share_price))

        [3].each { |index| expect(game.corporation_available?(game.corporations[index])).to be_truthy }
        [1, 2].each { |index| expect(game.corporation_available?(game.corporations[index])).to be_falsy }
      end
    end
  end
end
