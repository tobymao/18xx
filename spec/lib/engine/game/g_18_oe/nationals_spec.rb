# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Nationals' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }

  describe 'Locomotive Works' do
    let(:major) { fund!(game, start_major!(game, 'LNWR', player), 500) }
    let(:train) { game.depot.upcoming.first }

    def advance_to_phase!(phase_name)
      game.phase.next! until game.phase.name == phase_name
    end

    def rust_with_four!
      advance_to_phase!('4')
      game.rust_trains!(game.depot.upcoming.find { |t| t.name == '4' }, major)
    end

    before do
      game.buy_train(major, train, :free)
      rust_with_four!
    end

    it 'keeps a rusted 2+2 in the Works' do
      expect(train.rusted).to be true
      expect(train.owner).to eq(game.depot)
      expect(major.trains).not_to include(train)
      expect(game.rusted_trains).to include(train)
    end

    it 'never offers a rusted train to a major or as the cheapest forced buy' do
      buyer = fund!(game, start_major!(game, 'GWR', player), 1000)
      step = round_step(enter_round!(game, game.operating_round(1)), Engine::Game::G18OE::Step::BuyTrain)

      expect(step.buyable_trains(buyer)).not_to include(train)
      expect(game.depot.min_depot_train.rusted).to be false
    end

    it 'records which owner each train rusted from' do
      expect(game.rusted_at_phase_change(major)).to eq([train])
      game.clear_rusted_at_phase_change!
      expect(game.rusted_at_phase_change(major)).to eq([])
    end

    it 'return_corporation_rusted_trains! gives the owner back its own rusted trains' do
      game.return_corporation_rusted_trains!(major)
      expect(major.trains).to include(train)
      expect(train.owner).to eq(major)
      expect(train.rusted).to be true
      expect(game.rusted_trains).not_to include(train)
    end

    it 'a rusted train held by a corporation does not rust again' do
      game.return_corporation_rusted_trains!(major)
      game.rust_trains!(game.depot.upcoming.find { |t| t.name == '4' }, major)
      expect(major.trains).to include(train)
      expect(train.owner).to eq(major)
    end
  end

  describe '#form_national!' do
    let(:major) { fund!(game, start_major!(game, 'LNWR', player), 500) }

    it 'pays the treasury cash to the bank' do
      major
      bank_cash = game.bank.cash
      cash = major.cash

      game.form_national!(major)

      expect(major.cash).to eq(0)
      expect(game.bank.cash).to eq(bank_cash + cash)
    end

    it 'moves treasury shares to the Open Market without moving the share price' do
      take_treasury_shares!(game, player, major, 1)
      game.share_pool.transfer_shares(major.treasury_shares.first.to_bundle, game.share_pool)
      price = major.share_price
      treasury = major.treasury_shares.size
      pooled = game.share_pool.shares_by_corporation[major].size
      player_shares = player.shares_by_corporation[major].dup

      game.form_national!(major)

      expect(major.treasury_shares).to be_empty
      expect(game.share_pool.shares_by_corporation[major].size).to eq(pooled + treasury)
      expect(game.share_pool.shares_by_corporation[major].size).to eq(7)
      expect(game.share_pool.percent_of(major)).to be > 50
      expect(major.share_price).to equal(price)
      expect(player.shares_by_corporation[major]).to eq(player_shares)
    end

    it 'moves its Pullman to the Open Market' do
      game.event_pullmans_available!
      pullman = game.depot.upcoming.find { |train| game.pullman?(train) }
      game.buy_train(major, pullman, :free)

      game.form_national!(major)

      expect(game.pullman(major)).to be_nil
      expect(game.depot.discarded).to include(pullman)
    end

    it 'removes all its tokens' do
      home = major.tokens.first.city
      open_city = lambda do |city|
        city != home && city.tokens.compact.empty? && city.available_slots.positive?
      end
      other = game.cities.find(&open_city)
      other.place_token(major, major.tokens.last, free: true)
      expect(major.placed_tokens.size).to eq(2)

      game.form_national!(major)

      expect(major.placed_tokens).to be_empty
      expect(major.tokens).to be_empty
      expect(home.tokens.compact.map(&:corporation)).not_to include(major)
      expect(other.tokens.compact.map(&:corporation)).not_to include(major)
    end

    it 'drops port authorities and the Orient Express marker' do
      sea = game.port_authority_seas.first
      game.buy_port_authority!(major, sea)
      game.place_orient_express_marker!(major)
      left = game.port_authorities_left(sea)

      game.form_national!(major)

      expect(game.port_authorities(major)).to be_empty
      expect(game.orient_express_marker?(major)).to be false
      expect(game.port_authorities_left(sea)).to eq(left)
    end

    it 'removes pass-through tokens placed for it' do
      shtc = give_company!(player, game.company_by_id('SHTC'))
      city = game.hexes.find { |hex| game.pass_through_hex?(shtc, hex) }.tile.cities.first
      game.place_pass_through_token!(shtc, major, city)

      game.form_national!(major)

      expect(city.extra_tokens).to be_empty
      expect(game.pass_through_token_lines(major)).to be_empty
      expect(shtc.owner).to eq(player)
    end

    it 'keeps its trains and the trains that just rusted' do
      game.phase.next! until game.phase.name == '4'
      two_plus_two = game.depot.upcoming.first
      three = game.depot.upcoming.find { |train| train.name == '3' }
      game.buy_train(major, two_plus_two, :free)
      game.buy_train(major, three, :free)
      game.rust_trains!(game.depot.upcoming.find { |train| train.name == '4' }, major)

      game.form_national!(major)

      expect(major.trains).to include(two_plus_two, three)
      expect(two_plus_two.rusted).to be true
    end

    it 'becomes a national at the same share price' do
      price = major.share_price

      game.form_national!(major)

      expect(major.type).to eq(:national)
      expect(game.national?(major)).to be true
      expect(major.share_price).to equal(price)
      expect(game.status_array(major)).to include(['National (UK)'])
      expect(major.name).to eq('LNWR')
    end

    it 'national_candidates lists only floated majors the player presides' do
      major
      other = game.players[1]
      start_regional!(game, 'GWR', player)

      expect(game.national_candidates(player)).to eq([major])
      expect(game.national_candidates(other)).to eq([])
    end
  end

  describe 'rusting trains held by a national' do
    let(:major) { fund!(game, start_major!(game, 'LNWR', player), 500) }

    def national_with!(name, phase)
      game.phase.next! until game.phase.name == phase
      train = game.depot.upcoming.find { |t| t.name == name }
      game.buy_train(major, train, :free)
      game.form_national!(major)
      train
    end

    it 'keeps a level 3 train, rusted, when Phase 6 rusts 3s' do
      three = national_with!('3', '4')
      game.phase.next! until game.phase.name == '6'
      game.rust_trains!(game.depot.upcoming.find { |t| t.name == '6' }, major)

      expect(three.rusted).to be true
      expect(major.trains).to include(three)
      expect(game.rusted_trains).not_to include(three)
      expect(game.rusted_at_phase_change(major)).to be_empty
    end

    it 'keeps a level 4 train, rusted, when Phase 8 rusts 4s' do
      four = national_with!('4', '6')
      game.phase.next! until game.phase.name == '8'
      game.rust_trains!(game.depot.upcoming.find { |t| t.name == '8+8' }, major)

      expect(four.rusted).to be true
      expect(major.trains).to include(four)
      expect(game.rusted_trains).not_to include(four)
    end
  end

  describe 'discarding a rusted train' do
    let(:major) { fund!(game, start_major!(game, 'LNWR', player), 500) }
    let(:train) { game.depot.upcoming.first }

    before do
      game.buy_train(major, train, :free)
      train.rusted = true
    end

    it 'sends it to the Locomotive Works, where majors cannot buy it' do
      round = enter_round!(game, game.operating_round(1))
      step = round_step(round, Engine::Step::DiscardTrain)

      step.process_discard_train(Engine::Action::DiscardTrain.new(major, train: train))

      expect(game.rusted_trains).to include(train)
      expect(major.trains).not_to include(train)
      expect(round_step(round, Engine::Game::G18OE::Step::BuyTrain).buyable_trains(major)).not_to include(train)
    end

    it 'sends a train declined during a merge to the Locomotive Works too' do
      round = stock_round!(game)
      round.merge_trains = { corporation: major, trains: [train] }
      step = round_step(round, Engine::Game::G18OE::Step::MergeDiscardTrain)

      step.process_discard_train(Engine::Action::DiscardTrain.new(major, train: train))

      expect(game.rusted_trains).to include(train)
    end
  end

  describe 'merged minors at national formation' do
    let(:major) { fund!(game, start_major!(game, 'LNWR', player), 500) }
    let(:k) { start_minor!(game, 'K', game.players[1], 'UK') }
    let(:g) { start_minor!(game, 'G', game.players[1], 'FR') }
    let(:k_train) { game.depot.upcoming.first }
    let(:g_train) { game.depot.upcoming[1] }
    let!(:g_ability) { g.abilities.first }

    before do
      game.buy_train(k, k_train, :free)
      game.buy_train(g, g_train, :free)
      [k, g].each do |minor|
        game.minor_regional_order.delete(minor)
        game.add_minor_charter!(minor, major)
        game.close_corporation(minor, quiet: true)
      end
    end

    it 'abandons each merged minor' do
      game.form_national!(major)

      expect(game.abandoned_minor?(k)).to be true
      expect(game.abandoned_minor?(g)).to be true
      expect(game.abandoned_minors).to include(k, g)
      expect(game.operating_order).not_to include(k, g)
      expect(game.corporations).to include(k, g)
      expect(k.presidents_share.owner).to eq(k)
      expect(k.presidents_share.buyable).to be false
      expect(game.players[1].shares_by_corporation[k]).to be_empty
    end

    it 'keeps the corporations in their original order' do
      order = game.corporations.map(&:id)

      game.form_national!(major)

      expect(game.corporations.map(&:id)).to eq(%w[A B C D E F G H J K L M] + (order - %w[A B C D E F G H J K L M]))
    end

    it 'returns the minor abilities and companies to the minor charter' do
      mail = game.company_by_id('MAIL')

      game.form_national!(major)

      expect(g.abilities).to include(g_ability)
      expect(major.abilities).not_to include(g_ability)
      expect(mail.owner).to eq(k)
      expect(k.companies).to include(mail)
      expect(major.companies).not_to include(mail)
    end

    it 'keeps the trains with the national' do
      game.form_national!(major)

      expect(major.trains).to include(k_train, g_train)
      expect(game.depot.discarded).not_to include(k_train, g_train)
    end

    it 'drops the merged minors track rights' do
      expect(game.track_rights_zones(major)).to include('FR')

      game.form_national!(major)

      expect(game.track_rights_zones(major)).to eq(['UK'])
      expect(game.merged_minors[major]).to be_empty
    end

    it 'a major can buy the abandoned minor afterwards' do
      game.form_national!(major)
      buyer = start_major!(game, 'GWR', game.players[2])
      buyer.spend(buyer.cash, game.bank) if buyer.cash.positive?
      game.bank.spend(300, buyer)
      round = enter_round!(game, game.operating_round(1))
      step = round_step(round, Engine::Game::G18OE::Step::IssueShares)
      round.instance_variable_set(:@current_operator, buyer)
      step.setup

      expect(step.can_buy_abandoned_minor?(buyer)).to be true
      step.process_choose(Engine::Action::Choose.new(buyer, choice: 'K'))

      expect(buyer.cash).to eq(300 - game.abandoned_minor_price)
      expect(game.merged_minors[buyer]).to include(k)
      expect(game.abandoned_minors).not_to include(k)
    end

    it 'abandons a minor again when the major that bought it forms a national' do
      game.form_national!(major)
      buyer = fund!(game, start_major!(game, 'GWR', game.players[2]), 500)
      game.add_minor_charter!(k, buyer)
      game.close_corporation(k, quiet: true)
      mail = game.company_by_id('MAIL')
      expect(mail.owner).to eq(buyer)

      game.form_national!(buyer)

      expect(game.abandoned_minor?(k)).to be true
      expect(mail.owner).to eq(k)
      expect(k.companies).to include(mail)
      expect(buyer.companies).not_to include(mail)
      expect(game.corporations.count(k)).to eq(1)
    end
  end

  describe 'a national' do
    let(:major) { fund!(game, start_major!(game, 'LNWR', player), 500) }
    let(:national) do
      game.phase.next! until game.phase.name == '4'
      game.buy_train(major, game.depot.upcoming.find { |train| train.name == '3' }, :free)
      game.form_national!(major)
      fund!(game, major, 500)
    end
    let(:minor) { start_minor!(game, 'K', game.players[1], 'UK') }

    def operate!(entity)
      round = enter_round!(game, game.operating_round(1))
      round.instance_variable_set(:@current_operator, entity)
      round.entities = [entity]
      round.setup
      round
    end

    it 'cannot issue or redeem shares' do
      expect(game.issuable_shares(national)).to be_empty
      expect(game.redeemable_shares(national)).to be_empty
    end

    it 'cannot buy a port authority' do
      sea = game.port_authority_seas.first

      expect(game.can_buy_port_authority?(national, sea)).to be false
    end

    it 'is not a merge target for a minor' do
      minor
      game.phase.next! until game.phase.available?('3')
      national

      expect(game.merge_candidates(game.players[1], minor)).not_to include(national)
      expect(game.merge_offer_majors(minor)).not_to include(national)
    end

    it 'never must buy a train' do
      national.trains.clear

      expect(Engine::Game::G18OE::Step::BuyTrain.new(game, [], round: operate!(national)).must_buy_train?(national)).to be false
    end

    it 'has no buy_train actions and is offered no trains' do
      round = operate!(national)
      step = round_step(round, Engine::Game::G18OE::Step::BuyTrain)

      expect(step.actions(national)).to be_empty
      expect(step.buyable_trains(national)).to be_empty
    end

    it 'never sells its trains to another railroad' do
      national
      buyer = fund!(game, start_major!(game, 'GWR', player), 1000)
      allow(game).to receive(:can_buy_train_from_others?).and_return(true)
      step = round_step(operate!(buyer), Engine::Game::G18OE::Step::BuyTrain)

      expect(step.buyable_trains(buyer).map(&:owner)).not_to include(national)
    end

    it 'has no token actions' do
      round = operate!(national)
      step = round_step(round, Engine::Game::G18OE::Step::Token)

      expect(step.actions(national)).to be_empty
      expect(step.available_tokens(national)).to be_empty
    end

    it 'takes a whole operating turn with no tokens, pays nothing and moves its share price left' do
      national.trains.clear
      game.national_formation_done!(game.national_formation_player) while game.national_formation_player
      price = national.share_price
      cash = national.cash

      round = nil
      expect { round = operate!(national) }.not_to raise_error
      act!(round, Engine::Action::Pass.new(national))

      expect(round).to be_finished
      expect(national.cash).to eq(cash)
      expect(national.placed_tokens).to be_empty
      expect(national.share_price.price).to be < price.price
      expect(national.share_price.coordinates.last).to be < price.coordinates.last
    end

    it 'takes a whole operating turn with trains, paying out its national revenue without a route step' do
      national
      game.national_formation_done!(game.national_formation_player) while game.national_formation_player
      game.stock_market.move(national, cell(game, 100).coordinates)
      cash = national.owner.cash

      round = nil
      expect { round = operate!(national) }.not_to raise_error
      act!(round, Engine::Action::Pass.new(national))

      messages = game.log.map(&:message)
      expect(round).to be_finished
      expect(messages.grep(/LNWR runs as a national/).size).to eq(1)
      expect(messages.grep(/skips run routes/i)).to be_empty
      expect(national.operating_history[[game.turn, 1]].dividend.kind).to eq('payout')
      expect(national.operating_history[[game.turn, 1]].revenue).to eq(game.national_revenue(national).total)
      expect(national.owner.cash).to be > cash
      expect(game.national_revenue(national).total).to be >= 100
      expect(national.share_price.price).to be > 100
    end

    it 'lays track only in its zone with 9 tile points' do
      expect(game.tile_point_budget(national)).to eq(9)
      expect(game.hex_within_national_region?(national, game.hex_by_id('J29'))).to be true
      expect(game.hex_within_national_region?(national, game.hex_by_id('Q30'))).to be false
    end
  end

  describe 'national operating round (§11.3.10)' do
    let(:national) do
      major = fund!(game, start_major!(game, 'LNWR', player), 500)
      game.form_national!(major)
      major
    end
    let(:round) do
      round = game.operating_round(1)
      round.entities = [national]
      round.instance_variable_set(:@current_operator, national)
      enter_round!(game, round)
    end

    before do
      train = game.trains.find { |t| t.name == '2+2' && !t.owner.is_a?(Engine::Corporation) }
      game.buy_train(national, train, :free)
    end

    it 'offers a national that owns trains no route actions' do
      expect(round_step(round, Engine::Game::G18OE::Step::Route).actions(national)).to eq([])
    end

    it 'skips the Route step without logging a skip' do
      round_step(round, Engine::Game::G18OE::Step::Route).skip!

      expect(game.log.map(&:message).grep(/skips run routes/i)).to be_empty
      expect(round.orient_express_revenue).to be_nil
    end
  end
end
