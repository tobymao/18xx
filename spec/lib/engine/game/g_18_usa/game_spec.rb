# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G18USA::Game do
  describe 109_372 do
    def lay_tile(game, corporation, hex_id, tile_name, rotation)
      hex = game.hex_by_id(hex_id)
      tile = game.round.active_step.upgradeable_tiles(corporation, hex).find { |t| t.name == tile_name }
      game.process_action(Engine::Action::LayTile.new(corporation, tile: tile, hex: hex, rotation: rotation))
      game.maybe_raise!
    end

    context 'when the home city is yellow' do
      let(:game) { fixture_at_action(907, clear_cache: true) }
      let(:up) { game.corporation_by_id('UP') }
      let(:i25) { game.hex_by_id('I25') }

      before do
        allow(game).to receive(:home_hex_for).and_call_original
        allow(game).to receive(:home_hex_for).with(up).and_return(i25)
      end

      it 'lets a new corporation upgrade its home to brown as a free tile action' do
        expect(game.round.active_step.upgradeable_tiles(up, i25).map(&:name)).to include('448')

        lay_tile(game, up, 'I25', '448', 0)

        expect(i25.tile.name).to eq('448')
        expect(up.cash).to eq(650)
        expect(game.round.num_laid_track).to eq(0)
        expect(game.round.active_step).to be_a(Engine::Game::G18USA::Step::Track)
      end
    end

    context 'when the home city is green' do
      let(:game) { fixture_at_action(831, clear_cache: true) }
      let(:gn) { game.corporation_by_id('GN') }

      before { allow(gn).to receive(:operated?).and_return(false) }

      it 'lets a new corporation upgrade its home to brown as a free tile action' do
        lay_tile(game, gn, 'D14', '63', 1)

        expect(game.hex_by_id('D14').tile.name).to eq('63')
        expect(gn.cash).to eq(0)
        expect(game.round.num_laid_track).to eq(0)
        expect(game.round.active_step).to be_a(Engine::Game::G18USA::Step::Track)
        expect(game.round.active_step.actions(gn)).to include('lay_tile')
      end

      it 'keeps the free home upgrade available after the normal tile lays are used' do
        lay_tile(game, gn, 'D12', '9', 1)
        game.process_action(Engine::Action::TakeLoan.new(gn, loan: game.loans[0]))
        game.maybe_raise!
        lay_tile(game, gn, 'F14', '9', 2)

        step = game.round.active_step
        expect(step).to be_a(Engine::Game::G18USA::Step::Track)
        expect(step.available_hex(gn, game.hex_by_id('D14'))).to be_truthy

        lay_tile(game, gn, 'D14', '63', 1)

        expect(game.hex_by_id('D14').tile.name).to eq('63')
        expect(gn.cash).to eq(80)
        expect(game.round.active_step).not_to be_a(Engine::Game::G18USA::Step::Track)
      end
    end
  end
end
