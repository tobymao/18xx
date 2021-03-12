# frozen_string_literal: true

require './spec/spec_helper'

require 'find'
require 'json'

# run all games found in spec/fixtures/, verify that the engine gets the result
# indicated in the game's "result" key in the JSON
module Engine
  Find.find(FIXTURES_DIR).select { |f| File.basename(f) =~ /.json/ }.each do |fixture|
    game_title = File.basename(File.dirname(fixture))
    filename = File.basename(fixture)
    game_id = filename.split('.json').first
    describe game_title do
      context game_id do
        it 'matches result exactly' do
          data = JSON.parse(File.read(fixture))
          result = data['result']

          expect(Engine::Game.load(data).maybe_raise!.result).to eq(result)

          rungame = Engine::Game.load(data, strict: true).maybe_raise!
          expect(rungame.result).to eq(result)
          expect(rungame.finished).to eq(true)
        end
      end
    end
  end

  AUTO_FIXTURES = [
    '1861/29683.json', # token pass
    '1830/29133.json', # buy till float
    '1817NA/25363.json', # pass in merger
    '1882/hs_iopxwxht_26178.json', # Auto-pass pass
    '1882/hs_fxmfdndg_26178.json', # Auto-pass disable (shares sold)
    '1882/hs_kufujwkw_26178.json', # Auto-pass disable (PAR)
    '1882/hs_vaxptumi_26178.json', # Auto-pass disable (buy unsecure)
    '1889/hs_lhglbbiz_17502.json', # Auto-buy from market
    '1889/hs_jmmljkbw_17502.json', # Auto-buy multiple from IPO
  ].freeze

  AUTO_FIXTURES.each do |fixture_name|
    fixture = FIXTURES_DIR + '/' + fixture_name
    game_title = File.basename(File.dirname(fixture))
    filename = File.basename(fixture)
    game_id = filename.split('.json').first
    describe game_title do
      context game_id do
        it 'should generate the same auto actions' do
          data = JSON.parse(File.read(fixture))
          rungame = Engine::Game.load(data, strict: true).maybe_raise!

          actions = rungame.class.filtered_actions(data['actions']).first
          # Find all the auto_actions
          actions.compact.each do |action|
            next unless action['auto_actions']

            # Run game as per the spec
            spec_game = Game.load(data, at_action: action['id'])

            # Process game to previous action
            auto_game = Game.load(data, at_action: action['id'] - 1)
            # Add the action but without the auto actions
            clone = action.dup
            clone.delete('auto_actions')
            auto_game.process_action(action, add_auto_actions: true)

            expect(spec_game.result).to eq(auto_game.result)
            expect(spec_game.actions.last.to_h).to eq(auto_game.actions.last.to_h)
          end
        end
      end
    end
  end

  describe 'Autoactions' do
    it '1867 should provide pass when token lay is impossible' do
      fixture = 'spec/fixtures/1867/21268.json'
      cursor = 835
      data = JSON.parse(File.read(fixture))
      game = Game.load(data, at_action: cursor)

      action = Engine::Action::Base.action_from_h(data['actions'][cursor], game)
      # Check creating new auto actions
      game.process_action(action, add_auto_actions: true)
      expect(action.auto_actions.size).to eq(1)
      expect(action.auto_actions.first).to be_instance_of(Engine::Action::Pass)
      # Game should have autopassed and be at RunRoutes
      expect(game.round.active_step).to be_instance_of(Engine::Step::Route)

      # Check reading existing actions
      game = Game.load(data, at_action: cursor)
      game.process_action(action.to_h)
      expect(game.round.active_step).to be_instance_of(Engine::Step::Route)
    end
  end
end
