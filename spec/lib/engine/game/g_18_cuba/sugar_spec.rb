# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

module Engine
  module Game
    module G18Cuba
      # Method-level tests for the sugar transport mechanic (Sugar module mixed into Game).
      describe Game do
        include G18CubaSpecHelpers

        let(:players) { %w[a b c] }
        let(:game) { Engine::Game::G18Cuba::Game.new(players) }
        let(:minor) { game.corporations.find { |c| c.type == :minor } }

        describe '#sugar_production' do
          it 'maps revenue to sugar cubes at Table 10 boundaries' do
            [[20, 0], [30, 1], [70, 1], [80, 2], [150, 2], [151, 3], [300, 3]].each do |rev, cubes|
              game.sugar_production(minor, rev)
              expect(game.sugar_cubes_for(minor)).to eq(cubes), "#{rev} revenue should yield #{cubes} cube(s)"
            end
          end
        end

        describe 'cube accounting' do
          let(:wagon_train) { give_train(minor, '1w') }
          let(:harbor) { double('harbor') }
          let(:route) { instance_double(Engine::Route, train: wagon_train, visited_stops: [harbor]) }

          it 'pays exactly $30 per delivered cube and never oversells the warehouse' do
            allow(game).to receive(:harbor?) { |s| s.equal?(harbor) }
            game.sugar_production(minor, 80) # 80 revenue -> 2 cubes (Table 10)
            2.times { game.attach_cube_to_train(wagon_train, minor) }

            expect(game.wagon_cube_bonus(route)).to eq(60) # 2 × CUBE_VALUE
            game.collect_wagon_cubes([route])
            expect(game.sugar_cubes_for(minor)).to eq(0) # exactly drawn down, not negative
          end
        end

        describe '#extended_harbor_revenue' do
          let(:wagon_train) { give_train(minor, '4') } # regular broad train, distance 4
          let(:wagon) { depot_train('1w') }

          it 'zeroes the +1-extended harbor for any attached wagon, regardless of cubes' do
            wt = wagon_train
            # @round after Game.new is an Auction round without wagon_for_train; inject a minimal stand-in.
            game.instance_variable_set(:@round, double(wagon_for_train: { wt.id => wagon }))

            harbor = double(visit_cost: 1)
            allow(harbor).to receive(:route_revenue).and_return(10)
            allow(game).to receive(:harbor?) { |s| s.equal?(harbor) }
            route = double(train: wt, phase: game.phase)

            extended = [harbor] + Array.new(4) { double(visit_cost: 1) } # sum 5 > distance 4
            in_range = [harbor] + Array.new(3) { double(visit_cost: 1) } # sum 4 == distance 4

            # +1 extension, empty wagon -> extended harbor revenue is returned (so it nets 0)
            expect(game.send(:extended_harbor_revenue, route, extended)).to eq(10)

            # loading a cube does not change it -> no exploit, no deadlock
            game.attach_cube_to_train(wt, minor)
            expect(game.send(:extended_harbor_revenue, route, extended)).to eq(10)

            # within the train's distance (no extension) -> harbor counts full
            expect(game.send(:extended_harbor_revenue, route, in_range)).to eq(0)
          end
        end

        describe 'Isla de Tesoros harbor' do
          let(:isla) { game.hex_by_id('E4').tile.offboards.first }
          let(:harbor) { game.hex_by_id('E12').tile.offboards.first }

          it 'pays 20 through phase 4 and 40 from phase 5' do
            train = game.depot.depot_trains.find { |t| t.track_type == :broad && !game.wagon?(t) }

            expect(game.phase.name).to eq('2')
            expect(isla.route_revenue(game.phase, train)).to eq(20)
            expect(harbor.route_revenue(game.phase, train)).to eq(10)

            game.export_train_to_fc! until game.phase.name == '4'
            expect(isla.route_revenue(game.phase, train)).to eq(20)

            game.export_train_to_fc! until game.phase.name == '5'
            expect(isla.route_revenue(game.phase, train)).to eq(40)
            expect(harbor.route_revenue(game.phase, train)).to eq(10)
          end

          it 'zeroes the cheaper harbor when a wagon extends a route with harbors at both ends' do
            wagon_train = give_train(minor, '4')
            game.instance_variable_set(:@round, double(wagon_for_train: { wagon_train.id => depot_train('1w') }))
            route = double(train: wagon_train, phase: game.phase)
            fillers = %w[C4 D13 F21].map { |id| game.hex_by_id(id).tile.cities.first }
            [[isla, *fillers, harbor], [harbor, *fillers, isla]].each do |stops|
              expect(stops.sum(&:visit_cost)).to eq(wagon_train.distance + 1)
              expect(game.send(:extended_harbor_revenue, route, stops)).to eq(10)
            end
          end
        end

        describe 'unshipped cubes' do
          let(:minor_a) { minor }
          let(:minor_b) { game.corporations.find { |c| c.type == :minor && c != minor_a } }

          it 'values the unshipped cubes at $10 each and returns them to the supply' do
            game.sugar_production(minor_a, 80)
            game.sugar_production(minor_b, 30)

            expect(game.unshipped_cubes_revenue).to eq(30)
            game.return_unshipped_cubes

            expect(game.sugar_cubes_for(minor_a)).to eq(0)
            expect(game.sugar_cubes_for(minor_b)).to eq(0)
          end

          it 'ends the game after the set when the FC revenue breaks the bank in its last OR' do
            ms = game.corporation_by_id('MS')
            float_major!(ms)
            act(Action::Pass) until game.round.is_a?(Engine::Round::Operating)
            act(Action::Pass) until game.round.active_step.is_a?(G18Cuba::Step::BuyTrain)
            train = game.round.active_step.buyable_trains(ms).find { |t| t.track_type == :broad && !game.wagon?(t) }
            act(Action::BuyTrain, train: train, price: train.price)

            game.sugar_production(minor, 80)
            game.bank.spend(game.bank.cash - 5, game.players.first)
            or_key = [game.turn, game.round.round_num]
            fc_revenue = game.fc_city_revenue + 20
            act(Action::Pass) until game.finished || !game.round.is_a?(Engine::Round::Operating)

            expect(game.fc.operating_history[or_key].revenue).to eq(fc_revenue)
            expect(game.sugar_cubes_for(minor)).to eq(0)
            expect(game.bank.broken?).to be(true)
            expect(game.finished).to be(true)
            expect(game.round).to be_a(Engine::Round::Operating)
          end
        end
      end
    end
  end
end
