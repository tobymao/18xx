# frozen_string_literal: true

require './spec/spec_helper'

require 'engine'
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
