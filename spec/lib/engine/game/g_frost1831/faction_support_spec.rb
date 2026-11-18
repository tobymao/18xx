# frozen_string_literal: true

require 'spec_helper'

module Engine
  module Game
    module GFrost1831
      describe Game do
        let(:game) { Engine::Game::GFrost1831::Game.new(%w[P1 P2 P3], id: 1, optional_rules: optional_rules) }
        let(:optional_rules) { [] }
        let(:p1) { game.players[0] }

        def float(corporation, player = p1)
          game.instance_variable_set(:@round, game.stock_round)
          game.round.goto_entity!(player)
          game.par_corporation(corporation, game.stock_market.par_prices.first)
          corporation.ipo_shares.first(5).each { |share| share.transfer(player) }
          corporation.owner = player
          game.float_corporation(corporation)
        end

        def choose(player, faction)
          game.process_action(Engine::Action::Choose.new(player, choice: faction))
          expect(game.exception&.message).to be_nil
        end

        def step
          game.round.active_step
        end

        it 'asks the President to choose 2 Factions when a Corporation floats' do
          cm = game.corporation_by_id('CM')
          float(cm)

          expect(step).to be_a(GFrost1831::Step::ChooseFactions)
          expect(step.ipo_type(cm)).to be_nil
          expect(step.choices.keys).to eq(%w[TEC LOR GUA EXP])
          expect(step.choice_views.map(&:first)).to eq(['GFrost1831::InfluenceArena'])
        end

        it 'gives a cube to the Corporation and the Faction and moves the Government for each choice' do
          cm = game.corporation_by_id('CM')
          float(cm)
          choose(p1, 'TEC')

          expect(step.choices.keys).to eq(%w[LOR EXP])

          choose(p1, 'LOR')

          expect(game.corporation_factions(cm)).to eq(%w[TEC LOR])
          expect(game.corporation_influence(cm)).to eq('TEC' => 1, 'LOR' => 1)
          expect(game.faction_influence('TEC')).to eq(1)
          expect(game.faction_influence('LOR')).to eq(1)
          expect(game.government_marker).not_to eq(Game::GOVERNMENT_START)
          expect(game.status_array(cm)).to eq([['Technicians: 1/3', ''], ['Lords: 1/3', '']])
          expect(game.round.active_step).not_to be_a(GFrost1831::Step::ChooseFactions)
        end

        it 'uses each Faction Support Card once and releases the second set after the fourth flotation' do
          %w[CM DL].each do |id|
            float(game.corporation_by_id(id))
            choose(p1, 'TEC')
            choose(p1, 'LOR')
          end

          expect(game.faction_support_remaining('TEC')).to eq(0)
          float(game.corporation_by_id('EC'))
          expect(step.choices.keys).to eq(%w[GUA EXP])
          choose(p1, 'GUA')
          choose(p1, 'EXP')

          float(game.corporation_by_id('HF'))
          choose(p1, 'GUA')
          choose(p1, 'EXP')

          expect(game.faction_support_available).to match_array(%w[TEC GUA EXP LOR])
          expect(game.faction_support_remaining('TEC')).to eq(2)
        end

        context 'with Parliamentary Intervention' do
          let(:optional_rules) { [:parliamentary_intervention] }

          it "makes a player's 2nd Corporation support a different Faction" do
            float(game.corporation_by_id('CM'))
            choose(p1, 'TEC')
            choose(p1, 'LOR')

            float(game.corporation_by_id('DL'))
            choose(p1, 'TEC')

            expect(step.choices.keys).to eq(%w[EXP])
          end

          it 'does not restrict the 2nd choice when the 1st is already different' do
            float(game.corporation_by_id('CM'))
            choose(p1, 'TEC')
            choose(p1, 'LOR')

            float(game.corporation_by_id('DL'))
            choose(p1, 'GUA')

            expect(step.choices.keys).to eq(%w[LOR EXP])
          end

          it 'only offers 1st choices that leave a different Faction for the 2nd' do
            float(game.corporation_by_id('CM'))
            choose(p1, 'TEC')
            choose(p1, 'LOR')
            game.instance_variable_set(:@faction_support_pool, %w[TEC TEC LOR EXP])

            float(game.corporation_by_id('DL'))

            expect(step.choices.keys).to match_array(%w[TEC EXP])
          end

          it 'allows the same Factions when no different pair is available' do
            float(game.corporation_by_id('CM'))
            choose(p1, 'TEC')
            choose(p1, 'LOR')
            game.instance_variable_set(:@faction_support_pool, %w[TEC TEC LOR LOR])

            float(game.corporation_by_id('DL'))
            expect(step.choices.keys).to match_array(%w[TEC LOR])

            choose(p1, 'LOR')
            expect(step.choices.keys).to eq(%w[TEC])
          end
        end
      end
    end
  end
end
