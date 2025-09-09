# frozen_string_literal: true

require 'find'

require 'spec_helper'

def game_at_action(game_file, action_id = nil)
  Engine::Game.load(game_file, at_action: action_id).maybe_raise!
end

def raw_action(game, action_index)
  game.instance_variable_get(:@raw_all_actions)[action_index]
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
      Find.find("#{FIXTURES_DIR}/#{title}").find { |f| File.basename(f) == "#{described_class}.json" }
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

    describe '1846' do
      describe 10_264 do
        it 'does not block the track and token step for an unused company tile-lay ability' do
          game = game_at_action(game_file, 260)

          expect(game.current_entity).to eq(game.illinois_central)
          expect(game.michigan_central.owner).to eq(game.illinois_central)
          expect(game.abilities(game.michigan_central, :tile_lay).count).to eq(2)
          expect(game.active_step).to be_a(Step::Dividend)
        end
      end

      describe 19_962 do
        it 'removes the reservation when a token is placed' do
          game = game_at_action(game_file, 114)
          city = game.hex_by_id('D20').tile.cities.first
          corp = game.corporation_by_id('ERIE')
          expect(city.reserved_by?(corp)).to be(false)
        end

        it 'has correct reservations and tokens after NYC closes' do
          game = game_at_action(game_file, 162)
          city = game.hex_by_id('D20').tile.cities.first
          erie = game.corporation_by_id('ERIE')

          expect(city.reservations).to eq([nil, nil])
          expect(city.tokens.map { |t| t&.corporation }).to eq([nil, erie])
        end

        it 'has a cert limit of 12 at the start of a 4p game' do
          game = game_at_action(game_file, 0)
          expect(game.cert_limit).to be(12)
        end

        it 'has a cert limit of 10 after a corporation closes' do
          game = game_at_action(game_file, 122)
          expect(game.cert_limit).to be(10)
        end

        it 'has a cert limit of 10 after a corporation closes and then a player is bankrupt' do
          game = game_at_action(game_file, 300)
          expect(game.cert_limit).to be(10)
        end

        it 'has a cert limit of 8 after a corporation closes, then a player is '\
           'bankrupt, and then another corporation closes' do
          game = game_at_action(game_file, 328)
          expect(game.cert_limit).to be(8)
        end

        it 'IC to lay a tile on J4 for free' do
          game = game_at_action(game_file, 64)
          expect(game.illinois_central.cash).to be(280)

          game = game_at_action(game_file, 65)
          expect(game.illinois_central.cash).to be(280)
        end
      end

      describe 20_381 do
        it 'cannot go bankrupt when shares can be emergency issued' do
          game = game_at_action(game_file, 308)
          prr = game.corporation_by_id('PRR')
          expect(game.can_go_bankrupt?(prr.player, prr)).to be(false)
          expect(game.emergency_issuable_cash(prr)).to eq(10)
        end
      end
    end

    describe '1846 2p Variant' do
      describe 11_098 do
        it 'has both reservations at the start of the game' do
          game = game_at_action(game_file, 0)
          city = game.hex_by_id('D20').tile.cities.first
          erie = game.corporation_by_id('ERIE')
          nyc = game.corporation_by_id('NYC')

          expect(city.reservations).to eq([nyc, erie])
        end

        it 'keeps the second slot reserved for ERIE when NYC floats' do
          game = game_at_action(game_file, 11)
          city = game.hex_by_id('D20').tile.cities.first
          erie = game.corporation_by_id('ERIE')
          nyc = game.corporation_by_id('NYC')

          expect(city.reservations).to eq([nil, erie])
          expect(city.tokens.map { |t| t&.corporation }).to eq([nyc, nil])
        end

        it 'ERIE\'s token does not replace NYC\'s when ERIE uses its reserved spot' do
          game = game_at_action(game_file, 24)
          city = game.hex_by_id('D20').tile.cities.first
          erie = game.corporation_by_id('ERIE')
          nyc = game.corporation_by_id('NYC')

          expect(city.reservations).to eq([nil, nil])
          expect(city.tokens.map { |t| t&.corporation }).to eq([nyc, erie])
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

    describe '1861' do
      describe 167_259 do
        it 'minors are nationalised in operating order' do
          # Checking RSR token locations and order tells us if the minors
          # have been nationalised in the correct order.
          game = game_at_action(game_file, 673)
          hexes = game.corporation_by_id('RSR').placed_tokens.map(&:hex).map(&:coordinates)
          expect(hexes).to eq(%w[E1 D14 D20 K17 I19 H8 B4 E9])
        end

        it 'majors are nationalised in operating order' do
          # MKN should be the first to be potentially nationalised.
          game = game_at_action(game_file, 582)
          corporation = game.corporation_by_id('MKN')
          expect(game.current_entity).to eq(corporation)
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

    describe '1822CA' do
      describe 1 do
        describe 'Windsor' do
          it "places the destination token in a new slot next to the minor's home" do
            game = game_at_action(game_file, 200)

            windsor_hex = game.hex_by_id('Z28')
            tile = windsor_hex.tile
            cities = tile.cities

            expect(tile.name).to eq('57')
            expect(cities.map(&:normal_slots)).to eq([1])
            expect(cities.map { |c| c.slots(all: false) }).to eq([2])
            expect(cities.map { |c| c.slots(all: true) }).to eq([2])
            expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
              .to eq([[nil, 'GWR']])
            expect(cities.map { |c| c.tokens.map { |t| t&.type } })
              .to eq([[nil, :destination]])
            expect(cities.map { |c| c.reservations.map { |r| r&.id } })
              .to eq([['16']])
          end
        end

        describe "M13's home choice in Toronto" do
          it "joins GT's home token" do
            action_index = 251

            game = game_at_action(game_file, action_index)

            # before
            cities = game.hex_by_id('AC21').tile.cities
            expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
              .to eq([[nil], ['GT']])
            expect(cities.map { |c| c.tokens.map { |t| t&.type } })
              .to eq([[nil], [:normal]])
            expect(cities.map { |c| c.reservations.map { |r| r&.id } })
              .to eq([['12'], [nil]])

            # act; in the fixture M13 went to the northern city, GT's home
            action = raw_action(game, action_index)
            game.process_action(action)

            # after
            cities = game.hex_by_id('AC21').tile.cities
            expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
              .to eq([[nil], %w[GT 13]])
            expect(cities.map { |c| c.tokens.map { |t| t&.type } })
              .to eq([[nil], %i[normal normal]])
            expect(cities.map { |c| c.reservations.map { |r| r&.id } })
              .to eq([['12'], [nil]])
          end

          it "joins M12's home reservation" do
            action_index = 251

            game = game_at_action(game_file, action_index)

            # before
            cities = game.hex_by_id('AC21').tile.cities
            expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
              .to eq([[nil], ['GT']])
            expect(cities.map { |c| c.tokens.map { |t| t&.type } })
              .to eq([[nil], [:normal]])
            expect(cities.map { |c| c.reservations.map { |r| r&.id } })
              .to eq([['12'], [nil]])

            # act; go to the southwestern city, M12's home
            action = {
              'type' => 'place_token',
              'entity' => '13',
              'entity_type' => 'corporation',
              'city' => 'AC21-0-0',
              'slot' => 0,
              'tokener' => '13',
            }
            game.process_action(action)

            # after
            cities = game.hex_by_id('AC21').tile.cities
            expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
              .to eq([[nil, '13'], ['GT']])
            expect(cities.map { |c| c.tokens.map { |t| t&.type } })
              .to eq([[nil, :normal], [:normal]])
            expect(cities.map { |c| c.reservations.map { |r| r&.id } })
              .to eq([['12'], [nil]])
          end
        end

        describe 'Montreal' do
          it 'returns duplicate token and stops using extra slot after cities join on tile upgrade' do
            action_index = 249

            game = game_at_action(game_file, action_index)

            # before: CPR has a token in both Montreal cities, GT's destination
            # is in an extra slot
            cities = game.hex_by_id('AF12').tile.cities
            expect(cities.map(&:normal_slots)).to eq([1, 2])
            expect(cities.map(&:slots)).to eq([1, 3]) # total of 4
            expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
              .to eq([['CPR'], [nil, 'CPR', 'GT']])
            expect(cities.map { |c| c.tokens.map { |t| t&.type } })
              .to eq([[:normal], [nil, :normal, :destination]])

            # act: lay M3 in Montreal, which has one joined city
            action = raw_action(game, action_index)
            game.process_action(action)

            # after: one city, there's room for everyone
            cities = game.hex_by_id('AF12').tile.cities
            expect(cities.map(&:normal_slots)).to eq([3])
            expect(cities.map(&:slots)).to eq([3]) # total down to 3
            expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
              .to eq([['CPR', nil, 'GT']])

            expect(cities.map { |c| c.tokens.map { |t| t&.type } })
              .to eq([[:normal, nil, :destination]])
          end
        end

        describe "ICR's destination choice in Quebec" do
          it 'chooses the northeast city' do
            # in the fixture the western city is chosen, don't need to repeat
            # that here

            game = game_at_action(game_file, 403)

            # before
            cities = game.hex_by_id('AH8').tile.cities
            expect(cities.map(&:normal_slots)).to eq([2, 1])
            expect(cities.map(&:slots)).to eq([2, 1])
            expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
              .to eq([[nil, 'QMOO'], [nil]])
            expect(cities.map { |c| c.tokens.map { |t| t&.type } })
              .to eq([[nil, :normal], [nil]])

            # act
            action = {
              'type' => 'place_token',
              'entity' => 'ICR',
              'entity_type' => 'corporation',
              'city' => 'Q1-0-1',
              'slot' => 0,
              'tokener' => 'ICR',
              'token_type' => 'destination',
            }
            game.process_action(action)

            # after
            cities = game.hex_by_id('AH8').tile.cities
            expect(cities.map(&:normal_slots)).to eq([2, 1])
            expect(cities.map(&:slots)).to eq([2, 1])
            expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
              .to eq([[nil, 'QMOO'], ['ICR']])
            expect(cities.map { |c| c.tokens.map { |t| t&.type } })
              .to eq([[nil, :normal], [:destination]])
          end

          it 'has no choice when there is only one city' do
            game = game_at_action(game_file, 402)

            # before
            cities = game.hex_by_id('AH8').tile.cities
            expect(cities.map(&:normal_slots)).to eq([2, 1])
            expect(cities.map(&:slots)).to eq([2, 1])
            expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
              .to eq([[nil, 'QMOO'], [nil]])
            expect(cities.map { |c| c.tokens.map { |t| t&.type } })
              .to eq([[nil, :normal], [nil]])

            # act
            action = {
              'type' => 'lay_tile',
              'entity' => 'ICR',
              'entity_type' => 'corporation',
              'hex' => 'AH8',
              'tile' => 'Q4-0',
              'rotation' => 0,
            }
            game.process_action(action, add_auto_actions: true)

            # after
            cities = game.hex_by_id('AH8').tile.cities
            expect(cities.map(&:normal_slots)).to eq([3])
            expect(cities.map(&:slots)).to eq([3])
            expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
              .to eq([[nil, 'QMOO', 'ICR']])
            expect(cities.map { |c| c.tokens.map { |t| t&.type } })
              .to eq([[nil, :normal, :destination]])
          end
        end
      end

      describe 2 do
        describe 'Winnipeg tile actions' do
          it 'does not allow tile W3 with rotation 1, 4, or 5' do
            action_index = 374
            game = game_at_action(game_file, action_index)
            winnipeg_hex = game.hex_by_id('N16')

            w1_tile = game.tile_by_id('W1-0')
            expect(winnipeg_hex.tile).to be(w1_tile)

            entity = game.current_entity

            w3_tile = game.tile_by_id('W3-0')
            w3_tile.rotate!(0)
            expect(game.legal_tile_rotation?(entity, winnipeg_hex, w3_tile)).to eq(true)
            w3_tile.rotate!(2)
            expect(game.legal_tile_rotation?(entity, winnipeg_hex, w3_tile)).to eq(true)
            w3_tile.rotate!(3)
            expect(game.legal_tile_rotation?(entity, winnipeg_hex, w3_tile)).to eq(true)

            w3_tile.rotate!(1)
            expect(game.legal_tile_rotation?(entity, winnipeg_hex, w3_tile)).to eq(false)
            w3_tile.rotate!(4)
            expect(game.legal_tile_rotation?(entity, winnipeg_hex, w3_tile)).to eq(false)
            w3_tile.rotate!(5)
            expect(game.legal_tile_rotation?(entity, winnipeg_hex, w3_tile)).to eq(false)
          end

          it 'the correct cities join up for tile #W2' do
            action_index = 374

            game = game_at_action(game_file, action_index)

            # before
            cities = game.hex_by_id('N16').tile.cities
            expect(cities.map(&:exits)).to eq([[1, 2], [3], [4], [5]])
            expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
              .to eq([%w[CNoR GTP], ['CPR'], ['21'], [nil]])
            expect(cities.map { |c| c.tokens.map { |t| t&.type } })
              .to eq([%i[normal normal], [:normal], [:normal], [nil]])

            # act: upgrade Winnipeg to green
            action = raw_action(game, action_index)
            game.process_action(action)

            # after: north and northeast cities combined
            cities = game.hex_by_id('N16').tile.cities
            expect(cities.map(&:exits)).to eq([[1, 2], [3, 4], [0, 5]])
            expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
              .to eq([%w[CNoR GTP], %w[CPR 21], [nil]])
            expect(cities.map { |c| c.tokens.map { |t| t&.type } })
              .to eq([%i[normal normal], %i[normal normal], [nil]])
          end

          it 'destination icon is uncovered when a city slot is added in brown' do
            action_index = 485

            game = game_at_action(game_file, action_index)
            winnipeg_hex = game.hex_by_id('N16')

            # before: QMOO token and NTR icon in same slot
            southeast_city = winnipeg_hex.tile.cities[2]
            expect(southeast_city.normal_slots).to eq(1)
            expect(southeast_city.tokens.map { |t| t&.corporation&.id })
              .to eq(['QMOO'])
            expect(southeast_city.tokens.map { |t| t&.type })
              .to eq([:normal])
            expect(southeast_city.slot_icons.size).to eq(1)
            expect(southeast_city.slot_icons[0].corporation.id).to eq('NTR')

            # act: upgrade Winnipeg to brown
            action = raw_action(game, action_index)
            game.process_action(action)

            # after: QMOO token in slot 0, NTR icon in slot 1
            southeast_city = winnipeg_hex.tile.cities[2]
            expect(southeast_city.normal_slots).to eq(2)
            expect(southeast_city.tokens.map { |t| t&.corporation&.id })
              .to eq(['QMOO', nil])
            expect(southeast_city.tokens.map { |t| t&.type })
              .to eq([:normal, nil])
            expect(southeast_city.slot_icons.size).to eq(1)
            expect(southeast_city.slot_icons[1].corporation.id).to eq('NTR')
          end

          it 'combines all cities when upgraded to gray' do
            action_index = 669

            game = game_at_action(game_file, action_index)
            winnipeg_hex = game.hex_by_id('N16')

            # before: three separate cities
            cities = winnipeg_hex.tile.cities
            expect(cities.map(&:normal_slots)).to eq([2, 2, 2])
            expect(cities.map(&:slots)).to eq([2, 3, 2])
            expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
              .to eq([%w[CNoR GTP], %w[CPR 21 GNWR], %w[QMOO PGE]])
            expect(cities.map { |c| c.tokens.map { |t| t&.type } })
              .to eq([%i[normal normal], %i[normal normal destination], %i[normal normal]])

            # act: upgrade Winnipeg to gray, NTR destinates
            action = raw_action(game, action_index)
            game.process_action(action)

            # after: one city, additional token
            cities = winnipeg_hex.tile.cities
            expect(cities.map(&:normal_slots)).to eq([6])
            expect(cities.map(&:slots)).to eq([8])
            expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
              .to eq([%w[CNoR GTP CPR 21 QMOO PGE GNWR NTR]])
            expect(cities.map { |c| c.tokens.map { |t| t&.type } })
              .to eq([%i[normal normal normal normal normal normal destination destination]])
          end
        end

        describe 'Winnipeg token actions' do
          it 'Major (CPR) token can cover up destination icon (GNWR)' do
            # QMOO also covers NTR's destination icon at action 380 (green tile)
            # PGE also covers NTR's destination icon at action 487 (brown tile)

            action_index = 349

            game = game_at_action(game_file, action_index)
            winnipeg_hex = game.hex_by_id('N16')
            north_city = winnipeg_hex.tile.cities[1]

            # before: GNWR destination icon, no tokens
            expect(north_city.normal_slots).to eq(1)
            expect(north_city.slots).to eq(1)
            expect(north_city.slot_icons.size).to eq(1)
            expect(north_city.slot_icons[0].corporation.id).to eq('GNWR')
            expect(north_city.tokens).to eq([nil])

            # act: CPR lays a token in the North slot
            action = raw_action(game, action_index)
            game.process_action(action)

            # after: destination icon and new token are both present, still 1 slot
            expect(north_city.normal_slots).to eq(1)
            expect(north_city.slots).to eq(1)
            expect(north_city.slot_icons.size).to eq(1)
            expect(north_city.slot_icons[0].corporation.id).to eq('GNWR')
            expect(north_city.tokens.map { |t| t.corporation.id }).to eq(%w[CPR])
            expect(north_city.tokens.map(&:type)).to eq(%i[normal])
          end

          it 'adds the destination token to a full city' do
            action_index = 663

            game = game_at_action(game_file, action_index)
            winnipeg_hex = game.hex_by_id('N16')
            north_city = winnipeg_hex.tile.cities[1]

            # before: city full of tokens, plus GNWR destination icon
            expect(north_city.tokens.map { |t| t.corporation.id }).to eq(%w[CPR 21])
            expect(north_city.tokens.map(&:type)).to eq(%i[normal normal])
            expect(north_city.normal_slots).to eq(2)
            expect(north_city.slots).to eq(2)

            expect(north_city.slot_icons.size).to eq(1)
            expect(north_city.slot_icons.values[0].corporation.id).to eq('GNWR')

            # act: GNWR passes track step and destinates
            action = raw_action(game, action_index)
            game.process_action(action)

            # after: GNWR destination token added, increasing slots; no more icon
            expect(north_city.tokens.size).to eq(3)
            token = north_city.tokens[2]
            expect(token.type).to eq(:destination)
            expect(token.corporation.id).to eq('GNWR')
            expect(north_city.normal_slots).to eq(2)
            expect(north_city.slots).to eq(3)
            expect(north_city.slot_icons).to eq({})
          end

          it 'adds token from P10, increasing slots' do
            action_index = 677

            game = game_at_action(game_file, action_index)
            winnipeg_hex = game.hex_by_id('N16')
            city = winnipeg_hex.tile.cities[0]

            # before: city full of tokens
            expect(city.tokens.map { |t| t.corporation.id }).to eq(%w[CNoR GTP CPR 21 QMOO PGE GNWR NTR])
            expect(city.tokens.map(&:type))
              .to eq(%i[normal normal normal normal normal normal destination destination])
            expect(city.extra_tokens).to eq([])
            expect(city.normal_slots).to eq(6)
            expect(city.slots(all: false)).to eq(8)
            expect(city.slots(all: true)).to eq(8)

            # act: P10 places bonus token in Winnipeg
            action = raw_action(game, action_index)
            game.process_action(action)

            # after: extra token is present
            expect(city.tokens.map { |t| t.corporation.id }).to eq(%w[CNoR GTP CPR 21 QMOO PGE GNWR NTR])
            expect(city.tokens.map(&:type))
              .to eq(%i[normal normal normal normal normal normal destination destination])
            expect(city.extra_tokens.map { |t| t.corporation.id }).to eq(%w[GWR])
            expect(city.extra_tokens.map(&:type)).to eq(%i[normal])
            expect(city.normal_slots).to eq(6)
            expect(city.slots(all: false)).to eq(8)
            expect(city.slots(all: true)).to eq(9)
          end
        end
      end

      describe 3 do
        it "keeps ICR's destination token on the eastern city when Quebec is upgraded from Q3 to Q5" do
          game = game_at_action(game_file, 1212)
          quebec_hex = game.hex_by_id('AH8')
          icr = game.corporation_by_id('ICR')
          token = icr.placed_tokens.find { |t| t.type == :destination }

          expect(token.hex).to be(quebec_hex)
          expect(token.city.exits.sort).to eq([4, 5])
        end
      end

      describe 4 do
        it 'M13 Toronto' do
          game = game_at_action(game_file, 1258)

          toronto_hex = game.hex_by_id('AC21')
          cities = toronto_hex.tile.cities

          # before
          expect(cities.map(&:normal_slots)).to eq([1, 1])
          expect(cities.map(&:slots)).to eq([2, 1])

          # act
          action = {
            'type' => 'lay_tile',
            'entity' => 'P14',
            'entity_type' => 'company',
            'hex' => 'AC21',
            'tile' => 'T4-0',
            'rotation' => 0,
          }
          game.process_action(action)

          # after
          toronto = game.hex_by_id('AC21').tile.cities[0]
          expect(toronto.normal_slots).to eq(2)
          expect(toronto.slots).to eq(3)
        end
      end
    end

    describe '1822PNW' do
      describe 165_580 do
        it 'does not include associated minors for majors that were started '\
           'directly as valid choices for P20' do
          game = game_at_action(game_file, 926)

          actual = game.active_step.p20_targets
          expected = [game.corporation_by_id('1')]

          expect(actual).to eq(expected)
        end
      end
    end
  end
end
