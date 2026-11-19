# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1833NE::Game do
  let(:players) { %w[alice bob carol dave] }
  let(:takeover_game) { described_class.new(players, seed: 1, optional_rules: [:takeover_game]) }
  let(:standard_game) { described_class.new(players, seed: 1) }

  describe 'Takeover Game setup' do
    it 'adds the five Variable Start railroads only in the Takeover Game' do
      expect(standard_game.corporations.size).to eq(9)
      expect(takeover_game.corporations.map(&:id).last(5)).to eq(%w[B&M LSL Era NYNH&H UP])
      expect(takeover_game.corporations.last(5).map(&:coordinates).uniq).to eq([nil])
      expect(takeover_game.corporations.map(&:type).tally).to eq(major: 9, variable_start: 5)
    end

    it 'reads the certificate limit from the number of corporations' do
      expect(standard_game.cert_limit).to eq(18)
      expect(takeover_game.cert_limit).to eq(26)
    end

    it 'adds two more Phase IV trains' do
      expect(standard_game.depot.trains.count { |t| t.name == '6/9' }).to eq(3)
      expect(takeover_game.depot.trains.count { |t| t.name == '6/9' }).to eq(5)
    end

    it 'uses the Takeover Game train limits' do
      limits = ->(game) { game.send(:game_phases).map { |phase| phase[:train_limit] } }

      expect(limits.call(standard_game)).to eq([3, 3, 3, 2, 2])
      expect(limits.call(takeover_game)).to eq([3, 3, 2, 1, 1])
    end

    it 'phases out the I trains in phase III and removes them in phase IV' do
      two_train = standard_game.depot.trains.first

      expect(two_train.obsolete_on).to eq('4/7')
      expect(two_train.rusts_on).to eq('6/9')
    end
  end

  describe 'Variable Start railroads' do
    let(:game) { takeover_game }
    let(:boston_maine) { game.corporation_by_id('B&M') }

    it 'is marked as a Variable Start Corp, with its phase until it is available' do
      expect(game.status_array(boston_maine)).to eq([['Variable Start Corp', 'bold'], ['Phase available: II']])
      expect(game.status_array(game.corporation_by_id('HR'))).to be_nil

      game.phase.next!

      expect(game.status_array(boston_maine)).to eq([['Variable Start Corp', 'bold']])
    end

    it 'has a free home token and one more for $80, like every corporation' do
      expect(game.corporations.map { |c| c.tokens.map(&:price) }.uniq).to eq([[0, 80]])
    end

    it 'chooses its home in the stock round' do
      expect(game.send(:stock_round).steps.map(&:class)).to include(Engine::Game::G1833NE::Step::HomeToken)
    end

    it 'cannot be launched in phase I' do
      expect(game.can_par?(boston_maine, game.players.first)).to be(false)

      game.phase.next!

      expect(game.can_par?(boston_maine, game.players.first)).to be(true)
    end

    it 'cannot be launched in the Standard game phases without takeovers' do
      standard_game.phase.next!

      expect(standard_game.takeovers_allowed?).to be(false)
    end

    def par!(corporation, price)
      game.par_corporation(corporation, game.stock_market.par_prices.find { |p| p.price == price })
    end

    it 'may start in open cities that are not reserved or another corporation’s home' do
      par!(boston_maine, 60)
      homes = game.home_token_locations(boston_maine).map(&:id)

      expect(homes).to include('C26', 'E22', 'H25', 'B3', 'F17')
      expect(homes).not_to include('F5', 'C24', 'C12', 'G22')
    end

    it 'needs a starting price of at least $60 for a home in a hex with track' do
      par!(boston_maine, 50)
      homes = game.home_token_locations(boston_maine).map(&:id)

      expect(homes).to include('C26', 'H25')
      expect(homes).not_to include('B3', 'F17')
    end

    it 'cannot start in an unlaunched corporation’s home once reservations are gone' do
      par!(boston_maine, 60)
      game.hexes.each { |hex| hex.tile.cities.each { |city| city.reservations.clear } }

      expect(game.home_token_locations(boston_maine).map(&:id)).not_to include('C12', 'C24')
      expect(game.variable_start_home?(boston_maine, game.hex_by_id('B3').tile.cities[1])).to be(false)
      expect(game.variable_start_home?(boston_maine, game.hex_by_id('B3').tile.cities[0])).to be(true)
    end

    [['C26', 80, 40], ['F17', 120, 0]].each do |hex_id, cost, left|
      it "pays #{cost} for a home in #{hex_id}" do
        game.phase.next!
        game.instance_variable_set(:@round, game.send(:new_stock_round))
        city = game.hex_by_id(hex_id).tile.cities.first
        par_price = game.stock_market.par_prices.find { |p| p.price == 60 }

        game.process_action(Engine::Action::Par.new(game.current_entity, corporation: boston_maine, share_price: par_price))
        game.process_action(Engine::Action::PlaceToken.new(boston_maine, city: city, slot: 0))

        expect(game.exception).to be_nil
        expect(city.tokened_by?(boston_maine)).to be(true)
        expect(boston_maine.cash).to eq(left)
      end
    end
  end

  describe 'takeovers' do
    let(:game) { takeover_game }
    let(:alice) { game.player_by_id('alice') }
    let(:bob) { game.player_by_id('bob') }
    let(:carol) { game.player_by_id('carol') }
    let(:hartford) { game.corporation_by_id('HR') }
    let(:boston_maine) { game.corporation_by_id('B&M') }

    def start!(corporation, player, price, hex_id)
      game.par_corporation(corporation, game.stock_market.par_prices.find { |p| p.price == price })
      game.share_pool.buy_shares(player, corporation.presidents_share.to_bundle, exchange: :free)
      city = game.hex_by_id(hex_id).tile.cities.first
      city.place_token(corporation, corporation.next_token, free: true, check_tokenable: false)
    end

    def give_cash(corporation, amount)
      corporation.spend(corporation.cash, game.bank) if corporation.cash.positive?
      game.bank.spend(amount, corporation) if amount.positive?
    end

    def give_train(corporation, obsolete: false)
      train = game.depot.upcoming.first
      game.buy_train(corporation, train, :free)
      train.obsolete = obsolete
      train
    end

    def lay_new_haven!
      tile = game.tiles.find { |t| t.name == '57' }
      game.hex_by_id('C26').lay(tile)
      game.graph.clear
    end

    def give_shares(player, corporation, count)
      shares = game.takeover_unissued_shares(corporation).take(count)
      game.share_pool.transfer_shares(Engine::ShareBundle.new(shares), player, allow_president_change: false)
    end

    def start_takeover_round!
      game.phase.next!
      game.instance_variable_set(:@round, game.send(:new_takeover_round))
      game.round.setup
    end

    def choose(entity, choice)
      game.process_action(Engine::Action::Choose.new(entity, choice: choice))
    end

    before do
      start!(hartford, alice, 100, 'C24')
      start!(boston_maine, bob, 60, 'C26')
      lay_new_haven!
      give_cash(hartford, 200)
      give_cash(boston_maine, 50)
      give_train(hartford)
    end

    it 'are only possible against connected corporations it can afford' do
      start_takeover_round!

      expect(game.takeover_candidates(hartford)).to eq([boston_maine])
      expect(game.takeover_candidates(boston_maine)).to eq([])
      expect(game.round.active_step).to be_a(Engine::Game::G1833NE::Step::TakeoverCorporation)
      expect(game.round.current_entity).to eq(hartford)
    end

    it 'are not possible against a corporation the acquirer has no track to' do
      game.hex_by_id('C26').lay(game.hex_by_id('C26').original_tile)
      game.graph.clear
      game.phase.next!

      expect(game.takeover_candidates(hartford)).to eq([])
    end

    it 'need a train that is not phased out' do
      hartford.trains.first.obsolete = true
      game.phase.next!

      expect(game.takeover_candidates(hartford)).to eq([])
    end

    it 'need enough cash and unissued shares to redeem every outstanding share' do
      give_cash(hartford, 0)
      game.phase.next!
      expect(game.takeover_candidates(hartford)).to eq([boston_maine])

      give_shares(carol, hartford, 6)
      expect(game.takeover_candidates(hartford)).to eq([boston_maine])

      give_shares(carol, hartford, 1)
      expect(game.takeover_candidates(hartford)).to eq([])
    end

    it 'are not held in phase I' do
      game.instance_variable_set(:@round, game.send(:new_takeover_round))
      game.round.setup

      expect(game.takeover_candidates(hartford)).to eq([])
      expect(game.round.finished?).to be(true)
    end

    it 'may be refused by the president of a target with a train' do
      give_train(boston_maine)
      start_takeover_round!

      game.process_action(Engine::Action::Merge.new(hartford, corporation: boston_maine))

      expect(game.round.active_step).to be_a(Engine::Game::G1833NE::Step::TakeoverConsent)
      expect(game.round.active_entities).to eq([bob])

      choose(bob, 'refuse')

      expect(boston_maine.closed?).to be(false)
      expect(hartford.cash).to eq(200)
      expect(game.round.current_entity).to eq(boston_maine)
    end

    it 'carry out the takeover when the target’s president accepts' do
      bm_train = give_train(boston_maine)
      start_takeover_round!
      unsold_phase_iv_trains = game.depot.upcoming.count { |t| t.name == '6/9' }

      game.process_action(Engine::Action::Merge.new(hartford, corporation: boston_maine))
      choose(bob, 'accept')
      choose(hartford, '0')

      expect(boston_maine.closed?).to be(true)
      expect(game.corporations).not_to include(boston_maine)
      expect(bob.cash).to eq(game.class::STARTING_CASH[4] + 120)
      expect(hartford.cash).to eq(200 - 120 + 50)
      expect(hartford.trains).to include(bm_train)
      expect(hartford.share_price.price).to eq(90)
      expect(game.hex_by_id('C26').tile.cities.first.tokened_by?(hartford)).to be(true)
      expect(game.train_limit(hartford)).to eq(4)
      expect(game.cert_limit).to eq(25)
      expect(game.depot.upcoming.count { |t| t.name == '6/9' }).to eq(unsold_phase_iv_trains - 1)
    end

    it 'need no consent from a vulnerable target' do
      give_train(boston_maine, obsolete: true)
      start_takeover_round!

      game.process_action(Engine::Action::Merge.new(hartford, corporation: boston_maine))
      choose(hartford, '0')

      expect(boston_maine.closed?).to be(true)
    end

    it 'need no consent when one player is president of both' do
      give_train(boston_maine)
      game.share_pool.transfer_shares(boston_maine.presidents_share.to_bundle, alice)
      start_takeover_round!

      game.process_action(Engine::Action::Merge.new(hartford, corporation: boston_maine))
      choose(hartford, '0')

      expect(boston_maine.closed?).to be(true)
    end

    it 'let the acquirer choose how many shares each holder takes instead of cash' do
      give_cash(hartford, 60)
      start_takeover_round!

      game.process_action(Engine::Action::Merge.new(hartford, corporation: boston_maine))

      expect(game.round.active_step.choices.keys).to eq(%w[1 2])

      choose(hartford, '2')

      expect(bob.num_shares_of(hartford)).to eq(2)
      expect(hartford.cash).to eq(60 + 50)
      expect(hartford.owner).to eq(alice)
    end

    it 'swap no more shares than needed when only one choice is legal' do
      give_cash(hartford, 0)
      start_takeover_round!

      game.process_action(Engine::Action::Merge.new(hartford, corporation: boston_maine))

      expect(boston_maine.closed?).to be(true)
      expect(bob.num_shares_of(hartford)).to eq(2)
    end

    it 'can change the acquirer’s president' do
      give_shares(bob, hartford, 1)
      give_cash(hartford, 0)
      start_takeover_round!

      game.process_action(Engine::Action::Merge.new(hartford, corporation: boston_maine))

      expect(hartford.owner).to eq(bob)
      expect(bob.percent_of(hartford)).to eq(30)
      expect(alice.percent_of(hartford)).to eq(20)
      expect(hartford.presidents_share.owner).to eq(bob)
    end

    it 'never leave a player with more than 60% of the acquirer' do
      give_shares(bob, hartford, 5)
      game.phase.next!

      expect(game.takeover_swap_capacity(hartford, bob)).to eq(1)
    end

    it 'replace the target’s tokens even when the acquirer has placed both of its own' do
      game.hex_by_id('E22').tile.cities.first.place_token(hartford, hartford.next_token, free: true, check_tokenable: false)
      start_takeover_round!

      game.process_action(Engine::Action::Merge.new(hartford, corporation: boston_maine))
      choose(hartford, '0')

      expect(game.hex_by_id('C26').tile.cities.first.tokened_by?(hartford)).to be(true)
      expect(hartford.placed_tokens.size).to eq(3)
    end

    it 'discard a duplicate token in a city both corporations share' do
      start!(game.corporation_by_id('UP'), carol, 50, 'E22')
      city = game.hex_by_id('C26').tile.cities.first
      city.place_token(hartford, hartford.next_token, free: true, check_tokenable: false, extra_slot: true)
      start_takeover_round!

      game.process_action(Engine::Action::Merge.new(hartford, corporation: boston_maine))
      choose(hartford, '0')

      expect(city.tokens.compact.map(&:corporation)).to eq([])
      expect(city.extra_tokens.map(&:corporation)).to eq([hartford])
    end

    it 'move on to the stock round after the takeover round' do
      start_takeover_round!
      turn = game.turn

      game.process_action(Engine::Action::Pass.new(hartford))

      expect(game.round).to be_a(Engine::Round::Stock)
      expect(game.turn).to eq(turn + 1)
    end

    it 'follow the second operating round from phase II' do
      game.phase.next!
      game.instance_variable_set(:@operating_rounds, 2)
      game.instance_variable_set(:@round, game.send(:operating_round, 2))
      game.send(:next_round!)

      expect(game.round).to be_a(Engine::Game::G1833NE::Round::Takeover)
    end

    it 'end at once when no corporation has floated' do
      empty_game = described_class.new(players, seed: 1, optional_rules: [:takeover_game])
      empty_game.phase.next!
      empty_game.instance_variable_set(:@round, empty_game.send(:new_takeover_round))
      empty_game.round.setup

      expect(empty_game.round.finished?).to be(true)
    end

    it 'are skipped in the Standard game' do
      standard_game.phase.next!
      standard_game.instance_variable_set(:@operating_rounds, 2)
      standard_game.instance_variable_set(:@round, standard_game.send(:operating_round, 2))
      standard_game.send(:next_round!)

      expect(standard_game.round).to be_a(Engine::Round::Stock)
    end
  end
end
