# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1894::Game do
  describe 'green_city_upgrades' do
    it "upgrades 14 to X16 when a corporation's only token is on the hex" do
      game = fixture_at_action(666)

      lf = game.corporation_by_id('LF')
      hex = game.hex_by_id('E6')
      tile = game.tile_by_id('X16-0')
      tile.rotate!(2)

      # the set up: LF's turn, track step
      expect(game.current_entity).to eq(lf)
      expect(game.round.operating?).to eq(true)
      expect(game.active_step).to be_a(Engine::Game::G1894::Step::Track)

      # 14 -> X16 is legal
      expect(game.active_step.legal_tile_rotation?(lf, hex, tile)).to eq(true)
      tile.rotate!(5)
      expect(game.active_step.legal_tile_rotation?(lf, hex, tile)).to eq(true)

      # 14 is the present tile, LF's only token is there
      expect(hex.tile.name).to eq('14')
      expect(lf.tokens.filter_map { |t| t.used && t.hex.name }).to eq([hex.name])

      # X16 tile laid, token is temporarily removed
      game.process_to_action(667)
      game.maybe_raise!
      expect(hex.tile.name).to eq('X16')
      expect(lf.tokens.filter_map { |t| t.used && t.hex.name }).to eq([])

      # token is back
      game.process_to_action(668)
      game.maybe_raise!
      expect(lf.tokens.filter_map { |t| t.used && t.hex.name }).to eq([hex.name])
    end
  end
end
