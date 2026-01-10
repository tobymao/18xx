# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1824Cisleithania::Game do
    describe '1824_cisleithania_game_end_reason_bank' do
      it 'should be two constructions companies after SR1' do
        start_action = 12 # First in SR1
        game = fixture_at_action(start_action)

        expect_at(game, Game::G1824Cisleithania::Step::Track, [1, 1], game.corporation_by_id('EPP'))
        expect(game.corporation_by_id('KK2').type).to eq(:construction_railway)
        expect(game.corporation_by_id('EOD').type).to eq(:construction_railway)
        expect(game.status_str(game.corporation_by_id('MS'))).to eq('Bond Railway - pay stock value each OR')
      end
    end

    describe '1824_cisleithania_ug1_to_act' do
      it 'verification of #12173 - UG1 to lay track' do
        start_action = 34 # OR 1.1 for UG1
        game = fixture_at_action(start_action)
        ug1 = game.corporation_by_id('UG1')
        expect_at(game, Game::G1824Cisleithania::Step::Track, [1, 1], ug1)

        tile = game.tile_by_id('9-0')
        hex = game.hex_by_id('F13')
        game.round.process_action(Action::LayTile.new(ug1, tile: tile, hex: hex, rotation: 0))
      end
    end

    def expect_at(game, step_class, turn_round_num, entity)
      expect(game.active_step.class).to eq(step_class)
      expect(game.turn_round_num).to eq(turn_round_num)
      expect(game.current_entity).to eq(entity)
    end
  end
end
