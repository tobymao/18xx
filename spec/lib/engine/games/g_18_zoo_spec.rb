# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/game/g_18_zoo'

module Engine
  describe Game::G18ZOO do
    def next_round!
      loop do
        game.send(:next_round!)
        game.round.setup
        break if yield
      end
      game.round
    end

    def next_sr!
      next_round! { game.round.is_a?(Round::Stock) }
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
            let(:game) { Game::G18ZOO.new(current_players, optional_rules: [variant.to_sym]) }
            let(:player_1) { game.players.first }

            it "should start with #{expected_cash[variant][num_players]}$N" do
              expect(player_1.cash).to eq(expected_cash[variant][num_players])
            end

            it "should have  #{expected_cert_limit[variant][num_players]} cert limit" do
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
          end
        end
      end
    end

    describe 'Powers' do
      let(:players) { %w[a b c] }

      [
        { name: 'Holiday', id: 'hs_mqzfamvd_1612649245', sym: :HOLIDAY, price: 3, choice: 'holiday' },
        { name: 'Midas', id: 'hs_mqzfamvd_1612649245', sym: :MIDAS, price: 2, choice: 'midas' },
        {
          name: 'It’s all greek to me',
          id: 'hs_yylreptp_1612654521',
          sym: :IT_S_ALL_GREEK_TO_ME,
          price: 2,
          choice: 'greek_to_me',
        },
        { name: 'Whatsup', id: 'hs_gpptfzdv_1612649034', sym: :WHATSUP, price: 3, choice: 'whatsup' },
      ].each do |power|
        describe power[:name] do
          let(:game) { Game::G18ZOO.new(players, id: power[:id]) }
          let(:current_power) { game.available_companies.find { |c| c.sym.to_sym == power[:sym] } }
          let(:player_1) { game.players.first }
          let!(:starting_money) { player_1.cash }

          it "should contains '#{power[:name]}' inside available_companies" do
            expect(current_power).to be_truthy
          end

          describe 'when bought by 1st player' do
            before do
              first_player_buy_power_on_isr(current_power)
              next_sr!
            end

            it "should costs #{power[:price]}$N to Player 1" do
              expect(player_1.cash).to eq(starting_money - power[:price])
            end

            it 'should add a choice for Player 1' do
              expect(game.round.active_step.actions(game.current_entity)).to include 'choose'
            end

            it "should have '#{power[:choice]}' as choice for Player 1" do
              expect(game.round.active_step.choices).to include power[:choice].to_sym
            end

            it 'should fail when power is used' do
              expect do
                game.round.process_action(Engine::Action::Choose.new(game.current_entity, choice: power[:choice]))
              end.to raise_error(Engine::GameError, 'Power not yet implemented')
            end
          end
        end
      end

      describe 'Too much responsibility' do
        let(:game) { Game::G18ZOO.new(players, id: 'hs_sazxgyzi_1612654581') }
        let(:power) { game.available_companies.find { |c| c.sym.to_sym == :TOO_MUCH_RESPONSIBILITY } }
        let(:player_1) { game.players.first }
        let!(:starting_money) { player_1.cash }

        it 'should contains "Too much responsibility" inside available_companies' do
          expect(power).to be_truthy
        end

        describe 'when bought by 1st player on ISR' do
          before do
            first_player_buy_power_on_isr(power)
          end

          it 'should costs 1$N but earns 3$N to Player 1' do
            expect(player_1.cash).to eq(starting_money - 1 + 3)
          end

          it 'should close the company after buy' do
            expect(power.closed?).to be_truthy
          end
        end

        describe 'when bought by 1st player on SR' do
          before do
            next_sr!
            game.round.process_action(Engine::Action::BuyCompany.new(game.current_entity, price: power.value,
                                                                                          company: power))
          end

          it 'should costs 1$N but earns 3$N to Player 1 on SR' do
            expect(player_1.cash).to eq(starting_money - 1 + 3)
          end

          it 'should close the company after buy on ISR' do
            expect(power.closed?).to be_truthy
          end
        end
      end

      describe 'Leprechaun pot of gold' do
        let(:game) { Game::G18ZOO.new(players, id: 'hs_qttengzm_1612655076') }
        let(:power) { game.available_companies.find { |c| c.sym.to_sym == :LEPRECHAUN_POT_OF_GOLD } }
        let(:player_1) { game.players.first }
        let!(:starting_money) { player_1.cash }

        it 'should contains "Leprechaun pot of gold" inside available_companies' do
          expect(power).to be_truthy
        end

        describe 'when bought by 1st player on ISR' do
          before do
            first_player_buy_power_on_isr(power)
          end

          it 'should costs 2$N but earns 2$N on ISR and 2$N on each SR to Player 1' do
            expect(player_1.cash).to eq(starting_money - 2 + 2)
            next_sr!
            expect(player_1.cash).to eq(starting_money - 2 + 2 + 2)
            next_sr!
            expect(player_1.cash).to eq(starting_money - 2 + 2 + 2 + 2)
            next_sr!
            expect(player_1.cash).to eq(starting_money - 2 + 2 + 2 + 2 + 2)
          end
        end

        describe 'when bought by 1st player on Monday SR' do
          before do
            next_sr!
            game.round.process_action(Engine::Action::BuyCompany.new(game.current_entity, price: power.value,
                                                                                          company: power))
          end

          it 'should costs 2$N but earns 2$N on each SR to Player 1' do
            expect(player_1.cash).to eq(starting_money - 2 + 2)
            next_sr!
            expect(player_1.cash).to eq(starting_money - 2 + 2 + 2)
            next_sr!
            expect(player_1.cash).to eq(starting_money - 2 + 2 + 2 + 2)
          end
        end
      end

      [
        { name: 'Rabbits', id: 'hs_tsquafuj_1612655713', sym: :RABBITS },
        { name: 'Moles', id: 'hs_tsquafuj_1612655713', sym: :MOLES },
        { name: 'Ancient maps', id: 'hs_yylreptp_1612654521', sym: :ANCIENT_MAPS },
        { name: 'Hole', id: 'hs_yylreptp_1612654521', sym: :HOLE },
        { name: 'On diet', id: 'hs_iwznzqfy_1612655316', sym: :ON_DIET },
        { name: 'Sparkling gold', id: 'hs_sazxgyzi_1612654581', sym: :SPARKLING_GOLD },
        { name: "That's mine!", id: 'hs_mqzfamvd_1612649245', sym: :THAT_S_MINE },
        { name: 'Work in progress', id: 'hs_gpptfzdv_1612649034', sym: :WORK_IN_PROGRESS },
        { name: 'Corn', id: 'hs_qttengzm_1612655076', sym: :CORN },
        { name: 'Two barrels', id: 'hs_mqzfamvd_1612649245', sym: :TWO_BARRELS },
        { name: 'A squeeze', id: 'hs_gpptfzdv_1612649034', sym: :A_SQUEEZE },
        { name: 'Bandage', id: 'hs_yylreptp_1612654521', sym: :BANDAGE },
        { name: 'Wings', id: 'hs_walbtakv_1612655500', sym: :WINGS },
        { name: 'A spoonful of sugar', id: 'hs_rykjpksq_1612654725', sym: :A_SPOONFUL_OF_SUGAR },
      ].each do |power|
        describe power[:name] do
          let(:game) { Game::G18ZOO.new(players, id: power[:id]) }
          let(:current_power) { game.available_companies.find { |c| c.sym.to_sym == power[:sym] } }
          let(:player_1) { game.players.first }
          let!(:starting_money) { player_1.cash }

          it "should contains '#{power[:name]}' inside available_companies" do
            expect(current_power).to be_truthy
          end

          it 'should fail when bought by 3rd player' do
            expect do
              game.round.process_action(Engine::Action::Bid.new(game.current_entity, price: current_power.value,
                                                                                     company: current_power))
            end.to raise_error(Engine::GameError, 'Power logic not yet implemented')
          end
        end
      end

      describe 'addition to available' do
        let(:game) { Game::G18ZOO.new(players) }

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
      let(:game) { Game::G18ZOO.new(players) }
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
            data[:trains].each { |train| phase.buying_train!(corporation, game.trains.find { |t| t.name == train }) }

            expect(par_prices).to eq(data[:expected_par_prices])
          end

          it "should gain #{data[:gain] || 'nothing'} when par #{data[:price]}" do
            game.round.process_action(Action::Par.new(player_1, corporation: corporation, share_price: share_price))

            expect(corporation.cash).to eq(data[:price] * 2 + data[:gain])
          end
        end
      end
    end

    describe 'sell company' do
      # TODO: add tests for this feature later
    end

    describe '"family near"' do
      let(:players) { %w[a b c] }
      let(:game) { Game::G18ZOO.new(players) }
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
        game.round.process_action(Engine::Action::Pass.new(player_1))
        game.round.process_action(Action::Par.new(player_2, corporation: second_corporation, share_price: share_price))

        [2].each { |index| expect(game.corporation_available?(game.corporations[index])).to be_truthy }
        [3, 4].each { |index| expect(game.corporation_available?(game.corporations[index])).to be_falsy }
      end

      it 'only previous corporation is available after first par and previous par' do
        game.round.process_action(Action::Par.new(player_1, corporation: corporation, share_price: share_price))
        game.round.process_action(Engine::Action::Pass.new(player_1))
        game.round.process_action(Action::Par.new(player_2, corporation: last_corporation, share_price: share_price))

        [3].each { |index| expect(game.corporation_available?(game.corporations[index])).to be_truthy }
        [1, 2].each { |index| expect(game.corporation_available?(game.corporations[index])).to be_falsy }
      end
    end
  end
end
