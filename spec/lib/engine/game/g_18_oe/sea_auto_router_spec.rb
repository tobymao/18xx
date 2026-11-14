# frozen_string_literal: true

require 'spec_helper'
require 'engine/auto_router'
require_relative 'route_helpers'

describe 'G18OE auto-router over sea (§11.3.4, §11.3.8)' do
  include_context 'with 18OE route helpers'

  let(:corp) { game.corporation_by_id('DSJ') }
  let(:three) { buy_train!('3') }
  let(:four) { buy_train!('4') }

  def routes_for(train, corporation = corp, trains: [train])
    Engine::AutoRouter.new(game).path(trains, corporation).first[train]
  end

  before { baltic! }

  it 'turns a yielded link into a pathless chain and keeps the route (core link assembly)' do
    token!('I50', corp)
    token!('I52', corp)
    link = game.sea_chains(city('I50'), city('I52'), corp).first[:crossing]
    allow(game.graph).to receive(:walk_routes) { |_node, **, &block| block.call(link, { link => true }, {}) }
    routes = routes_for(three)

    expect(routes.size).to eq(1)
    expect(routes.first.chains).to eq([link.chain])
    expect(routes.first.visited_stops).to contain_exactly(city('I50'), city('I52'))
    expect(routes.first.bitfield).to eq([0])
  end

  it 'gives a ferry-only route an empty bitfield so it conflicts with nothing' do
    token!('I52', corp)
    route = explicit_route(three, town('H55'), town('K60'))

    expect(Engine::AutoRouter.new(game).bitfield_from_connection(route.connection_data, Hash.new { |h, k| h[k] = 0 })).to eq([0])
  end
end
