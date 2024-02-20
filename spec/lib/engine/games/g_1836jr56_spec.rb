# frozen_string_literal: true

require 'find'
require './spec/spec_helper'

module Engine
  describe Game::G1836Jr56::Game do
    let(:players) { %w[a b c] }

    let(:game_file) do
      Find.find(FIXTURES_DIR).find { |f| File.basename(f) == "#{game_file_name}.json" }
    end

    let(:actions) do
      [
        { 'type' => 'bid', 'entity' => 'a', 'entity_type' => 'player', 'company' => 'ACC', 'price' => 20, 'id' => 1 },
        { 'type' => 'bid', 'entity' => 'b', 'entity_type' => 'player', 'company' => 'E-SF', 'price' => 40, 'id' => 2 },
        { 'type' => 'bid', 'entity' => 'c', 'entity_type' => 'player', 'company' => 'CdH', 'price' => 50, 'id' => 3 },
        { 'type' => 'bid', 'entity' => 'a', 'entity_type' => 'player', 'company' => 'RdP', 'price' => 70, 'id' => 4 },
        {
          'type' => 'par',
          'entity' => 'b',
          'entity_type' => 'player',
          'corporation' => 'B',
          'share_price' => '65,5,4',
          'id' => 5,
        },
        { 'type' => 'buy_shares', 'entity' => 'c', 'entity_type' => 'player', 'shares' => ['B_1'], 'percent' => 10, 'id' => 6 },
        { 'type' => 'buy_shares', 'entity' => 'a', 'entity_type' => 'player', 'shares' => ['B_2'], 'percent' => 10, 'id' => 7 },
        { 'type' => 'buy_shares', 'entity' => 'b', 'entity_type' => 'player', 'shares' => ['B_3'], 'percent' => 10, 'id' => 8 },
        { 'type' => 'buy_shares', 'entity' => 'c', 'entity_type' => 'player', 'shares' => ['B_4'], 'percent' => 10, 'id' => 9 },
        { 'type' => 'pass', 'entity' => 'a', 'entity_type' => 'player', 'id' => 10 },
        { 'type' => 'pass', 'entity' => 'b', 'entity_type' => 'player', 'id' => 11 },
        { 'type' => 'pass', 'entity' => 'c', 'entity_type' => 'player', 'id' => 12 },
      ]
    end

    # issue 9954
    # This will attempt to lay track, which adds the auto_actions from Escrow, which check for hexes_connected?
    # The original issue was that this tries to use @destinations, which the national corp does not have, so it would
    # try to call hexes_connected? with 0 arguments.

    context '1836Jr56 can lay initial track' do
      let(:players) { %w[a b c] }
      subject(:game) { Game::G1836Jr56::Game.new(players, actions: actions) }

      it 'should not enter infinite loop' do
        expect(game.raw_actions.size).to be 12
        expect(game.current_entity.name).to be 'B'

        action = Engine::Action::LayTile.new(game.current_entity,
                                             tile: game.tile_by_id('6-0'),
                                             hex: game.hex_by_id('G7'),
                                             rotation: 0)
        game.process_action(action, add_auto_actions: true).maybe_raise!

        expect(game.raw_actions.size).to be 13
      end
    end
  end
end
