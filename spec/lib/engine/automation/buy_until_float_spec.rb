# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/automation'
require 'engine/automation/buy_until_float'
require 'engine/game/g_1889'
require 'engine/action/par'
require 'engine/action/pass'

module Engine
  module Automation
    describe BuyUntilFloat do
      let(:game) { Game::G1889.new(%w[a b]) }
      let(:corporation) { game.corporations.first }
      let(:player) { game.players.first }
      let(:subject) { BuyUntilFloat.new(entity: corporation, id: 101) }

      def move_to_sr!
        # Move the game into an SR

        game.send(:next_round!) until game.round.is_a?(Round::Stock)

        game.round
      end

      def pass_until_player
        game.process_action(Action::Pass.new(game.round.current_entity)) while game.current_entity != player
      end

      describe '#run' do
        it 'disables when not in a stock round' do
          subject.run(game)
          expect(subject.disabled).to be_a(String)
        end
        it 'disabled when the company has not ipoed' do
          move_to_sr!
          subject.run(game)
          expect(subject.disabled).to be_a(String)
        end
        it 'buys when in stock round and company is not floated' do
          move_to_sr!
          pass_until_player
          par = Action::Par.new(player, corporation: corporation, share_price: game.stock_market.par_prices.last)
          game.process_action(par)

          expect(corporation.ipoed).to be true
          owned = player.num_shares_of(corporation)

          pass_until_player
          subject.run(game)

          expect(player.num_shares_of(corporation)).to be > owned
          expect(subject.disabled).to be false
        end
        it 'disables when company is floated' do
          move_to_sr!
          pass_until_player
          player.cash = 10_000
          par = Action::Par.new(player, corporation: corporation, share_price: game.stock_market.par_prices.last)
          game.process_action(par)

          expect(corporation.ipoed).to be true
          owned = player.num_shares_of(corporation)
          until corporation.floated?
            pass_until_player

            subject.run(game)
            expect(subject.disabled).to be false
            expect(player.num_shares_of(corporation)).to be > owned
            owned = player.num_shares_of(corporation)
          end

          pass_until_player
          subject.run(game)

          expect(subject.disabled).to be_a(String)
        end
      end
    end
  end
end
