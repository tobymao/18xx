# frozen_string_literal: true

require 'spec_helper'
require 'view/game/hex'

module View
  module Game
    describe Hex do
      let(:game) { Engine::Game::G1830::Game.new(%w[a b c], seed: 1) }
      let(:corp) { game.corporations.first }
      let(:hex) { game.hex_by_id(corp.coordinates) }
      let(:tile_selector) { Lib::HexChoiceSelector.new(hex, { 'x' => 'Explore' }, [0, 0], corp, :map) }
      let(:component) do
        described_class.new(nil, game: game, hex: hex, tile_selector: tile_selector,
                                 actions: %w[lay_tile], clickable: true)
      end

      before { allow(component).to receive(:store) }

      it 'resets the selector instead of crashing when a non-TileSelector selector is clicked ' \
         'while lay_tile is also offered' do
        expect { component.on_hex_click }.not_to raise_error
        expect(component).to have_received(:store).with(:tile_selector, nil)
      end
    end
  end
end
