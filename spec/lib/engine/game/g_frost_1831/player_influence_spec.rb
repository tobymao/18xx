# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module GFrost1831
      describe Game do
        let(:game) { Engine::Game::GFrost1831::Game.new(%w[P1 P2 P3], id: 1) }
        let(:p1) { game.players[0] }
        let(:p2) { game.players[1] }
        let(:cm) { game.corporation_by_id('CM') }
        let(:use_influence) { game.company_by_id('INF') }

        def give_convoy(player)
          convoy = game.company_by_id('PCO')
          convoy.owner = player
          player.companies << convoy
          game.after_buy_company(player, convoy, convoy.value)
        end

        def use(choice)
          game.process_action(Engine::Action::ChooseAbility.new(use_influence, choice: choice))
          expect(game.exception&.message).to be_nil
        end

        def stock_round(player)
          game.instance_variable_set(:@round, game.stock_round)
          game.round.goto_entity!(player)
        end

        it 'gives the Convoy owner a Use Influence ability that is not a certificate' do
          give_convoy(p1)

          expect(use_influence.owner).to eq(p1)
          expect(game.num_certs(p1)).to eq(1)
          expect(game.companies_sort(p1.companies).map(&:sym)).to eq(%w[PCO])
        end

        it "allocates the Influence to one of the player's Corporations without moving the Government" do
          give_convoy(p1)
          game.par_corporation(cm, game.stock_market.par_prices.first)
          cm.ipo_shares.first(5).each { |share| share.transfer(p1) }
          cm.owner = p1
          game.apply_faction_influence!(cm, 'TEC')
          game.apply_faction_influence!(cm, 'LOR')
          marker = game.government_marker.dup
          stock_round(p1)

          special = game.round.steps.find { |s| s.is_a?(GFrost1831::Step::SpecialChoose) }
          expect(special.choices_ability(use_influence).keys).to eq(%w[CM:TEC CM:LOR])

          use('CM:TEC')

          expect(game.corporation_influence(cm)['TEC']).to eq(2)
          expect(game.government_marker).to eq(marker)
          expect(game.player_influence(p1)).to eq(0)
          expect(use_influence.closed?).to be(true)
        end

        it 'allocates the Influence to a Faction where the player is President' do
          give_convoy(p1)
          tec = game.corporation_by_id('TEC')
          tec.owner = p1
          stock_round(p1)

          use('faction:TEC')

          expect(game.faction_influence('TEC')).to eq(1)
        end

        it 'stays when the private companies close' do
          give_convoy(p1)
          game.send(:event_close_companies!)

          expect(use_influence.closed?).to be(false)
        end

        it 'is not offered while the player presides nothing' do
          give_convoy(p1)
          stock_round(p1)

          expect(game.entity_can_use_company?(p1, use_influence)).to be(false)
        end

        it 'is only usable on the owner turn' do
          give_convoy(p1)
          stock_round(p2)

          expect(game.entity_can_use_company?(p2, use_influence)).to be(false)
        end
      end
    end
  end
end
