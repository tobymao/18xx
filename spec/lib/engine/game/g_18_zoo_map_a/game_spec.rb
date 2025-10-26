# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G18ZOOMapA::Game do
  describe 4 do
    it 'corporation should earn 2$N for each share in Market' do
      game = fixture_at_action(14, clear_cache: true)

      corporation = game.corporation_by_id('GI')
      action = {
        'type' => 'pass',
        'entity' => 'Player 1',
        'entity_type' => 'player',
      }
      expect(corporation.cash).to eq(28)
      expect(game.log.index { |item| item.message == 'GI earns 4$N (2 certs in the Market)' }).to be_nil

      game.process_action(action)

      expect(corporation.cash).to eq(32)
      expect(game.log.index { |item| item.message == 'GI earns 4$N (2 certs in the Market)' }).to be_truthy
    end
  end

  describe 5 do
    it 'log messages after buy / pass / sell' do
      game = fixture_at_action(10, clear_cache: true)

      expect(game.log.index { |item| item.action_id == 7 }).to be_nil # Buy, Pass
      expect(game.log.find { |item| item.action_id == 8 }.message).to eq('Player 1 passes') # Pass
      expect(game.log.find { |item| item.action_id == 10 }.message).to eq('Player 2 declines to buy shares') # Pass
    end
  end

  describe 17 do
    it 'whatsup cannot be used if corporation already own maximum number of trains' do
      game = fixture_at_action(23, clear_cache: true)

      action = {
        'type' => 'choose_ability',
        'entity' => 'WHATSUP',
        'entity_type' => 'company',
        'choice' => {
          'type' => 'whatsup',
          'corporation_id' => 'GI',
          'train_id' => '3S-2',
        },
      }
      expect(game.exception).to be_nil
      expect(game.process_action(action).exception).to be_a(Engine::GameError)
    end
  end

  describe 18 do
    it 'buying a new train after whatsup (on first train on new phase) must not give "new-phase" bonus' do
      game = fixture_at_action(26, clear_cache: true)

      corporation = game.corporation_by_id('GI')
      action = {
        'type' => 'buy_train',
        'entity' => 'GI',
        'entity_type' => 'corporation',
        'train' => '3S-1',
        'price' => 12,
        'variant' => '3S',
      }
      expect(corporation.share_price.price).to eq(7)
      game.process_action(action)
      expect(corporation.share_price.price).to eq(8)
    end
  end

  describe 'Powers' do
    describe 'That is mine!' do
      context 'corporation already put a token' do
        describe 'or_power.that_s_mine.cannot_convert_if_already_tokened' do
          it 'cannot convert' do
            game = fixture_at_action(33, clear_cache: true)

            action = {
              'type' => 'place_token',
              'entity' => 'THAT_S_MINE',
              'entity_type' => 'company',
              'city' => '619-0-0',
              'slot' => 1,
            }
            expect(game.exception).to be_nil
            expect(game.process_action(action).exception).to be_a(Engine::GameError)
          end
        end
      end

      context 'corporation has no token' do
        describe 'or_power.that_s_mine.cannot_convert_if_no_token' do
          it 'cannot convert' do
            game = fixture_at_action(17, clear_cache: true)

            action = {
              'type' => 'place_token',
              'entity' => 'THAT_S_MINE',
              'entity_type' => 'company',
              'city' => '201-0-0',
              'slot' => 0,
            }
            expect(game.exception).to be_nil
            expect(game.process_action(action).exception).to be_a(Engine::GameError)
          end
        end
      end

      context 'corporation has no money' do
        describe 'or_power.that_s_mine.cannot_convert_if_no_money' do
          it 'cannot convert' do
            game = fixture_at_action(16, clear_cache: true)

            action = {
              'type' => 'place_token',
              'entity' => 'THAT_S_MINE',
              'entity_type' => 'company',
              'city' => '201-0-0',
              'slot' => 0,
            }
            expect(game.exception).to be_nil
            expect(game.process_action(action).exception).to be_a(Engine::GameError)
          end
        end
      end

      context 'reserved hex is not reachable' do
        describe 'or_power.that_s_mine' do
          it 'cannot convert' do
            game = fixture_at_action(10, clear_cache: true)

            action = {
              'type' => 'place_token',
              'entity' => 'THAT_S_MINE',
              'entity_type' => 'company',
              'city' => 'L4-3-1',
              'slot' => 0,
            }
            expect(game.exception).to be_nil
            expect(game.process_action(action).exception).to be_a(Engine::GameError)
          end
        end
      end

      context 'reserved hex in a single city cannot be blocked by Work In Progress' do
        describe 'or_power.work_in_progress.cannot_block_that_s_mine' do
          it 'cannot assign Work in Progress' do
            game = fixture_at_action(35, clear_cache: true)

            action = {
              'type' => 'assign',
              'entity' => 'WORK_IN_PROGRESS',
              'entity_type' => 'company',
              'target' => 'L4',
              'target_type' => 'hex',
            }
            expect(game.exception).to be_nil
            expect(game.process_action(action).exception).to be_a(Engine::GameError)
          end
        end
      end

      context 'reserved hex in a double city with also Work In Progress' do
        describe 'or_power.work_in_progress.cannot_block_that_s_mine' do
          it 'cannot assign token' do
            game = fixture_at_action(38, clear_cache: true)

            action = {
              'type' => 'place_token',
              'entity' => 'PB',
              'entity_type' => 'corporation',
              'city' => '793-0-0',
              'slot' => 1,
              'tokener' => 'PB',
            }
            expect(game.exception).to be_nil
            expect(game.process_action(action).exception).to be_a(Engine::GameError)
          end
        end
      end
    end

    describe 'A tip of sugar' do
      context 'when used on two train' do
        describe 'or_power.a_tip_of_sugar' do
          it 'must fail' do
            game = fixture_at_action(33, clear_cache: true)

            action = {
              'type' => 'run_routes',
              'entity' => 'PE',
              'entity_type' => 'corporation',
              'routes' => [
                {
                  'train' => '2S-0',
                  'connections' => [
                    %w[K17 J18 I19],
                    %w[K17 L16 M17 N18],
                  ],
                  'hexes' => %w[I19 K17 N18],
                },
                {
                  'train' => '2S-1',
                  'connections' => [
                    %w[K15 K17],
                    %w[K15 J16 I17 I19],
                  ],
                  'hexes' => %w[K17 K15 I19],
                },
              ],
            }
            expect do
              game.process_action(action).maybe_raise!
            end.to raise_error(Engine::GameError, 'Only one train can use "A tip of sugar"')
          end
        end
      end

      context 'two different train use wings' do
        describe 'or_power.wings' do
          it 'is not possible' do
            game = fixture_at_action(59, clear_cache: true)

            action = {
              'type' => 'run_routes',
              'entity' => 'GI',
              'entity_type' => 'corporation',
              'routes' => [
                {
                  'train' => '2S-1',
                  'connections' => [
                    %w[L4 M5],
                    %w[K9 K7 L6 L4],
                  ],
                  'hexes' => %w[M5 L4 K9],
                },
                {
                  'train' => '3S-0',
                  'connections' => [
                    %w[K15 K13 K11 K9],
                    %w[K15 K17],
                    %w[K17 L16 M15 N14],
                    %w[N14 N12],
                  ],
                  'hexes' => %w[K15 K17 N14 N12],
                },
              ],
            }
            expect do
              game.process_action(action).maybe_raise!
            end.to raise_error(Engine::GameError, 'Only one train can bypass a tokened-out city')
          end
        end
      end

      context 'City with "Work in progress"' do
        describe 'or_power.work_in_progress.cannot_ignore_with_wings' do
          it 'cannot be pass-through' do
            game = fixture_at_action(17, clear_cache: true)

            action = {
              'type' => 'run_routes',
              'entity' => 'GI',
              'entity_type' => 'corporation',
              'routes' => [
                {
                  'train' => '2S-0',
                  'connections' => [
                    %w[L4 M5],
                    %w[K9 K7 L6 L4],
                  ],
                  'hexes' => %w[M5 L4 K9],
                },
              ],
            }
            expect do
              game.process_action(action).maybe_raise!
            end.to raise_error(Engine::GameError,
                               %(City with only 'Work in progress' slot cannot be bypassed))
          end
        end
      end
    end

    describe 'Wings' do
      context 'fly over two cities' do
        describe 'or_power.wings' do
          it 'is not possible' do
            game = fixture_at_action(59, clear_cache: true)

            action = {
              'type' => 'run_routes',
              'entity' => 'GI',
              'entity_type' => 'corporation',
              'routes' => [
                {
                  'train' => '3S-0',
                  'connections' => [
                    %w[L4 M5],
                    %w[K9 K7 L6 L4],
                    %w[K15 K13 K11 K9],
                    %w[K15 K17],
                    %w[K17 L16 M15 N14],
                    %w[N14 N12],
                  ],
                  'hexes' => %w[M5 L4 K9 K15 K17 N14 N12],
                },
              ],
            }
            expect do
              game.process_action(action).maybe_raise!
            end.to raise_error(Engine::GameError, 'Route can only bypass one tokened-out city')
          end
        end
      end

      context 'two different train use wings' do
        describe 'or_power.wings' do
          it 'is not possible' do
            game = fixture_at_action(59, clear_cache: true)

            action = {
              'type' => 'run_routes',
              'entity' => 'GI',
              'entity_type' => 'corporation',
              'routes' => [
                {
                  'train' => '2S-1',
                  'connections' => [
                    %w[L4 M5],
                    %w[K9 K7 L6 L4],
                  ],
                  'hexes' => %w[M5 L4 K9],
                },
                {
                  'train' => '3S-0',
                  'connections' => [
                    %w[K15 K13 K11 K9],
                    %w[K15 K17],
                    %w[K17 L16 M15 N14],
                    %w[N14 N12],
                  ],
                  'hexes' => %w[K15 K17 N14 N12],
                },
              ],
            }
            expect do
              game.process_action(action).maybe_raise!
            end.to raise_error(Engine::GameError, 'Only one train can bypass a tokened-out city')
          end
        end
      end

      context 'City with "Work in progress"' do
        describe 'or_power.work_in_progress.cannot_ignore_with_wings' do
          it 'cannot be pass-through' do
            game = fixture_at_action(17)

            action = {
              'type' => 'run_routes',
              'entity' => 'GI',
              'entity_type' => 'corporation',
              'routes' => [
                {
                  'train' => '2S-0',
                  'connections' => [
                    %w[L4 M5],
                    %w[K9 K7 L6 L4],
                  ],
                  'hexes' => %w[M5 L4 K9],
                },
              ],
            }
            expect do
              game.process_action(action).maybe_raise!
            end.to raise_error(Engine::GameError,
                               'City with only \'Work in progress\' slot cannot be bypassed')
          end
        end
      end
    end

    describe 'Work in progress' do
      context 'token on single-slot city' do
        describe 'or_power.work_in_progress' do
          it 'block path' do
            game = fixture_at_action(15, clear_cache: true)

            action = {
              'type' => 'lay_tile',
              'entity' => 'PB',
              'entity_type' => 'corporation',
              'hex' => 'J4',
              'tile' => '9-0',
              'rotation' => 1,
            }
            expect { game.process_action(action).maybe_raise! }.to raise_error(Engine::GameError)
          end
        end
      end
    end

    describe 'Ancient Maps' do
      describe 'or_power.ancient_maps' do
        it 'can be used for M' do
          game = fixture_at_action(21, clear_cache: true)

          action = {
            'type' => 'lay_tile',
            'entity' => 'ANCIENT_MAPS',
            'entity_type' => 'company',
            'hex' => 'J14',
            'tile' => '8-0',
            'rotation' => 3,
          }

          game.process_action(action).maybe_raise!

          hex = game.hex_by_id('J14')
          expect(hex.tile.label.to_s).to eq('M')
          expect(hex.tile.upgrades).to be_empty

          icon = hex.tile.icons[0]
          expect(icon.image).to eq('/icons/18_zoo/mountain.svg')
          expect(icon.sticky).to be_truthy
          expect(icon.blocks_lay?).to be_truthy
        end

        it 'can be used for MM' do
          game = fixture_at_action(21, clear_cache: true)

          action = {
            'type' => 'lay_tile',
            'entity' => 'ANCIENT_MAPS',
            'entity_type' => 'company',
            'hex' => 'L18',
            'tile' => '8-0',
            'rotation' => 2,
          }
          game.process_action(action).maybe_raise!

          hex = game.hex_by_id('L18')
          expect(hex.tile.label.to_s).to eq('MM')
          expect(hex.tile.upgrades).to be_empty

          icon = hex.tile.icons[0]
          expect(icon.image).to eq('/icons/18_zoo/mountain.svg')
          expect(icon.sticky).to be_truthy
          expect(icon.blocks_lay?).to be_truthy
        end

        it 'can be used for Y' do
          game = fixture_at_action(20, clear_cache: true)

          action = {
            'type' => 'lay_tile',
            'entity' => 'ANCIENT_MAPS',
            'entity_type' => 'company',
            'hex' => 'K15',
            'tile' => '202-0',
            'rotation' => 0,
          }
          game.process_action(action)

          hex = game.hex_by_id('K15')
          expect(hex.tile.label.to_s).to eq('Y')
        end
      end
    end

    describe 'Holes' do
      describe 'or_power.hole.no_reuse' do
        it 'cannot be used twice as terminal' do
          game = fixture_at_action(50, clear_cache: true).maybe_raise!

          action = {
            'type' => 'run_routes',
            'entity' => 'TI',
            'entity_type' => 'corporation',
            'routes' => [{
              'train' => '3S Long-0',
              'connections' => [
                             %w[I19 I17 H16 H14],
                             %w[H14 G15 F16 E15],
                             %w[E15 D16 C17],
                           ],
              'hexes' => %w[I19 H14 E15 C17],
            }],
          }

          expect(game.exception).to be_nil
          expect do
            game.process_action(action).maybe_raise!
          end.to raise_error(Engine::GameError, 'Route cannot use holes as terminal more than once')
        end

        it 'cannot enter and exit from a single hole' do
          game = fixture_at_action(50, clear_cache: true).maybe_raise!

          action = {
            'type' => 'run_routes',
            'entity' => 'TI',
            'entity_type' => 'corporation',
            'routes' => [{
              'train' => '3S Long-0',
              'connections' => [
                             %w[C13 C15 C17],
                             %w[C17 D16 E15],
                           ],
              'hexes' => %w[C13 C17 E15],
            }],
          }

          expect(game.exception).to be_nil
          expect do
            game.process_action(action).maybe_raise!
          end.to raise_error(Engine::GameError, 'Route cannot go in and out from the same hex of one of the two R AREA')
        end
      end
    end

    describe 'Moles' do
      describe 'or_power.moles' do
        it 'can be used for M' do
          game = fixture_at_action(18, clear_cache: true)

          hex = game.hex_by_id('E17')
          expect(hex.tile.label.to_s).to eq('M')
          expect(hex.tile.color).to eq(:green)
          expect(hex.tile.upgrades).to be_empty

          icon = hex.tile.icons[0]
          expect(icon.image).to eq('/icons/18_zoo/mountain.svg')
          expect(icon.sticky).to be_truthy
          expect(icon.blocks_lay?).to be_truthy
        end

        it 'can be used for MM' do
          game = fixture_at_action(26, clear_cache: true)

          hex = game.hex_by_id('G17')
          expect(hex.tile.label.to_s).to eq('MM')
          expect(hex.tile.color).to eq(:green)
          expect(hex.tile.upgrades).to be_empty

          icon = hex.tile.icons[0]
          expect(icon.image).to eq('/icons/18_zoo/mountain.svg')
          expect(icon.sticky).to be_truthy
          expect(icon.blocks_lay?).to be_truthy
        end

        it 'can be used for O' do
          game = fixture_at_action(17, clear_cache: true)

          hex = game.hex_by_id('F18')
          expect(hex.tile.label.to_s).to eq('O')
          expect(hex.tile.color).to eq(:green)

          icon = hex.tile.icons[0]
          expect(icon.image).to eq('/icons/river.svg')
          expect(icon.sticky).to be_truthy
          expect(icon.blocks_lay?).to be_falsy
        end
      end
    end

    describe 'Rabbits' do
      describe 'or_power.rabbits.cannot_upgrade' do
        [
          { 'tile_1' => 'X8-0', 'rotation_1' => 0, 'tile_2' => 'X25-0', 'rotation_2' => 4 },
          { 'tile_1' => 'X8-0', 'rotation_1' => 0, 'tile_2' => 'X19-0', 'rotation_2' => 0 },
          { 'tile_1' => 'X8-0', 'rotation_1' => 0, 'tile_2' => 'X19-0', 'rotation_2' => 2 },
          { 'tile_1' => 'X7-1', 'rotation_1' => 0, 'tile_2' => 'X28-0', 'rotation_2' => 2 },
          { 'tile_1' => 'X7-1', 'rotation_1' => 0, 'tile_2' => 'X29-0', 'rotation_2' => 5 },
        ].each do |invalid_action|
          it "must not update invalid track (#{invalid_action['tile_2']}) on #{invalid_action['tile_1']}" do
            game = fixture_at_action(19, clear_cache: true)

            game.process_action({
                                  'type' => 'lay_tile',
                                  'entity' => 'GI',
                                  'entity_type' => 'corporation',
                                  'hex' => 'I9',
                                  'tile' => invalid_action['tile_1'],
                                  'rotation' => invalid_action['rotation_1'],
                                })

            action = {
              'type' => 'lay_tile',
              'entity' => 'RABBITS',
              'entity_type' => 'company',
              'hex' => 'I9',
              'tile' => invalid_action['tile_2'],
              'rotation' => invalid_action['rotation_2'],
            }

            expect(game.exception).to be_nil
            expect do
              game.process_action(action).maybe_raise!
            end.to raise_error(Engine::GameError, 'New track must override old one')
          end
        end
      end
    end
  end
end
