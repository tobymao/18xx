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
        let(:double_town) { j77.tile.double_towns.first }
        let(:train) { buy_train!(game, corp, '3') }
        let(:route) do
          Engine::Route.new(game, game.phase, train, routes: []).tap { |r| r.routes = [r] }
        end

        let(:selected_route) { route }
        let(:dot) do
          described_class.new(nil, tile: j77.tile, double_town: double_town, show_revenue: false,
                                   region_use: {}, game: game, selected_route: selected_route)
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

        def hit_box_callback(current_actions)
          step = double('Step', current_actions: current_actions)
          allow(game).to receive(:active_step).and_return(step)
          allow(dot).to receive(:translate).and_return('translate(0 0)')
          callback = nil
          allow(dot).to receive(:h) do |component, props|
            callback = props[:click] if component == View::Game::HitBox
          end
          dot.render_hit_box
          callback
        end

        it 'renders no hit box when the double town is the only node on its tile' do
          allow(dot).to receive(:translate).and_return('translate(0 0)')

          expect(dot.render_hit_box).to be_nil
        end

        context 'with a city beside the double town' do
          let(:tile) do
            Engine::Tile.from_code('XJ77', :green, 'city=revenue:20;double_town=revenue:10;path=a:0,b:_0;path=a:3,b:_1')
          end
          let(:double_town) { tile.double_towns.first }
          let(:dot) do
            described_class.new(nil, tile: tile, double_town: double_town, show_revenue: false,
                                     region_use: {}, game: game, selected_route: selected_route)
          end

          before { j77.lay(tile) }

          it 'adds the double town to the selected route with one click' do
            route.touch_node(west)
            expect(route).to receive(:touch_node).with(double_town).once.and_call_original
            expect(dot).to receive(:store).with(:selected_route, route).once

            hit_box_callback(['run_routes']).call
          end

          it 'ignores a click when the step does not run routes' do
            expect(route).not_to receive(:touch_node)
            expect(dot).not_to receive(:store)

            hit_box_callback([]).call
          end

          context 'with no selected route' do
            let(:selected_route) { nil }

            it 'ignores a click' do
              expect(dot).not_to receive(:store)

              hit_box_callback(['run_routes']).call
            end
          end
        end
      end
    end
  end
end
