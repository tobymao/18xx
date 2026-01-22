# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1824::Game do
  describe '1824_game_end_reason_bank' do
    it 'EPP to go first in OR1' do
      game = fixture_at_action(18) # Completes SR1
      coal_railway_1 = game.corporation_by_id('EPP')
      track_step = game.active_step

      # Player one has priority deal
      expect(game.players.first.name).to eq('Player 2')

      # First to go in the OR1 is EPP
      expect(game.current_entity).to eq(coal_railway_1)
      expect(track_step.class).to eq(Engine::Game::G1824::Step::Track)
      expect(game).to have_available_hexes(%w[B5 B7 C6])
    end

    it 'SD formation after OR 4.2' do
      start_action = 218 # Just before last action in OR 4.2
      game = fixture_at_action(start_action)
      expect_at(game, Engine::Game::G1824::Step::BuyTrain, [4, 2], game.corporation_by_id('MS'))

      sd = game.corporation_by_id('SD')
      sd1 = game.corporation_by_id('SD1')
      sd2 = game.corporation_by_id('SD2')
      sd3 = game.corporation_by_id('SD3')
      pre_staatsbahns = [sd1, sd2, sd3]

      # Check cash and status before formation
      expect(sd.floated?).to be false
      pre_staatsbahns.each { |corp| expect(corp.closed?).to be false }
      expect(sd.cash).to eq(0)
      expect(sd1.cash).to eq(110)
      expect(sd2.cash).to eq(5)
      expect(sd3.cash).to eq(31)

      # Check tokens before formation
      vienna = 'E12'
      graz = 'G10'
      innsbruck = 'G4'
      expect(get_token_owners_in_hex(game, vienna)).to eq([['SD1'], ['KK1'], ['KK2']])
      expect(get_token_owners_in_hex(game, graz)).to eq([['SD2', nil]])
      expect(get_token_owners_in_hex(game, innsbruck)).to eq([['SD3', nil]])

      # Check trains before formation
      [sd1, sd2].each { |corp| expect(corp.trains.map(&:name)).to eq(['3']) }
      expect(sd3.trains.map(&:name)).to eq(['2'])
      expect(sd.trains).to be_empty

      # Check shares before formation
      p1 = game.players.find { |p| p.name == 'Player 1' }
      p2 = game.players.find { |p| p.name == 'Player 2' }
      p3 = game.players.find { |p| p.name == 'Player 3' }
      p4 = game.players.find { |p| p.name == 'Player 4' }
      expect(get_percentage_owned(p1, sd)).to eq(0)
      expect(get_percentage_owned(p1, sd2)).to eq(100)
      expect(get_percentage_owned(p2, sd)).to eq(0)
      expect(get_percentage_owned(p2, sd1)).to eq(100)
      expect(get_percentage_owned(p3, sd)).to eq(0)
      expect(get_percentage_owned(p3, sd3)).to eq(100)
      expect(get_percentage_owned(p4, sd)).to eq(0)

      # Step forward one step, to SR 5 (Forced MR exchange), when SD should have formed
      game.process_to_action(start_action + 1)
      expect_at(game, Engine::Game::G1824::Step::ForcedMountainRailwayExchange, [5, 1], p2)

      # Check cash and status after formation
      expect(sd.cash).to eq((6 * 120) + 110 + 5 + 31)
      pre_staatsbahns.each { |corp| expect(corp.cash).to eq(0) }
      expect(sd.floated?).to be true
      pre_staatsbahns.each { |corp| expect(corp.closed?).to be true }

      # Check tokens after formation
      expect(get_token_owners_in_hex(game, vienna)).to eq([['SD'], ['KK1'], ['KK2']])
      expect(get_token_owners_in_hex(game, graz)).to eq([['SD', nil]])
      expect(get_token_owners_in_hex(game, innsbruck)).to eq([['SD', nil]])

      # Check trains after formation
      pre_staatsbahns.each { |corp| expect(corp.trains).to be_empty }
      expect(sd.trains.map(&:name)).to eq(%w[3 3])

      # Check shares after formation
      expect(get_percentage_owned_by_players(game, sd)).to eq(40)
      expect(get_percentage_owned(p1, sd)).to eq(10)
      expect(get_percentage_owned(p1, sd2)).to eq(0)
      expect(get_percentage_owned(p2, sd)).to eq(20)
      expect(get_percentage_owned(p2, sd1)).to eq(0)
      expect(get_percentage_owned(p3, sd)).to eq(10)
      expect(get_percentage_owned(p4, sd)).to eq(0)
      expect(sd.president?(p2)).to be true

      expect(get_number_of_shares(game, p1)).to eq(8)
      expect(game.num_certs(p1)).to eq(8) # 6 share certificates plus 2 MR
      expect(get_number_of_shares(game, p2)).to eq(6)
      expect(game.num_certs(p2)).to eq(6) # 6 share certificates plus 2 MR
      expect(get_number_of_shares(game, p3)).to eq(8)
      expect(game.num_certs(p3)).to eq(5) # 3 president shares
      expect(get_number_of_shares(game, p4)).to eq(7)
      expect(game.num_certs(p4)).to eq(6) # 2 president shares, 1 MR
    end

    it 'UG formation after OR 5.2' do
      start_action = 322 # Just before last action in OR 5.2
      game = fixture_at_action(start_action)
      expect_at(game, Engine::Game::G1824::Step::BuyTrain, [5, 2], game.corporation_by_id('BK'))

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
      game.process_to_action(start_action + 1)
      expect_at(game, Engine::Game::G1824::Step::BuySellParExchangeShares, [6, 1], p4)

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
      expect(get_percentage_owned_by_players(game, ug)).to eq(30)
      expect(get_percentage_owned(p1, ug)).to eq(0)
      expect(get_percentage_owned(p2, ug)).to eq(0)
      expect(get_percentage_owned(p3, ug)).to eq(30)
      expect(get_percentage_owned(p4, ug)).to eq(0)
      expect(ug.president?(p3)).to be true

      expect(get_number_of_shares(game, p1)).to eq(13)
      expect(game.num_certs(p1)).to eq(10) # 3 president shares
      expect(get_number_of_shares(game, p2)).to eq(11)
      expect(game.num_certs(p2)).to eq(10) # 1 president share
      expect(get_number_of_shares(game, p3)).to eq(10)
      expect(game.num_certs(p3)).to eq(8) # 2 president shares
      expect(get_number_of_shares(game, p4)).to eq(10)
      expect(game.num_certs(p4)).to eq(8) # 2 president shares
    end

    it 'KK formation after OR 6.1' do
      start_action = 396 # Just before last action in OR 6.1
      game = fixture_at_action(start_action)
      expect_at(game, Engine::Game::G1824::Step::BuyTrain, [6, 1], game.corporation_by_id('CL'))

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
      game.process_to_action(start_action + 1)
      expect_at(game, Engine::Game::G1824::Step::Track, [6, 2], game.corporation_by_id('MS'))

      # Check cash and status after formation
      expect(kk.cash).to eq((7 * 120) + 195 + 230)
      pre_staatsbahns.each { |corp| expect(corp.cash).to eq(0) }
      expect(kk.floated?).to be true
      pre_staatsbahns.each { |corp| expect(corp.closed?).to be true }

      # Check tokens after formation
      expect(get_token_owners_in_hex(game, vienna)).to eq([['SD'], ['KK', nil, 'MS']])

      # Check trains after formation
      pre_staatsbahns.each { |corp| expect(corp.trains).to be_empty }
      expect(kk.trains.map(&:name)).to eq(['4'])

      # Check shares after formation
      expect(get_percentage_owned_by_players(game, kk)).to eq(60)
      expect(get_percentage_owned(p1, kk)).to eq(0)
      expect(get_percentage_owned(p2, kk)).to eq(40)
      expect(get_percentage_owned(p3, kk)).to eq(0)
      expect(get_percentage_owned(p4, kk)).to eq(20)
      expect(kk.president?(p2)).to be true

      expect(get_number_of_shares(game, p1)).to eq(17)
      expect(game.num_certs(p1)).to eq(14) # 3 president shares
      expect(get_number_of_shares(game, p2)).to eq(14)
      expect(game.num_certs(p2)).to eq(13) # 1 president share
      expect(get_number_of_shares(game, p3)).to eq(14)
      expect(game.num_certs(p3)).to eq(12) # 2 president shares
      expect(get_number_of_shares(game, p4)).to eq(13)
      expect(game.num_certs(p4)).to eq(12) # 1 president share
    end

    it 'Forced MR exchange when first 4 train is sold/exported' do
      start_action = 218 # Just before last action in OR 4.2
      game = fixture_at_action(start_action)
      expect_at(game, Engine::Game::G1824::Step::BuyTrain, [4, 2], game.corporation_by_id('MS'))

      p1 = game.players.find { |p| p.name == 'Player 1' }
      p2 = game.players.find { |p| p.name == 'Player 2' }
      p4 = game.players.find { |p| p.name == 'Player 4' }
      b1 = game.company_by_id('B1')
      expect(b1.owner).to eq(p2)
      expect(game.active_step.class).to eq(Engine::Game::G1824::Step::BuyTrain)

      # Player 4 passes, and 4 train is exported, which triggers a new phase
      game.process_to_action(start_action + 1)
      # Player 2 owns MR 1, and goes first in the forced MR exchange
      expect_at(game, Engine::Game::G1824::Step::ForcedMountainRailwayExchange, [5, 1], p2)

      # Perform MR exchange and check that player has received 10% in the regional
      ms = game.corporation_by_id('MS')
      action = Engine::Action::BuyShares.new(b1, shares: ms.available_share, percent: 10)
      game.process_action(action)
      expect(b1.owner).to eq(nil)
      expect(b1.closed?).to be true
      expect(get_percentage_owned(p2, game.corporation_by_id('MS'))).to eq(10)

      # Player 4 owns MR 2, and goes next in the forced MR exchange
      b2 = game.company_by_id('B2')
      expect(game.current_entity).to eq(p4)
      game.process_action(Engine::Action::BuyShares.new(b2, shares: ms.available_share, percent: 10))

      # Player 1 owns MR 3, and goes next in the forced MR exchange
      b3 = game.company_by_id('B3')
      expect(game.current_entity).to eq(p1)
      game.process_action(Engine::Action::BuyShares.new(b3, shares: ms.available_share, percent: 10))

      # Player 2 owns MR 4, and goes next in the forced MR exchange
      b4 = game.company_by_id('B4')
      expect(game.current_entity).to eq(p2)
      game.process_action(Engine::Action::BuyShares.new(b4, shares: ms.available_share, percent: 10))

      # MR 5 already exchanged.
      # Player 1 owns MR 6, and goes next in the forced MR exchange
      b6 = game.company_by_id('B6')
      expect(game.current_entity).to eq(p1)
      sb = game.corporation_by_id('SB')
      game.process_action(Engine::Action::BuyShares.new(b6, shares: sb.available_share, percent: 10))

      # After the forced MR exchange, the normal SR commences
      expect(game.current_entity).to eq(p1)
      expect(game.active_step.class).to eq(Engine::Game::G1824::Step::BuySellParExchangeShares)
    end

    it 'Verify #12275 - MR exchange wont float a regional, and parring is possible' do
      game = fixture_at_action(128) # Start of SR4
      share_price_100 = game.stock_market.par_prices.find { |par_price| par_price.price == 100 }

      bh = game.corporation_by_id('BH')
      p2 = game.players.find { |p| p.name == 'Player 2' }
      p3 = game.players.find { |p| p.name == 'Player 3' }
      p4 = game.players.find { |p| p.name == 'Player 4' }

      expect(game.active_step.class).to eq(Engine::Game::G1824::Step::BuySellParExchangeShares)
      game.process_action(Engine::Action::BuyShares.new(game.company_by_id('B4'), shares: bh.available_share, percent: 10))
      game.process_action(Engine::Action::Pass.new(p3))
      game.process_action(Engine::Action::BuyShares.new(game.company_by_id('B2'), shares: bh.available_share, percent: 10))
      game.process_action(Engine::Action::BuyShares.new(game.company_by_id('B6'), shares: bh.available_share, percent: 10))
      game.process_action(Engine::Action::BuyShares.new(game.company_by_id('B1'), shares: bh.available_share, percent: 10))
      game.process_action(Engine::Action::Pass.new(p3))
      game.process_action(Engine::Action::Pass.new(p4))

      # BH has exchanged 40%. Another exchange will not float it as still not parred
      expect(get_percentage_owned_by_players(game, bh)).to eq(40)
      game.process_action(Engine::Action::BuyShares.new(game.company_by_id('B3'), shares: bh.available_share, percent: 10))
      expect(bh.floated?).to be false
      expect(get_percentage_owned_by_players(game, bh)).to eq(50)

      # Parring it will now float BH
      expect(game.current_entity).to eq(p2)
      expect(p2.cash).to eq(205)
      game.process_action(Engine::Action::Par.new(p2, corporation: bh, share_price: share_price_100))
      expect(get_percentage_owned_by_players(game, bh)).to eq(70)
      expect(bh.floated?).to be true
      expect(bh.cash).to eq(10 * 100)
      expect(p2.cash).to eq(5)
    end
  end

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
  end

  describe 'verification_of_kk_formation' do
    it 'Verification of #12226 - formation where primary owner not president' do
      start_action = 533 # Just before last of OR 7.1
      game = fixture_at_action(start_action)
      expect_at(game, Engine::Game::G1824::Step::BuyTrain, [7, 1], game.corporation_by_id('BH'))

      kk = game.corporation_by_id('KK')
      kk1 = game.corporation_by_id('KK1')
      kk2 = game.corporation_by_id('KK2')
      pre_staatsbahns = [kk1, kk2]

      # Check cash and status before formation
      expect(kk.floated?).to be false
      pre_staatsbahns.each { |corp| expect(corp.closed?).to be false }
      expect(kk.cash).to eq(0)
      expect(kk1.cash).to eq(1)
      expect(kk2.cash).to eq(333)

      # Check tokens before formation
      vienna = 'E12'
      expect(get_token_owners_in_hex(game, vienna)).to eq([['SD'], %w[KK1 KK2 BK]])

      # Check trains before formation
      pre_staatsbahns.each { |corp| expect(corp.trains.map(&:name)).to be_empty }
      expect(kk.trains).to be_empty

      # Check shares before formation
      p1 = game.players.find { |p| p.name == 'Player 1' }
      p2 = game.players.find { |p| p.name == 'Player 2' }
      p3 = game.players.find { |p| p.name == 'Player 3' }
      p4 = game.players.find { |p| p.name == 'Player 4' }
      expect(get_percentage_owned(p1, kk)).to eq(30)
      expect(get_percentage_owned(p1, kk2)).to eq(100)
      expect(get_percentage_owned(p2, kk)).to eq(0)
      expect(get_percentage_owned(p3, kk)).to eq(0)
      expect(get_percentage_owned(p3, kk1)).to eq(100)
      expect(get_percentage_owned(p4, kk)).to eq(0)

      expect(get_number_of_shares(game, p1)).to eq(15)
      expect(game.num_certs(p1)).to eq(13) # 2 president shares (one is KK2)
      expect(get_number_of_shares(game, p2)).to eq(13)
      expect(game.num_certs(p2)).to eq(11) # 2 president shares
      expect(get_number_of_shares(game, p3)).to eq(14)
      expect(game.num_certs(p3)).to eq(11) # 3 president shares (one is KK1)
      expect(get_number_of_shares(game, p4)).to eq(14)
      expect(game.num_certs(p4)).to eq(12) # 2 president shares

      # Step forward one step, to OR 7.2, when KK should have formed
      game.process_to_action(start_action + 1)
      expect_at(game, Engine::Game::G1824::Step::Track, [7, 2], game.corporation_by_id('SB'))

      # Check cash and status after formation
      expect(kk.cash).to eq((7 * 120) + 1 + 333)
      pre_staatsbahns.each { |corp| expect(corp.cash).to eq(0) }
      expect(kk.floated?).to be true
      pre_staatsbahns.each { |corp| expect(corp.closed?).to be true }

      # Check tokens after formation
      expect(get_token_owners_in_hex(game, vienna)).to eq([['SD'], ['KK', nil, 'BK']])

      # Check trains after formation
      pre_staatsbahns.each { |corp| expect(corp.trains).to be_empty }
      expect(kk.trains.map(&:name)).to be_empty

      # Check shares after formation
      expect(get_percentage_owned_by_players(game, kk)).to eq(60)
      expect(get_percentage_owned(p1, kk)).to eq(40)
      expect(get_percentage_owned(p2, kk)).to eq(0)
      expect(get_percentage_owned(p3, kk)).to eq(20)
      expect(get_percentage_owned(p4, kk)).to eq(0)

      # KK presidency goes to p1 as most shares
      expect(kk.president?(p1)).to be true

      # p1 exchange 2 KK2 shares for 1 KK, but also becomes president, so cert number is still 2
      expect(get_number_of_shares(game, p1)).to eq(14)
      expect(game.num_certs(p1)).to eq(12) # 2 president shares

      expect(get_number_of_shares(game, p2)).to eq(13)
      expect(game.num_certs(p2)).to eq(11) # 2 president shares

      # p3 exchange 2 KK1 shares for 1 KK, but does not become president, so cert number increases by 1
      expect(get_number_of_shares(game, p3)).to eq(14)
      expect(game.num_certs(p3)).to eq(12) # 2 president shares

      expect(get_number_of_shares(game, p4)).to eq(14)
      expect(game.num_certs(p4)).to eq(12) # 2 president shares
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

  def get_percentage_owned_by_players(game, corporation)
    game.players.sum { |player| get_percentage_owned(player, corporation) }
  end

  def get_number_of_shares(game, player)
    player.shares.sum { |share| game.minor?(share.corporation) ? 2 : share.percent / 10 }
  end

  def expect_at(game, step_class, turn_round_num, entity)
    expect(game.active_step.class).to eq(step_class)
    expect(game.turn_round_num).to eq(turn_round_num)
    expect(game.current_entity).to eq(entity)
  end
end
