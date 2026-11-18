# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../../lib/engine/game/g_18_oe/helpers'
require 'view/game/token_selector'
require 'view/game/part/city_slot'

describe View::Game::TokenSelector do
  include G18OESpecHelpers

  def render_nodes(component)
    nodes = []
    allow(component).to receive(:setting_for).with(:simple_logos, anything).and_return(false)
    allow(component).to receive(:h) do |tag, props = {}, children = nil|
      nodes << [tag, props, children]
      [tag, props, children]
    end
    component.render
    nodes
  end

  context 'with an 18OE railroad placing a station token' do
    let(:game) { new_game }
    let(:city) { game.hex_by_id('C48').tile.cities.first }
    let(:city_slot) do
      View::Game::Part::CitySlot.new(nil, game: game, tile: city.tile, city: city, token: nil,
                                          slot_index: 0, edge: nil, radius: 20, region_use: {})
    end
    let(:click_event) { double(JS: double(stopPropagation: nil)) }

    it 'opens a picker with one total per price and disables tokens the railroad cannot afford' do
      major = start_major!(game, 'DSJ', game.players.first)
      round = station_token_round!(game, major)
      expect(city_slot).not_to receive(:process_action)
      selector = nil
      allow(city_slot).to receive(:store).with(:tile_selector, an_instance_of(Lib::TokenSelector)) do |_, selection|
        selector = selection
      end

      city_slot.on_click(click_event)

      component = described_class.new(nil, game: game, tile_selector: selector)
      buttons = render_nodes(component).select { |tag, _, _| tag == :button }
      expect(buttons.map { |_, _, children| children.last }).to eq(%w[£60 £80 £100 £120])
      expect(buttons.map { |_, props, _| props[:attrs][:disabled] }).to eq([nil, nil, nil, true])
      expect(buttons.last[1].dig(:on, :click)).to be_nil
      expect(component).to receive(:process_action) do |action|
        expect(action.to_h).to include('city' => city.id, 'slot' => 0, 'token_index' => 3, 'cost' => 100)
        act!(round, action)
      end

      buttons[2][1][:on][:click].call

      expect(city.tokens).to include(major.tokens[3])
      expect(major.cash).to eq(10)
    end

    it 'places the token with one click when the available charter tokens share a price' do
      regional = start_regional!(game, 'DSJ', game.players.first)
      regional.tokens << Engine::Token.new(regional, price: 20)
      round = station_token_round!(game, regional)
      expect(city_slot).to receive(:store).with(:selected_company, nil, skip: true)
      expect(city_slot).to receive(:process_action) { |action| act!(round, action) }

      city_slot.on_click(click_event)

      expect(city.tokens).to include(regional.tokens[1])
    end
  end

  it 'continues to select by token type in 1882' do
    game = Engine::Game::G1882::Game.new(%w[a b c], seed: 1)
    corporation = game.corporations.find { |corp| corp.tokens.map(&:type).uniq.size > 1 }
    allow(game).to receive(:current_entity).and_return(corporation)
    hex = game.hex_by_id(corporation.coordinates)
    city = hex.tile.cities.first
    selector = Lib::TokenSelector.new(hex, [0, 0], city, 0)
    component = described_class.new(nil, game: game, tile_selector: selector)
    images = render_nodes(component).select { |tag, _, _| tag == :img }
    expect(images.size).to eq(2)
    expect(component).to receive(:process_action) do |action|
      expect(action.to_h).to include('city' => city.id, 'tokener' => corporation.id, 'token_type' => :neutral)
      expect(action.to_h).not_to have_key('token_index')
    end

    images.last[1][:on][:click].call
  end
end
