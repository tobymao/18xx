# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE merging a minor into a major in a Stock Round (§10.5)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:round) { stock_round!(game) }
  let(:step) { round.active_step }
  let(:player) { round.current_entity }
  let(:major) { start_major!(game, 'LNWR', player) }
  let(:minor) { start_minor!(game, 'B', player, 'SP') }

  before do
    allow(game).to receive(:major_phase?).and_return(true)
    game.phase.next!
  end

  it 'offers no merge before Train Phase 3 (§10.5)' do
    phase_two_game = new_game
    phase_two_round = stock_round!(phase_two_game)
    allow(phase_two_game).to receive(:major_phase?).and_return(true)
    phase_two_player = phase_two_round.current_entity
    start_major!(phase_two_game, 'LNWR', phase_two_player)
    phase_two_minor = start_minor!(phase_two_game, 'B', phase_two_player, 'SP')

    expect(phase_two_game.merge_targets(phase_two_player, phase_two_minor)).to be_empty
    expect(phase_two_round.active_step.can_merge_any?(phase_two_player)).to be(false)
  end

  it 'offers to merge a minor into a major the player presides from Train Phase 3 (§10.5)' do
    major
    expect(game.merge_targets(player, minor)).to eq([major])
    expect(step.actions(player)).to include('choose')
  end

  it 'lists minors after the share corporations' do
    major
    minor
    types = step.visible_corporations.map(&:type)
    expect(types.drop_while { |t| t != :minor }.uniq).to eq([:minor])
    expect(step.visible_corporations).to include(minor)
  end

  it 'offers no merge into a major presided by another player' do
    start_major!(game, 'LNWR', game.players.last)
    expect(game.merge_targets(player, minor)).to be_empty
  end

  it 'allows one minor per major per SR (§10.5)' do
    major
    round.merged_majors << major
    expect(game.merge_targets(player, minor)).to be_empty
  end

  it 'offers no merge after another stock action this turn (§10)' do
    take_treasury_shares!(game, player, major, 1)
    act!(round, Engine::Action::SellShares.new(player, shares: [player.shares_of(major).reject(&:president).first], percent: 10))
    expect(step.can_merge?(player, minor)).to be(false)
  end

  it 'still offers the merge after selling that major in an earlier turn (§10.2)' do
    major
    round.players_sold[player][major] = :now
    expect(step.can_merge?(player, minor)).to be(true)
  end

  it 'never sells a minor share' do
    expect(step.can_sell?(player, player.shares_of(minor).first.to_bundle)).to be(false)
  end

  it 'starts the merge with Choose' do
    major
    act!(round, Engine::Action::Choose.new(player, choice: minor.id))
    expect(round.merge_minor).to eq(minor)
  end

  def to_pool!(corporation, count)
    game.share_pool.transfer_shares(Engine::ShareBundle.new(corporation.ipo_shares.first(count)), game.share_pool)
  end

  def merge!(target = major, from: round, merging: minor)
    act!(from, Engine::Action::Choose.new(from.current_entity, choice: merging.id))
    act!(from, Engine::Action::Merge.new(merging, corporation: target))
  end

  def resolve_follow_ups!(from = round)
    until from.active_step.is_a?(Engine::Game::G18OE::Step::BuySellParShares)
      act!(from, Engine::Action::Pass.new(from.active_step.current_entity))
    end
  end

  def pass_tokens!
    token_step = Engine::Game::G18OE::Step::MergeToken
    act!(round, Engine::Action::Pass.new(round.current_entity)) while round.active_step.is_a?(token_step)
  end

  def place_minor_token!(hex_id, index = 0)
    city = game.hex_by_id(hex_id).tile.cities[index]
    city.place_token(minor, minor.next_token, free: true, check_tokenable: false)
    city
  end

  def empty_treasury_into_pool!
    major.treasury_shares.size.times { |index| take_treasury_shares!(game, game.players[index % game.players.size], major, 1) }
    game.share_pool.transfer_shares(player.shares_of(major).reject(&:president).first.to_bundle, game.share_pool)
  end

  it 'rejects Choose for a minor the player cannot merge' do
    major
    minor
    other = start_minor!(game, 'C', game.players.last, 'SP')
    expect(step.actions(player)).to include('choose')
    expect { act!(round, Engine::Action::Choose.new(player, choice: other.id)) }
      .to raise_error(Engine::GameError, /Cannot merge C/)
  end

  it 'lists the eligible majors once Merge is chosen' do
    major
    act!(round, Engine::Action::Choose.new(player, choice: minor.id))
    expect(round.active_step.mergeable_entities).to eq([major])
  end

  it 'gives the owner a treasury share and the major the minor cash (§10.5)' do
    major
    minor
    cash_before = major.cash
    expect { merge! }.to change { player.num_shares_of(major) }.by(1)
    expect(major.cash).to eq(cash_before + 120)
  end

  it 'takes the share from the Open Market only when the treasury is empty, and the bank keeps the cash (§10.5)' do
    major
    minor
    empty_treasury_into_pool!
    expect(game.merge_share(major).owner).to eq(game.share_pool)

    cash_before = major.cash
    bank_before = game.bank.cash
    expect { merge! }.to change { game.share_pool.shares_by_corporation[major].size }.by(-1)
    expect(major.cash).to eq(cash_before)
    expect(game.bank.cash).to eq(bank_before + 120)
  end

  it 'prefers the treasury when both have shares (§10.5)' do
    major
    to_pool!(major, 1)
    expect(game.merge_share(major).owner).to eq(major)
  end

  it 'gives the share even above 60% (§10.2)' do
    major
    take_treasury_shares!(game, player, major, 4)
    merge!
    expect(player.percent_of(major)).to eq(70)
  end

  it 'moves the minor trains to the major (§10.5)' do
    major
    train = game.depot.upcoming.first
    game.buy_train(minor, train, :free)
    merge!
    expect(train.owner).to eq(major)
    expect(round.merge_trains).to eq(corporation: major, trains: [train])
  end

  it 'records the charter and removes the minor from the operating order (§10.5)' do
    major
    merge!
    expect(game.merged_minors[major]).to eq([minor])
    expect(game.minor_regional_order).not_to include(minor)
  end

  it 'leaves the acquisition pending while the minor has a token to resolve (§10.5)' do
    major
    place_minor_token!('Q38')
    merge!
    expect(round.pending_acquisition).to eq(minor: minor, corporation: major)
    expect(round.merged_majors).to eq([major])
  end

  it 'closes the minor once its tokens are resolved (§10.5)' do
    major
    merge!
    resolve_follow_ups!
    expect(minor).to be_closed
    expect(game.corporations).not_to include(minor)
    expect(round.pending_acquisition).to be_nil
  end

  it 'keeps the merged minor treasury with the major after the minor closes (§10.5)' do
    major
    cash_before = major.cash
    merge!
    expect(major.cash).to eq(cash_before + 120)
    expect(minor.cash).to eq(0)
  end

  it 'replaces a minor token with the major\'s most expensive unplaced token for free (§10.5)' do
    major
    city = place_minor_token!('Q38')
    cash = major.cash
    merge!
    expect(round.active_step).to be_a(Engine::Game::G18OE::Step::MergeToken)
    act!(round, Engine::Action::PlaceToken.new(major, city: city, slot: 0))
    placed = city.tokens.compact.find { |t| t.corporation == major }
    expect(placed.price).to eq(80)
    expect(city.tokens.compact.map(&:corporation)).not_to include(minor)
    expect(major.cash).to eq(cash + 120)
    expect(minor).to be_closed
  end

  it 'removes a declined minor token (§10.5)' do
    major
    city = place_minor_token!('Q38')
    merge!
    act!(round, Engine::Action::Pass.new(major))
    expect(city.tokens.compact).to be_empty
    expect(minor).to be_closed
  end

  it 'rejects replacing a minor token in another city (§10.5)' do
    major
    place_minor_token!('Q38')
    other = game.hex_by_id('W64').tile.cities.first
    merge!
    expect { act!(round, Engine::Action::PlaceToken.new(major, city: other, slot: 0)) }.to raise_error(Engine::GameError)
  end

  it 'prompts for each minor token in turn (§10.5)' do
    major
    first = place_minor_token!('Q38')
    second = place_minor_token!('W64')
    merge!
    act!(round, Engine::Action::PlaceToken.new(major, city: first, slot: 0))
    expect(round.active_step).to be_a(Engine::Game::G18OE::Step::MergeToken)
    expect(minor).not_to be_closed
    act!(round, Engine::Action::Pass.new(major))
    expect(second.tokens.compact).to be_empty
    expect(minor).to be_closed
  end

  it 'auto-declines a token in a hex the major already occupies (§10.5)' do
    major
    city = place_minor_token!('AA82', 1)
    game.hex_by_id('AA82').tile.cities.first.place_token(major, major.unplaced_tokens.first, free: true, check_tokenable: false)
    merge!
    expect(round.active_step).not_to be_a(Engine::Game::G18OE::Step::MergeToken)
    expect(city.tokens.compact).to be_empty
    expect(minor).to be_closed
    expect(round.pending_acquisition).to be_nil
  end

  it 'auto-declines when the major has no unplaced tokens (§10.5)' do
    major
    city = place_minor_token!('Q38')
    spare = game.hexes.flat_map { |hex| hex.tile.cities }.reject { |c| c == city }.select { |c| c.tokens.compact.empty? }
    major.unplaced_tokens.each { |token| spare.shift.place_token(major, token, free: true, check_tokenable: false) }
    merge!
    expect(round.active_step).not_to be_a(Engine::Game::G18OE::Step::MergeToken)
    expect(city.tokens.compact).to be_empty
    expect(minor).to be_closed
  end

  it 'ends the stock action with the merge (§10)' do
    major
    merge!
    resolve_follow_ups!
    expect(round.current_entity).not_to eq(player)
  end

  it 'does not force a sale of the merge share above 60% on the next turn (§10.2)' do
    major
    take_treasury_shares!(game, player, major, 4)
    merge!
    resolve_follow_ups!
    pass_until!(round, player)
    expect(player.percent_of(major)).to eq(70)
    expect(step.must_sell?(player)).to be(false)
    expect(step.actions(player)).not_to eq(['sell_shares'])
  end

  it 'merges during the Consolidation round (§5.1.5)' do
    major
    c = enter_round!(game, game.new_consolidation_round)
    merge!(from: c)
    expect(game.merged_minors[major]).to eq([minor])
  end

  it 'lets a second minor merge into another major but not the same one (§10.5)' do
    major
    other_major = start_major!(game, 'GWR', player)
    second = start_minor!(game, 'C', player, 'SP')
    merge!
    resolve_follow_ups!
    expect(game.merge_targets(player, second)).to eq([other_major])
  end

  it 'rejects a merge into a major that is not a target' do
    major
    other_major = start_major!(game, 'GWR', game.players.last)
    act!(round, Engine::Action::Choose.new(player, choice: minor.id))
    expect { act!(round, Engine::Action::Merge.new(minor, corporation: other_major)) }.to raise_error(Engine::GameError)
  end

  it 'lets the major decline a train from the minor, which goes to the bank (§10.5)' do
    major
    train = game.depot.upcoming.first
    game.buy_train(minor, train, :free)
    merge!
    pass_tokens!
    act!(round, Engine::Action::DiscardTrain.new(major, train: train))
    expect(major.trains).not_to include(train)
    expect(game.depot.discarded).to include(train)
  end

  it 'lets the major keep the minor trains by passing (§10.5)' do
    major
    train = game.depot.upcoming.first
    game.buy_train(minor, train, :free)
    merge!
    pass_tokens!
    expect(round.active_step).to be_a(Engine::Game::G18OE::Step::MergeDiscardTrain)
    act!(round, Engine::Action::Pass.new(major))
    expect(major.trains).to include(train)
    expect(round.merge_trains).to be_nil
    expect(round.current_entity).not_to eq(player)
  end

  it 'offers no decline when the minor had no trains (§10.5)' do
    major
    merge!
    pass_tokens!
    expect(round.active_step).not_to be_a(Engine::Game::G18OE::Step::MergeDiscardTrain)
  end

  it 'offers the major\'s own trains as well as the minor\'s (§10.5)' do
    major
    own = game.depot.upcoming.first
    game.buy_train(major, own, :free)
    taken = game.depot.upcoming.first
    game.buy_train(minor, taken, :free)
    merge!
    pass_tokens!
    expect(round.active_step.trains(major)).to contain_exactly(own, taken)
  end

  it 'lets the major discard one of its own trains and keep the minor\'s (§10.5)' do
    major
    own = game.depot.upcoming.first
    game.buy_train(major, own, :free)
    taken = game.depot.upcoming.first
    game.buy_train(minor, taken, :free)
    merge!
    pass_tokens!
    act!(round, Engine::Action::DiscardTrain.new(major, train: own))
    expect(game.depot.discarded).to include(own)
    expect(taken.owner).to eq(major)
    expect(round.active_step).to be_a(Engine::Game::G18OE::Step::MergeDiscardTrain)
    act!(round, Engine::Action::Pass.new(major))
    expect(round.current_entity).not_to eq(player)
  end

  it 'lets the major decline both trains from a minor that had two (§10.5)' do
    major
    first = game.depot.upcoming.first
    game.buy_train(minor, first, :free)
    second = game.depot.upcoming.first
    game.buy_train(minor, second, :free)
    merge!
    pass_tokens!
    act!(round, Engine::Action::DiscardTrain.new(major, train: first))
    act!(round, Engine::Action::DiscardTrain.new(major, train: second))
    expect(game.depot.discarded).to include(first, second)
    expect(round.merge_trains).to be_nil
    expect(round.current_entity).not_to eq(player)
  end

  it 'stops offering discards once every minor train is declined (§10.5)' do
    major
    own = game.depot.upcoming.first
    game.buy_train(major, own, :free)
    taken = game.depot.upcoming.first
    game.buy_train(minor, taken, :free)
    merge!
    pass_tokens!
    act!(round, Engine::Action::DiscardTrain.new(major, train: taken))
    expect(major.trains).to eq([own])
    expect(round.active_step).not_to be_a(Engine::Game::G18OE::Step::MergeDiscardTrain)
  end

  it 'forces a discard over the train limit (§10.5)' do
    major
    own = game.depot.upcoming.first
    game.buy_train(major, own, :free)
    3.times { game.buy_train(major, game.depot.upcoming.first, :free) }
    taken = game.depot.upcoming.first
    game.buy_train(minor, taken, :free)
    merge!
    pass_tokens!
    expect(round.active_step).to be_a(Engine::Step::DiscardTrain)
    act!(round, Engine::Action::DiscardTrain.new(major, train: own))
    expect(game.depot.discarded).to include(own)
    expect(taken.owner).to eq(major)
  end

  describe 'with no share available (§10.5)' do
    before do
      take_treasury_shares!(game, player, major, major.treasury_shares.size)
    end

    def place_major_token!(hex_id, index = 0)
      city = game.hex_by_id(hex_id).tile.cities[index]
      city.remove_all_reservations!
      city.place_token(major, major.next_token, free: true, check_tokenable: false)
      city
    end

    def lay_valencia_palma_tiles!(*hex_ids)
      rotations = { 'AB27' => 1, 'AA20' => 4 }
      hex_ids.each do |hex_id|
        tile = game.tiles.find { |t| t.name == '5' && !t.hex }
        tile.rotate!(rotations[hex_id])
        game.hex_by_id(hex_id).lay(tile)
      end
    end

    it 'has no share to merge for' do
      expect(game.merge_share(major)).to be_nil
    end

    it 'is a target when track joins a minor token to a major token (§10.5)' do
      place_minor_token!('N31')
      place_major_token!('M28')
      expect(game.merge_targets(player, minor)).to eq([major])
    end

    it 'is not a target without a track connection (§10.5)' do
      place_minor_token!('N31')
      expect(game.merge_targets(player, minor)).to be_empty
    end

    it 'ignores other railroads\' tokens on the way (§10.5)' do
      lay_valencia_palma_tiles!('AB27', 'AA20')
      other = start_regional!(game, 'GWR', game.players.last)
      game.hex_by_id('AB27').tile.cities.first.place_token(other, other.next_token, free: true, check_tokenable: false)
      place_minor_token!('AA20')
      place_major_token!('Z27')
      expect(game.merge_targets(player, minor)).to eq([major])
    end

    it 'does not cross the sea through ports (§10.5)' do
      expect(game.port_sea_zone('D57', 4)).to eq(game.port_sea_zone('B67', 5))
      place_minor_token!('D57')
      place_major_token!('B67')
      expect(game.merge_targets(player, minor)).to be_empty
    end

    it 'counts a shared city as connected' do
      place_minor_token!('T87')
      place_major_token!('T87')
      expect(game.merge_targets(player, minor)).to eq([major])
    end

    it 'does not check the connection while loading (§10.5)' do
      game.instance_variable_set(:@loading, true)
      expect(game).not_to receive(:merge_connected?)
      place_minor_token!('N31')
      expect(game.merge_targets(player, minor)).to eq([major])
    end

    def stub_other_options_off!(target = step)
      %i[can_buy_any? can_ipo_any? can_float_minor? can_sell_any? can_remove_any_corporation? can_reserve_any?].each do |name|
        allow(target).to receive(name).and_return(false)
      end
      allow(target).to receive(:purchasable_companies).and_return([])
      allow(target).to receive(:buyable_bank_owned_companies).and_return([])
      allow(target).to receive(:must_sell?).and_return(false)
    end

    it 'skips a player whose only option is an unconnected no-share merge (§10.5)' do
      place_minor_token!('N31')
      stub_other_options_off!
      expect(step.actions(player)).to eq(['skip'])
      expect(step.auto_actions(player).map(&:class)).to eq([Engine::Action::Skip])
      expect(step.auto_actions(player).map(&:entity)).to eq([player])
      act!(round, step.auto_actions(player).first)
      expect(game.log.map(&:message)).to include("#{player.name} has no valid actions and passes")
      expect(player.passed?).to be(true)
    end

    it 'does not skip when the no-share merge is connected (§10.5)' do
      place_minor_token!('N31')
      place_major_token!('M28')
      stub_other_options_off!
      expect(step.actions(player)).to eq(%w[choose pass])
      expect(step.auto_actions(player).to_a.map(&:class)).not_to include(Engine::Action::Skip)
    end

    it 'accepts a recorded skip while loading without checking the connection (§10.5)' do
      place_minor_token!('N31')
      stub_other_options_off!
      game.instance_variable_set(:@loading, true)
      expect(game).not_to receive(:merge_connected?)
      expect(step.actions(player)).to eq(%w[choose pass skip])
      act!(round, Engine::Action::Skip.new(player))
      expect(player.passed?).to be(true)
    end

    it 'skips in the Consolidation round too (§10.6)' do
      place_minor_token!('N31')
      start_regional!(game, 'GWR', player)
      consolidation = enter_round!(game, game.new_consolidation_round)
      consolidate = consolidation.active_step
      stub_other_options_off!(consolidate)
      expect(consolidate.actions(player)).to eq(['skip'])
      expect(consolidate.auto_actions(player).map(&:class)).to eq([Engine::Action::Skip])
      act!(consolidation, consolidate.auto_actions(player).first)
      expect(game.log.map(&:message)).to include("#{player.name} has no valid actions and passes")
      expect(player.passed?).to be(true)
    end

    it 'rebuilds the merge graph for the next stock round' do
      lay_valencia_palma_tiles!('AB27')
      place_minor_token!('AA20')
      place_major_token!('Z27')
      expect(game.merge_targets(player, minor)).to be_empty
      lay_valencia_palma_tiles!('AA20')
      stock_round!(game)
      expect(game.merge_targets(player, minor)).to eq([major])
    end

    it 'never connects a minor with no tokens' do
      place_major_token!('M28')
      expect(game.merge_targets(player, minor)).to be_empty
    end

    it 'merges with no share and forfeits the minor cash to the bank (§10.5)' do
      place_minor_token!('N31')
      place_major_token!('M28')
      train = game.depot.upcoming.first
      game.buy_train(minor, train, :free)
      shares = player.num_shares_of(major)
      major_cash = major.cash
      bank_cash = game.bank.cash
      minor_cash = minor.cash
      expect { merge! }.not_to raise_error
      expect(player.num_shares_of(major)).to eq(shares)
      expect(major.cash).to eq(major_cash)
      expect(game.bank.cash).to eq(bank_cash + minor_cash)
      expect(train.owner).to eq(major)
      expect(game.merged_minors[major]).to eq([minor])
    end

    it 'closes the minor after a no-share merge (§10.5)' do
      place_minor_token!('N31')
      place_major_token!('M28')
      merge!
      resolve_follow_ups!
      expect(minor).to be_closed
      expect(round.pending_acquisition).to be_nil
    end
  end
end
