# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module GFrost1831
      describe Game do
        let(:game) { Engine::Game::GFrost1831::Game.new(%w[P1 P2 P3], id: 1) }
        let(:step) { game.round.active_step }
        let(:p1) { game.players[0] }
        let(:p2) { game.players[1] }
        let(:p3) { game.players[2] }

        def pass(player)
          game.process_action(Engine::Action::Pass.new(player))
        end

        def bid(player, price)
          game.process_action(Engine::Action::Bid.new(player, price: price))
        end

        def buy(player, sym)
          company = game.company_by_id(sym)
          game.process_action(Engine::Action::Bid.new(player, company: company, price: company.value))
        end

        def par(player, corporation_id, price)
          share_price = game.stock_market.par_prices.find { |p| p.price == price }
          game.process_action(Engine::Action::Par.new(player, corporation: game.corporation_by_id(corporation_id),
                                                              share_price: share_price))
        end

        def everyone_passes
          game.players.size.times { pass(game.current_entity) }
        end

        it 'starts with an auction for the turn to buy a private company' do
          expect(game.round).to be_a(Engine::Round::Auction)
          expect(step).to be_a(GFrost1831::Step::BuyCert)
          expect(step.companies.map(&:sym)).to match_array(%w[PDI PEX PCO PAF POG PGJ])
          expect(step.auctioning).to eq(:turn)
        end

        it 'gives the turn to the player who opened the auction when everyone passes' do
          everyone_passes
          buy(p1, 'PDI')
          everyone_passes

          expect(game.current_entity).to eq(p2)
          expect(game.log.map(&:message).count { |m| m.end_with?('wins auction for £0') }).to eq(2)
        end

        it 'charges the winning bid on top of the face value' do
          bid(p1, 20)
          pass(p2)
          pass(p3)
          buy(p1, 'PEX')

          expect(p1.cash).to eq(800 - 20 - 40)
          expect(p1.companies.map(&:sym)).to eq(%w[PEX])
          expect(game.current_entity).to eq(p2)
        end

        it 'only accepts bids in multiples of £5' do
          bid(p1, 7)

          expect(game.exception).to be_a(GameError)
          expect(game.exception.message).to include('multiple of £5')
        end

        it 'grants a 10% share of Old England Corp with Old Guard' do
          everyone_passes
          buy(p1, 'POG')

          expect(p1.shares.map { |s| [s.corporation.id, s.percent] }).to eq([['OE', 10]])
        end

        it 'makes the buyer of Grand Junction par it and pay twice the par to the bank' do
          bank_cash = game.bank.cash
          everyone_passes
          buy(p1, 'PGJ')

          expect(step.auctioning).to eq(game.corporation_by_id('GJ'))
          expect(step.actions(p1)).to eq(%w[par])
          expect(step.get_par_prices(p1, game.corporation_by_id('GJ')).map(&:price)).to match_array([60, 70, 80, 90, 100])

          par(p1, 'GJ', 90)

          gj = game.corporation_by_id('GJ')
          expect(gj.owner).to eq(p1)
          expect(gj.par_price.price).to eq(90)
          expect(gj.cash).to eq(0)
          expect(p1.cash).to eq(800 - 180)
          expect(game.bank.cash).to eq(bank_cash + 180)
          expect(game.current_entity).to eq(p2)
        end

        it 'lets a player who cannot afford the face value pay what they have' do
          p1.spend(p1.cash - 30, game.bank)
          everyone_passes
          buy(p1, 'PEX')

          expect(p1.cash).to eq(0)
          expect(p1.companies.map(&:sym)).to eq(%w[PEX])
        end

        it 'offers only the par prices the buyer of Grand Junction can afford' do
          p1.spend(p1.cash - 150, game.bank)
          everyone_passes
          buy(p1, 'PGJ')

          expect(step.get_par_prices(p1, game.corporation_by_id('GJ')).map(&:price)).to match_array([60, 70])
        end

        it 'pars Grand Junction at the lowest price when everyone passed and the buyer cannot afford it' do
          p1.spend(p1.cash - 100, game.bank)
          everyone_passes
          buy(p1, 'PGJ')

          gj = game.corporation_by_id('GJ')
          expect(gj.owner).to eq(p1)
          expect(gj.par_price.price).to eq(60)
          expect(p1.cash).to eq(0)
          expect(game.current_entity).to eq(p2)
        end

        it 'gives priority in the first stock round to the player after the last buyer' do
          %w[PDI PEX PCO PAF POG].each do |sym|
            everyone_passes
            buy(game.current_entity, sym)
          end
          everyone_passes
          last_buyer = game.current_entity
          buy(last_buyer, 'PGJ')
          par(last_buyer, 'GJ', 60)

          expect(game.round).to be_a(Engine::Round::Stock)
          expect(last_buyer).to eq(p3)
          expect(game.players.map(&:name)).to eq(%w[P1 P2 P3])
        end

        context 'with four players' do
          let(:game) { Engine::Game::GFrost1831::Game.new(%w[P1 P2 P3 P4], id: 1) }

          it 'rotates the stock round order so the player after the last buyer goes first' do
            %w[PDI PEX PCO PAF POG].each do |sym|
              everyone_passes
              buy(game.current_entity, sym)
            end
            everyone_passes
            last_buyer = game.current_entity
            buy(last_buyer, 'PGJ')
            par(last_buyer, 'GJ', 60)

            expect(game.round).to be_a(Engine::Round::Stock)
            expect(last_buyer.name).to eq('P2')
            expect(game.players.map(&:name)).to eq(%w[P3 P4 P1 P2])
          end
        end
      end
    end
  end
end
