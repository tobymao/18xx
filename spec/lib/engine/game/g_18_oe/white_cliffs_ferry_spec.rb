# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE White Cliffs Ferry (§11.2.2, §14.7)' do
  include G18OESpecHelpers

  [
    ['18OE', Engine::Game::G18OE::Game],
    ['18OE UK-FR', Engine::Game::G18OEUKFR::Game],
  ].each do |title, klass|
    context "in #{title}" do
      let(:game) { new_game(klass: klass) }
      let(:owner) { game.players[0] }
      let(:other) { game.players[1] }
      let(:wcf) { give_company!(owner, game.company_by_id('WCF')) }
      let(:lille) { game.hex_by_id('N31').tile.cities.first }

      def token_step_round!(game, operator, phase: '5')
        game.phase.next! until game.phase.name == phase
        game.minor_regional_order.delete(operator)
        game.minor_regional_order.unshift(operator)
        round = enter_round!(game, game.operating_round(1))
        round.setup
        round_step(round, Engine::Step::Track).pass!
        round
      end

      def fill_lille!(game, id = 'PLM')
        blocker = start_regional!(game, id, other)
        lille.place_token(blocker, blocker.next_token, free: true)
        blocker
      end

      def special_token(round)
        round_step(round, Engine::Step::SpecialToken)
      end

      def place_in_lille!(round, operator)
        act!(round, Engine::Action::PlaceToken.new(wcf, city: lille, tokener: operator))
      end

      it 'offers no WCF action before Train Phase 5 (§14.7)' do
        operator = start_major!(game, 'LNWR', owner)
        wcf
        round = token_step_round!(game, operator, phase: '4')

        expect(round.current_operator).to eq(operator)
        expect(special_token(round).actions(wcf)).to eq([])
      end

      it 'offers the WCF owner a place token action for a controlled RR from Train Phase 5 (§14.7)' do
        operator = start_major!(game, 'LNWR', owner)
        wcf
        round = token_step_round!(game, operator)

        expect(special_token(round).actions(wcf)).to eq(['place_token'])
      end

      it 'offers no WCF action to a player who does not own the RR' do
        operator = start_major!(game, 'LNWR', other)
        wcf
        round = token_step_round!(game, operator)

        expect(special_token(round).actions(wcf)).to eq([])
      end

      it 'places the token in an extra Lille position when the normal slot is taken (§11.2.2, §14.7)' do
        operator = start_major!(game, 'LNWR', owner)
        blocker = fill_lille!(game)
        wcf
        round = token_step_round!(game, operator)

        place_in_lille!(round, operator)

        expect(lille.tokens.map { |t| t&.corporation }).to eq([blocker])
        expect(lille.extra_tokens.map(&:corporation)).to eq([operator])
      end

      it 'takes the token price from the RR treasury and needs no connection (§11.2.2)' do
        operator = start_major!(game, 'LNWR', owner)
        fund!(game, operator, 200)
        fill_lille!(game)
        wcf
        round = token_step_round!(game, operator)
        price = operator.next_token.price

        expect { place_in_lille!(round, operator) }.to change { operator.cash }.by(-price)
      end

      it 'closes the private once used (§14.7)' do
        operator = start_major!(game, 'LNWR', owner)
        fund!(game, operator, 200)
        wcf
        round = token_step_round!(game, operator)

        place_in_lille!(round, operator)

        expect(wcf).to be_closed
        expect(owner.companies).not_to include(wcf)
      end

      it 'uses up the RR place token step for the round (§14.7)' do
        operator = start_major!(game, 'LNWR', owner)
        fund!(game, operator, 200)
        wcf
        round = token_step_round!(game, operator)

        place_in_lille!(round, operator)

        expect(round.tokened).to be(true)
        expect(round_step(round, Engine::Game::G18OE::Step::Token).actions(operator)).to eq([])
      end

      it 'leaves a normal token placed in Lille in the normal position without using the private' do
        operator = start_major!(game, 'LNWR', owner)
        fund!(game, operator, 200)
        wcf
        round = token_step_round!(game, operator)
        step = round_step(round, Engine::Game::G18OE::Step::Token)

        step.place_token(operator, lille, operator.next_token, connected: false)

        expect(lille.tokens.map { |t| t&.corporation }).to eq([operator])
        expect(lille.extra_tokens).to eq([])
        expect(wcf).not_to be_closed
      end

      it 'keeps the Place Token step open for the private when the RR cannot place a normal token' do
        operator = start_major!(game, 'LNWR', owner)
        wcf
        round = token_step_round!(game, operator)
        allow(game.token_graph_for_entity(operator)).to receive(:can_token?).and_return(false)

        expect(round_step(round, Engine::Game::G18OE::Step::Token).actions(operator)).to eq(%w[place_token pass])
      end

      it 'does not open the Place Token step for a RR whose president lacks the private' do
        operator = start_major!(game, 'LNWR', other)
        wcf
        round = token_step_round!(game, operator)
        allow(game.token_graph_for_entity(operator)).to receive(:can_token?).and_return(false)

        expect(round_step(round, Engine::Game::G18OE::Step::Token).actions(operator)).to eq([])
      end

      it 'charges the token price even when Lille is already reachable' do
        operator = start_major!(game, 'LNWR', owner)
        token = operator.next_token

        expect(wcf.abilities.first.price(token)).to eq(token.price)
      end
    end
  end
end
