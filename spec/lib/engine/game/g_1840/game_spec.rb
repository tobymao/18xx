# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1840::Game do
  describe '218809' do
    describe 'available_hexes' do
      it 'includes hexes with Stadtbahnen tokens' do
        game = fixture_at_action(861)

        # Stadtbahnen tokens on A13, B10, C7, D12, E23, I9, I15
        expect(game).to have_available_hexes(%w[A13 A29 B10 B22 B24 B26 B28 C23 C25 C27 C29 C7
                                                D12 D22 D24 D26 D28 E23 E25 E27 F28 F30 G27 G29 H28 H30 I15 I9])
      end

      it 'includes layable and tokenable hexes' do
        game = fixture_at_action(896)

        expect(game).to have_available_hexes(%w[A13 A29 B22 B24 B26 B28 C23 C25 C27 C29 D12 D22
                                                D24 D26 D28 E23 E25 E27 F28 F30 G27 G29 H28 H30 I15 I9])
      end

      it 'after upgrading a tile, still includes tokenable hexes and Stadtbahnen token hexes' do
        game = fixture_at_action(897)

        expect(game).to have_available_hexes(%w[A13 A29 D12 D20 D22 D24 E21 E23 F28 I15 I9])
      end
    end
  end
end
