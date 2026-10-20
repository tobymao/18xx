# frozen_string_literal: true

require 'spec_helper'
require_relative 'spec_helper_1835'

describe Engine::Game::G1835::Game do
  let(:game) { Engine::Game::G1835::Game.new(players) }
  let(:by) { game.corporation_by_id('BY') }
  let(:m1) { game.minor_by_id('1') }
  let(:m2) { game.minor_by_id('2') }
  let(:m3) { game.minor_by_id('3') }
  let(:m4) { game.minor_by_id('4') }
  let(:m5) { game.minor_by_id('5') }
  let(:m6) { game.minor_by_id('6') }
  let(:nf) { game.company_by_id('NF') }
  let(:player_1) { game.players.find { |player| player.id == 'a' } }
  let(:player_2) { game.players.find { |player| player.id == 'b' } }
  let(:player_3) { game.players.find { |player| player.id == 'c' } }

  def sell_start_packet
    buy(player_1, 'NF')
    buy(player_2, 'LD')
    buy(player_3, '2')
    buy(player_1, '1')
    buy(player_2, '4')
    buy(player_3, 'BB')
    buy(player_1, 'BY_D')
    buy(player_2, 'HB')
    buy(player_3, '3')
    buy(player_1, 'PB')
    buy(player_2, '6')
    buy(player_3, 'OBB')
    buy(player_1, '5')
    buy_shares(player_3, 'SX')
    # The Bayern director (player 1) ends up with the NF and PB privates
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

  describe 'privates' do
    let(:players) { %w[a b c] }
    it 'should let corporation place extra token in Nürnberg without connection' do
      sell_start_packet
      skip_operation_for_minors

      # Start building towards Augsburg
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('202-0'), hex: hex('O15'), rotation: 0)).maybe_raise!
      game.process_action(Engine::Action::LayTile.new(by, tile: tile('9-0'), hex: hex('O13'), rotation: 2)).maybe_raise!
      pass(by) # skip laying track using Pfalzbahnen
      pass(by) # skip tokening using Nürnberg-Fürth
      train = game.depot.depot_trains.first
      game.process_action(Engine::Action::BuyTrain.new(by, train: train, price: train.price))
      pass(by) # skip buying more trains

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
      game.process_action(Engine::Action::PlaceToken.new(nf, city: hex('L14').tile.cities.first, tokener: by))
      # Ensure placing the token was free
      expect(by.cash).to be bayern_cash

      expect(nf.owner).to eq(nil)
      expect(nf.closed?).to be true

      # Make sure we can place another token, but this one costs money: Augsburg is 2 hexes away, so 2 * 20 = 40
      game.process_action(Engine::Action::PlaceToken.new(by, city: game.hex_by_id('N12').tile.cities.first))
      expect(by.cash).to be bayern_cash - 40

      # Make sure NF used one of BY's tokens
      expect(by.tokens.count { |t| !t.used }).to be bayern_num_unused_tokens - 2
    end
  end
end
