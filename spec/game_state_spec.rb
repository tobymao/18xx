# frozen_string_literal: true

require 'find'

require 'spec_helper'

def game_at_action(game_file, action_id = nil)
  Engine::Game.load(game_file, at_action: action_id).maybe_raise!
end

# get the title string from the `describe` block
def game_title_for_test(test)
  all_titles = Engine::GAME_META_BY_TITLE
  parent = :parent_example_group

  group = test.metadata[:example_group][parent]
  group = group[parent] until all_titles.include?((title = group[:description]))
  title
end

module Engine
  describe 'Fixture Game State' do
    let(:game_file) do
      title = game_title_for_test(RSpec.current_example)
      dir = Engine.meta_by_title(title).fixture_dir_name
      Find.find("#{FIXTURES_DIR}/#{dir}").find { |f| File.basename(f) == "#{described_class}.json" }
    end

    describe '18Chesapeake' do
      describe 1277 do
        it 'closes Cornelius Vanderbilt when SRR buys a train' do
          game = game_at_action(game_file, 171)
          expect(game.cornelius.closed?).to eq(false)

          srr = game.corporation_by_id('SRR')
          expect(game.abilities(game.cornelius, :shares).shares.first.corporation).to eq(srr)

          game = game_at_action(game_file, 172)
          expect(game.cornelius.closed?).to eq(true)
        end
      end

      describe 14_377 do
        it 'closes Cornelius Vanderbilt when the first 5-train is bought' do
          game = game_at_action(game_file, 199)
          expect(game.cornelius.closed?).to eq(false)

          ca = game.corporation_by_id('C&A')
          expect(game.abilities(game.cornelius, :shares).shares.first.corporation).to eq(ca)
          expect(ca.trains).to eq([])

          game = game_at_action(game_file, 200)
          expect(game.cornelius.closed?).to eq(true)
        end
      end

      describe 22_383 do
        it '2p: when one share is in the market for an unfloated corporation, the '\
           'non-president may do a "buy" action, but then the share is owned by the bank' do
          game = game_at_action(game_file, 104)

          share_id = 'LV_1'
          share = game.share_by_id(share_id)

          action = {
            'type' => 'buy_shares',
            'entity' => 4985,
            'entity_type' => 'player',
            'shares' => [
              share_id,
            ],
            'percent' => 10,
          }

          expect(share.owner).to eq(game.share_pool)

          game.process_action(action)

          expect(share.owner).to eq(game.bank)
        end
      end
    end

    describe '1848' do
      describe 101 do
        it '2nd receivership removes the next permanent and triggers phase change' do
          game = game_at_action(game_file, 483)

          expect(game.phase.name).to eq('5')

          expect(game.depot.upcoming.count { |train| train.name == '5' }).to eq(2)
        end
      end
    end

    describe '1836Jr30' do
      describe 2809 do
        it 'CFLV blocks I3 and J4' do
          game = game_at_action(game_file, 34)

          i3 = game.hex_by_id('I3')
          j4 = game.hex_by_id('J4')
          cflv = game.company_by_id('CFLV')
          blocking_ability = game.abilities(cflv, :blocks_hexes)

          expect(i3.tile.blockers).to eq([cflv])
          expect(j4.tile.blockers).to eq([cflv])
          expect(blocking_ability.hexes).to eq([j4, i3])
        end

        it 'CFLV no longer blocks I3 and J4 after the Nord buys a train' do
          game = game_at_action(game_file, 35)

          i3 = game.hex_by_id('I3')
          j4 = game.hex_by_id('J4')
          cflv = game.company_by_id('CFLV')
          blocking_ability = game.abilities(cflv, :blocks_hexes)

          expect(i3.tile.blockers).to eq([])
          expect(j4.tile.blockers).to eq([])
          expect(blocking_ability).to be_nil
        end
      end
    end

    describe '1882' do
      describe 10_526 do
        it 'Saskatchewan Central is open before the first 6-train is purchased' do
          game = game_at_action(game_file, 316)
          sc = game.company_by_id('SC')
          expect(sc.closed?).to eq(false)
        end

        it 'Saskatchewan Central closes when the first 6-train is purchased' do
          game = game_at_action(game_file, 317)
          sc = game.company_by_id('SC')
          expect(sc.closed?).to eq(true)
        end
      end
    end

    describe '18 Los Angeles' do
      describe 19_984 do
        it 'LA Title places a neutral token' do
          game = game_at_action(game_file, 167)

          la_title = game.company_by_id('LAT')
          corp = la_title.corporation

          expect(corp.id).to eq('LA')
          expect(corp.cash).to eq(37)
          expect(corp.tokens.partition(&:used).map(&:size)).to eq([3, 2])

          action = {
            'type' => 'place_token',
            'entity' => 'LAT',
            'entity_type' => 'company',
            'city' => '619-0-0',
            'slot' => 1,
          }
          game.process_action(action)
          token = game.hex_by_id('C8').tile.cities.first.tokens[1]

          expect(token.type).to eq(:neutral)

          # free token, not from the charter
          expect(corp.cash).to eq(37)
          expect(corp.tokens.partition(&:used).map(&:size)).to eq([3, 2])
        end

        it 'Dewey, Cheatham, & Howe places a cheater token from the charter at normal price' do
          game = game_at_action(game_file, 145)

          dch = game.company_by_id('DC&H')
          corp = dch.corporation
          city = game.hex_by_id('C6').tile.cities.first

          # slots before
          expect(city.tokens.size).to eq(2)

          # corporation cash and tokens before
          expect(corp.id).to eq('LAIR')
          expect(corp.cash).to eq(137)
          expect(corp.tokens.partition(&:used).map(&:size)).to eq([3, 3])

          action = {
            'type' => 'place_token',
            'entity' => 'DC&H',
            'entity_type' => 'company',
            'city' => '295-0-0',
            'slot' => 0,
          }
          game.process_action(action)

          # cheater token added a slot
          expect(city.tokens.size).to eq(3)

          token = city.tokens[2]
          expect(token.type).to eq(:normal)

          # corporation had to pay and use a token from the charter
          expect(token.corporation).to eq(corp)
          expect(corp.cash).to eq(57)
          expect(corp.tokens.partition(&:used).map(&:size)).to eq([4, 2])
        end
      end
    end

    describe '18ZOO - Map A' do
      describe 4 do
        it 'corporation should earn 2$N for each share in Market' do
          game = game_at_action(game_file, 14)
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
          game = game_at_action(game_file, 10)

          expect(game.log.index { |item| item.action_id == 7 }).to be_nil # Buy, Pass
          expect(game.log.find { |item| item.action_id == 8 }.message).to eq('Player 1 passes') # Pass
          expect(game.log.find { |item| item.action_id == 10 }.message).to eq('Player 2 declines to buy shares') # Pass
        end
      end

      describe 17 do
        it 'whatsup cannot be used if corporation already own maximum number of trains' do
          game = game_at_action(game_file, 23)
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
          expect(game.process_action(action).exception).to be_a(GameError)
        end
      end

      describe 18 do
        it 'buying a new train after whatsup (on first train on new phase) must not give "new-phase" bonus' do
          game = game_at_action(game_file, 26)
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
    end

    describe '18ZOO - Map F' do
      describe 6535 do
        it '"on a diet" cannot be executed automatically' do
          game = game_at_action(game_file, 255)
          action = {
            'type' => 'place_token',
            'entity' => 'BB',
            'entity_type' => 'corporation',
            'city' => '5-1-0',
            'slot' => 1,
            'tokener' => 'BB',
          }
          expect(game.exception).to be_nil
          expect(game.process_action(action).exception).to be_a(GameError)
        end
      end
    end

    describe '1822NRS' do
      describe 128_129 do
        it 'ability_combo_entities should not throw an error when one of the combo entities was removed during setup' do
          # in https://github.com/tobymao/18xx/issues/9309,
          # ability_combo_entities threw an error instead of successfully
          # returning because P10 is removed in NRS setup
          game = game_at_action(game_file, 495)
          entity = game.company_by_id('P12')
          expect(game.ability_combo_entities(entity)).to eq([])
        end
      end
    end
  end
end
