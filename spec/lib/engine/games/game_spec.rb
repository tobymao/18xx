# frozen_string_literal: true

require './spec/spec_helper'

require 'engine'
require 'json'

module Engine
  TEST_CASES = {
    GAMES_BY_TITLE['1846'] => {
      4106 => {
        'CheesePetrol' => 5677,
        'Tim Prime' => 5914,
        'toast' => 6978,
        'tomusher' => 5143,
      },
      3099 => {
        'Blondie' => 6713,
        'Emilybry26' => 6115,
        'MrDiskord' => 3987,
        'mfmise' => 6338,
        'sirstevie3' => 4847,
      },
      4949 => {
        'Apreche' => 6619,
        'GeekNightsRym' => 8956,
        'pence' => 6718,
      },
      # bankruptcy sending two corps into receivership, one of them buying a
      # train immediately; also has emergency share issuing
      'hs_ynxuqvex_1595710756' => {
        'Player 1' => 0,
        'Player 2' => 0,
        'Player 3' => 1527,
      },
      # bankruptcy sending a corp into receivership, unable to buy a train on
      # the turn of the bankruptcy, and then buying a train on its next turn
      # thanks to company income; also includes emergency share issuing
      'hs_gcumggit_1595777670' => {
        'Player 1' => 0,
        'Player 2' => 1387,
        'Player 3' => 0,
      },
      # bankruptcy that forces the new president to buy a train, which actually
      # bankrupts them as well
      'hs_hxrxpbjl_1595784599' => {
        'Player 1' => 0,
        'Player 2' => 0,
        'Player 3' => 552,
      },
      # bankruptcy where the bankruptcy action automatically issues the rest of
      # the corporation's shares
      'hs_qxroaokg_1595793382' => {
        'Player 1' => 1266,
        'Player 2' => 0,
        'Player 3' => 0,
      },
    },
    GAMES_BY_TITLE['18Chesapeake'] => {
      3055 => {
        'CullenF' => 4960,
        'KillerMonkey' => 3456,
        'Nastroker' => 4782,
        'SamK' => 5649,
        'hhlodesign' => 4472,
      },
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
        'fdinh' => 1059,
        'gugvib' => 1073,
        'marco4884' => 1089,
        'vecchioleone' => 275,
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
    GAMES_BY_TITLE['1882'] => {
      5236 => {
        'Akado' => 5333,
        'starchitect' => 4826,
        'Dix' => 4429,
        'nigelsandwich' => 4222,
        'ryu' => 2260,
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
