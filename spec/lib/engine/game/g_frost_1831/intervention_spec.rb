# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module GFrost1831
      describe Game do
        let(:game) { Engine::Game::GFrost1831::Game.new(%w[P1 P2 P3], id: 1) }
        let(:p1) { game.players[0] }
        let(:p2) { game.players[1] }
        let(:p3) { game.players[2] }
        let(:cm) { game.corporation_by_id('CM') }
        let(:gua) { game.corporation_by_id('GUA') }
        let(:exp) { game.corporation_by_id('EXP') }
        let(:dl) { game.corporation_by_id('DL') }
        let(:founded_factions) { [gua, exp] }

        def found(faction)
          [faction.presidents_share, *faction.ipo_shares.reject(&:president).first(2)].each do |share|
            share.transfer(p3)
          end
          faction.owner = p3
        end

        def place_station(hex_id)
          game.hex_by_id(hex_id).tile.cities.first.place_token(cm, cm.next_token, check_tokenable: false)
        end

        def move_to(corporation, coordinates)
          price = game.stock_market.share_price(coordinates)
          corporation.share_price.corporations.delete(corporation)
          corporation.share_price = price
          price.corporations << corporation
        end

        def float_dl(coordinates)
          game.par_corporation(dl, game.stock_market.par_prices.first)
          dl.ipoed = true
          [dl.presidents_share, *dl.ipo_shares.reject(&:president).first(3)].each { |share| share.transfer(p3) }
          dl.owner = p3
          move_to(dl, coordinates)
        end

        def sell(player)
          share = player.shares_of(cm).reject(&:president).first
          game.round.goto_entity!(player)
          game.process_action(Engine::Action::SellShares.new(player, shares: [share], share_price: nil, percent: 10))
          expect(game.exception&.message).to be_nil
        end

        def choose(hex_id, faction)
          game.process_action(Engine::Action::Choose.new(cm, choice: "#{hex_id}:#{faction.id}"))
          expect(game.exception&.message).to be_nil
        end

        def bases(hex_id)
          game.hex_by_id(hex_id).tile.cities.first.tokens.compact.map(&:corporation)
        end

        def step
          game.round.active_step
        end

        def messages
          game.log.map(&:message)
        end

        before do
          game.event_parliament_opens!
          founded_factions.each { |faction| found(faction) }
          game.par_corporation(cm, game.stock_market.par_prices.first)
          cm.ipoed = true
          [cm.presidents_share, cm.ipo_shares.reject(&:president).first].each { |share| share.transfer(p1) }
          cm.ipo_shares.reject(&:president).first(2).each { |share| share.transfer(p2) }
          cm.owner = p1
          game.apply_faction_influence!(cm, 'TEC')
          game.apply_faction_influence!(cm, 'LOR')
          move_to(cm, [7, 1])
          game.instance_variable_set(:@turn, 2)
          game.instance_variable_set(:@round, game.stock_round)
        end

        it 'starts an Intervention when a sale reaches the Intervention Zone' do
          place_station('G14')
          place_station('J9')
          sell(p2)

          expect(step).to be_a(GFrost1831::Step::Intervention)
          expect(step.actions(cm)).to eq(%w[choose])
          expect(game.intervention_certificates(gua)).to eq(1)
          expect(game.intervention_certificates(exp)).to eq(1)
          expect(game.status_array(gua)).to include(['Intervention Certificates: 1', ''])
        end

        it 'compensates the other players at the Par Price, with the President taking a loan for the shortfall' do
          place_station('G14')
          cm.spend(cm.cash, game.bank) if cm.cash.positive?
          p1.spend(p1.cash, game.bank)
          p2_cash = p2.cash + cm.share_price.price
          sell(p2)

          par = cm.par_price.price
          expect(p2.cash).to eq(p2_cash + par)
          expect(p1.cash).to eq(0)
          expect(p1.debt).to eq(par)
          expect(messages).to include("P2 receives #{game.format_currency(par)} compensation for CM shares")
          expect(messages).to include("P1 takes on #{game.format_currency(par)} loan")
        end

        it 'repays the loan with any money the President receives, so they cannot buy while they owe' do
          place_station('G14')
          cm.spend(cm.cash, game.bank) if cm.cash.positive?
          p1.spend(p1.cash, game.bank)
          par = cm.par_price.price
          sell(p2)
          choose('G14', gua)
          game.round.goto_entity!(p1)
          stock_step = game.round.steps.find { |s| s.is_a?(GFrost1831::Step::BuySellParShares) }

          expect(p1.cash).to eq(0)
          expect(stock_step.can_ipo_any?(p1)).to be(false)
          expect(stock_step.actions(p1)).not_to include('payoff_player_debt')

          game.bank.spend(par / 2, p1)
          game.repay_player_loans!

          expect(p1.cash).to eq(0)
          expect(p1.debt).to eq(par - (par / 2))
          expect(messages).to include("P1 pays #{game.format_currency(par / 2)} toward their loan. "\
                                      "#{game.format_currency(par - (par / 2))} is still owed.")

          game.bank.spend(500, p1)
          game.repay_player_loans!

          expect(p1.debt).to eq(0)
          expect(p1.cash).to eq(500 - (par - (par / 2)))
          expect(stock_step.can_ipo_any?(p1)).to be(true)
        end

        it 'repays the loan at the end of the action that gives the President money' do
          place_station('G14')
          cm.spend(cm.cash, game.bank) if cm.cash.positive?
          p1.spend(p1.cash, game.bank)
          sell(p2)
          debt = p1.debt
          game.bank.spend(30, p1)

          game.process_action(Engine::Action::Choose.new(cm, choice: 'G14:GUA'))

          expect(game.exception&.message).to be_nil
          expect(p1.cash).to eq(0)
          expect(p1.debt).to eq(debt - 30)
        end

        it 'lets the President distribute the stations between the Intervening Factions' do
          place_station('G14')
          place_station('J9')
          sell(p2)

          expect(step.available_hex(cm, game.hex_by_id('G14'))).to be(true)
          expect(step.available_hex(cm, game.hex_by_id('D7'))).to be(false)
          expect(step.hex_choices(game.hex_by_id('G14'))).to eq('G14:GUA' => gua, 'G14:EXP' => exp)
          expect(step.help).to eq(['Southern Coal Mine is being intervened.',
                                   'Choose stations to distribute between Guardians and Expansionists.'])

          choose('G14', gua)

          expect(bases('G14')).to eq([gua])
          expect(bases('J9')).to eq([exp])
          expect(gua.share_price.price).to eq(80)
          expect(exp.share_price.price).to eq(80)
          expect(cm).to be_closed
          expect(step).to be_a(GFrost1831::Step::BuySellParShares)
          expect(game.current_entity).to eq(p2)
        end

        it 'lets the President choose the Faction when only 1 station is available' do
          place_station('G14')
          sell(p2)

          expect(step.help.last).to eq('Choose which faction between Guardians and Expansionists receives the station.')

          choose('G14', exp)

          expect(bases('G14')).to eq([exp])
          expect(gua.share_price.price).to eq(70)
        end

        it 'asks the President to confirm the only possible replacement' do
          place_station('C10')
          game.hex_by_id('C10').tile.cities.last.place_token(gua, gua.next_base, check_tokenable: false)
          sell(p2)

          expect(game.intervention_choices.keys).to eq(['C10:EXP'])
          expect(step.help.last).to eq('Choose a station to give to Expansionists.')

          choose('C10', exp)

          expect(bases('C10')).to eq([exp])
          expect(cm).to be_closed
        end

        it 'only offers the distributions that give a base to both Factions' do
          place_station('C10')
          place_station('J9')
          game.hex_by_id('C10').tile.cities.last.place_token(gua, gua.next_base, check_tokenable: false)
          sell(p2)

          expect(game.intervention_choices.keys).to contain_exactly('C10:EXP', 'J9:GUA')

          choose('J9', gua)

          expect(bases('J9')).to eq([gua])
          expect(bases('C10')).to eq([exp])
          expect(cm).to be_closed
        end

        it 'gives a single base when only 1 Faction can replace the stations' do
          place_station('C10')
          place_station('I12')
          %w[C10 I12].each do |hex_id|
            game.hex_by_id(hex_id).tile.cities.last.place_token(gua, gua.next_base, check_tokenable: false)
          end
          sell(p2)

          expect(game.intervention_choices.keys).to contain_exactly('C10:EXP', 'I12:EXP')

          choose('I12', exp)

          expect(bases('I12')).to eq([exp])
          expect(game.hex_by_id('C10').tile.cities.first.tokens.compact).to be_empty
          expect(cm).to be_closed
        end

        it 'rejects a replacement that is not possible' do
          place_station('G14')
          place_station('J9')
          sell(p2)

          game.process_action(Engine::Action::Choose.new(cm, choice: 'D7:GUA'))

          expect(game.exception&.message).to eq('D7:GUA is not a possible replacement')
        end

        context 'without founded Intervening Factions' do
          let(:founded_factions) { [] }

          it 'removes the stations without creating bases' do
            place_station('G14')
            sell(p2)

            expect(game.hex_by_id('G14').tile.cities.first.tokens.compact).to be_empty
            expect(game.intervention_certificates(gua)).to eq(0)
            expect(cm).to be_closed
          end
        end

        it 'gives the President Intervention Cards and removes the Corporation' do
          place_station('G14')
          sell(p2)
          choose('G14', gua)

          expect(p1.companies.map(&:name)).to eq(['Intervention Card', 'Intervention Card'])
          expect(game.num_certs(p1)).to eq(2)
          expect(game.corporation_influence(cm)).to be_empty
          expect(game.corporations).not_to include(cm)
          expect(messages).to include('P1 receives 2 Intervention Card(s)', 'CM is removed from the game')
        end

        it 'changes the President before applying the Intervention' do
          cm.ipo_shares.reject(&:president).first.transfer(p2)
          par = cm.par_price.price
          sell(p1)

          expect(cm).to be_closed
          expect(p2.companies.map(&:name)).to eq(['Intervention Card', 'Intervention Card'])
          expect(p1.companies.map(&:name)).not_to include('Intervention Card')
          expect(messages).to include("P1 receives #{game.format_currency(par * 2)} compensation for CM shares")
        end

        it 'removes the cheapest train from the Train Depot from the second Corporation removed' do
          sell(p2)
          expect(messages).not_to include(a_string_matching(/train removed from the game/))

          train = game.depot.min_depot_train
          float_dl([8, 1])
          game.close_corporations_in_close_cell!

          expect(dl).to be_closed
          expect(game.depot.upcoming).not_to include(train)
          expect(messages).to include("-- #{train.name} train removed from the game (2th+ corporation eliminated) --")
        end

        it 'stops the operating turn of the Corporation undergoing the Intervention' do
          place_station('G14')
          move_to(cm, [6, 2])
          float_dl([7, 1])
          game.instance_variable_set(:@round, game.operating_round(1))
          game.round.setup
          expect(game.round.current_operator).to eq(cm)

          move_to(cm, [6, 0])
          game.close_corporations_in_close_cell!
          choose('G14', gua)

          expect(cm).to be_closed
          expect(game.round.current_operator).to eq(dl)
        end
      end
    end
  end
end
