# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module GFrost1831
      describe Game do
        let(:game) { Engine::Game::GFrost1831::Game.new(%w[P1 P2 P3], id: 1) }
        let(:factions) { game.corporations.select { |c| c.type == :faction } }

        it 'has the four factions' do
          expect(factions.map(&:id)).to contain_exactly('TEC', 'GUA', 'EXP', 'LOR')
        end

        it 'gives each faction a £500 treasury and five 20% certificates' do
          factions.each do |faction|
            expect(faction.cash).to eq(500)
            expect(faction.shares.map(&:percent)).to eq([20, 20, 20, 20, 20])
          end
        end

        it 'does not let a player par a Faction' do
          expect(game.factions.none? { |faction| game.can_par?(faction, game.players.first) }).to be(true)
          expect(game.factions.map(&:capitalization).uniq).to eq([:none])
        end

        it 'picks the certificate limit by the Corporations in play' do
          expect(game.cert_limit).to eq(25)
          game.corporation_by_id('CM').close!
          expect(game.send(:init_cert_limit)).to eq(22)
        end

        it 'starts each faction with only its home base as a token' do
          factions.each do |faction|
            expect(faction.tokens.size).to eq(1)
            expect(game.token_string(faction)).to eq('9/9')
          end
        end

        it 'creates a new token when a faction places another base' do
          faction = game.corporation_by_id('TEC')
          home = game.hex_by_id('F3')
          other = game.hex_by_id('G8')
          home.tile.cities.first.place_token(faction, faction.find_token_by_type, check_tokenable: false)
          expect(game.token_string(faction)).to eq('8/9')

          other.tile.cities.first.place_token(faction, faction.next_base, check_tokenable: false)

          expect(faction.tokens.size).to eq(2)
          expect(faction.tokens.map(&:hex)).to eq([home, other])
        end

        it 'finds a faction from an action it took' do
          faction = game.corporation_by_id('TEC')
          action = Engine::Action::Pass.new(faction)

          expect(Engine::Action::Base.action_from_h(action.to_h, game).entity).to eq(faction)
        end

        it 'calls the faction IPO Parliament' do
          expect(game.ipo_name(factions.first)).to eq('Parliament')
          expect(game.ipo_name(game.corporation_by_id('CM'))).to eq('IPO')
        end
      end
    end
  end
end
