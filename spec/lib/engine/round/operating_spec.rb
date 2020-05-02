# frozen_string_literal: true

require './spec/spec_helper'

require 'engine/game/g_1889'
require 'engine/phase'
require 'engine/round/operating'

module Engine
  describe Round::Operating do
    let(:players) { %w[a b] }
    let(:game) { Game::G1889.new(players) }
    let(:hex_j3) { game.hex_by_id('J3') }
    let(:hex_j5) { game.hex_by_id('J5') }
    let(:hex_k4) { game.hex_by_id('K4') }
    let(:hex_k6) { game.hex_by_id('K6') }
    let(:hex_k8) { game.hex_by_id('K8') }
    let(:hex_l7) { game.hex_by_id('L7') }

    let(:hex_e8) { game.hex_by_id('E8') }
    let(:hex_f7) { game.hex_by_id('F7') }
    let(:hex_f9) { game.hex_by_id('F9') }
    let(:hex_g8) { game.hex_by_id('G8') }
    let(:hex_g10) { game.hex_by_id('G10') }
    let(:hex_g12) { game.hex_by_id('G12') }
    let(:hex_g14) { game.hex_by_id('G14') }
    let(:hex_h11) { game.hex_by_id('H11') }
    let(:hex_h13) { game.hex_by_id('H13') }
    let(:hex_i12) { game.hex_by_id('I12') }

    subject { Round::Operating.new([corporation], game: game, round_num: 1) }

    before :each do
      game.stock_market.set_par(corporation, game.stock_market.par_prices[0])
      corporation.cash = 100
      corporation.owner = game.players.first
    end

    describe '#layable_hexes' do
      context 'with awa' do
        let(:corporation) { game.corporation_by_id('AR') }

        it 'returns the layable hexes' do
          expect(subject.layable_hexes).to eq(
            hex_k8 => [1, 2, 3, 4]
          )

          subject.process_action(Action::LayTile.new(corporation, Tile.for('5'), hex_k8, 3))

          expect(subject.layable_hexes).to eq(
            hex_k6 => [0],
            hex_k8 => [1, 2, 3, 4],
            hex_l7 => [1],
          )

          subject.process_action(Action::LayTile.new(corporation, Tile.for('9'), hex_k6, 0))

          expect(subject.layable_hexes).to eq(
            hex_j3 => [5],
            hex_j5 => [4],
            hex_k4 => [0, 2, 1],
            hex_k6 => [0, 3],
            hex_k8 => [1, 2, 3, 4],
            hex_l7 => [1],
          )
        end
      end

      context 'with tse' do
        let(:corporation) { game.corporation_by_id('TR') }

        it 'can handle forks' do
          subject.process_action(Action::LayTile.new(corporation, Tile.for('58'), hex_g10, 0))
          subject.process_action(Action::LayTile.new(corporation, Tile.for('15'), hex_g12, 3))
          subject.process_action(Action::LayTile.new(corporation, Tile.for('9'), hex_h13, 1))

          expect(subject.layable_hexes).to eq(
            hex_e8 => [5],
            hex_f7 => [0],
            hex_f9 => [2, 3, 4, 5],
            hex_g8 => [1],
            hex_g10 => [2, 0],
            hex_g12 => [3, 5, 4, 0],
            hex_g14 => [3, 4],
            hex_h11 => [1],
            hex_h13 => [2, 1, 4],
            hex_i12 => [1],
          )
        end
      end
    end
  end
end
