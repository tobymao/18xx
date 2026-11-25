# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Star Harbor and Central Circle pass-through tokens (§14.5, §14.6)' do
  include G18OESpecHelpers

  [
    ['18OE', Engine::Game::G18OE::Game],
    ['18OE UK-FR', Engine::Game::G18OEUKFR::Game],
  ].each do |title, klass|
    context "in #{title}" do
      let(:game) { new_game(klass: klass) }
      let(:owner) { game.players[0] }
      let(:other) { game.players[1] }
      let(:shtc) { give_company!(owner, game.company_by_id('SHTC')) }
      let(:cctc) { give_company!(owner, game.company_by_id('CCTC')) }
      let(:port_hex) { game.hexes.find { |hex| game.pass_through_hex?(game.company_by_id('SHTC'), hex) } }
      let(:plain_hex) { game.hexes.find { |hex| game.pass_through_hex?(game.company_by_id('CCTC'), hex) } }
      let(:port_city) { port_hex.tile.cities.first }
      let(:plain_city) { plain_hex.tile.cities.first }

      def token_step_round!(game, operator)
        game.minor_regional_order.delete(operator)
        game.minor_regional_order.unshift(operator)
        round = enter_round!(game, game.operating_round(1))
        round.setup
        round_step(round, Engine::Step::Track).pass!
        round
      end

      def special_token(round)
        round_step(round, Engine::Step::SpecialToken)
      end

      def token_step(round)
        round_step(round, Engine::Game::G18OE::Step::Token)
      end

      def place!(round, company, operator, city)
        act!(round, Engine::Action::PlaceToken.new(company, city: city, tokener: operator))
      end

      it 'offers the owner of SHTC a place token action for a controlled RR' do
        operator = start_major!(game, 'LNWR', owner)
        shtc
        round = token_step_round!(game, operator)

        expect(special_token(round).actions(shtc)).to eq(['place_token'])
      end

      it 'places the SHTC token in any port city for free in an extra slot without using the private (§14.5)' do
        operator = start_major!(game, 'LNWR', owner)
        shtc
        round = token_step_round!(game, operator)
        slots = port_city.tokens.dup

        expect { place!(round, shtc, operator, port_city) }.not_to(change { operator.cash })

        expect(port_city.tokens).to eq(slots)
        expect(port_city.extra_tokens.map(&:corporation)).to eq([operator])
        expect(port_city.extra_tokens.map(&:type)).to eq([:pass_through])
        expect(shtc.owner).to eq(owner)
        expect(shtc).not_to be_closed
        expect(shtc.revenue).to eq(15)
        expect(special_token(round).actions(shtc)).to eq([])
      end

      it 'places the CCTC token in a non-port city, including Lille (§14.6)' do
        operator = start_major!(game, 'LNWR', owner)
        cctc
        round = token_step_round!(game, operator)

        place!(round, cctc, operator, plain_city)

        expect(plain_city.extra_tokens.map(&:corporation)).to eq([operator])
      end

      it 'allows the CCTC token on Lille' do
        operator = start_major!(game, 'LNWR', owner)
        cctc
        round = token_step_round!(game, operator)

        place!(round, cctc, operator, game.lille_city)

        expect(game.lille_city.extra_tokens.map(&:corporation)).to include(operator)
      end

      it 'rejects the CCTC token in a port city (§14.6)' do
        operator = start_major!(game, 'LNWR', owner)
        cctc
        round = token_step_round!(game, operator)

        expect { place!(round, cctc, operator, port_city) }.to raise_error(Engine::GameError)
        expect(port_city.extra_tokens).to be_empty
      end

      it 'rejects the SHTC token in a non-port city (§14.5)' do
        operator = start_major!(game, 'LNWR', owner)
        shtc
        round = token_step_round!(game, operator)

        expect { place!(round, shtc, operator, plain_city) }.to raise_error(Engine::GameError)
      end

      it 'does not use the RR token placement, so a normal token can still be laid (§14.5)' do
        operator = start_major!(game, 'LNWR', owner)
        fund!(game, operator, 200)
        shtc
        round = token_step_round!(game, operator)

        place!(round, shtc, operator, port_city)
        step = token_step(round)

        expect(round.tokened).to be(false)
        expect(step.actions(operator)).to eq(%w[place_token pass])
        expect(operator.tokens).not_to include(port_city.extra_tokens.first)

        open_city = game.hexes.flat_map { |hex| hex.tile.cities }.find do |city|
          city.available_slots.positive? && !city.reserved_by?(operator) && !city.tokened_by?(operator)
        end
        step.place_token(operator, open_city, operator.next_token, connected: false)

        expect(open_city.tokens.map { |t| t&.corporation }).to include(operator)
        expect(round.tokened).to be(true)
      end

      it 'keeps the Place Token step open while the token is unused even when no normal token can be laid' do
        operator = start_major!(game, 'LNWR', owner)
        shtc
        round = token_step_round!(game, operator)
        allow(game.token_graph_for_entity(operator)).to receive(:can_token?).and_return(false)

        expect(token_step(round).actions(operator)).to eq(%w[place_token pass])
      end

      it 'closes the Place Token step again once nothing can be placed' do
        operator = start_major!(game, 'LNWR', owner)
        shtc
        round = token_step_round!(game, operator)
        place!(round, shtc, operator, port_city)
        allow(game.token_graph_for_entity(operator)).to receive(:can_token?).and_return(false)

        expect(token_step(round).actions(operator)).to eq([])
      end

      it 'rejects a city where the RR already has a token' do
        operator = start_major!(game, 'LNWR', owner)
        shtc
        round = token_step_round!(game, operator)
        port_city.place_token(operator, operator.next_token, free: true)

        expect { place!(round, shtc, operator, port_city) }.to raise_error(Engine::GameError)
      end

      it 'rejects a city reserved by the RR' do
        operator = start_major!(game, 'LNWR', owner)
        shtc
        round = token_step_round!(game, operator)
        port_city.add_reservation!(operator)

        expect { place!(round, shtc, operator, port_city) }.to raise_error(Engine::GameError)
      end

      it 'accepts a city already full of other RRs tokens and leaves their slots alone (§14.5)' do
        operator = start_major!(game, 'LNWR', owner)
        blocker = start_regional!(game, 'PLM', other)
        shtc
        round = token_step_round!(game, operator)
        port_city.tokens.each_index { |i| port_city.tokens[i] ||= Engine::Token.new(blocker) }
        port_city.tokens.each { |t| t.place(port_city) if t.city.nil? }
        slots = port_city.tokens.dup

        place!(round, shtc, operator, port_city)

        expect(port_city.tokens).to eq(slots)
        expect(port_city.blocks?(blocker)).to be(false)
        expect(port_city.blocks?(operator)).to be(false)
        third = game.corporations.find { |c| c.type == :regional && ![blocker, operator].include?(c) }
        expect(port_city.blocks?(third)).to be(true)
        expect(port_city.extra_tokens.map(&:corporation)).to eq([operator])
      end

      it 'rejects another city of a hex where the RR already has a token', if: klass == Engine::Game::G18OE::Game do
        operator = start_major!(game, 'LNWR', owner)
        shtc
        round = token_step_round!(game, operator)
        first, second = game.hex_by_id('AA82').tile.cities
        first.place_token(operator, operator.next_token, free: true, check_tokenable: false)

        expect { place!(round, shtc, operator, second) }.to raise_error(Engine::GameError)
      end

      it 'processes the UI built action from its serialized form on replay' do
        operator = start_major!(game, 'LNWR', owner)
        shtc
        round = token_step_round!(game, operator)
        action = Engine::Action::PlaceToken.new(shtc, city: port_city, tokener: operator, token_type: :pass_through)

        rebuilt = Engine::Action::Base.action_from_h(action.to_h, game)
        game.instance_variable_set(:@loading, true)
        act!(round, rebuilt)

        expect(port_city.extra_tokens.map(&:corporation)).to eq([operator])
      end

      it 'lists the token on the RR charter status' do
        operator = start_major!(game, 'LNWR', owner)
        shtc
        round = token_step_round!(game, operator)

        place!(round, shtc, operator, port_city)

        line = "#{shtc.name} token: #{port_hex.name} (#{port_hex.location_name})"
        expect(game.status_array(operator)).to include([line])
      end
    end
  end

  it 'identifies port hexes from the port arrows' do
    game = new_game
    expect([game.port_hex?(game.hex_by_id('AD1')), game.port_hex?(game.hex_by_id('N31'))]).to eq([true, false])
  end
end
