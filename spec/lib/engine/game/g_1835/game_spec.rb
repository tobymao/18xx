# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1835::Game do
  let(:game) { Engine::Game::G1835::Game.new(players) }
  let(:by) { game.corporation_by_id('BY') }
  let(:sx) { game.corporation_by_id('SX') }
  let(:ba) { game.corporation_by_id('BA') }
  let(:wt) { game.corporation_by_id('WT') }
  let(:he) { game.corporation_by_id('HE') }
  let(:pr) { game.corporation_by_id('PR') }
  let(:ms) { game.corporation_by_id('MS') }
  let(:ol) { game.corporation_by_id('OL') }
  let(:player_1) { game.players.find { |player| player.id == 'a' } }
  let(:player_2) { game.players.find { |player| player.id == 'b' } }
  let(:player_3) { game.players.find { |player| player.id == 'c' } }
  let(:player_4) { game.players.find { |player| player.id == 'd' } }
  let(:player_5) { game.players.find { |player| player.id == 'e' } }
  let(:player_6) { game.players.find { |player| player.id == 'f' } }
  let(:player_7) { game.players.find { |player| player.id == 'g' } }

  def pass(entity)
    game.process_action(Engine::Action::Pass.new(entity)).maybe_raise!
  end

  def buy(player, company_id)
    game.process_action(Engine::Action::Bid.new(player, company: game.company_by_id(company_id),
                                                        price: game.company_by_id(company_id).value)).maybe_raise!
  end

  def buy_shares(player, corporation_id, percent = nil, other_player = nil)
    corp = game.corporation_by_id(corporation_id)
    unless other_player
      return game.process_action(Engine::Action::BuyShares.new(player,
                                                               shares: corp.shares.find(&:buyable))).maybe_raise!
    end

    game.process_action(Engine::Action::BuyShares.new(player, shares: other_player.shares_of(corp).find do |share|
      share.percent == percent
    end)).maybe_raise!
  end

  describe 'after_starter_pack_player_order_3' do
    let(:players) { %w[a b c] }
    let(:game) { Engine::Game::G1835::Game.new(players) }

    it 'should not move the PD if everyone passes' do
      3.times do |index|
        pass(game.players[index])
      end
      expect(game.players.first).to eq(player_1)
    end

    it 'should skip a player without money' do
      buy(player_1, 'NF') # player_1 down to 500
      pass(player_2)
      pass(player_3)
      buy(player_1, '1') # player_1 down to 420
      pass(player_2)
      pass(player_3)
      buy(player_1, 'LD') # player_1 down to 230
      pass(player_2)
      pass(player_3)
      buy(player_1, '2') # player_1 down to 60
      pass(player_2)
      pass(player_3)
      # player_1 is skipped, so the draft round ends
      expect(game.players.first).to eq(player_2)
    end
    it 'should skip two players without money' do
      buy(player_1, 'NF') # player_1 down to 500
      buy(player_2, '1') # player_2 down to 520
      pass(player_3)
      buy(player_1, 'LD') # player_1 down to 310
      buy(player_2, '2') # player_2 down to 350
      pass(player_3)
      buy(player_1, '3') # player_1 down to 230
      buy(player_2, '4') # player_2 down to 190
      pass(player_3)
      buy(player_1, 'BY_D') # player_1 down to 46
      buy(player_2, 'BB') # player_1 down to 60
      buy(player_3, 'HB')
      # player_1 is skipped
      # player_2 is skipped
      buy(player_3, '5')
      # player_1 is skipped
      # player_2 is skipped
      pass(player_3)
      expect(game.players.first).to eq(player_1)
    end
    it 'should set the PD properly after the full sale of the starter packet' do
      buy(player_1, 'NF')
      buy(player_2, '1')
      buy(player_3, 'LD')
      buy(player_1, '2')
      buy(player_2, '3')
      buy(player_3, '4')
      buy(player_1, 'BY_D')
      buy(player_2, 'HB')
      buy(player_3, '5')
      buy(player_1, 'BB')
      buy(player_2, '6')
      buy(player_3, 'PB')
      # player_1 is skipped
      buy(player_2, 'OBB')

      expect(game.players.first).to eq(player_3)
    end
  end

  describe 'after_starter_pack_player_order_4' do
    let(:players) { %w[a b c d] }
    let(:game) { Engine::Game::G1835::Game.new(players) }

    it 'should not move the PD if everyone passes' do
      4.times do |index|
        pass(game.players[index])
      end
      expect(game.players.first).to eq(player_1)
    end

    it 'should set the PD properly after the full sale of the starter packet' do
      buy(player_1, 'NF')
      buy(player_2, 'LD')
      pass(player_3)
      buy(player_4, '1')
      buy(player_1, '2')
      buy(player_2, 'BY_D')
      buy(player_3, '4')
      buy(player_4, '3')
      pass(player_1)
      # player_2 is skipped. Still has 101, but no current option
      buy(player_3, 'BB')
      buy(player_4, 'PB')
      buy(player_1, 'OBB')
      buy(player_2, '5')
      buy(player_3, 'HB')
      pass(player_4)
      buy(player_1, '6')

      expect(game.players.first).to eq(player_2)
    end
  end

  describe 'after_starter_pack_player_order_5' do
    let(:players) { %w[a b c d e] }
    let(:game) { Engine::Game::G1835::Game.new(players) }

    it 'should not move the PD if everyone passes' do
      5.times do |index|
        pass(game.players[index])
      end
      expect(game.players.first).to eq(player_1)
    end

    it 'should set the PD properly after the full sale of the starter packet' do
      buy(player_1, 'NF')
      buy(player_2, '1')
      buy(player_3, 'LD')
      buy(player_4, '2')
      buy(player_5, '3')
      buy(player_1, '4')
      buy(player_2, 'BY_D')
      buy(player_3, 'BB')
      buy(player_4, 'HB')
      buy(player_5, '5')
      buy(player_1, '6')
      buy(player_2, 'OBB')
      # player 3 is skipped
      # player 4 is skipped
      buy(player_5, 'PB')
      expect(game.players.first).to eq(player_1)
    end
  end

  describe 'after_starter_pack_player_order_6' do
    let(:players) { %w[a b c d e f] }
    let(:game) { Engine::Game::G1835::Game.new(players) }

    it 'should not move the PD if everyone passes' do
      6.times do |index|
        pass(game.players[index])
      end
      expect(game.players.first).to eq(player_1)
    end

    it 'should set the PD properly after the full sale of the starter packet' do
      buy(player_1, 'NF')
      buy(player_2, '1')
      buy(player_3, 'LD')
      buy(player_4, '2')
      buy(player_5, '3')
      buy(player_6, '4')
      buy(player_1, 'BY_D')
      buy(player_2, 'BB')
      buy(player_3, 'PB')
      buy(player_4, 'HB')
      buy(player_5, 'OBB')
      buy(player_6, '5')
      # player 1 is skipped
      buy(player_2, '6')
      expect(game.players.first).to eq(player_3)
    end
  end

  describe 'after_starter_pack_player_order_7' do
    let(:players) { %w[a b c d e f g] }
    let(:game) { Engine::Game::G1835::Game.new(players) }

    it 'should not move the PD if everyone passes' do
      7.times do |index|
        pass(game.players[index])
      end
      expect(game.players.first).to eq(player_1)
    end

    it 'should set the PD properly after the full sale of the starter packet' do
      buy(player_1, 'NF')
      buy(player_2, '1')
      buy(player_3, 'LD')
      buy(player_4, '2')
      buy(player_5, '3')
      buy(player_6, '4')
      buy(player_7, 'BY_D')
      buy(player_1, 'BB')
      buy(player_2, 'HB')
      buy(player_3, '5')
      buy(player_4, '6')
      buy(player_5, 'OBB')
      buy(player_6, 'PB')
      expect(game.players.first).to eq(player_7)
    end
  end

  describe 'start_packet_sale' do
    let(:players) { %w[a b c] }

    def may_purchase?(company_id)
      game.active_step.may_purchase?(game.company_by_id(company_id))
    end

    it 'should implement the vanilla start packet draft' do
      %w[NF 1].each do |company_id|
        expect(may_purchase?(company_id)).to be true
      end
      %w[LD 2 3 4 BY_D BB HB 5 6 OBB PB].each do |company_id|
        expect(may_purchase?(company_id)).to be false
      end

      # players buy the second row
      buy(player_1, '1')
      expect(may_purchase?('LD')).to be true

      buy(player_2, 'LD')
      expect(may_purchase?('2')).to be true

      buy(player_3, '2')

      # now the first row has minor 1 and the second row is empty. The third row is still not purchasable
      %w[3 4 BY_D BB HB 5 6 OBB PB].each do |company_id|
        expect(may_purchase?(company_id)).to be false
      end

      buy(player_1, 'NF')

      # now the first and second row are empty, the entire third row becomes available
      %w[3 4 BY_D BB].each do |company_id|
        expect(may_purchase?(company_id)).to be true
      end
      %w[5 6 OBB PB].each do |company_id|
        expect(may_purchase?(company_id)).to be false
      end

      buy(player_2, '3')
      buy(player_3, '4')

      # there are still 2 companies in the third row, so the entire last row is unavailable
      %w[5 6 OBB PB].each do |company_id|
        expect(may_purchase?(company_id)).to be false
      end

      buy(player_1, 'BB')

      # only one company (BY_D) left in the third row, first company of row four must be available
      expect(may_purchase?('HB')).to be true
      %w[6 OBB PB].each do |company_id|
        expect(may_purchase?(company_id)).to be false
      end

      buy(player_2, 'HB')
      buy(player_3, '5')
      pass(player_1)
      buy(player_2, '6')
      pass(player_3)
      buy(player_1, 'OBB')
      # player_2 is out of money
      pass(player_3)
      buy(player_1, 'PB')
      # player_2 is out of money
      buy(player_3, 'BY_D')

      # START PACKET SOLD

      # player 3 bought the BY director share, but player 1 already had 30%, so player 1 must be the director
      expect(by.owner).to eq(player_1)

      expect(game.minor_by_id('1').owner).to eq(player_1)
    end
  end

  def sell_start_packet
    buy(player_1, 'NF')
    buy(player_2, '2')
    buy(player_3, 'LD')
    buy(player_1, '1')
    buy(player_2, '3')
    buy(player_3, '4')
    buy(player_1, 'BY_D')
    buy(player_2, 'BB')
    buy(player_3, 'HB')
    buy(player_1, 'OBB')
    buy(player_2, '5')
    buy(player_3, '6')
    buy(player_1, 'PB')

    expect(player_1.percent_of(by)).to be 50
    expect(player_3.percent_of(game.corporation_by_id('SX'))).to be 20

    # player_2 has priority deal
    expect(game.players.first).to eq(player_2)
    # Final distribution is:
    # player 1: NF, 1, OBB, PR, 50% BY
    # player 2: 2, 3, 5, BB
    # player 3: 4, 6, HB, 20% SX
  end

  describe 'cert_limit' do
    let(:players) { %w[a b c] }

    it 'increases the cert limit when having 80% or more of a corp' do
      expect(game.cert_limit(player_1)).to be 19
      expect(game.cert_limit(player_2)).to be 19
      expect(game.cert_limit(player_3)).to be 19

      player_1.set_cash(3000, game.bank)
      player_2.set_cash(3000, game.bank)
      player_3.set_cash(3000, game.bank)
      sell_start_packet

      pass(player_2)
      pass(player_3)
      3.times do
        buy_shares(player_1, 'BY')
        pass(player_2)
        pass(player_3)
      end

      expect(player_1.percent_of(by)).to be 80
      expect(game.cert_limit(player_1)).to be 20
      expect(game.cert_limit(player_2)).to be 19
      expect(game.cert_limit(player_3)).to be 19

      8.times do
        buy_shares(player_1, 'SX')
        pass(player_2)
        pass(player_3)
      end

      expect(player_1.percent_of(game.corporation_by_id('SX'))).to be 80
      expect(game.cert_limit(player_1)).to be 21
      expect(game.cert_limit(player_2)).to be 19
      expect(game.cert_limit(player_3)).to be 19
    end
  end

  describe 'cert_packages_in_SR' do
    let(:players) { %w[a b c] }
    def purchasable?(corporation)
      game.corporation_available?(corporation) && corporation.ipoed
    end

    it 'is makes cert packages available at the proper time' do
      # we test the availability of all cert packages before the first OR by giving everyone a lot of money.
      # By doing this we don't have to bother with 'pass' actions after buying, because as long as a company hasn't operated,
      # its shares cannot be sold, so 'pass' is not an option after buying
      player_1.set_cash(3000, game.bank)
      player_2.set_cash(3000, game.bank)
      player_3.set_cash(3000, game.bank)
      sell_start_packet

      %w[BA WT HE PR OL MS].map { |id| game.corporation_by_id(id) }.each { |corp| expect(purchasable?(corp)).to be false }

      # let player 1 buy BY up to 100%
      5.times do
        pass(player_2)
        pass(player_3)
        buy_shares(player_1, 'BY')
      end
      pass(player_2)

      # let player 3 buy SX up to 100%
      7.times do
        buy_shares(player_3, 'SX')
        pass(player_1)
        pass(player_2)
      end
      buy_shares(player_3, 'SX')
      # first package gone, BA, WT, HE, and PR get IPO'ed, but only BA can be purchased
      %w[BA WT HE PR].map { |id| game.corporation_by_id(id) }.each { |corp| expect(corp.ipoed).to be true }
      expect(game.corporation_available?(ba)).to be true
      %w[WT HE PR].map { |id| game.corporation_by_id(id) }.each { |corp| expect(game.corporation_available?(corp)).to be false }
      %w[OL MS].map { |id| game.corporation_by_id(id) }.each { |corp| expect(purchasable?(corp)).to be false }

      # buying the BA director makes PR available
      buy_shares(player_1, 'BA')
      expect(game.corporation_available?(pr)).to be true
      3.times do
        pass(player_2)
        pass(player_3)
        buy_shares(player_1, 'BA')
      end

      # buying 50% of BA makes WT available
      expect(game.corporation_available?(game.corporation_by_id('WT'))).to be true

      3.times do
        buy_shares(player_2, 'WT')
        pass(player_3)
        buy_shares(player_1, 'BA')
      end
      expect(game.corporation_available?(game.corporation_by_id('HE'))).to be false

      # buying 50% of WT makes HE available
      buy_shares(player_2, 'WT')
      expect(game.corporation_available?(game.corporation_by_id('HE'))).to be true

      7.times do
        buy_shares(player_3, 'HE')
        pass(player_1)
        pass(player_2)
      end
      buy_shares(player_3, 'PR')
      buy_shares(player_1, 'PR')
      buy_shares(player_2, 'PR')
      buy_shares(player_3, 'PR')

      buy_shares(player_1, 'WT')
      buy_shares(player_2, 'WT')
      buy_shares(player_3, 'WT')

      # There are now one BA, one WT, and one HE share left, each has 20%
      %w[BA WT HE].map { |corp_id| game.corporation_by_id(corp_id) }.each { |corp| expect(corp.shares.first.percent).to be 20 }

      # player_1 and player_3 have reached the cert limit
      pass(player_1)
      buy_shares(player_2, 'WT')
      [player_3, player_1].each { |player| pass(player) }
      buy_shares(player_2, 'BA')
      [player_3, player_1].each { |player| pass(player) }

      %w[OL MS].map { |id| game.corporation_by_id(id) }.each { |corp| expect(purchasable?(corp)).to be false }

      # let's buy the last share of the package IPO-ing MS and OL and making MS available
      buy_shares(player_2, 'HE')
      %w[OL MS].map { |id| game.corporation_by_id(id) }.each { |corp| expect(corp.ipoed).to be true }
      expect(game.corporation_available?(game.corporation_by_id('MS'))).to be true
      [player_3, player_1].each { |player| pass(player) }

      # let's buy the first three MS shares and check if we got 60%
      3.times do
        buy_shares(player_2, 'MS')
        [player_3, player_1].each { |player| pass(player) }
      end

      expect(player_2.percent_of(game.corporation_by_id('MS'))).to be 60

      # let's buy the first three OL shares and check if we got 60%
      3.times do
        buy_shares(player_2, 'OL')
        [player_3, player_1].each { |player| pass(player) }
      end

      expect(player_2.percent_of(game.corporation_by_id('OL'))).to be 60
    end
  end

  describe 'PR_conversion' do
    let(:players) { %w[a b c] }
    def bring_game_to_pr_conversion
      player_1.set_cash(3000, game.bank)
      player_2.set_cash(3000, game.bank)
      player_3.set_cash(3000, game.bank)
      sell_start_packet
      game.players.each do |player|
        pass(player)
      end
      minor_1 = game.minor_by_id('1')
      minor_1.set_cash(3000, game.bank)
      pass(minor_1) # skip track

      # let's remove all trains before the 4T
      %w[2 2+2 3 3+3].each { |train| game.depot.export_all!(train) }

      # and then buy that to trigger the PR conversion
      train = game.depot.depot_trains.first
      game.process_action(Engine::Action::BuyTrain.new(minor_1, train: train, price: train.price))

      expect(game.active_step.current_actions).to include('choose')
    end

    it 'should continue with minor 2 in the OR after 1 triggered the PR conversion and 2 declines' do
      bring_game_to_pr_conversion

      game.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'decline'))
      expect(game.current_entity).to eq(game.minor_by_id('2'))
      expect(game.active_step.current_actions).not_to include('choose')
      expect(game.round.class.short_name).to eq('OR')
    end

    it 'should let the owner of minor 2 convert all of their preprussians and privates first' do
      bring_game_to_pr_conversion

      expect(game.current_entity.owner).to eq(player_2)
      game.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'form'))
      expect(game.current_entity.owner).to eq(player_2)
      game.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'fold_in'))
      expect(game.current_entity.owner).to eq(player_2)
      game.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'fold_in'))
      expect(game.current_entity.owner).to eq(player_2)
      game.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'fold_in'))

      expect(player_2.percent_of(pr)).to be 30
    end

    it 'should transfer the ownership of PR if another player converts more shares' do
      bring_game_to_pr_conversion

      expect(game.current_entity.owner).to eq(player_2)
      game.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'form'))
      expect(game.current_entity.owner).to eq(player_2)
      game.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'decline'))
      expect(game.current_entity.owner).to eq(player_2)
      game.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'decline'))
      expect(game.current_entity.owner).to eq(player_2)
      game.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'decline'))

      expect(game.current_entity).to eq(game.minor_by_id('4'))
      game.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'fold_in'))
      expect(game.current_entity).to eq(game.minor_by_id('6'))
      game.process_action(Engine::Action::Choose.new(game.current_entity, choice: 'fold_in'))

      expect(player_2.percent_of(pr)).to be 10
      expect(player_3.percent_of(pr)).to be 15
      expect(pr.owner).to eq(player_3)
    end
  end

  describe 'nationalization' do
    let(:players) { %w[a b c] }
    it 'is possible to nationalize' do
      # ignore cash limits for now....
      player_1.set_cash(3000, game.bank)
      player_2.set_cash(3000, game.bank)
      player_3.set_cash(3000, game.bank)
      sell_start_packet

      buy_shares(player_2, 'BY')
      pass(player_3)
      buy_shares(player_1, 'BY')
      # player_1 now has 60% and player_2 has 10% of BY, so player_1 can nationalize
      pass(player_2)
      pass(player_3)

      nationalization_price = 138 # BY stock value is 92
      # give player 1 exactly the money they need for the nationlization
      player_1.set_cash(nationalization_price, game.bank)
      player_1_cash_before = player_1.cash
      player_2_cash_before = player_2.cash
      buy_shares(player_1, 'BY', 10, player_2)
      expect(player_1.percent_of(by)).to be 70
      expect(player_2.percent_of(by)).to be 0
      expect(player_1.cash).to be(player_1_cash_before - nationalization_price)
      expect(player_2.cash).to be(player_2_cash_before + nationalization_price)
    end
  end
end
