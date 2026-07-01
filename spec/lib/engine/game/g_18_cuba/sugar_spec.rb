# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module G18Cuba
      # Method-level tests for the sugar transport mechanic (Sugar module mixed into Game).
      describe Game do
        let(:players) { %w[a b c] }
        let(:game) { Engine::Game::G18Cuba::Game.new(players) }
        let(:minor) { game.corporations.find { |c| c.type == :minor } }

        # Finds a train by name in the depot (includes upcoming trains).
        def depot_train(name)
          game.depot.depot_trains.find { |t| t.name == name } ||
            game.depot.upcoming.find { |t| t.name == name }
        end

        # Injects a train directly into a corporation, bypassing cash / buy-step validation.
        def give_train(corp, name)
          train = depot_train(name)
          return nil unless train

          game.depot.remove_train(train)
          train.owner = corp
          corp.trains << train
          train
        end

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
      end
    end
  end
end
