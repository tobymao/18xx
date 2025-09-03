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
        before(:all) do
          @text = File.read(fixture)
          @data = JSON.parse(@text)
        end

        describe "formatted with `rake fixture_format[\"#{game_id}\"]`" do
          it 'text is compressed' do
            expect(@text.lines.size).to eq(1)
          end

          it 'players are anonymized' do
            @data['players'].each do |player|
              expect(player['name']).to match(/(Player )?(\d+|[A-Z])/)
            end
          end

          it 'has no chat messages' do
            expect(@data['actions'].count { |a| a['type'] == 'message' && a['message'] != 'chat' }).to eq(0)
          end
        end

        it 'is finished and matches result exactly' do
          result = @data['result']
          game_result = JSON.parse(JSON.generate(Engine::Game.load(@data).maybe_raise!.result))
          expect(game_result).to eq(result)

          rungame = Engine::Game.load(@data, strict: true).maybe_raise!
          expect(JSON.parse(JSON.generate(rungame.result))).to eq(result)
          expect(rungame.finished).to eq(true)
          expect(@data['status']).to eq('finished')

          # this is required for opening fixtures in the browser at /fixture/<title>/<id>
          expect(@data['loaded']).to eq(true)

          # some fixtures want to test that the last N actions of the game replayed the same as in the fixture
          test_last_actions = @data['test_last_actions']
          next unless test_last_actions

          actions = @data['actions']
          (1..(test_last_actions.to_i)).each do |index|
            run_action = rungame.actions[rungame.actions.size - index].to_h
            expect(run_action).to eq(actions[actions.size - index])
          end
        end
      end
    end
  end
end
