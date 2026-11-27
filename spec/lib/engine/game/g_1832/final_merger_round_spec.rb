# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1832::Game do
    let(:game) { Game::G1832::Game.new(%w[a b c]) }

    describe 'the merger round held for the final merger chance (first 6-train)' do
      let(:corporations) { game.corporations.first(3) }

      before do
        corporations.each { |corp| corp.owner = game.players.first }
        allow(game).to receive(:operating_order).and_return(corporations)
        game.instance_variable_set(:@operating_rounds, 2)
      end

      def start_or
        game.instance_variable_set(:@round, game.send(:new_operating_round))
        game.round
      end

      it 'builds the 1832 operating round' do
        expect(start_or).to be_a(Game::G1832::Round::Operating)
      end

      it 'interrupts the OR after the current entity, holds a merger round, then resumes with the rest' do
        round = start_or
        expect(round.entities).to eq(corporations)
        expect(round.current_entity).to eq(corporations[0])

        game.event_final_merger_chance!
        round.next_entity!

        expect(round).to be_finished
        game.send(:next_round!)
        expect(game.round).to be_a(Game::G1832::Round::Merger)

        game.send(:transition_to_next_round!)
        expect(game.round).to be(round)
        expect(game.round.entities).to eq(corporations[1..])
        expect(game.round.round_num).to eq(1)
        expect(game.final_merger_triggered?).to be(false)
      end

      it 'moves on to the next operating round when the last entity bought the 6-train' do
        round = start_or
        round.entity_index = corporations.size - 1
        game.event_final_merger_chance!
        round.next_entity!
        game.send(:next_round!)

        game.send(:transition_to_next_round!)
        expect(game.round).to be(round)
        expect(round).to be_finished
        game.send(:next_round!)

        expect(game.round).to be_a(Engine::Round::Operating)
        expect(game.round.round_num).to eq(2)
      end

      it 'slots a system formed in the merger round into the resumed round' do
        acl = game.corporation_by_id('ACL')
        salr = game.corporation_by_id('SALR')
        system = game.corporation_by_id('AMTK')
        grr = game.corporation_by_id('GRR')
        other = game.corporation_by_id('A&WP')
        par = game.stock_market.par_prices.find { |p| p.price == 100 }
        [acl, salr].each do |corp|
          game.par_corporation(corp, par)
          corp.ipoed = true
        end
        player_a, player_b = game.players
        game.share_pool.buy_shares(player_a, ShareBundle.new([acl.presidents_share]), exchange: :free)
        game.share_pool.buy_shares(player_b, ShareBundle.new([salr.presidents_share]), exchange: :free)
        game.share_pool.buy_shares(player_a, ShareBundle.new(salr.ipo_shares.reject(&:president).first(2)),
                                   exchange: :free)
        [grr, other].each { |corp| corp.owner = player_a }
        allow(game).to receive(:operating_order).and_return([grr, acl, salr, other])

        round = start_or
        game.event_final_merger_chance!
        round.next_entity!
        game.send(:next_round!)
        expect(game.round).to be_a(Game::G1832::Round::Merger)

        game.perform_system_formation(acl, salr, system)
        allow(game).to receive(:operating_order).and_return([grr, system, other])
        game.send(:transition_to_next_round!)

        expect(game.round.entities).to eq([system, other])
      end
    end
  end
end
