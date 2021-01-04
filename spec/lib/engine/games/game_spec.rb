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
end
