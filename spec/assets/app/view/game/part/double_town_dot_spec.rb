# frozen_string_literal: true

require './spec/spec_helper'
require_relative '../../../../../lib/engine/game/g_18_oe/helpers'
require 'view/game/part/double_town_dot'

module View
  module Game
    module Part
      describe DoubleTownDot do
        include G18OESpecHelpers

        let(:game) { new_game }
        let(:corp) { game.corporation_by_id('A') }
        let(:j77) { game.hex_by_id('J77') }
        let(:west) { game.hex_by_id('I76').tile.cities.first }
        let(:a) { j77.tile.towns[0] }
        let(:b) { j77.tile.towns[1] }
        let(:east) { game.hex_by_id('K78').tile.cities.first }
        let(:train) { buy_train!(game, corp, '3') }
        let(:route) do
          Engine::Route.new(game, game.phase, train, routes: []).tap { |r| r.routes = [r] }
        end
        let(:dot) do
          described_class.new(nil, tile: j77.tile, double_town: j77.tile.double_towns.first, show_revenue: false,
                                   region_use: {}, game: game)
        end

        before do
          stub_const('Native', double('Class', convert: ''))
          lay_tile!(game, 'J77', 'OE1', 2)
          lay_tile!(game, 'I76', '57', 2)
          lay_tile!(game, 'K78', '57', 2)
          west.place_token(corp, corp.next_token, check_tokenable: false)
          game.graph.clear
        end

        def lay_tile!(game, hex_id, name, rotation)
          tile = game.tiles.find { |t| t.name == name && !t.hex }
          tile.rotate!(rotation)
          game.hex_by_id(hex_id).lay(tile)
          tile
        end

        def buy_train!(game, corporation, name)
          train = game.trains.find { |t| t.name == name && !t.owner.is_a?(Engine::Corporation) }
          game.buy_train(corporation, train, :free)
          train
        end

        def route_nodes
          return [route.last_node].compact if route.connection_data.empty?

          [route.head[:left]] + route.connection_data.map { |c| c[:right] }
        end

        def click_pill
          dot.send(:touch_towns, route)
          route_nodes
        end

        it 'touches both towns when neither is on the route' do
          expect(click_pill).to contain_exactly(a, b)
        end

        it 'touches the other town when the route already has one' do
          route.touch_node(west)
          route.touch_node(a)
          expect(click_pill).to contain_exactly(west, a, b)
        end

        it 'touches the other town when the route starts at one town' do
          route.touch_node(b)
          expect(click_pill).to contain_exactly(a, b)
        end

        it 'removes both towns when they are at the route end' do
          [a, b, east].each { |node| route.touch_node(node) }
          expect(click_pill).to be_empty
        end

        it 'leaves the route alone when both towns are mid-route' do
          [west, a, b, east].each { |node| route.touch_node(node) }
          expect(click_pill).to contain_exactly(west, a, b, east)
        end
      end
    end
  end
end
