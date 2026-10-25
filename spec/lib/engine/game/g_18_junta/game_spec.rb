# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module G18Junta
      describe Game do
        let(:players) { %w[a b c] }
        let(:optional_rules) { [] }
        let(:game) { Engine::Game::G18Junta::Game.new(players, id: 1, optional_rules: optional_rules) }

        def auction_step
          game.round.active_step
        end

        def current_player
          game.round.active_entities.first
        end

        def bid(company, price)
          game.process_action(Engine::Action::Bid.new(current_player, company: company, price: price)).maybe_raise!
        end

        def pass
          game.process_action(Engine::Action::Pass.new(current_player)).maybe_raise!
        end

        describe 'private company auction (rules summary 2.1)' do
          it 'opens at face value and needs a raise of at least $5' do
            company = game.companies.first
            expect(auction_step.min_bid(company)).to eq(company.value)

            bid(company, company.value)
            expect(auction_step.min_bid(company)).to eq(company.value + 5)
          end

          context 'with the faster auction option' do
            let(:optional_rules) { [:bid_increment_10] }

            it 'needs a raise of at least $10' do
              company = game.companies.first
              bid(company, company.value)
              expect(auction_step.min_bid(company)).to eq(company.value + 10)
            end
          end

          it 'rejects bids that are not a multiple of $5' do
            company = game.companies.first
            expect { bid(company, company.value + 1) }.to raise_error(GameError, /multiple of \$5/)
          end

          it 'gives the company to the highest bidder, and the next player chooses' do
            company = game.companies.first
            opener = current_player
            bid(company, company.value)
            pass
            pass

            expect(company.owner).to eq(opener)
            expect(opener.cash).to eq(game.class::STARTING_CASH[players.size] - company.value)
            expect(current_player).to eq(game.players[(game.players.index(opener) + 1) % players.size])
          end

          it 'offers a discount round at half value after everyone passes the choice' do
            company = game.companies.max_by(&:value)
            players.size.times { pass }

            expect(auction_step.min_bid(company)).to eq((company.value / 10.0).ceil * 5)
          end

          it 'removes the remaining companies when the discount round is declined too' do
            companies = game.companies.dup
            (players.size * 2).times { pass }

            expect(companies).to all(be_closed)
            expect(game.round).to be_a(Engine::Round::Stock)
          end
        end

        describe 'priority after the auction (rules summary 2.1)' do
          it 'goes to the player with the most cash, ties broken by seating order' do
            seating = game.players.dup
            company = game.companies.max_by(&:value)
            buyer = current_player
            bid(company, company.value)
            pass
            pass
            pass while game.round.is_a?(Engine::Round::Auction)

            expected = (seating - [buyer]).first
            expect(game.round.active_entities.first).to eq(expected)
            expect(game.log.map(&:message)).to include(a_string_including("#{expected.name} has priority"))
          end
        end

        describe 'stock market (rules summary 3.5)' do
          let(:corporation) { game.corporations.first }

          def place_at(row, column)
            price = game.stock_market.market[row][column]
            corporation.share_price = price
            price.corporations << corporation
          end

          it 'moves right instead of up on the top row' do
            place_at(0, 3)
            game.stock_market.move_up(corporation)
            expect(corporation.share_price.coordinates).to eq([0, 4])
          end

          it 'stays on the last space of the top row' do
            last = game.stock_market.market[0].size - 1
            place_at(0, last)
            game.stock_market.move_up(corporation)
            expect(corporation.share_price.coordinates).to eq([0, last])
          end

          it 'moves up as usual below the top row' do
            place_at(2, 4)
            game.stock_market.move_up(corporation)
            expect(corporation.share_price.coordinates).to eq([1, 4])
          end
        end

        describe 'dividend movement (rules summary 3.5)' do
          let(:corporation) { game.corporations.first }
          let(:step) { G18Junta::Step::Dividend.new(game, game.round) }

          before { corporation.share_price = game.stock_market.market[2][4] } # $100

          it 'moves left when withholding' do
            expect(step.share_price_change(corporation, 0)).to eq(share_direction: :left, share_times: 1)
          end

          it 'moves right for a normal payout' do
            expect(step.share_price_change(corporation, 199)).to eq(share_direction: :right, share_times: 1)
          end

          it 'moves right and up for a high dividend (at least twice the share price)' do
            expect(step.share_price_change(corporation, 200))
              .to eq(share_direction: %i[right up], share_times: [1, 1])
          end
        end
      end
    end
  end
end
