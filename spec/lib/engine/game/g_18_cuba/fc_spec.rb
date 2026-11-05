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

          it 'pays the FC its best city revenues up to the reach of its top train' do
            float_major!(ms)
            game.phase.next!

            lay('B9', :yellow)
            fc_cash = game.fc.cash
            lay('B9', :green)
            expect(game.fc.cash).to eq(fc_cash + 30)
            expect(game.fc.tokens.filter_map { |t| t.hex&.id }).to match_array(%w[B7 B9])

            fc_cash = game.fc.cash
            game.pay_fc_city_revenue
            expect(game.fc.cash).to eq(fc_cash + 30)

            game.export_train_to_fc!
            fc_cash = game.fc.cash
            bank_cash = game.bank.cash
            game.pay_fc_city_revenue
            expect(game.fc.cash).to eq(fc_cash + 60)
            expect(game.bank.cash).to eq(bank_cash - 60)
          end
        end
      end
    end
  end
end
