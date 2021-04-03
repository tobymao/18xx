# frozen_string_literal: true

require 'find'

require 'spec_helper'

def game_at_action(game_file, action_id = nil)
  Engine::Game.load(game_file, at_action: action_id).maybe_raise!
end

module Engine
  describe 'Fixture Game State' do
    let(:game_file) do
      Find.find(FIXTURES_DIR).find { |f| File.basename(f) == "#{described_class}.json" }
    end

    describe '18GA' do
      describe 9222 do
        it 'MRC\'s ability cannot be used by a non-owning corporation' do
          game = game_at_action(game_file, 248)
          action = {
            'type' => 'lay_tile',
            'entity' => 'MRC',
            'entity_type' => 'company',
            'hex' => 'F12',
            'tile' => '9-2',
            'rotation' => 2,
          }
          expect(game.exception).to be_nil
          expect(game.process_action(action).exception).to be_a(GameError)
        end
        it 'MRC\'s ability can be used by the owning corporation' do
          game = game_at_action(game_file, 284)
          mrc = game.company_by_id('MRC')

          expect(game.active_step).to be_a(Step::Track)
          expect(game.round.actions_for(mrc)).to eq(%w[lay_tile pass])

          game = game_at_action(game_file, 285)
          mrc = game.company_by_id('MRC')

          expect(game.active_step).to be_a(Step::Token)
          expect(game.round.actions_for(mrc)).to eq([])
        end
      end
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
          game = game_at_action(game_file, 154)
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
          game = game_at_action(game_file, 162)
          expect(game.cert_limit).to be(10)
        end

        it 'has a cert limit of 10 after a corporation closes and then a player is bankrupt' do
          game = game_at_action(game_file, 405)
          expect(game.cert_limit).to be(10)
        end

        it 'has a cert limit of 8 after a corporation closes, then a player is '\
           'bankrupt, and then another corporation closes' do
          game = game_at_action(game_file, 443)
          expect(game.cert_limit).to be(8)
        end

        it 'IC to lay a tile on J4 for free' do
          game = game_at_action(game_file, 84)
          expect(game.illinois_central.cash).to be(280)

          game = game_at_action(game_file, 85)
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
          expect(blocking_ability.hexes).to eq(%w[I3 J4])
        end

        it 'CFLV no longer blocks I3 and J4 after the Nord buys a train' do
          game = game_at_action(game_file, 35)

          i3 = game.hex_by_id('I3')
          j4 = game.hex_by_id('J4')
          cflv = game.company_by_id('CFLV')
          blocking_ability = game.abilities(cflv, :blocks_hexes)

          expect(i3.tile.blockers).to eq([cflv])
          expect(j4.tile.blockers).to eq([cflv])
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
  end
end
