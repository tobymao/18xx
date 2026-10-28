# frozen_string_literal: true

require './spec/spec_helper'
require './spec/lib/engine/game/g_18_oe/helpers'

require 'view/game/part/double_town_touch'

module View
  module Game
    module Part
      describe DoubleTownTouch do
        include G18OESpecHelpers

        let(:game) { new_game }
        let(:corp) { game.corporation_by_id('A') }
        let(:far) { game.hex_by_id('H75').tile.cities.first }
        let(:west) { game.hex_by_id('I76').tile.cities.first }
        let(:a) { game.hex_by_id('J77').tile.towns[0] }
        let(:b) { game.hex_by_id('J77').tile.towns[1] }
        let(:train) { buy_train!('4') }

        def lay_tile!(hex_id, name, rotation)
          tile = game.tiles.find { |t| t.name == name && !t.hex }
          tile.rotate!(rotation)
          game.hex_by_id(hex_id).lay(tile)
        end

        def buy_train!(name)
          train = game.trains.find { |t| t.name == name && !t.owner.is_a?(Engine::Corporation) }
          game.buy_train(corp, train, :free)
          train
        end

        def route_through(*nodes)
          route = Engine::Route.new(game, game.phase, train, routes: [])
          route.routes = [route]
          nodes.each { |node| route.touch_node(node) }
          route
        end

        def click_pill(route)
          described_class.touch_towns(route, [a, b])
        end

        before do
          lay_tile!('J77', 'OE1', 2)
          lay_tile!('I76', '57', 2)
          lay_tile!('H75', '57', 2)
          game.graph.clear
        end

        describe '.touch_towns' do
          it 'adds both towns from a city' do
            route = route_through(west)
            click_pill(route)

            expect(described_class.route_nodes(route)).to contain_exactly(west, a, b)
          end

          it 'continues past the pill to the far city' do
            route = route_through(west)
            click_pill(route)
            route.touch_node(far)

            expect(described_class.route_nodes(route)).to contain_exactly(far, west, a, b)
          end

          it 'adds the second town when one town is already the end of the route' do
            route = route_through(west, b)
            click_pill(route)

            expect(described_class.route_nodes(route)).to contain_exactly(west, a, b)
          end

          it 'adds both towns when the route is a single town' do
            route = route_through(a)
            click_pill(route)

            expect(described_class.route_nodes(route)).to contain_exactly(a, b)
          end

          it 'removes both towns when they were the last nodes clicked onto the route' do
            route = route_through(west, a, b)
            click_pill(route)

            expect(described_class.route_nodes(route)).to eq([west])
          end

          it 'removes both towns from the tail of a three node route, keeping the city' do
            route = route_through(a, b, west)
            click_pill(route)

            expect(described_class.route_nodes(route)).to eq([west])
          end

          it 'removes both towns from the tail of a longer route, keeping the other nodes in order' do
            route = route_through(a, b, west, far)
            click_pill(route)

            expect(described_class.route_nodes(route)).to eq([far, west])
          end

          it 'removes both towns from the head of a longer route, keeping the other nodes in order' do
            route = route_through(far, west, a, b)
            click_pill(route)

            expect(described_class.route_nodes(route)).to eq([west, far])
          end

          it 'clears a route that is only the double town' do
            route = route_through(a, b)
            click_pill(route)

            expect(described_class.route_nodes(route)).to be_empty
          end

          it 'leaves a route alone when both towns are in its middle' do
            lay_tile!('K78', '57', 2)
            east = game.hex_by_id('K78').tile.cities.first
            route = route_through(west, a, b, east)
            click_pill(route)

            expect(described_class.route_nodes(route)).to contain_exactly(west, a, b, east)
          end
        end
      end
    end
  end
end
