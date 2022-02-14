# frozen_string_literal: true

require './spec/spec_helper'
require 'engine/auto_router'

require 'find'
require 'json'

require 'mini_racer'

# run all games found in spec/auto_router_fixtures/, verify that the auto-router gets the result
# indicated in the game's "result" key in the JSON
module AutoRouter
  SERVER_JS = '../../../public/assets/server.js'
  SCRIPT_HELPER_JS = 'auto_router_helper.js'
  EMPTY_GAME = '{ "result": "EMPTY_GAME", "mode": "hotseat" }' # TEMP

  Find.find(AUTOROUTE_FIXTURES_DIR).select { |f| File.basename(f) =~ /.json/ }.each do |fixture|
    game_title = File.basename(File.dirname(fixture))
    filename = File.basename(fixture)
    game_id = filename.split('.json').first

    script = File.read(File.expand_path(SERVER_JS, __dir__), encoding: 'UTF-8')
    snapshot = MiniRacer::Snapshot.new(script)

    call_script = File.read(File.expand_path(SCRIPT_HELPER_JS, __dir__), encoding: 'UTF-8')

    describe "Auto_Router #{game_title}" do
      context game_id do
        it 'matches result exactly' do
          # json = File.read(fixture)
          json = EMPTY_GAME
          data = JSON.parse(json)
          result = data['result']

          context = MiniRacer::Context.new(snapshot: snapshot)

          script = 'const data = ' + json + ';' + call_script
          revenue = context.eval(script)

          expect(revenue).to eq(result)
        end
      end
    end
  end

  # TODO: add additional scenarios that pass in routes for subset of trains,
  # or auto-generate by clearing each train and re-auto-ing
end
