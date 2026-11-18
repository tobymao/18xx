# frozen_string_literal: true

require 'spec_helper'

module Engine
  describe Game::G1832::Game do
    let(:game) { Game::G1832::Game.new(%w[a b c]) }

    describe 'interrupting an operating round for the final merger chance' do
      let(:corporations) { game.corporations.first(3) }

      before do
        corporations.each { |corp| corp.owner = game.players.first }
        allow(game).to receive(:operating_order).and_return(corporations)
        game.instance_variable_set(:@operating_rounds, 2)
      end

      # An operating step that always has something to do, so that the round waits on each entity.
      let(:waiting_step) do
        Class.new(Engine::Step::Base) do
          def actions(_entity)
            ['pass']
          end

          def description
            'Waiting'
          end
        end
      end

      def start_or(round_num = 1)
        Game::G1832::Round::Operating.new(game, [waiting_step], round_num: round_num)
      end

      it 'finishes the round after the current entity once the event has fired' do
        round = start_or
        expect(round.entities[round.entity_index]).to eq(corporations[0])

        game.event_final_merger_chance!
        round.next_entity!

        expect(round).to be_finished
        expect(game.final_merger_triggered?).to be(false)
      end

      it 'does not interrupt when the event has not fired' do
        round = start_or
        round.next_entity!

        expect(round.entities[round.entity_index]).to eq(corporations[1])
        expect(round).not_to be_finished
      end

      it 'resumes with the entities that had not operated' do
        round = start_or
        game.event_final_merger_chance!
        round.next_entity!

        round.setup

        expect(round.entities).to eq(corporations[1..])
        expect(round.current_operator).to eq(corporations[1])
        expect(round).not_to be_finished
        expect(game.saved_or_round).to be_nil
      end

      it 'has nothing left to resume when the last entity bought the 6-train' do
        round = start_or
        round.instance_variable_set(:@entity_index, 2)
        game.event_final_merger_chance!
        round.next_entity!

        round.setup

        expect(round.entities).to be_empty
        expect(round).to be_finished
      end

      it 'does not resume the entities of a corporation closed in the meantime' do
        round = start_or
        game.event_final_merger_chance!
        round.next_entity!
        corporations[1].close!

        round.setup

        expect(round.entities).to eq([corporations[2]])
      end

      it 'slots a system formed in the meantime into the rest of the round' do
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
        game.perform_system_formation(acl, salr, system)
        allow(game).to receive(:operating_order).and_return([grr, system, other])
        round.setup

        expect(round.entities).to eq([system, other])
      end
    end
  end
end
