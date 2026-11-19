# frozen_string_literal: true

require 'spec_helper'
require 'engine/auto_router'
require_relative 'helpers'

shared_context 'with 18OE route helpers' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:corp) { game.corporation_by_id('A') }
  let(:c1) { game.hex_by_id('J79').tile.cities.first }
  let(:c3) { game.hex_by_id('J83').tile.cities.first }
  let(:c2) { game.hex_by_id('K80').tile.cities.first }

  def buy_train!(name)
    train = game.trains.find { |t| t.name == name && !t.owner.is_a?(Engine::Corporation) }
    game.buy_train(corp, train, :free)
    train
  end

  def route_through(train, *nodes)
    route = Engine::Route.new(game, game.phase, train, routes: [])
    route.routes = [route]
    nodes.each { |node| route.touch_node(node) }
    route
  end

  def explicit_route(train, *nodes)
    route = Engine::Route.new(game, game.phase, train, routes: [])
    route.routes = [route]
    nodes.each_cons(2) do |left, right|
      chain = route.select(left, right).first
      raise "No unused connection between #{left.signature} and #{right.signature}" unless chain

      route.connection_data << route.segment(chain, left: left)
    end
    route
  end

  def lay_code!(hex_id, code)
    game.hex_by_id(hex_id).lay(Engine::Tile.from_code("X#{hex_id}", :green, code,
                                                      revisitable_nodes: game.class::REVISITABLE_NODES))
    game.graph.clear
  end

  def rebuild(route)
    rebuilt = Engine::Route.new(game, game.phase, route.train, routes: [], connection_hexes: route.connection_hexes)
    rebuilt.routes = [rebuilt]
    rebuilt
  end

  def auto_best(train)
    Engine::AutoRouter.new(game).path([train], corp).first[train].first
  end

  def node_sequence(route)
    route.connection_data.map { |c| [c[:left], c[:right]] }
  end

  def token!(hex_id, corporation)
    node = game.hex_by_id(hex_id).tile.cities.first
    node.place_token(corporation, Engine::Token.new(corporation), free: true, check_tokenable: false)
    game.graph.clear
  end

  def city(hex_id) = game.hex_by_id(hex_id).tile.cities.first
  def town(hex_id) = game.hex_by_id(hex_id).tile.towns.first
  def offboard(hex_id) = game.hex_by_id(hex_id).tile.offboards.first

  def baltic!
    lay_code!('I50', 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0')
    lay_code!('I52', 'city=revenue:20;path=a:0,b:_0;path=a:3,b:_0')
    lay_code!('H53', 'path=a:0,b:4')
    lay_code!('H55', 'town=revenue:10;path=a:1,b:_0;path=a:4,b:_0')
    lay_code!('K60', 'town=revenue:10;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0')
    lay_code!('K62', 'path=a:1,b:3')
    lay_code!('J63', 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0')
  end
end
