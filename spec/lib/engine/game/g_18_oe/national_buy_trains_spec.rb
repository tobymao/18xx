# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE National Buy Trains' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }

  def train_named(name)
    game.depot.upcoming.find { |t| t.name == name }
  end

  def works_train!(name)
    train = train_named(name)
    train.rusted = true
    game.depot.reclaim_train(train)
    train
  end

  def owned_rusted_train!(owner, name)
    train = train_named(name)
    game.buy_train(owner, train, :free)
    train.rusted = true
    train
  end

  def national_for(owner_major)
    game.phase.next! until game.phase.name == '5'
    game.form_national!(owner_major)
    owner_major
  end

  describe 'game methods' do
    let(:lnwr) { fund!(game, start_major!(game, 'LNWR', player), 500) }

    describe '#national_claimable_trains' do
      it 'lists one train per sym' do
        works_train!('2+2')
        works_train!('2+2')
        works_train!('2+2')
        three = works_train!('3')

        expect(game.national_claimable_trains.map(&:sym)).to eq(game.national_claimable_trains.map(&:sym).uniq)
        expect(game.national_claimable_trains.size).to eq(2)
        expect(game.national_claimable_trains).to include(three)
      end
    end

    describe '#discard_discount' do
      it 'is zero for a rusted train' do
        expect(game.discard_discount(works_train!('3'), 100)).to eq(0)
      end

      it 'keeps the price of a non-rusted depot train' do
        expect(game.discard_discount(train_named('3'), 200)).to eq(200)
      end
    end

    describe '#discountable_trains_for' do
      it 'is the base behaviour for a major' do
        expect(game.discountable_trains_for(fund!(game, start_major!(game, 'GWR', player), 500))).to eq([])
      end

      it 'offers swaps to every variant of a higher level Works train' do
        two = owned_rusted_train!(lnwr, '2+2')
        national_for(lnwr)
        three = works_train!('3')
        works_two = works_train!('2+2')

        entries = game.discountable_trains_for(lnwr)

        expect(entries).to include([two, three, '3', 0], [two, three, '3+3', 0])
        expect(entries.map { |e| e[1] }).not_to include(works_two)
      end

      it 'offers no swap for a Works train of lower level' do
        owned_rusted_train!(lnwr, '4')
        national_for(lnwr)
        works_train!('3')

        expect(game.discountable_trains_for(lnwr)).to eq([])
      end

      it 'offers no swap once the national has upgraded' do
        owned_rusted_train!(lnwr, '2+2')
        national_for(lnwr)
        works_train!('3')
        enter_round!(game, Engine::Round::Operating.new(game, [Engine::Game::G18OE::Step::NationalBuyTrains], round_num: 1))
        game.round.national_upgraded = true

        expect(game.discountable_trains_for(lnwr)).to eq([])
      end

      it 'offers one set of swap rows for identical owned rusted trains' do
        first = owned_rusted_train!(lnwr, '2+2')
        owned_rusted_train!(lnwr, '2+2')
        national_for(lnwr)
        three = works_train!('3')

        entries = game.discountable_trains_for(lnwr)

        expect(entries).to contain_exactly([first, three, '3', 0], [first, three, '3+3', 0])
      end

      describe 'upgrades' do
        let(:gwr) { fund!(game, start_major!(game, 'GWR', player), 500) }

        it 'offers only trains of floated majors presided by the national owner' do
          gwr
          other = fund!(game, start_major!(game, 'PLM', game.players.last), 500)
          regional = start_regional!(game, 'MIDI', player)
          five = train_named('5')
          four = train_named('4')
          game.buy_train(gwr, five, :free)
          game.buy_train(gwr, four, :free)
          game.buy_train(gwr, train_named('Pullman'), :free)
          game.buy_train(other, train_named('6'), :free)
          game.buy_train(regional, train_named('3'), :free)
          rusted = owned_rusted_train!(lnwr, '2+2')
          national_for(lnwr)

          entries = game.discountable_trains_for(lnwr)

          expect(entries).to contain_exactly([rusted, five, '5', 0], [rusted, four, '4', 0])
        end

        it 'offers one upgrade row per owned rusted train for two identical trains of a seller' do
          first_four = train_named('4')
          game.buy_train(gwr, first_four, :free)
          game.buy_train(gwr, train_named('4'), :free)
          rusted = owned_rusted_train!(lnwr, '2+2')
          national_for(lnwr)

          entries = game.discountable_trains_for(lnwr)

          expect(entries.size).to eq(1)
          expect(entries.first[0]).to eq(rusted)
          expect(entries.first[1].name).to eq('4')
        end

        it 'still offers upgrades once the national has upgraded' do
          five = train_named('5')
          game.buy_train(gwr, five, :free)
          rusted = owned_rusted_train!(lnwr, '2+2')
          national_for(lnwr)
          enter_round!(game, Engine::Round::Operating.new(game, [Engine::Game::G18OE::Step::NationalBuyTrains], round_num: 1))
          game.round.national_upgraded = true

          expect(game.discountable_trains_for(lnwr)).to eq([[rusted, five, '5', 0]])
        end
      end
    end

    describe '#national_claim_train!' do
      it 'gives the national the Works train on the chosen variant for free' do
        national = national_for(lnwr)
        three = works_train!('3')
        cash = national.cash

        game.national_claim_train!(national, three, '3+3')

        expect(three.owner).to eq(national)
        expect(national.trains).to include(three)
        expect(three.name).to eq('3+3')
        expect(three.rusted).to be true
        expect(game.rusted_trains).not_to include(three)
        expect(national.cash).to eq(cash)
      end
    end

    describe '#national_swap_train!' do
      it 'returns the owned rusted train to the Works and claims the target' do
        two = owned_rusted_train!(lnwr, '2+2')
        national = national_for(lnwr)
        three = works_train!('3')

        game.national_swap_train!(national, two, three, '3')

        expect(game.rusted_trains).to include(two)
        expect(two.rusted).to be true
        expect(national.trains).to eq([three])
      end
    end

    describe '#national_upgrade_train!' do
      it 'pays the seller half the price from the bank and nothing from the national' do
        gwr = fund!(game, start_major!(game, 'GWR', player), 500)
        five = train_named('5')
        game.buy_train(gwr, five, :free)
        five.variant = '5+5'
        rusted = owned_rusted_train!(lnwr, '2+2')
        national = national_for(lnwr)
        gwr_cash = gwr.cash
        bank_cash = game.bank.cash
        national_cash = national.cash

        game.national_upgrade_train!(national, rusted, five)

        expect(gwr.cash).to eq(gwr_cash + 237)
        expect(game.bank.cash).to eq(bank_cash - 237)
        expect(national.cash).to eq(national_cash)
        expect(gwr.trains).not_to include(five)
        expect(national.trains).to eq([five])
        expect(five.rusted).to be_falsey
        expect(five.name).to eq('5+5')
        expect(game.rusted_trains).to include(rusted)
      end
    end

    it 'does not offer upgrades from an unfloated major presided by the national owner' do
      unfloated = game.corporation_by_id('GWR')
      unfloated.owner = player
      five = train_named('5')
      game.buy_train(unfloated, five, :free)
      owned_rusted_train!(lnwr, '2+2')
      national_for(lnwr)

      expect(unfloated.floated?).to be false
      expect(game.national_upgrade_trains(lnwr)).not_to include(five)
    end

    it 'does not offer upgrades from another national of the same president' do
      gwr = fund!(game, start_major!(game, 'GWR', player), 500)
      owned_rusted_train!(lnwr, '2+2')
      game.phase.next! until game.phase.name == '5'
      game.buy_train(gwr, train_named('5'), :free)
      game.form_national!(gwr)
      game.form_national!(lnwr)

      expect(game.national_upgrade_trains(lnwr)).to eq([])
    end

    it 'applies the chosen target variant on a swap' do
      two = owned_rusted_train!(lnwr, '2+2')
      national = national_for(lnwr)
      three = works_train!('3')

      game.national_swap_train!(national, two, three, '3+3')

      expect(three.name).to eq('3+3')
    end
  end

  describe 'step' do
    let(:lnwr) { fund!(game, start_major!(game, 'LNWR', player), 500) }
    let(:gwr) { fund!(game, start_major!(game, 'GWR', player), 500) }
    let(:step_class) { Engine::Game::G18OE::Step::NationalBuyTrains }

    def national_round!(national)
      round = Engine::Round::Operating.new(game, [step_class], round_num: 1)
      round.entities = [national]
      round.instance_variable_set(:@current_operator, national)
      enter_round!(game, round)
    end

    def buy!(round, national, train, variant: nil, exchange: nil, price: 0)
      act!(round, Engine::Action::BuyTrain.new(national, train: train, price: price, variant: variant, exchange: exchange))
    end

    def give_upgradeable_five!
      five = train_named('5')
      game.buy_train(gwr, five, :free)
      five
    end

    it 'lets a national with room claim a rusted train on a chosen variant for nothing' do
      three = works_train!('3')
      national = national_for(lnwr)
      round = national_round!(national)

      buy!(round, national, three, variant: '3+3')

      expect(national.trains).to eq([three])
      expect(three.name).to eq('3+3')
    end

    it 'accepts any copy of an identical rusted train' do
      works_train!('2+2')
      second = works_train!('2+2')
      national = national_for(lnwr)
      round = national_round!(national)

      buy!(round, national, second, variant: '2+2')

      expect(national.trains).to eq([second])
    end

    it 'refuses a claim at the train limit but still accepts a swap' do
      owned = [owned_rusted_train!(lnwr, '2+2'), owned_rusted_train!(lnwr, '2+2'),
               owned_rusted_train!(lnwr, '2+2'), owned_rusted_train!(lnwr, '2+2')]
      national = national_for(lnwr)
      three = works_train!('3')
      round = national_round!(national)
      step = round_step(round, step_class)

      expect(step.buyable_trains(national)).to eq([])
      expect { buy!(round, national, three, variant: '3') }.to raise_error(Engine::GameError)

      buy!(round, national, three, variant: '3', exchange: owned.first)

      expect(national.trains).to include(three)
    end

    it 'lets a rusted train returned by a swap be claimed again before an upgrade' do
      five = give_upgradeable_five!
      two = owned_rusted_train!(lnwr, '2+2')
      national = national_for(lnwr)
      three = works_train!('3')
      round = national_round!(national)

      buy!(round, national, three, variant: '3', exchange: two)
      buy!(round, national, two, variant: '2+2')

      expect(national.trains).to contain_exactly(three, two)

      buy!(round, national, five, variant: '5', exchange: two)

      expect(national.trains).to contain_exactly(three, five)
    end

    it 'accepts an upgrade when the national is at its train limit' do
      five = give_upgradeable_five!
      owned = Array.new(4) { owned_rusted_train!(lnwr, '2+2') }
      national = national_for(lnwr)
      round = national_round!(national)

      buy!(round, national, five, variant: '5', exchange: owned.first)

      expect(national.trains).to include(five)
      expect(national.trains.size).to eq(4)
    end

    it 'refuses a swap to a train of equal or lower level' do
      owned_three = owned_rusted_train!(lnwr, '3')
      national = national_for(lnwr)
      other = works_train!('3')
      round = national_round!(national)

      expect { buy!(round, national, other, variant: '3', exchange: owned_three) }.to raise_error(Engine::GameError)
    end

    it 'refuses a swap to a train that is not in the Works' do
      two = owned_rusted_train!(lnwr, '2+2')
      national = national_for(lnwr)
      depot_three = train_named('3')
      round = national_round!(national)

      expect { buy!(round, national, depot_three, variant: '3', exchange: two) }.to raise_error(Engine::GameError)
    end

    it 'refuses an upgrade from a major of another president' do
      other = fund!(game, start_major!(game, 'PLM', game.players.last), 500)
      five = train_named('5')
      game.buy_train(other, five, :free)
      two = owned_rusted_train!(lnwr, '2+2')
      national = national_for(lnwr)
      round = national_round!(national)

      expect { buy!(round, national, five, variant: '5', exchange: two) }.to raise_error(Engine::GameError)
    end

    it 'refuses a priced acquisition' do
      five = give_upgradeable_five!
      two = owned_rusted_train!(lnwr, '2+2')
      national = national_for(lnwr)
      round = national_round!(national)

      expect { buy!(round, national, five, variant: '5', exchange: two, price: 10) }.to raise_error(Engine::GameError)
    end

    it 'refuses an upgrade that changes the variant' do
      five = give_upgradeable_five!
      two = owned_rusted_train!(lnwr, '2+2')
      national = national_for(lnwr)
      round = national_round!(national)

      expect { buy!(round, national, five, variant: '5+5', exchange: two) }.to raise_error(Engine::GameError)
    end

    it 'upgrades from a major of the same president and pays the seller half' do
      five = give_upgradeable_five!
      two = owned_rusted_train!(lnwr, '2+2')
      national = national_for(lnwr)
      round = national_round!(national)
      cash = gwr.cash

      buy!(round, national, five, variant: '5', exchange: two)

      expect(national.trains).to eq([five])
      expect(gwr.cash).to eq(cash + (five.price.to_f / 2).floor)
    end

    it 'closes claims and swaps after an upgrade but allows another upgrade' do
      five = give_upgradeable_five!
      four = train_named('4')
      game.buy_train(gwr, four, :free)
      two = owned_rusted_train!(lnwr, '2+2')
      second_two = owned_rusted_train!(lnwr, '2+2')
      national = national_for(lnwr)
      works_three = works_train!('3')
      round = national_round!(national)

      buy!(round, national, five, variant: '5', exchange: two)

      expect { buy!(round, national, works_three, variant: '3') }.to raise_error(Engine::GameError)
      expect { buy!(round, national, works_three, variant: '3', exchange: second_two) }.to raise_error(Engine::GameError)

      buy!(round, national, four, variant: '4', exchange: second_two)

      expect(national.trains).to contain_exactly(five, four)
    end

    it 'offers no actions to a major' do
      national_for(fund!(game, start_major!(game, 'PLM', game.players.last), 500))
      works_train!('3')
      round = national_round!(lnwr)

      expect(round_step(round, step_class).actions(lnwr)).to eq([])
    end

    it 'offers no actions to a national with nothing to do' do
      national = national_for(lnwr)
      round = national_round!(national)

      expect(round_step(round, step_class).actions(national)).to eq([])
    end

    it 'offers buy_train and pass to a national that can claim' do
      works_train!('3')
      national = national_for(lnwr)
      round = national_round!(national)

      expect(round_step(round, step_class).actions(national)).to eq(%w[buy_train pass])
    end

    it 'refuses a claim with an invalid variant' do
      three = works_train!('3')
      national = national_for(lnwr)
      round = national_round!(national)

      expect { buy!(round, national, three, variant: '4') }.to raise_error(Engine::GameError)
    end

    it 'offers a single variant for a 2+2 claim and both for a 3 claim' do
      two = works_train!('2+2')
      three = works_train!('3')
      national = national_for(lnwr)
      round = national_round!(national)
      step = round_step(round, step_class)

      expect(step.buyable_train_variants(two, national).map { |v| v[:name] }).to eq(['2+2'])
      expect(step.buyable_train_variants(three, national).map { |v| v[:name] }).to contain_exactly('3', '3+3')
    end

    it 'passes the step once nothing remains to claim, swap or upgrade' do
      three = works_train!('3')
      national = national_for(lnwr)
      round = national_round!(national)
      step = round_step(round, step_class)

      buy!(round, national, three, variant: '3')

      expect(step.passed?).to be true
    end

    it 'offers actions in the full operating round and none in the abbreviated one' do
      works_train!('3')
      national = national_for(lnwr)
      round = national_round!(national)
      step = round_step(round, step_class)
      expect(step.actions(national)).to eq(%w[buy_train pass])

      allow(game).to receive(:abbreviated_operating_round?).and_return(true)

      expect(step.actions(national)).to eq([])
      step.log_skip(national)
      expect(game.log.map(&:message).join).not_to include('skips buy trains')
    end

    describe 'skip logging' do
      it 'does not log a skip for a major passing through the national step' do
        round = national_round!(lnwr)

        round_step(round, step_class).log_skip(lnwr)

        expect(game.log.map(&:message).join).not_to include('skips buy trains')
      end

      it 'does not log a skip from the regular Buy Trains step for a national' do
        national = national_for(lnwr)
        round = station_token_round!(game, national, step_class: Engine::Game::G18OE::Step::BuyTrain)

        round_step(round, Engine::Game::G18OE::Step::BuyTrain).log_skip(national)

        expect(game.log.map(&:message).join).not_to include('buy trains')
      end
    end

    it 'moves a major that converts during Buy Trains into the national step with claims on offer' do
      works_train!('3')
      game.phase.next! until game.phase.name == '5'
      round = game.operating_round(1)
      enter_round!(game, round)
      round.instance_variable_set(:@current_operator, lnwr)
      round.entities = [lnwr]
      round.instance_variable_set(:@entity_index, 0)
      round.steps.each(&:unpass!)
      buy_step = round_step(round, Engine::Game::G18OE::Step::BuyTrain)
      round.steps.take_while { |s| s != buy_step }.each(&:pass!)

      game.form_national!(lnwr)
      round.clear_cache!

      expect(round.active_step).to be_a(step_class)
      expect(round.actions_for(lnwr)).to eq(%w[buy_train pass])
    end
  end
end
