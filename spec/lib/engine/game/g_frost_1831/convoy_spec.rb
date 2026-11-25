# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module GFrost1831
      describe Game do
        let(:game) { Engine::Game::GFrost1831::Game.new(%w[P1 P2 P3], id: 1) }
        let(:p1) { game.players[0] }
        let(:p2) { game.players[1] }

        def everyone_passes
          game.players.size.times { game.process_action(Engine::Action::Pass.new(game.current_entity)) }
        end

        def buy(player, sym)
          company = game.company_by_id(sym)
          game.process_action(Engine::Action::Bid.new(player, company: company, price: company.value))
        end

        it 'starts every player without Influence' do
          expect(game.players.map { |p| game.player_influence(p) }).to eq([0, 0, 0])
          expect(game.player_card_rows(p1)).to be_nil
        end

        it 'gives 1 Influence to the player who buys Convoy' do
          everyone_passes
          buy(p1, 'PCO')

          expect(game.player_influence(p1)).to eq(1)
          expect(game.player_influence(p2)).to eq(0)
          expect(game.player_card_rows(p1)).to eq(%w[Influence 1])
          expect(game.log.map(&:message)).to include('P1 receives 1 Influence from Convoy')
        end

        it 'gives no Influence for the other private companies' do
          everyone_passes
          buy(p1, 'PAF')

          expect(game.player_influence(p1)).to eq(0)
        end
      end
    end
  end
end
