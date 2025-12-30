# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1824::Game do
  describe '235932_premature_ending' do
    it 'UG1 is closed as unsold in SR1' do
      game = fixture_at_action(22) # Completes SR1

      ug1 = game.corporation_by_id('UG1')
      ug2 = game.corporation_by_id('UG2')

      # UG1 was unsold so it has been closed, UG2 was sold so still open
      expect(ug1.closed?).to be true
      expect(ug2.closed?).to be false
    end

    it 'Verify #12324 - Correct capitalization count' do
      game = fixture_at_action(22) # Start of OR1

      bh = game.corporation_by_id('BH')
      bk = game.corporation_by_id('BK')
      cl = game.corporation_by_id('CL')
      kk = game.corporation_by_id('KK')
      ms = game.corporation_by_id('MS')
      sb = game.corporation_by_id('SB')
      sd = game.corporation_by_id('SD')
      ug = game.corporation_by_id('UG')

      # Regionals without coal railway association get 100% capitalization when floated
      expect(bh.capitalization_share_count).to eq(10) # BH not associated to any coal railway

      # Regionals associated with a coal railway will get 80% capitalization when floated
      expect(bk.capitalization_share_count).to eq(8)
      expect(cl.capitalization_share_count).to eq(8)
      expect(ms.capitalization_share_count).to eq(8)
      expect(sb.capitalization_share_count).to eq(8)

      # Staatsbahn railways gets capitalization depending on pre-staatsbahn sold
      expect(kk.capitalization_share_count).to eq(7) # KK1 (20%) and KK2 sold, so 30% reserved
      expect(sd.capitalization_share_count).to eq(6) # SD1 (20%), SD2, and SD3 sold, so 40% reserved
      expect(ug.capitalization_share_count).to eq(9) # Only UG2 sold, so 10% reserved
    end

    it 'EPP to go first in OR1' do
      game = fixture_at_action(22) # Completes SR1
      coal_railway_1 = game.corporation_by_id('EPP')
      track_step = game.active_step

      # Player one has priority deal
      expect(game.players.first.name).to eq('Player 1')

      # First to go in the OR1 is EPP
      expect(game.current_entity).to eq(coal_railway_1)
      expect(track_step.class).to eq(Engine::Game::G1824::Step::Track)
      expect(game).to have_available_hexes(%w[B5 B7 C6])
    end

    it 'SD formation' do
      game = fixture_at_action(280) # Before last action in OR 5.1

      sd = game.corporation_by_id('SD')
      sd1 = game.corporation_by_id('SD1')
      sd2 = game.corporation_by_id('SD2')
      sd3 = game.corporation_by_id('SD3')

      expect(sd.floated?).to be false
      expect(sd1.closed?).to be false
      expect(sd2.closed?).to be false
      expect(sd3.closed?).to be false
      expect(sd.cash).to eq(0)
      expect(sd1.cash).to eq(47)
      expect(sd2.cash).to eq(0)
      expect(sd3.cash).to eq(15)

      # Check tokens before formation
      vienna = 'E12'
      graz = 'G10'
      innsbruck = 'G4'
      expect(get_token_owners_in_hex(game, vienna)).to eq([['SD1'], ['KK1'], ['KK2']])
      expect(get_token_owners_in_hex(game, graz)).to eq([['SD2', nil]])
      expect(get_token_owners_in_hex(game, innsbruck)).to eq([['SD3', nil]])

      # Check trains before formation
      [sd1, sd2, sd3].each { |corp| expect(corp.trains.map(&:name)).to eq(%w[3]) }
      expect(sd.trains).to be_empty

      game = fixture_at_action(281) # OR 5.2 started, SD formed at end of OR 5.1

      # Check cash and status after formation
      expect(sd.cash).to eq(720 + 47 + 0 + 15)
      expect(sd1.cash).to eq(0)
      expect(sd2.cash).to eq(0)
      expect(sd3.cash).to eq(0)
      expect(sd.floated?).to be true
      expect(sd1.closed?).to be true
      expect(sd2.closed?).to be true
      expect(sd3.closed?).to be true

      # Check tokens after formation
      expect(get_token_owners_in_hex(game, vienna)).to eq([['SD'], ['KK1'], ['KK2']])
      expect(get_token_owners_in_hex(game, graz)).to eq([['SD', nil]])
      expect(get_token_owners_in_hex(game, innsbruck)).to eq([['SD', nil]])

      # Check trains after formation
      [sd1, sd2, sd3].each { |corp| expect(corp.trains).to be_empty }
      expect(sd.trains.map(&:name)).to eq(%w[3 3 3])
    end

    def get_token_owners_in_hex(game, hex_id)
      game.hex_by_id(hex_id).tile.cities.map do |city|
        city.tokens.map { |t| t&.corporation&.id }
      end
    end
  end
end
