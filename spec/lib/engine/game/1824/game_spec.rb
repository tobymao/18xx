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

    it 'SD formation after OR 5.1' do
      game = fixture_at_action(280) # Before last action in OR 5.1

      sd = game.corporation_by_id('SD')
      sd1 = game.corporation_by_id('SD1')
      sd2 = game.corporation_by_id('SD2')
      sd3 = game.corporation_by_id('SD3')
      pre_staatsbahns = [sd1, sd2, sd3]

      # Check cash and status before formation
      expect(sd.floated?).to be false
      pre_staatsbahns.each { |corp| expect(corp.closed?).to be false }
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
      pre_staatsbahns.each { |corp| expect(corp.trains.map(&:name)).to eq(['3']) }
      expect(sd.trains).to be_empty

      # Check shares before formation
      p1 = game.players.find { |p| p.name == 'Player 1' }
      p2 = game.players.find { |p| p.name == 'Player 2' }
      p3 = game.players.find { |p| p.name == 'Player 3' }
      p4 = game.players.find { |p| p.name == 'Player 4' }
      expect(get_percentage_owned(p1, sd)).to eq(10)
      expect(get_percentage_owned(p1, sd2)).to eq(100)
      expect(get_percentage_owned(p1, sd3)).to eq(100)
      expect(get_percentage_owned(p2, sd)).to eq(20)
      expect(get_percentage_owned(p2, sd1)).to eq(100)
      expect(get_percentage_owned(p3, sd)).to eq(0)
      expect(get_percentage_owned(p4, sd)).to eq(10)

      # Step forward one step,to OR 5.2, when SD should have formed
      game.process_to_action(281)

      # Check cash and status after formation
      expect(sd.cash).to eq((6 * 120) + 47 + 0 + 15)
      pre_staatsbahns.each { |corp| expect(corp.cash).to eq(0) }
      expect(sd.floated?).to be true
      pre_staatsbahns.each { |corp| expect(corp.closed?).to be true }

      # Check tokens after formation
      expect(get_token_owners_in_hex(game, vienna)).to eq([['SD'], ['KK1'], ['KK2']])
      expect(get_token_owners_in_hex(game, graz)).to eq([['SD', nil]])
      expect(get_token_owners_in_hex(game, innsbruck)).to eq([['SD', nil]])

      # Check trains after formation
      pre_staatsbahns.each { |corp| expect(corp.trains).to be_empty }
      expect(sd.trains.map(&:name)).to eq(%w[3 3 3])

      # Check shares after formation
      expect(get_percentage_owned(p1, sd)).to eq(30)
      expect(get_percentage_owned(p1, sd2)).to eq(0)
      expect(get_percentage_owned(p1, sd3)).to eq(0)
      expect(get_percentage_owned(p2, sd)).to eq(40)
      expect(get_percentage_owned(p2, sd1)).to eq(0)
      expect(get_percentage_owned(p3, sd)).to eq(0)
      expect(get_percentage_owned(p4, sd)).to eq(10)
      expect(sd.president?(p2)).to be true
    end

    describe '1824_game_end_reason_bank' do
      it 'UG formation after OR 5.2' do
        game = fixture_at_action(322) # Before last action in OR 5.2

        ug = game.corporation_by_id('UG')
        ug1 = game.corporation_by_id('UG1')
        ug2 = game.corporation_by_id('UG2')
        pre_staatsbahns = [ug1, ug2]

        # Check cash and status before formation
        expect(ug.floated?).to be false
        pre_staatsbahns.each { |corp| expect(corp.closed?).to be false }
        expect(ug.cash).to eq(0)
        expect(ug1.cash).to eq(80)
        expect(ug2.cash).to eq(179)

        # Check tokens before formation
        budapest = 'F17'
        funfkirchen = 'H15'
        expect(get_token_owners_in_hex(game, budapest)).to eq([['UG1', nil]])
        expect(get_token_owners_in_hex(game, funfkirchen)).to eq([['UG2', nil]])

        # Check trains before formation
        expect(ug1.trains.map(&:name)).to eq(['4'])
        expect(ug2.trains.map(&:name)).to eq(['3'])
        expect(ug.trains).to be_empty

        # Check shares before formation
        p1 = game.players.find { |p| p.name == 'Player 1' }
        p2 = game.players.find { |p| p.name == 'Player 2' }
        p3 = game.players.find { |p| p.name == 'Player 3' }
        p4 = game.players.find { |p| p.name == 'Player 4' }
        expect(get_percentage_owned(p1, ug)).to eq(0)
        expect(get_percentage_owned(p2, ug)).to eq(0)
        expect(get_percentage_owned(p3, ug)).to eq(0)
        expect(get_percentage_owned(p3, ug1)).to eq(100)
        expect(get_percentage_owned(p3, ug2)).to eq(100)
        expect(get_percentage_owned(p4, ug)).to eq(0)

        # Step forward one step,to SR 6, when UG should have formed
        game.process_to_action(323)

        # Check cash and status after formation
        expect(ug.cash).to eq((7 * 120) + 80 + 179)
        pre_staatsbahns.each { |corp| expect(corp.cash).to eq(0) }
        expect(ug.floated?).to be true
        pre_staatsbahns.each { |corp| expect(corp.closed?).to be true }

        # Check tokens after formation
        expect(get_token_owners_in_hex(game, budapest)).to eq([['UG', nil]])
        expect(get_token_owners_in_hex(game, funfkirchen)).to eq([['UG', nil]])

        # Check trains after formation
        pre_staatsbahns.each { |corp| expect(corp.trains).to be_empty }
        expect(ug.trains.map(&:name)).to eq(%w[4 3])

        # Check shares after formation
        expect(get_percentage_owned(p1, ug)).to eq(0)
        expect(get_percentage_owned(p2, ug)).to eq(0)
        expect(get_percentage_owned(p3, ug)).to eq(30)
        expect(get_percentage_owned(p3, ug1)).to eq(0)
        expect(get_percentage_owned(p3, ug2)).to eq(0)
        expect(get_percentage_owned(p4, ug)).to eq(0)
        expect(ug.president?(p3)).to be true
      end

      it 'KK formation after OR 6.1' do
        game = fixture_at_action(396) # Before last action in OR 6.1

        kk = game.corporation_by_id('KK')
        kk1 = game.corporation_by_id('KK1')
        kk2 = game.corporation_by_id('KK2')
        pre_staatsbahns = [kk1, kk2]

        # Check cash and status before formation
        expect(kk.floated?).to be false
        pre_staatsbahns.each { |corp| expect(corp.closed?).to be false }
        expect(kk.cash).to eq(0)
        expect(kk1.cash).to eq(195)
        expect(kk2.cash).to eq(230)

        # Check tokens before formation
        vienna = 'E12'
        expect(get_token_owners_in_hex(game, vienna)).to eq([['SD'], %w[KK1 KK2 MS]])

        # Check trains before formation
        expect(kk1.trains.map(&:name)).to eq(['4'])
        expect(kk.trains).to be_empty
        expect(kk2.trains).to be_empty

        # Check shares before formation
        p1 = game.players.find { |p| p.name == 'Player 1' }
        p2 = game.players.find { |p| p.name == 'Player 2' }
        p3 = game.players.find { |p| p.name == 'Player 3' }
        p4 = game.players.find { |p| p.name == 'Player 4' }
        expect(get_percentage_owned(p1, kk)).to eq(0)
        expect(get_percentage_owned(p2, kk)).to eq(30)
        expect(get_percentage_owned(p2, kk2)).to eq(100)
        expect(get_percentage_owned(p3, kk)).to eq(0)
        expect(get_percentage_owned(p4, kk)).to eq(0)
        expect(get_percentage_owned(p4, kk1)).to eq(100)

        # Step forward one step,to OR 6.2, when KK should have formed
        game.process_to_action(397)

        # Check cash and status after formation
        expect(kk.cash).to eq((7 * 120) + 195 + 230)
        pre_staatsbahns.each { |corp| expect(corp.cash).to eq(0) }
        expect(kk.floated?).to be true
        pre_staatsbahns.each { |corp| expect(corp.closed?).to be true }

        # Check tokens after formation
        expect(get_token_owners_in_hex(game, vienna)).to eq([['SD'], ["KK", nil, "MS"]])

        # Check trains after formation
        pre_staatsbahns.each { |corp| expect(corp.trains).to be_empty }
        expect(kk.trains.map(&:name)).to eq(['4'])

        # Check shares after formation
        expect(get_percentage_owned(p1, kk)).to eq(0)
        expect(get_percentage_owned(p2, kk)).to eq(40)
        expect(get_percentage_owned(p2, kk2)).to eq(0)
        expect(get_percentage_owned(p3, kk)).to eq(0)
        expect(get_percentage_owned(p4, kk)).to eq(20)
        expect(get_percentage_owned(p4, kk1)).to eq(0)
        expect(kk.president?(p2)).to be true
      end
    end
  end

  def get_token_owners_in_hex(game, hex_id)
    game.hex_by_id(hex_id).tile.cities.map do |city|
      city.tokens.map { |t| t&.corporation&.id }
    end
  end

  def get_percentage_owned(player, corporation)
    player.shares_of(corporation).sum(&:percent)
  end
end
