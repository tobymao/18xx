# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1864::Game do
  let(:players) { %w[alice bob carol] }

  it 'is registered under the title 1864: Forty-Niner' do
    expect(Engine::GAME_META_BY_TITLE['1864: Forty-Niner']).to eq(Engine::Game::G1864::Meta)
  end

  it 'depends on 1861' do
    expect(Engine::Game::G1864::Meta::DEPENDS_ON).to eq('1861')
  end

  it 'constructs a game' do
    game = described_class.new(players, seed: 1)

    expect(game.players.map(&:name)).to eq(players)
  end

  it "uses 1867's rule for where a major may start" do
    game = described_class.new(players, seed: 1)

    expect(game.method(:home_token_locations).owner).to eq(Engine::Game::G1867::Game)
    expect(game.method(:unconnected_hexes).owner).to eq(Engine::Game::G1867::Game)
    expect(described_class::HOME_TOKEN_TIMING).to eq(Engine::Game::G1867::Game::HOME_TOKEN_TIMING)
    expect(game.send(:stock_round).steps.map(&:class)).to include(Engine::Game::G1867::Step::HomeToken)
  end

  describe 'ability card legend' do
    let(:game) { described_class.new(players, seed: 1) }

    def legend_minors
      game.minor_ability_legend('black')[2..].map { |row| row[0][:text] }
    end

    def start!(minor)
      game.par_corporation(minor, game.stock_market.market.first[5])
      game.share_pool.buy_shares(game.players.first, minor.shares.first.to_bundle, exchange: :free)
      game.place_home_token(minor)
    end

    it 'drops a minor once it is regionalized' do
      n = game.corporation_by_id('N')
      start!(n)

      expect(legend_minors).to include('N')

      game.nationalize!(n)

      expect(legend_minors).not_to include('N')
      expect(legend_minors.size).to eq(15)
    end

    it 'drops a minor once it merges or converts into a major' do
      ro = game.corporation_by_id('RO')
      start!(ro)
      game.close_corporation(ro)

      expect(legend_minors).not_to include('RO')
    end
  end

  describe 'No Pre-determined Starting Locations' do
    let(:game) { described_class.new(players, seed: 1, optional_rules: [:no_starting_locations]) }

    it 'gives minors no home and reserves no cities for them' do
      minors = (game.corporations + game.future_corporations).select { |c| c.type == :minor }

      expect(minors.map(&:coordinates).uniq).to eq([nil])
      expect(game.hexes.flat_map { |h| h.tile.cities.flat_map(&:reservations) }.compact).to be_empty
    end

    it 'has the player starting the auction choose where the minor starts, before any other bid' do
      n = game.corporation_by_id('N')
      game.process_action(Engine::Action::Bid.new(game.player_by_id('alice'), corporation: n, price: 100))

      expect(game.active_step).to be_a(Engine::Game::G1867::Step::HomeToken)
      expect(game.round.active_entities).to eq([game.player_by_id('alice')])
      expect(game.round.pending_tokens.first[:hexes].map(&:id)).not_to include('F27')

      city = game.hex_by_id('G2').tile.cities.first
      game.process_action(Engine::Action::PlaceToken.new(n, city: city, slot: 0))

      expect(game.exception).to be_nil
      expect(city.tokened_by?(n)).to be(true)
    end

    it 'fills in the ability card legend Home column once a minor places its home station' do
      n = game.corporation_by_id('N')
      legend_home = -> { game.minor_ability_legend('black')[2..].find { |row| row[0][:text] == 'N' }[1][:text] }
      expect(legend_home.call).to eq('')

      game.process_action(Engine::Action::Bid.new(game.player_by_id('alice'), corporation: n, price: 100))
      game.process_action(Engine::Action::PlaceToken.new(n, city: game.hex_by_id('G2').tile.cities.first, slot: 0))

      expect(game.exception).to be_nil
      expect(legend_home.call).to eq('San Francisco')
    end
  end

  describe 'Train Trade-in' do
    let(:game) { described_class.new(players, seed: 1, optional_rules: [:train_trade_in]) }
    let(:major) { (game.corporations + game.future_corporations).find { |c| c.type == :major } }

    it 'lets a major at its train limit exchange a train in phase 8' do
      game.phase.next! until game.phase.name == '8'
      game.depot.upcoming.select { |t| t.name == '6' }.first(game.train_limit(major)).each do |train|
        game.buy_train(major, train, :free)
      end
      major.owner = game.players.first
      game.bank.spend(1200, major)
      round = game.operating_round(1)
      step = round.steps.find { |st| st.is_a?(Engine::Game::G1864::Step::BuyTrain) }
      allow(step).to receive(:current_entity).and_return(major)
      old_train, new_train, _, price = game.discountable_trains_for(major).find { |_, t, _, _| t.name == '5+5E' }

      step.process_buy_train(Engine::Action::BuyTrain.new(major, train: new_train, price: price, exchange: old_train))

      expect(major.trains.map(&:name)).to eq(%w[6 5+5E])
    end
  end
end
