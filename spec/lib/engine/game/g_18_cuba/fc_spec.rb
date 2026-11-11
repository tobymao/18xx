# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

module Engine
  module Game
    module G18Cuba
      describe Game do
        include G18CubaSpecHelpers

        let(:players) { %w[a b c] }
        let(:game) { Engine::Game::G18Cuba::Game.new(players) }

        # The topmost regular (broad, non-wagon) train in the bank — what an export pulls.
        def top_broad_train
          game.depot.upcoming.find { |t| !game.wagon?(t) && t.track_type == :broad }
        end

        describe '#export_train_to_fc!' do
          it 'moves the top broad train to the FC, non-rusting and unbuyable' do
            train = top_broad_train
            expect(train.name).to eq('2') # cheapest broad train, first in the bank

            game.export_train_to_fc!

            expect(game.fc.trains).to include(train)          # now on the FC stack
            expect(game.depot.upcoming).not_to include(train) # gone from the bank
            expect(train.rusts_on).to be_nil                  # never scrapped (VII.15/16)
            expect(train.buyable).to be(false)                # cannot be bought back
            expect(game.phase.name).to eq('2')                # exporting a 2 does not advance the phase
          end

          it 'advances the phase when it exports the first 3, like a purchase (VII.17)' do
            game.export_train_to_fc! while top_broad_train&.name == '2' # drain the 2s
            expect(top_broad_train.name).to eq('3')

            game.export_train_to_fc!

            expect(game.phase.name).to eq('3')
          end

          it 'ends the game immediately when the second 8+ is exported' do
            40.times do
              game.export_train_to_fc!
              break if game.finished
            end

            expect(game.finished).to be(true)
            expect(game.game_end_check_second_eight_plus?).to be(true) # ended via 2nd 8+, not bank/bankrupt
          end
        end

        describe 'FC share price' do
          it 'starts at 50 on the first market space' do
            expect(game.fc.share_price.price).to eq(50)
            expect(game.stock_market.market.first.first.corporations).to include(game.fc)
          end
        end

        describe 'FC operating turn' do
          it 'operates last without floating and without asking for an action' do
            ms = game.corporation_by_id('MS')
            float_major!(ms)
            expect(game.fc.floated?).to be(false)
            expect(game.operating_order.last).to eq(game.fc)

            act(Action::Pass) until game.round.is_a?(Engine::Round::Operating)
            act(Action::Pass) until game.round.active_step.is_a?(G18Cuba::Step::BuyTrain)
            train = game.round.active_step.buyable_trains(ms).find { |t| t.track_type == :broad && !game.wagon?(t) }
            act(Action::BuyTrain, train: train, price: train.price)
            or_key = [game.turn, game.round.round_num]
            fc_revenue = game.fc_revenue
            bank_cash = game.bank.cash
            act(Action::Pass) while game.round.is_a?(Engine::Round::Operating) && game.current_entity != game.fc

            expect(game.round).to be_a(Engine::Round::Stock)
            expect(game.fc.operating_history).not_to be_empty
            expect(game.fc.operating_history[or_key].revenue).to eq(fc_revenue)
            expect(game.bank.cash).to eq(bank_cash)
            expect(game.fc.share_price.price).to eq(55)
            expect(game.log.map(&:message)).not_to include(a_string_matching(/\AFC .*skips/))
          end
        end

        describe 'FC shares' do
          let(:ms) { game.corporation_by_id('MS') }
          let(:fc) { game.fc }

          def buy_fc_shares(count)
            count.times { act(Action::BuyShares, shares: fc.ipo_shares.first, share_price: fc.share_price.price) }
          end

          def play_until
            until yield
              step = game.round.active_step
              actions = step.actions(game.current_entity)
              if actions.include?('buy_train') && ms.trains.empty?
                train = step.buyable_trains(ms).find { |t| t.track_type == :broad && !game.wagon?(t) }
                act(Action::BuyTrain, train: train, price: train.price)
              elsif actions.include?('run_routes')
                act(Action::RunRoutes, routes: [])
              else
                act(Action::Pass)
              end
            end
          end

          def on_turn(entity, klass, **args)
            play_until { game.current_entity == entity }
            act(klass, entity, **args)
          end

          def fc_dividend
            or_key = nil
            play_until { (or_key ||= game.round.operating? && [game.turn, game.round.round_num]) && fc.operating_history[or_key] }
            fc.operating_history[or_key].revenue
          end

          before do
            float_major!(ms)
          end

          it 'sells IPO shares for the bank, without float, president, double listing or sold-out bump' do
            bank_cash = game.bank.cash
            buy_fc_shares(10)

            expect(game.bank.cash).to eq(bank_cash + 500)
            expect([fc.cash, fc.owner]).to eq([0, nil])
            expect(game.log.map(&:message)).not_to include(a_string_matching(/president of FC|FC floats/))
            expect(game.operating_order.count(fc)).to eq(1)
            expect(game.operating_order.last).to eq(fc)
            play_until { game.round.operating? }
            expect([game.sold_out?(fc), fc.share_price.price]).to eq([true, 50])
          end

          it 'pays 10% per share, lets the sole holder sell share 0 at an unchanged price and pays nothing for it in the pool' do
            holder = game.current_entity
            buy_fc_shares(1)
            holder_cash = holder.cash
            revenue = fc_dividend
            expect(revenue).to be_positive
            expect(holder.cash).to eq(holder_cash + (revenue * holder.percent_of(fc) / 100))

            price = fc.share_price
            expect(game.value_for_dumpable(holder, fc)).to eq(price.price)
            on_turn(holder, Action::SellShares, shares: holder.shares_of(fc), share_price: price.price, percent: 10)
            expect([fc.share_price, fc.owner, game.share_pool.shares_of(fc).map(&:index)]).to eq([price, nil, [0]])

            bank_cash = game.bank.cash
            fc_dividend
            expect([fc.cash, game.bank.cash]).to eq([0, bank_cash])
          end

          it 'keeps the FC without president when share 0 is sold next to another holder' do
            holder = game.current_entity
            buy_fc_shares(2)
            play_until { game.turn == 2 && game.round.stock? }
            price = fc.share_price
            on_turn(holder, Action::SellShares, shares: holder.shares_of(fc), share_price: price.price, percent: 10)

            expect([fc.share_price, fc.owner]).to eq([price, nil])
            expect(game.log.map(&:message)).not_to include(a_string_matching(/president of FC/))
          end

          it 'lets a major president in emergency sell share 0 of the FC' do
            president = ms.owner
            major = game.corporations.find { |c| c != ms && c.type == :major && game.can_par?(c, president) }
            on_turn(president, Action::BuyShares, shares: fc.ipo_shares.first, share_price: fc.share_price.price)
            on_turn(president, Action::Par, corporation: major, share_price: game.stock_market.par_prices.max_by(&:price))
            on_turn(president, Action::BuyShares, shares: major.ipo_shares.first, share_price: 100) while president.cash >= 100
            game.export_train_to_fc! until top_broad_train.name == '8+'
            play_until { game.round.active_step.is_a?(G18Cuba::Step::BuyTrain) }

            act(Action::SellShares, president, shares: president.shares_of(fc), share_price: fc.share_price.price, percent: 10)
            expect(game.share_pool.shares_of(fc).map(&:index)).to eq([0])
          end
        end

        describe '#crowded_corps' do
          it 'never includes the FC (no train limit, never discards)' do
            # the FC holds its preprinted train and its train limit is 0 — flagged without the exemption
            expect(game.crowded_corps).not_to include(game.fc)
          end
        end

        describe 'FC station markers' do
          let(:ms) { game.corporation_by_id('MS') }

          def advance
            step = game.round.active_step
            actions = step.actions(game.current_entity)
            if actions.include?('buy_train') && ms.trains.empty?
              train = step.buyable_trains(ms).find { |t| t.track_type == :broad && !game.wagon?(t) }
              act(Action::BuyTrain, train: train, price: train.price)
            elsif actions.include?('run_routes')
              act(Action::RunRoutes, routes: [])
            elsif actions.include?('dividend')
              act(Action::Dividend, kind: 'withhold')
            else
              act(Action::Pass)
            end
          end

          def lay(hex_id, color, exit = nil)
            advance until game.current_entity == ms && game.round.active_step.is_a?(G18Cuba::Step::Track)
            step = game.round.active_step
            hex = game.hex_by_id(hex_id)
            tile, rotation = step.potential_tiles(ms, hex).select { |t| t.color == color }
                                 .flat_map { |t| step.legal_tile_rotations(ms, hex, t).map { |r| [t, r] } }
                                 .find { |t, r| exit.nil? || t.rotate!(r).exits.include?(exit) }
            act(Action::LayTile, tile: tile, hex: hex, rotation: rotation)
          end

          it 'places the first FC marker in Havana city 1 at setup and keeps seven unplaced' do
            havana = game.hex_by_id('B7').tile.cities
            expect(havana.last.tokens.compact.map(&:corporation)).to eq([game.fc])
            expect(havana.first.tokened_by?(game.fc)).to be(false)
            expect(game.fc.tokens.size).to eq(8)
            expect(game.fc.tokens.count { |t| !t.used }).to eq(7)
          end

          it 'places an FC marker on green FC hexes only, not on yellow or outside FC hexes' do
            float_major!(ms)
            game.export_train_to_fc! while game.phase.name == '2'

            lay('B9', :yellow, 4)
            lay('B11', :yellow, 5)
            expect(game.fc.tokens.filter_map { |t| t.hex&.id }).to match_array(%w[B7])
            lay('B11', :green)
            expect(game.fc.tokens.filter_map { |t| t.hex&.id }).to match_array(%w[B7 B11])
            expect(game.hex_by_id('B11').tile.icons.map(&:name)).not_to include('FC')
            expect(game.hex_by_id('B9').tile.icons.map(&:name)).to include('FC')
            lay('C12', :yellow, 5)
            lay('D13', :yellow)
            lay('D13', :green)
            expect(game.fc.tokens.filter_map { |t| t.hex&.id }).to match_array(%w[B7 B11])
            expect(game.fc.tokens.count { |t| !t.used }).to eq(6)
          end

          it 'sums the FC best city revenues up to the reach of its top train' do
            float_major!(ms)
            game.phase.next!

            lay('B9', :yellow)
            lay('B9', :green)
            expect(game.fc.tokens.filter_map { |t| t.hex&.id }).to match_array(%w[B7 B9])
            expect(game.fc_city_revenue).to eq(30)

            game.export_train_to_fc!
            expect(game.fc_city_revenue).to eq(60)
          end
        end
      end
    end
  end
end
