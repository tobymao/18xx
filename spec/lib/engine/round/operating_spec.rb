# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/game/g_1889'
require 'engine/round/operating'

module Engine
  describe Round::Operating do
    let(:players) { [Player.new('a'), Player.new('b')] }
    let(:game) { Game::G1889.new(players) }
    let(:corporation) { game.corporation_by_name('Awa Railroad') }
    let(:hex_j3) { game.hex_by_name('J3') }
    let(:hex_j5) { game.hex_by_name('J5') }
    let(:hex_k4) { game.hex_by_name('K4') }
    let(:hex_k6) { game.hex_by_name('K6') }
    let(:hex_k8) { game.hex_by_name('K8') }
    let(:hex_l7) { game.hex_by_name('L7') }

    subject do
      Round::Operating.new(
        [corporation],
        hexes: game.hexes,
        phase: :yellow,
        tiles: game.tiles,
        companies: game.companies,
        bank: game.bank,
        round_num: 1,
      )
    end

    describe '#layable_hexes' do
      it 'returns the layable hexes' do
        expect(subject.layable_hexes).to eq(
          hex_k8 => [1, 2, 3, 4]
        )

        subject.process_action(Action::LayTile.new(corporation, Tile.for('5'), hex_k8, 3))

        expect(subject.layable_hexes).to eq(
          hex_k6 => [0],
          hex_k8 => [3, 4, 1, 2],
          hex_l7 => [1],
        )

        subject.process_action(Action::LayTile.new(corporation, Tile.for('9'), hex_k6, 0))

        expect(subject.layable_hexes).to eq(
          hex_j3 => [5],
          hex_j5 => [4],
          hex_k4 => [0, 1, 2],
          hex_k6 => [0, 3],
          hex_k8 => [3, 4, 1, 2],
          hex_l7 => [1],
        )
      end
    end
  end
end
