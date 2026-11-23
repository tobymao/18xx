# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../../lib/engine/game/g_18_oe/helpers'
require 'view/game/choose'

describe View::Game::Choose do
  include G18OESpecHelpers

  [Engine::Game::G18OE::Game, Engine::Game::G18OEUKFR::Game].each do |klass|
    context "with #{klass.title} Minor C" do
      let(:game) { new_game(%w[a b c], klass: klass) }
      let(:player) { game.players.first }
      let(:minor) { start_minor!(game, 'C', player, 'UK') }
      let(:component) { described_class.new(nil, game: game) }

      it 'renders all positions and submits the choice as C while another railroad is normally first' do
        regional = start_regional!(game, 'PLM', game.players.last)
        minor
        round = enter_round!(game, game.operating_round(1)).tap(&:setup)
        nodes = []
        allow(component).to receive(:h) do |tag, props = {}, children = nil|
          nodes << [tag, props, children]
          [tag, props, children]
        end
        allow(component).to receive(:process_action) { |action| round.process_action(action) }

        component.render
        buttons = nodes.select { |tag, _, _| tag == 'button' }
        expect(buttons.map(&:last)).to eq(%w[First Normal Last])
        expect(round.entities.first).to eq(regional)
        expect(game.current_entity).to eq(minor)

        buttons.first[1][:on][:click].call
        expect(round.current_operator).to eq(minor)
        expect(round.entities).to eq([minor, regional])
        expect(round.actions_for(minor)).to include('lay_tile')
      end
    end
  end

  context 'with 18OE port authority sales in Transfer Tokens' do
    let(:game) { new_game }
    let(:buyer) { start_major!(game, 'LNWR', game.players.first) }
    let(:seller) { start_major!(game, 'GWR', game.players.first) }
    let(:sea) { game.port_authority_seas.first }
    let(:component) { described_class.new(nil, game: game) }
    let(:nodes) { [] }

    before do
      fund!(game, buyer, 500)
      game.instance_variable_get(:@port_authorities)[seller] << sea
      station_token_round!(game, buyer, step_class: Engine::Game::G18OE::Step::TransferTokens)
      allow(component).to receive(:h) do |tag, props = {}, children = nil|
        nodes << [tag, props, children]
        [tag, props, children]
      end
    end

    it 'renders a button per port authority purchase and submits the choice' do
      component.render
      buttons = nodes.select { |tag, _, _| tag == 'button' }
      expect(buttons.map(&:last)).to eq(["Buy #{game.port_authority_name(sea)} from #{seller.name} (£125)"])
      expect(component).to receive(:process_action) do |action|
        expect(action.choice).to eq("#{seller.id}:#{sea}")
        act!(game.round, action)
      end

      buttons.first[1][:on][:click].call

      expect(game.port_authorities(buyer)).to eq([sea])
    end

    it "asks the seller's president to consent before buying from another player" do
      seller.owner = game.players[1]
      component.render
      button = nodes.find { |tag, _, _| tag == 'button' }
      expect(component).to receive(:check_consent).with(buyer, game.players[1], an_instance_of(Proc))

      button[1][:on][:click].call
    end
  end

  context 'with national formation' do
    let(:game) { new_game }
    let(:player) { game.players.first }

    it 'renders each convertible major and Done for the forming player, submitted as the player' do
      lnwr = start_major!(game, 'LNWR', player)
      start_major!(game, 'GWR', player)
      round = enter_round!(game, game.operating_round(1)).tap(&:setup)
      round.instance_variable_set(:@current_operator, lnwr)
      game.start_national_formation!(player)
      round.send(:clear_cache!)
      nodes = []
      component = described_class.new(nil, game: game)
      allow(component).to receive(:h) do |tag, props = {}, children = nil|
        nodes << [tag, props, children]
        [tag, props, children]
      end
      allow(component).to receive(:process_action) { |action| round.process_action(action) }

      component.render
      buttons = nodes.select { |tag, _, _| tag == 'button' }
      expect(buttons.map(&:last)).to eq(['Convert LNWR', 'Convert GWR', 'Done'])

      buttons.first[1][:on][:click].call
      expect(lnwr.type).to eq(:national)
    end
  end
end
