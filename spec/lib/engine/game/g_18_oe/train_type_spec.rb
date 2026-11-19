# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe '18OE train types on purchase (§11.6)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:buyer) { start_regional!(game, 'LNWR', game.players.first) }
  let(:seller) { start_regional!(game, 'PLM', game.players.last) }
  let(:train) { game.depot.upcoming.find { |t| t.name == '3' } }
  let(:step) { round_step(game.round, Engine::Game::G18OE::Step::BuyTrain) }

  before do
    buyer
    seller
    game.fulfill_train_obligation!(buyer)
    game.instance_variable_set(:@first_or_complete, true)
    allow(game).to receive(:major_phase?).and_return(true)
    game.depot.upcoming.select { |t| t.name == '2+2' }.each { |t| game.depot.remove_train(t) }
    fund!(game, buyer)
    enter_round!(game, game.operating_round(1))
  end

  def purchase(variant, price = 100)
    step.process_buy_train(Engine::Action::BuyTrain.new(buyer, train: train, variant: variant, price: price))
  end

  %w[3 3+3].each do |original|
    context "a railroad owns the #{original} side" do
      before do
        train.variant = original
        game.buy_train(seller, train, :free)
      end

      it 'offers only the current type' do
        expect(step.buyable_trains(buyer)).to include(train)
        expect(step.buyable_train_variants(train, buyer).map { |v| v[:name] }).to eq([original])
      end

      it 'rejects switching without changing the train or cash' do
        state = [train.variant, train.name, train.owner, buyer.cash, seller.cash, game.bank.cash,
                 buyer.trains.dup, seller.trains.dup]
        other = original == '3' ? '3+3' : '3'
        expect { purchase(other) }.to raise_error(Engine::GameError, /type/)
        expect([train.variant, train.name, train.owner, buyer.cash, seller.cash, game.bank.cash,
                buyer.trains, seller.trains]).to eq(state)
      end

      [original, nil].each do |requested|
        it "keeps the current type with #{requested ? 'an explicit variant' : 'no variant'} and pays the seller" do
          cash = [buyer.cash, seller.cash, game.bank.cash]
          purchase(requested)
          expect(train.name).to eq(original)
          expect(train.owner).to eq(buyer)
          expect(buyer.trains).to include(train)
          expect(seller.trains).not_to include(train)
          expect([buyer.cash, seller.cash, game.bank.cash]).to eq([cash[0] - 100, cash[1] + 100, cash[2]])
        end
      end

      %w[3 3+3].each do |requested|
        it "allows the Open Market to sell the #{requested} side at its face price" do
          game.depot.reclaim_train(train)
          expect(game.depot.discarded).to include(train)
          expect(step.buyable_train_variants(train, buyer).map { |v| v[:name] }).to match_array(%w[3 3+3])
          price = train.variants[requested][:price]
          cash = [buyer.cash, seller.cash, game.bank.cash]
          purchase(requested, price)
          expect(train.name).to eq(requested)
          expect(train.owner).to eq(buyer)
          expect(game.depot.discarded).not_to include(train)
          expect([buyer.cash, seller.cash, game.bank.cash]).to eq([cash[0] - price, cash[1], cash[2] + price])
        end
      end
    end
  end

  %w[3 3+3].each do |requested|
    it "allows a new #{requested} from the Works at its face price" do
      expect(step.buyable_train_variants(train, buyer).map { |v| v[:name] }).to match_array(%w[3 3+3])
      price = train.variants[requested][:price]
      cash = [buyer.cash, game.bank.cash]
      purchase(requested, price)
      expect(train.name).to eq(requested)
      expect(train.owner).to eq(buyer)
      expect([buyer.cash, game.bank.cash]).to eq([cash[0] - price, cash[1] + price])
    end
  end
end
