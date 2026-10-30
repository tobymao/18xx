# frozen_string_literal: true

require 'spec_helper'
require_relative 'spec_helper_1835'

describe Engine::Game::G1835::Game do
  let(:game) { Engine::Game::G1835::Game.new(players) }
  let(:by) { game.corporation_by_id('BY') }
  let(:sx) { game.corporation_by_id('SX') }
  let(:m1) { game.minor_by_id('1') }
  let(:m2) { game.minor_by_id('2') }
  let(:m3) { game.minor_by_id('3') }
  let(:m4) { game.minor_by_id('4') }
  let(:m5) { game.minor_by_id('5') }
  let(:m6) { game.minor_by_id('6') }
  let(:nf) { game.company_by_id('NF') }
  let(:obb) { game.company_by_id('OBB') }
  let(:player_1) { game.players.find { |player| player.id == 'a' } }
  let(:player_2) { game.players.find { |player| player.id == 'b' } }
  let(:player_3) { game.players.find { |player| player.id == 'c' } }

  def sell_start_packet
    buy(player_1, 'NF')
    buy(player_2, 'LD')
    buy(player_3, '1')
    pass(player_1)
    buy(player_2, '2')
    buy(player_3, '4')
    buy(player_1, 'BY_D')
    buy(player_2, '3')
    buy(player_3, 'BB')
    buy(player_1, 'OBB')
    buy(player_2, 'HB')
    buy(player_3, '5')
    buy(player_1, 'PB')
    # player 2 is out of money
    buy(player_3, '6')
    # The Bayern director (player 1) ends up with the NF, OBB, and PB privates
  end

  def skip_operation_for_minors
    [m1, m2, m3, m4, m5, m6].each do |minor|
      pass(minor) # pass track
      pass(minor) # pass buy train
    end
  end

  def tile(id)
    game.tile_by_id(id)
  end

  def hex(id)
    game.hex_by_id(id)
  end

  def buy_single_train(corp)
    train = game.depot.depot_trains.first
    game.process_action(Engine::Action::BuyTrain.new(corp, train: train, price: train.price))
    pass(corp) # skip buying more trains
  end

  describe 'Ostbayern' do
    let(:players) { %w[a b c] }
    it 'is possible to lay one tile extra unconnected for free and OBB stays open' do
      sell_start_packet
      skip_operation_for_minors

      bayern_cash = by.cash
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('202-0'), hex: hex('O15'), rotation: 0)).maybe_raise!
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('9-0'), hex: hex('O13'), rotation: 2)).maybe_raise!
      game.process_action(Engine::Action::LayTile.new(obb, tile: tile('3-0'), hex: hex('M15'), rotation: 2)).maybe_raise!

      expect(by.cash).to be bayern_cash
      expect(obb.closed?).to be false
    end

    it 'is possible to lay two tiles extra unconnected for free and OBB closes' do
      sell_start_packet
      skip_operation_for_minors

      bayern_cash = by.cash
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('202-0'), hex: hex('O15'), rotation: 0)).maybe_raise!
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('8-0'), hex: hex('N14'), rotation: 3)).maybe_raise!
      game.process_action(Engine::Action::LayTile.new(obb, tile: tile('3-0'), hex: hex('M15'), rotation: 2)).maybe_raise!
      game.process_action(Engine::Action::LayTile.new(obb, tile: tile('8-1'), hex: hex('M17'), rotation: 2)).maybe_raise!

      expect(by.cash).to be bayern_cash
      expect(obb.closed?).to be true
    end

    it 'is possible to lay one tile connected and OBB for free stays open' do
      sell_start_packet
      skip_operation_for_minors

      bayern_cash = by.cash
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('202-0'), hex: hex('O15'), rotation: 0)).maybe_raise!
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('8-0'), hex: hex('O13'), rotation: 3)).maybe_raise!
      game.process_action(Engine::Action::LayTile.new(obb, tile: tile('58-0'), hex: hex('M15'), rotation: 4)).maybe_raise!

      expect(by.cash).to be bayern_cash
      expect(obb.closed?).to be false
    end

    it 'is possible to lay two tiles connected and OBB for free stays closed' do
      sell_start_packet
      skip_operation_for_minors

      bayern_cash = by.cash
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('202-0'), hex: hex('O15'), rotation: 0)).maybe_raise!
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('8-0'), hex: hex('O13'), rotation: 3)).maybe_raise!
      game.process_action(Engine::Action::LayTile.new(obb, tile: tile('58-0'), hex: hex('M15'), rotation: 4)).maybe_raise!
      game.process_action(Engine::Action::LayTile.new(obb, tile: tile('7-0'), hex: hex('M17'), rotation: 1)).maybe_raise!

      expect(by.cash).to be bayern_cash
      expect(obb.closed?).to be true
    end

    it 'is possible to use OBB with two different corps' do
      sell_start_packet
      skip_operation_for_minors

      pass(by) # pass track
      pass(by) # pass token

      buy_single_train(by)

      # let player 1 take over SX so that they have OBB and the BY and SX director
      sell_shares(player_1, 'BY', 30)
      buy_shares(player_1, 'SX')
      pass(player_1)
      expect(game.current_entity).to eq(player_3)
      pass(player_3)
      buy_shares(player_1, 'SX')
      pass(player_1)
      pass(player_2)
      pass(player_3)
      buy_shares(player_1, 'SX')
      pass(player_1)

      # end the stock round
      pass(player_2)
      pass(player_3)
      pass(player_1)

      skip_operation_for_minors

      # SX uses OBB first
      game.process_action(Engine::Action::LayTile.new(obb, tile: tile('4-0'), hex: hex('M15'), rotation: 0)).maybe_raise!
      pass(sx) # skip more track
      pass(sx) # skip token
      buy_single_train(sx)

      # BY uses OBB second
      game.process_action(Engine::Action::LayTile.new(obb, tile: tile('7-0'), hex: hex('M17'), rotation: 0)).maybe_raise!

      expect(obb.closed?).to be true
    end
  end

  describe 'Nürnberg-Fürth' do
    let(:players) { %w[a b c] }
    it 'should let corporation place extra token in Nürnberg without connection' do
      sell_start_packet
      skip_operation_for_minors

      # Start building towards Augsburg
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('202-0'), hex: hex('O15'), rotation: 0)).maybe_raise!
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('9-0'), hex: hex('O13'), rotation: 2)).maybe_raise!
      pass(by) # skip laying track using Pfalzbahnen
      pass(by) # skip tokening using Nürnberg-Fürth
      buy_single_train(by)

      # Do nothing during the stock round
      pass(player_1) # no valid actions for player 2
      pass(player_3)

      skip_operation_for_minors

      # Lay tile on Augsburg
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('57-0'), hex: hex('N12'), rotation: 2)).maybe_raise!
      pass(by) # skip rest of track laying

      bayern_cash = by.cash
      bayern_num_unused_tokens = by.tokens.count { |t| !t.used }
      # Place token in Nürnberg/Fürth without connection
      game.process_action(Engine::Action::PlaceToken.new(nf, city: hex('L14').tile.cities.first, tokener: by)).maybe_raise!
      # Ensure placing the token was free
      expect(by.cash).to be bayern_cash

      expect(nf.owner).to eq(nil)
      expect(nf.closed?).to be true

      # Make sure we can place another token, but this one costs money: Augsburg is 2 hexes away, so 2 * 20 = 40
      game.process_action(Engine::Action::PlaceToken.new(by, city: game.hex_by_id('N12').tile.cities.first)).maybe_raise!
      expect(by.cash).to be bayern_cash - 40

      # Make sure NF used one of BY's tokens
      expect(by.tokens.count { |t| !t.used }).to be bayern_num_unused_tokens - 2
    end

    it 'should let corporation place extra token in Nürnberg with connection' do
      sell_start_packet
      skip_operation_for_minors

      # Start building towards Augsburg
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('202-0'), hex: hex('O15'), rotation: 0)).maybe_raise!
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('9-0'), hex: hex('O13'), rotation: 2)).maybe_raise!
      pass(by) # skip laying track using Pfalzbahnen
      pass(by) # skip tokening using Nürnberg-Fürth
      buy_single_train(by)

      # Do nothing during the stock round
      pass(player_1) # no valid actions for player 2
      pass(player_3)

      skip_operation_for_minors

      # Lay tile on Augsburg
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('6-0'), hex: hex('N12'), rotation: 3)).maybe_raise!
      # Connect to Nürnberg
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('9-1'), hex: hex('M13'), rotation: 3)).maybe_raise!
      pass(by) # skip rest of track laying

      bayern_cash = by.cash
      bayern_num_unused_tokens = by.tokens.count { |t| !t.used }
      # Place token in Nürnberg/Fürth with connection
      game.process_action(Engine::Action::PlaceToken.new(nf, city: hex('L14').tile.cities.first, tokener: by)).maybe_raise!
      # Ensure placing the token was free
      expect(by.cash).to be bayern_cash

      expect(nf.owner).to eq(nil)
      expect(nf.closed?).to be true

      # Make sure we can place another token, but this one costs money: Augsburg is 2 hexes away, so 2 * 20 = 40
      game.process_action(Engine::Action::PlaceToken.new(by, city: game.hex_by_id('N12').tile.cities.first)).maybe_raise!
      expect(by.cash).to be bayern_cash - 40

      # Make sure NF used one of BY's tokens
      expect(by.tokens.count { |t| !t.used }).to be bayern_num_unused_tokens - 2
    end
  end
end
