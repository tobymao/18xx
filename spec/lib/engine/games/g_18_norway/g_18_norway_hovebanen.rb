# frozen_string_literal: true

require 'find'
require './spec/spec_helper'
require 'json'

module Engine
  describe Game::G18Norway do
    let(:players) { %w[a b c] }

    let(:game_file) do
      Find.find(FIXTURES_DIR).find { |f| File.basename(f) == "#{game_file_name}.json" }
    end

    context '18Norway Hovebanen' do
      let(:game_file_name) { '18_norway_buy_ship' }

      it 'Hovedbanen cash should match the auction price' do
        game = Engine::Game.load(game_file, at_action: 7)
        expect(game.players.map(&:cash)).to eq([300, 190, 240])
        expect(game.hovedbanen.cash).to eq(170)
        expect(game.hovedbanen.shares[0].price).to eq(80)
      end
    end
  end
end
