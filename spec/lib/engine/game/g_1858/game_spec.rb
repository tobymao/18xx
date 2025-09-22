# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1858::Game do
  describe 219_682 do
    it 'broad and narrow gauge graphs calculated' do
      game = fixture_at_action(942)
      corp = game.corporation_by_id('N')
      # Check which hexes are reachable by broad and metre gauge routes.
      hexes_broad = %w[B9 C10 D11 D15 D17 D19 E10 E12 E14 E18 E20 F1 F3 F5 F9
                       F13 F15 F19 F21 G4 G6 G8 G10 G12 G14 G18 G20 H3 H9 H11
                       H13 H19 H21 I2 I4 I10 I14 J1 J3 J5 J9 J11 J13 J15 J17 K2
                       K4 K6 K8 K16 K18 K20 L7 L9 L13 L15 L17 L19 M6 M8 M10 M12
                       N3 N5 N7 N9 O8 P5 P7]
      expect(game.graph_broad.reachable_hexes(corp).keys.map(&:coordinates)).to match_array(hexes_broad)

      hexes_metre = %w[B3 B5 C2 C4 D1 D3 E2 F1 G2 G8 G10 G12 G18 H3 H5 H7 H9 H11
                       H13 H15 H17 I2 I4 J1 J3 K2]
      expect(game.graph_metre.reachable_hexes(corp).keys.map(&:coordinates)).to match_array(hexes_metre)
    end
  end
end
