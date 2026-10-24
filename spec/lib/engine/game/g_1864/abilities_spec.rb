# frozen_string_literal: true

require 'spec_helper'

describe 'G1864 minor abilities' do
  let(:game) { Engine::Game::G1864::Game.new(%w[alice bob carol], seed: 1) }

  it 'has 16 ability cards with the printed distribution' do
    counts = Engine::Game::G1864::Entities::COMPANIES.map { |c| c[:name] }.tally

    expect(counts).to eq(
      'Corporate Lobbyists' => 2,
      'U.S. Government Subsidy' => 2,
      'Track Builder' => 2,
      'Local Contract' => 2,
      'Angel Investors' => 2,
      'Union Station' => 1,
      'Central Station' => 1,
      'Early Adopter' => 1,
      'Civil Engineering Firm' => 1,
      'Double Tracks' => 1,
      'Pullman Car' => 1
    )
  end

  it 'deals exactly one card to each of the 16 minors' do
    minors = (game.corporations + game.future_corporations).select { |c| c.type == :minor }
    dealt = game.minor_ability_legend('black')[2..].map { |row| row[0][:text] }

    expect(minors.size).to eq(16)
    expect(dealt).to match_array(minors.map(&:id))
  end

  describe 'starting abilities' do
    it 'reserves a 2-train for the Early Adopter minor at setup, out of the depot' do
      minor = game.companies.find { |c| c.name == 'Early Adopter' }.owner

      expect(minor.trains.map(&:name)).to eq(['2'])
      expect(minor.trains.first.buyable).to be(false)
      expect(game.depot.upcoming.count { |t| t.name == '2' }).to eq(9)
    end

    it 'charges the Early Adopter minor $100 when it starts, makes the train tradeable, and closes the card' do
      card = game.company_by_id('EA1')
      minor = card.owner
      game.bank.spend(200, minor)

      game.activate_minor_power!(minor)

      expect(minor.cash).to eq(100)
      expect(minor.trains.first.buyable).to be(true)
      expect(card.closed?).to be(true)
      expect(game.minor_ability_legend('black')[2..].find { |r| r[0][:text] == minor.id }[2][:text]).to eq('Early Adopter')
    end

    it 'gives the Angel Investors minor $60 when it starts and closes the card' do
      card = game.companies.find { |c| c.name == 'Angel Investors' }
      minor = card.owner
      game.bank.spend(200, minor)

      game.activate_minor_power!(minor)

      expect(minor.cash).to eq(260)
      expect(card.closed?).to be(true)
      expect(game.minor_ability_legend('black')[2..].find { |r| r[0][:text] == minor.id }[2][:text]).to eq('Angel Investors')
    end

    it 'pays the Government Subsidy to started minors only, at the start of each OR' do
      started = game.company_by_id('GS1').owner
      unstarted = game.company_by_id('GS2').owner
      started.floated = true

      game.payout_companies

      expect(started.cash).to eq(20)
      expect(unstarted.cash).to eq(0)
    end
  end

  it 'deals Early Adopter to a minor that is available from the start' do
    holder = game.companies.find { |c| c.name == 'Early Adopter' }.owner

    expect(Engine::Game::G1864::Game::GREEN_CORPORATIONS).not_to include(holder.id)
  end

  it 'gives Corporate Lobbyists +1 train limit' do
    minor = game.companies.find { |c| c.name == 'Corporate Lobbyists' }.owner

    expect(game.train_limit(minor)).to eq(game.phase.train_limit(minor) + 1)
  end

  describe 'cost abilities' do
    let!(:round) { game.operating_round(1) }
    let(:step) { round.steps.find { |st| st.is_a?(Engine::Game::G1864::Step::Track) } }
    let(:yellow) { game.tiles.find { |t| t.color == :yellow } }
    let(:green) { game.tiles.find { |t| t.color == :green } }

    it 'reports the additional tile lay as free for Track Builder' do
      minor = game.companies.find { |c| c.name == 'Track Builder' }.owner
      other = game.companies.find { |c| c.name != 'Track Builder' }.owner

      expect(step.extra_lay_cost(minor, 20)).to eq(0)
      expect(step.extra_lay_cost(other, 20)).to eq(20)
    end

    it 'makes the additional lay free for Track Builder when it is paired with an upgrade' do
      minor = game.companies.find { |c| c.name == 'Track Builder' }.owner
      round.upgraded_track = true

      expect(step.extra_lay_cost(minor, 20)).to eq(0)
    end

    it 'lets Track Builder make the additional lay without $20 or a loan available' do
      minor = game.companies.find { |c| c.name == 'Track Builder' }.owner
      other = game.companies.find { |c| c.name != 'Track Builder' }.owner
      [minor, other].each { |corp| game.maximum_loans(corp).times { corp.loans << game.loans.pop } }
      round.num_laid_track = 1

      expect(minor.cash).to be < 20
      expect(other.cash).to be < 20
      expect(step.can_lay_tile?(minor)).to be(true)
      expect(step.can_lay_tile?(other)).to be(false)
    end

    it 'reports terrain as free for Civil Engineering Firm' do
      minor = game.companies.find { |c| c.name == 'Civil Engineering Firm' }.owner
      other = game.companies.find { |c| c.name != 'Civil Engineering Firm' }.owner

      expect(step.terrain_cost(minor, 40)).to eq(0)
      expect(step.terrain_cost(other, 40)).to eq(40)
    end

    it 'makes the extra yellow lay free for Track Builder, with the Bank funding Credit Mobilier instead' do
      minor = game.companies.find { |c| c.name == 'Track Builder' }.owner
      game.bank.spend(100, minor)

      minor_cash_before = minor.cash
      bank_cash_before = game.bank.cash
      cm_cash_before = game.credit_mobilier.cash

      hex = game.hex_by_id(minor.coordinates)
      step.pay_tile_cost!([minor], yellow, 0, hex, minor, 20, 20)

      expect(minor.cash).to eq(minor_cash_before)
      expect(game.bank.cash).to eq(bank_cash_before - 20)
      expect(game.credit_mobilier.cash).to eq(cm_cash_before + 20)
    end

    it 'makes terrain free for Civil Engineering Firm, with the Bank funding Credit Mobilier instead' do
      minor = game.companies.find { |c| c.name == 'Civil Engineering Firm' }.owner
      game.bank.spend(100, minor)

      minor_cash_before = minor.cash
      bank_cash_before = game.bank.cash
      cm_cash_before = game.credit_mobilier.cash

      hex = game.hex_by_id(minor.coordinates)
      step.instance_variable_set(:@terrain_cost, 30)
      step.pay_tile_cost!([minor], hex.tile, 0, hex, minor, 30, 0)

      expect(minor.cash).to eq(minor_cash_before)
      expect(game.bank.cash).to eq(bank_cash_before - 30)
      expect(game.credit_mobilier.cash).to eq(cm_cash_before + 30)
    end

    it 'still charges a corporation without either ability the full cost' do
      ce_holder = game.companies.find { |c| c.name == 'Civil Engineering Firm' }.owner
      plain = game.corporations.find { |c| c != ce_holder && c.type == :minor }
      game.bank.spend(100, plain)

      minor_cash_before = plain.cash
      bank_cash_before = game.bank.cash
      cm_cash_before = game.credit_mobilier.cash

      hex = game.hex_by_id(plain.coordinates)
      step.pay_tile_cost!([plain], hex.tile, 0, hex, plain, 40, 0)

      expect(plain.cash).to eq(minor_cash_before - 40)
      expect(game.bank.cash).to eq(bank_cash_before)
      expect(game.credit_mobilier.cash).to eq(cm_cash_before + 40)
    end
  end

  describe 'Union Station and Central Station' do
    let(:company) { game.companies.find { |c| c.name == 'Union Station' } }
    let(:minor) { company.owner }
    let(:home_hex) { game.hex_by_id(minor.coordinates) }
    let(:target_hex) do
      game.hexes.find do |h|
        city = h.tile.cities.first
        h != home_hex && city && city.tokens.none? && city.reservations.compact.empty?
      end
    end
    let(:step) { Engine::Game::G1864::Step::SpecialToken.new(game, []) }

    before do
      allow(game).to receive(:ability_right_time?).and_return(true)
      game.place_home_token(minor)
    end

    it 'does not add a token until the extra station is placed' do
      expect(minor.tokens.size).to eq(1)
      expect(game.abilities(company, :token)).not_to be_nil
    end

    it 'prices the extra station at $10 per hex from the nearest placed station' do
      ability = game.abilities(company, :token)
      token, = step.adjust_token_price_ability!(minor, step.available_tokens(company).first, target_hex,
                                                target_hex.tile.cities.first, special_ability: ability)

      expect(token.price).to eq(10 * home_hex.distance(target_hex))
    end

    def place_extra_station(holder, city)
      extra = Engine::Token.new(holder, price: 10)
      holder.tokens << extra
      city.place_token(holder, extra, check_tokenable: false)
      game.record_extra_station!(company, extra)
    end

    it 'removes the placed extra station at phase 6' do
      city = target_hex.tile.cities.first
      place_extra_station(minor, city)

      game.event_remove_minor_abilities!

      expect(city.tokened_by?(minor)).to be(false)
      expect(minor.tokens.size).to eq(1)
      expect(home_hex.tile.cities.any? { |c| c.tokened_by?(minor) }).to be(true)
    end

    describe 'at a merger or conversion' do
      let(:city) { target_hex.tile.cities.first }
      let(:major) { game.future_corporations.find { |c| c.type == :major } }
      let(:merge_step) { Engine::Game::G1864::Step::Merge.new(game, game.round) }

      before do
        place_extra_station(minor, city)
        merge_step.instance_variable_set(:@converting, minor)
        allow(merge_step).to receive(:current_entity).and_return(minor)
      end

      def convert(choice)
        merge_step.process_choose(Engine::Action::Choose.new(minor, choice: choice))
        merge_step.move_tokens(minor, major)
        game.transfer(:companies, minor, major)
        game.attach_extra_stations!(major)
      end

      it 'asks the player whether to replace the extra station before choosing the major' do
        expect(merge_step.actions(minor)).to eq(%w[choose])
        expect(merge_step.choices).to eq(
          'replace' => 'Replace Union Station with a regular station',
          'keep' => 'Keep as the Union Station (removed at Phase 6)',
        )
      end

      it 'asks nothing once the choice is made' do
        merge_step.process_choose(Engine::Action::Choose.new(minor, choice: 'keep'))

        expect(merge_step.undecided_extra_station).to be_nil
      end

      it 'makes a replaced station a regular station that survives phase 6' do
        convert('replace')
        game.event_remove_minor_abilities!

        expect(company.closed?).to be(true)
        expect(city.tokened_by?(major)).to be(true)
        expect(major.tokens.select(&:used).map(&:city)).to include(city)
      end

      it "adds a kept station to the major's tokens without using a charter token, then removes it at phase 6" do
        charter_size = major.tokens.size
        convert('keep')

        expect(city.tokened_by?(major)).to be(true)
        expect(major.tokens.select(&:used).map(&:city)).to include(city)
        expect(major.tokens.size).to eq(charter_size + 1)

        game.event_remove_minor_abilities!

        expect(city.tokened_by?(major)).to be(false)
        expect(major.tokens.size).to eq(charter_size)
      end

      it 'hands a kept station to the UP when the major is regionalized' do
        convert('keep')
        game.par_corporation(major, game.stock_market.market.flatten.compact.find { |sp| sp.price == 100 })
        major.ipoed = true
        major.floated = true
        game.corporations << major

        game.nationalize!(major)

        expect(city.tokened_by?(game.union_pacific)).to be(true)
      end
    end

    describe 'in a merger holding both extra stations' do
      let(:central) { game.companies.find { |c| c.name == 'Central Station' } }
      let(:other_minor) { central.owner }
      let(:open_cities) do
        game.hexes.filter_map do |h|
          city = h.tile.cities.first
          city if h != home_hex && city && city.tokens.none? && city.reservations.compact.empty?
        end
      end
      let(:union_city) { open_cities[0] }
      let(:central_city) { open_cities[1] }
      let(:major) { game.future_corporations.find { |c| c.type == :major } }
      let(:merge_step) { Engine::Game::G1864::Step::Merge.new(game, game.round) }

      before do
        game.place_home_token(other_minor)
        place_extra_station(minor, union_city)
        extra = Engine::Token.new(other_minor, price: 10)
        other_minor.tokens << extra
        central_city.place_token(other_minor, extra, check_tokenable: false)
        game.record_extra_station!(central, extra)
        merge_step.instance_variable_set(:@merge_major, true)
        merge_step.instance_variable_set(:@merging, [minor, other_minor])
        allow(merge_step).to receive(:current_entity).and_return(minor)
      end

      def choose(choice)
        merge_step.process_choose(Engine::Action::Choose.new(minor, choice: choice))
      end

      it 'prompts once for each station, then applies each choice' do
        expect(merge_step.actions(minor)).to eq(%w[choose])
        expect(merge_step.choice_name).to start_with('Union Station in ')
        choose('replace')

        expect(merge_step.actions(minor)).to eq(%w[choose])
        expect(merge_step.choice_name).to start_with('Central Station in ')
        expect(merge_step.choices).to eq(
          'replace' => 'Replace Central Station with a regular station',
          'keep' => 'Keep as the Central Station (removed at Phase 6)',
        )
        choose('keep')

        expect(merge_step.undecided_extra_station).to be_nil

        merge_step.move_tokens(minor, major)
        merge_step.move_tokens(other_minor, major)
        game.transfer(:companies, minor, major)
        game.transfer(:companies, other_minor, major)

        expect(major.tokens.select(&:used).map(&:city)).to include(union_city)
        expect(major.tokens.select(&:used).map(&:city)).not_to include(central_city)
        expect(central_city.tokened_by?(major)).to be(true)

        game.attach_extra_stations!(major)

        expect(major.tokens.select(&:used).map(&:city)).to include(union_city, central_city)

        game.event_remove_minor_abilities!

        expect(union_city.tokened_by?(major)).to be(true)
        expect(central_city.tokened_by?(major)).to be(false)
      end
    end

    describe 'kept through a merger' do
      let(:central) { game.companies.find { |c| c.name == 'Central Station' } }
      let(:other_minor) { central.owner }
      let(:open_cities) do
        game.hexes.filter_map do |h|
          city = h.tile.cities.first
          city if h != home_hex && city && city.tokens.none? && city.reservations.compact.empty?
        end
      end
      let(:major) { game.future_corporations.find { |c| c.type == :major } }
      let(:merge_step) { Engine::Game::G1864::Step::Merge.new(game, game.round) }

      before do
        game.place_home_token(other_minor)
        place_extra_station(minor, open_cities[0])
        extra = Engine::Token.new(other_minor, price: 10)
        other_minor.tokens << extra
        open_cities[1].place_token(other_minor, extra, check_tokenable: false)
        game.record_extra_station!(central, extra)
        merge_step.instance_variable_set(:@merge_major, true)
        merge_step.instance_variable_set(:@merging, [minor, other_minor])
        allow(merge_step).to receive(:current_entity).and_return(minor)
        2.times { merge_step.process_choose(Engine::Action::Choose.new(minor, choice: 'keep')) }
        merge_step.move_tokens(minor, major)
        merge_step.move_tokens(other_minor, major)
      end

      it 'does not count toward the merger station limit' do
        expect(merge_step.tokens_above_limits?(major, [minor, other_minor])).to be(false)
      end

      it 'cannot be removed in the station-removal step' do
        city = open_cities[1]
        reduce_step = Engine::Game::G1864::Step::ReduceTokens.new(game, game.round)
        action = Engine::Action::RemoveToken.new(major, city: city, slot: city.tokens.index { |t| t&.corporation == major })

        expect { reduce_step.process_remove_token(action) }.to raise_error(Engine::GameError, /not part of the merger/)
      end
    end

    it 'is replaced by a UP station when its holder is regionalized' do
      holder = game.corporation_by_id('O&NW')
      company.owner.companies.delete(company)
      company.owner = holder
      holder.companies << company
      game.par_corporation(holder, game.stock_market.market.first[5])
      game.share_pool.buy_shares(game.players.first, holder.shares.first.to_bundle, exchange: :free)
      game.place_home_token(holder)
      city = target_hex.tile.cities.first
      place_extra_station(holder, city)

      game.nationalize!(holder)

      expect(company.closed?).to be(true)
      expect(city.tokened_by?(game.union_pacific)).to be(true)
    end
  end

  describe 'Double Tracks' do
    let(:holder) { game.companies.find { |c| c.name == 'Double Tracks' }.owner }
    let(:other) { game.companies.find { |c| c.name != 'Double Tracks' }.owner }
    let(:shared_path) { game.hex_by_id(holder.coordinates).tile.paths.first }
    let(:separate_path) { game.hexes.find { |h| h.id != holder.coordinates && h.tile.paths.any? }.tile.paths.first }

    def route(corporation, path)
      instance_double(Engine::Route, corporation: corporation, paths: [path])
    end

    it 'lets two of its trains reuse the same track' do
      expect { game.check_overlap([route(holder, shared_path), route(holder, shared_path)]) }.not_to raise_error
    end

    it 'lets two trains share track alongside a third train on its own track' do
      routes = [route(holder, shared_path), route(holder, shared_path), route(holder, separate_path)]

      expect { game.check_overlap(routes) }.not_to raise_error
    end

    it 'does not let a third train share the track as well' do
      routes = Array.new(3) { route(holder, shared_path) }

      expect { game.check_overlap(routes) }.to raise_error(Engine::GameError, /Only two trains/)
    end

    it 'still forbids a plain corporation from reusing track across two trains' do
      path = game.hex_by_id(other.coordinates).tile.paths.first

      expect { game.check_overlap([route(other, path), route(other, path)]) }
        .to raise_error(Engine::GameError, /reuse track/)
    end
  end

  describe 'Pullman Car' do
    let(:pullman) { game.company_by_id('PC1') }
    let(:holder) { (game.corporations + game.future_corporations).find { |c| c.trains.any? { |t| game.pullman?(t) } } }
    let(:pullman_train) { holder.trains.find { |t| game.pullman?(t) } }
    let(:other) { game.corporations.find { |c| c != holder && c.type == :minor } }
    let(:route_step) { Engine::Game::G1864::Step::Route.new(game, []) }

    def give_trains(corporation, count)
      game.depot.upcoming.first(count).each { |train| game.buy_train(corporation, train, :free) }
      corporation.trains.reject { |t| game.pullman?(t) }
    end

    def buy_step_for(entity)
      round = game.operating_round(1)
      step = round.steps.find { |st| st.is_a?(Engine::Game::G1864::Step::BuyTrain) }
      allow(round).to receive(:current_operator).and_return(entity)
      allow(step).to receive(:current_entity).and_return(entity)
      step
    end

    it 'gives the dealt minor the Pullman train, which cannot be sold until the minor starts' do
      expect(pullman_train).not_to be_nil
      expect(game.depot.upcoming).not_to include(pullman_train)
      expect(pullman_train.buyable).to be(false)

      game.activate_minor_power!(holder)

      expect(pullman_train.buyable).to be(true)
    end

    it 'does not run, count toward the train limit, or stop its holder being trainless' do
      expect(game.route_trains(holder)).not_to include(pullman_train)
      expect(game.num_corp_trains(holder)).to eq(0)
      expect(game.trainless?(holder)).to be(true)
      expect(game.must_buy_train?(holder)).to be(true)
    end

    it 'lets the holder attach it to one train, which becomes a P train until it runs' do
      trains = give_trains(holder, 2)

      expect(route_step.choosing_pullman?(holder)).to be(true)
      expect(route_step.pullman_train_choices(holder)).to eq(trains)

      route_step.process_choose(Engine::Action::Choose.new(holder, choice: trains.last.id))

      expect(trains.map(&:name)).to eq(%w[2 2P])
      expect(route_step.choosing_pullman?(holder)).to be(false)

      route_step.detach_pullman

      expect(trains.map(&:name)).to eq(%w[2 2])
    end

    describe 'route revenue' do
      let(:train) { give_trains(holder, 1).first }
      let(:boise) { game.hex_by_id('D11') }
      let(:salt_lake) { game.hex_by_id('G14') }
      let(:towns) { %w[D13 D15 I8].map { |id| game.hex_by_id(id) } }

      before do
        boise.tile.cities.last.place_token(holder, holder.next_token, check_tokenable: false)
      end

      def route_through(hexes)
        stops = hexes.flat_map { |hex| hex.tile.stops.last(1) }
        instance_double(Engine::Route, corporation: holder, phase: game.phase, train: train,
                                       hexes: hexes, visited_stops: stops)
      end

      def revenue(route)
        game.revenue_for(route, game.compute_stops(route))
      end

      describe 'of the train it is attached to' do
        before do
          route_step.process_choose(Engine::Action::Choose.new(holder, choice: train.id))
        end

        it 'adds two towns to a route that fills the train with cities' do
          expect(revenue(route_through([boise, salt_lake] + towns.first(2)))).to eq(40 + 40 + 10 + 10)
        end

        it 'adds two towns beyond those the train counts as stops' do
          expect(revenue(route_through([boise] + towns))).to eq(40 + 10 + 10 + 10)
        end

        it 'stops adding towns once it runs' do
          route_step.detach_pullman

          expect(revenue(route_through([boise, salt_lake] + towns.first(2)))).to eq(40 + 40)
        end
      end

      describe 'of a train it was never attached to' do
        it 'skips towns when cities fill the train' do
          expect(revenue(route_through([boise, salt_lake] + towns.first(2)))).to eq(40 + 40)
        end

        it 'counts a town as one of its stops' do
          expect(revenue(route_through([boise, towns.first]))).to eq(40 + 10)
        end
      end
    end

    it 'offers no Pullman choice to a corporation without the Pullman' do
      give_trains(other, 1)

      expect(route_step.choosing_pullman?(other)).to be(false)
    end

    it 'may be bought by another corporation for as little as $1 in the buy train step' do
      game.activate_minor_power!(holder)
      give_trains(other, 1)
      game.bank.spend(10, other)
      holder_cash = holder.cash
      step = buy_step_for(other)

      expect(step.buyable_trains(other)).to include(pullman_train)
      step.process_buy_train(Engine::Action::BuyTrain.new(other, train: pullman_train, price: 1))

      expect(pullman_train.owner).to eq(other)
      expect(holder.trains).not_to include(pullman_train)
      expect(holder.cash).to eq(holder_cash + 1)
    end

    it 'can be bought at the train limit, when no other train can' do
      game.activate_minor_power!(holder)
      give_trains(other, game.train_limit(other))
      game.bank.spend(10, other)
      step = buy_step_for(other)

      expect(step.room?(other)).to be(true)
      expect(step.buyable_trains(other)).to eq([pullman_train])
      expect { step.process_buy_train(Engine::Action::BuyTrain.new(other, train: game.depot.upcoming.first, price: 80)) }
        .to raise_error(Engine::GameError, /no room/)
    end

    it 'may be bought by a company that must buy a train, using only its treasury cash' do
      game.activate_minor_power!(holder)
      game.bank.spend(10, other)
      step = buy_step_for(other)

      expect(step.buyable_trains(other)).to include(pullman_train)
      expect(step.spend_minmax(other, pullman_train)).to eq([1, other.cash])
      expect { step.process_buy_train(Engine::Action::BuyTrain.new(other, train: pullman_train, price: other.cash + 1)) }
        .to raise_error(Engine::GameError)

      step.process_buy_train(Engine::Action::BuyTrain.new(other, train: pullman_train, price: 5))

      expect(pullman_train.owner).to eq(other)
      expect(other.loans).to be_empty
      expect(game.must_buy_train?(other)).to be(true)
    end

    it 'is not offered to a company with no treasury cash' do
      game.activate_minor_power!(holder)
      step = buy_step_for(other)

      expect(other.cash).to eq(0)
      expect(step.buyable_trains(other)).not_to include(pullman_train)
    end

    it 'closes the Pullman Car card when its minor starts, keeping it in the ability table' do
      expect(pullman.closed?).to be(false)

      game.activate_minor_power!(holder)
      row = game.minor_ability_legend('black')[2..].find { |r| r[0][:text] == holder.id }

      expect(pullman.closed?).to be(true)
      expect(holder.trains.map(&:name)).to include('Pullman')
      expect(row[2][:text]).to eq('Pullman Car')
    end

    describe 'held alone by an operating minor' do
      before do
        game.par_corporation(holder, game.stock_market.market.first[5])
        game.share_pool.buy_shares(game.players.first, holder.shares.first.to_bundle, exchange: :free)
        game.place_home_token(holder)
        game.corporations << holder unless game.corporations.include?(holder)
        holder.operating_history[[1, 1]] = :operated
      end

      it 'must buy a train when it can afford one' do
        game.bank.spend(500, holder)

        expect(buy_step_for(holder).actions(holder)).to eq(%w[buy_train])
      end

      it 'is regionalized when it passes the buy train step' do
        step = buy_step_for(holder)

        expect(step.actions(holder)).to be_empty

        step.pass!

        expect(holder.closed?).to be(true)
        expect(game.corporations).not_to include(holder)
      end

      it 'is regionalized by trainless regionalization' do
        game.event_trainless_regionalization!
        game.send(:postevent_trainless_nationalization!)

        expect(holder.closed?).to be(true)
        expect(game.corporations).not_to include(holder)
      end
    end

    it 'is never offered for discard' do
      give_trains(holder, 1)
      step = Engine::Game::G1864::Step::DiscardTrain.new(game, [])

      expect(step.trains(holder)).not_to include(pullman_train)
    end
  end

  describe 'Local Contract' do
    let(:company) { game.companies.find { |c| c.name == 'Local Contract' } }
    let(:corporation) { company.owner }
    let(:home_hex) { game.hex_by_id(corporation.coordinates) }
    let(:home_city) { home_hex.tile.cities.find { |c| c.tokened_by?(corporation) } }
    let(:other_hex) { game.hexes.find { |h| h != home_hex && h.tile.cities.any? } }
    let(:step) { Engine::Game::G1864::Step::Assign.new(game, []) }

    before do
      allow(game).to receive(:ability_right_time?).and_return(true)
      game.place_home_token(corporation)
    end

    def stop(city, revenue)
      allow(city).to receive(:route_revenue).and_return(revenue)
      city
    end

    def route_for(corp, hexes)
      instance_double(Engine::Route, corporation: corp, phase: game.phase, train: double('train', multiplier: nil), hexes: hexes)
    end

    def move_card_to(target)
      company.owner.companies.delete(company)
      company.owner = target
      target.companies << company
    end

    it 'is wired into the operating round' do
      expect(game.operating_round(1).steps.map(&:class)).to include(Engine::Game::G1864::Step::Assign)
    end

    it 'offers only the stations where the holder has a placed token' do
      expect(step.available_hex(company, home_hex)).to be(true)
      expect(step.available_hex(company, other_hex)).to be(false)
    end

    it 'rejects assignment to a hex the corporation has no station in' do
      action = Engine::Action::Assign.new(company, target: other_hex)

      expect { step.process_assign(action) }.to raise_error(Engine::GameError, /stations/)
    end

    it "places the marker in an extra slot of the station's city, then offers no further assignment" do
      expect(step.actions(company)).to eq(%w[assign])

      step.process_assign(Engine::Action::Assign.new(company, target: home_hex))

      expect(home_city.extra_tokens.map(&:logo)).to eq(['/icons/1864/local_contract.svg'])
      expect(home_city.tokens.compact.map(&:corporation)).to eq([corporation])
      expect(home_city.slots(all: true)).to eq(home_city.normal_slots + 1)
      expect(step.actions(company)).to eq([])
    end

    it "adds $10 for a stop in the marker's city only" do
      game.place_local_contract!(company, home_city)
      other_city = other_hex.tile.cities.first

      expect(game.revenue_for(route_for(corporation, [home_hex]), [stop(home_city, 30)])).to eq(40)
      expect(game.revenue_for(route_for(corporation, [other_hex]), [stop(other_city, 30)])).to eq(30)
    end

    describe 'on a multi-city hex' do
      let(:corporation) { (game.corporations + game.future_corporations).find { |c| c.id == 'DPR' } }
      let(:denver) { game.hex_by_id('G20') }

      before { move_card_to(corporation) }

      it 'pays only for the city holding the marked station' do
        step.process_assign(Engine::Action::Assign.new(company, target: denver))

        expect(game.local_contract_bonus([denver.tile.cities[0]])).to eq(10)
        expect(game.local_contract_bonus([denver.tile.cities[1]])).to eq(0)
        expect(denver.tile.cities[0].extra_tokens.size).to eq(1)
        expect(denver.tile.cities[1].extra_tokens).to be_empty
      end

      it 'follows the marked city through an upgrade that renumbers the cities' do
        step.process_assign(Engine::Action::Assign.new(company, target: denver))
        track = game.operating_round(1).steps.find { |st| st.is_a?(Engine::Game::G1864::Step::Track) }
        allow(track).to receive(:legal_tile_rotation?).and_return(true)
        game.phase.next! while game.phase.name.to_i < 3
        tile = game.tiles.find { |t| t.name == '637' }

        track.lay_tile(Engine::Action::LayTile.new(corporation, tile: tile, hex: denver, rotation: 5),
                       entity: corporation)

        expect(denver.tile.cities[2].extra_tokens.size).to eq(1)
        expect(denver.tile.cities[0].extra_tokens).to be_empty
        expect(denver.tile.cities[2].tokened_by?(corporation)).to be(true)
        expect(game.local_contract_bonus([denver.tile.cities[2]])).to eq(10)
        expect(game.local_contract_bonus([denver.tile.cities[0]])).to eq(0)
      end
    end

    it 'pays any corporation that runs to the marked city' do
      game.place_local_contract!(company, home_city)
      other = (game.corporations + game.future_corporations).find { |c| c != corporation }

      expect(game.revenue_for(route_for(other, [home_hex]), [stop(home_city, 30)])).to eq(40)
    end

    it 'keeps paying after the card moves to a new corporation in a merger' do
      game.place_local_contract!(company, home_city)
      move_card_to((game.corporations + game.future_corporations).find { |c| c.type == :major })

      expect(game.local_contract_bonus([home_city])).to eq(10)
    end

    it 'removes the marker and its extra slot when abilities are removed at phase 6' do
      step.process_assign(Engine::Action::Assign.new(company, target: home_hex))

      game.event_remove_minor_abilities!

      expect(company.closed?).to be(true)
      expect(home_city.extra_tokens).to be_empty
      expect(home_city.slots(all: true)).to eq(home_city.normal_slots)
      expect(game.local_contract_bonus([home_city])).to eq(0)
    end

    it 'removes the marker and its extra slot when the holder is regionalized' do
      minor = game.corporation_by_id('O&NW')
      move_card_to(minor)
      game.par_corporation(minor, game.stock_market.market.first[5])
      game.share_pool.buy_shares(game.players.first, minor.shares.first.to_bundle, exchange: :free)
      game.place_home_token(minor)
      minor_hex = game.hex_by_id(minor.coordinates)
      minor_city = minor_hex.tile.cities.find { |c| c.tokened_by?(minor) }
      step.process_assign(Engine::Action::Assign.new(company, target: minor_hex))
      expect(minor_city.slots(all: true)).to eq(minor_city.normal_slots + 1)

      game.nationalize!(minor)

      expect(company.closed?).to be(true)
      expect(minor_city.extra_tokens).to be_empty
      expect(minor_city.slots(all: true)).to eq(minor_city.normal_slots)
    end
  end
end
