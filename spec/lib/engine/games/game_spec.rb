# frozen_string_literal: true

require './spec/spec_helper'

require 'engine'
require 'json'

module Engine
  TEST_CASES = {
    GAMES_BY_TITLE['1846'] => {
      2987 => {
        'Saintis' => 6050,
        'steak' => 7371,
        'tomdidiot' => 7643,
      },
    },
    GAMES_BY_TITLE['18Chesapeake'] => {
      1277 => {
        'Harshit' => 1216,
        'jagdish' => 1045,
        'mfwesq' => 1153,
        'tgg' => 600,
        'wery' => 1028,
      },
      1905 => {
        'Apreche' => 4604,
        'GeekNightsRym' => 4210,
        'agrajag' => 6214,
        'pence' => 4848,
      },
      2593 => {
        'Harshit' => 4661,
        'isaacbf' => 3848,
        'jagdish' => 4697,
        'mfwesq' => 4319,
        'wery' => 3333,
      },
    },
    GAMES_BY_TITLE['1889'] => {
      247 => {
        'fdinh' => 1094,
        'gugvib' => 1148,
        'marco4884' => 1089,
        'vecchioleone' => 305,
      },
      314 => {
        'Rebus' => 1134,
        'johnhawkhaines' => 320,
        'scottredracecar' => 1473,
      },
      962 => {
        'Dimikosta' => 3091,
        'Joshua6' => 4317,
        'SamK' => 4444,
        'ventusignis' => 3880,
      },
    },
    GAMES_BY_TITLE['1836Jr30'] => {
      2809 => {
        'Azureth' => 4833,
        'Navor' => 3034,
        'willbeplaying' => 2095,

      },
      2851 => {
        'Shaz' => 5693,
        'markmenm' => 3159,
        'scottredracecar' => 5021,
      },
    },
  }.freeze

  TEST_CASES.each do |game, results|
    describe game do
      results.each do |game_id, result|
        context game_id do
          it 'matches result exactly' do
            game_path = game.title.gsub(/(.)([A-Z])/, '\1_\2').downcase
            data = JSON.parse(File.read("spec/fixtures/#{game_path}/#{game_id}.json"))
            players = data['players'].map { |p| p['name'] }
            expect(game.new(players, id: game_id, actions: data['actions']).result).to eq(result)
            rungame = game.new(players, id: game_id, actions: data['actions'], strict: true)
            expect(rungame.result).to eq(result)
            expect(rungame.finished).to eq(true)
          end
        end
      end
    end
  end
end
