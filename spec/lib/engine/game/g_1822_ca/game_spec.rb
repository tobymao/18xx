# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1822CA::Game do
  describe '1' do
    describe 'Windsor' do
      it "places the destination token in a new slot next to the minor's home" do
        game = fixture_at_action(200)

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

    describe 'Montreal' do
      it 'returns duplicate token and stops using extra slot after cities join on tile upgrade' do
        game = fixture_at_action(249)

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
        game.process_to_action(250)

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

    describe "M13's home choice in Toronto" do
      it "joins GT's home token" do
        game = fixture_at_action(251)

        # before
        cities = game.hex_by_id('AC21').tile.cities
        expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
          .to eq([[nil], ['GT']])
        expect(cities.map { |c| c.tokens.map { |t| t&.type } })
          .to eq([[nil], [:normal]])
        expect(cities.map { |c| c.reservations.map { |r| r&.id } })
          .to eq([['12'], [nil]])

        # act; in the fixture M13 went to the northern city, GT's home
        game.process_to_action(252)

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
        game = fixture_at_action(251, clear_cache: true)

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

    describe "ICR's destination choice in Quebec" do
      it 'chooses the northeast city' do
        # in the fixture the western city is chosen, don't need to repeat
        # that here

        game = fixture_at_action(403, clear_cache: true)

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
        game = fixture_at_action(402, clear_cache: true)

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

  describe '2' do
    describe 'Winnipeg tile actions' do
      it 'does not allow tile W3 with rotation 1, 4, or 5' do
        game = fixture_at_action(374)
        winnipeg_hex = game.hex_by_id('N16')

        w1_tile = game.tile_by_id('W1-0')
        expect(winnipeg_hex.tile).to be(w1_tile)

        entity = game.current_entity

        w3_tile = game.tile_by_id('W3-0')
        w3_tile.rotate!(0)
        expect(game.legal_tile_rotation?(entity, winnipeg_hex, w3_tile)).to be(true)
        w3_tile.rotate!(2)
        expect(game.legal_tile_rotation?(entity, winnipeg_hex, w3_tile)).to be(true)
        w3_tile.rotate!(3)
        expect(game.legal_tile_rotation?(entity, winnipeg_hex, w3_tile)).to be(true)

        w3_tile.rotate!(1)
        expect(game.legal_tile_rotation?(entity, winnipeg_hex, w3_tile)).to be(false)
        w3_tile.rotate!(4)
        expect(game.legal_tile_rotation?(entity, winnipeg_hex, w3_tile)).to be(false)
        w3_tile.rotate!(5)
        expect(game.legal_tile_rotation?(entity, winnipeg_hex, w3_tile)).to be(false)
      end

      it 'the correct cities join up for tile #W2' do
        game = fixture_at_action(374)

        # before
        cities = game.hex_by_id('N16').tile.cities
        expect(cities.map(&:exits)).to eq([[1, 2], [3], [4], [5]])
        expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
          .to eq([%w[CNoR GTP], ['CPR'], ['21'], [nil]])
        expect(cities.map { |c| c.tokens.map { |t| t&.type } })
          .to eq([%i[normal normal], [:normal], [:normal], [nil]])

        # act: upgrade Winnipeg to green
        game.process_to_action(375)

        # after: north and northeast cities combined
        cities = game.hex_by_id('N16').tile.cities
        expect(cities.map(&:exits)).to eq([[1, 2], [3, 4], [0, 5]])
        expect(cities.map { |c| c.tokens.map { |t| t&.corporation&.id } })
          .to eq([%w[CNoR GTP], %w[CPR 21], [nil]])
        expect(cities.map { |c| c.tokens.map { |t| t&.type } })
          .to eq([%i[normal normal], %i[normal normal], [nil]])
      end

      it 'destination icon is uncovered when a city slot is added in brown' do
        game = fixture_at_action(485)
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
        game.process_to_action(486)

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
        game = fixture_at_action(669)
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
        game.process_to_action(670)

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

        game = fixture_at_action(349)
        winnipeg_hex = game.hex_by_id('N16')
        north_city = winnipeg_hex.tile.cities[1]

        # before: GNWR destination icon, no tokens
        expect(north_city.normal_slots).to eq(1)
        expect(north_city.slots).to eq(1)
        expect(north_city.slot_icons.size).to eq(1)
        expect(north_city.slot_icons[0].corporation.id).to eq('GNWR')
        expect(north_city.tokens).to eq([nil])

        # act: CPR lays a token in the North slot
        game.process_to_action(350)

        # after: destination icon and new token are both present, still 1 slot
        expect(north_city.normal_slots).to eq(1)
        expect(north_city.slots).to eq(1)
        expect(north_city.slot_icons.size).to eq(1)
        expect(north_city.slot_icons[0].corporation.id).to eq('GNWR')
        expect(north_city.tokens.map { |t| t.corporation.id }).to eq(%w[CPR])
        expect(north_city.tokens.map(&:type)).to eq(%i[normal])
      end

      it 'adds the destination token to a full city' do
        game = fixture_at_action(663)
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
        game.process_to_action(664)

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
        game = fixture_at_action(677)
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
        game.process_to_action(678)

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

  describe '3' do
    it "keeps ICR's destination token on the eastern city when Quebec is upgraded from Q3 to Q5" do
      game = fixture_at_action(1212)
      quebec_hex = game.hex_by_id('AH8')
      icr = game.corporation_by_id('ICR')
      token = icr.placed_tokens.find { |t| t.type == :destination }

      expect(token.hex).to be(quebec_hex)
      expect(token.city.exits.sort).to eq([4, 5])
    end
  end

  describe '4' do
    it 'M13 Toronto' do
      game = fixture_at_action(988)

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
