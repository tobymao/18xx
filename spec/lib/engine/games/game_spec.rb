# frozen_string_literal: true

require './spec/spec_helper'

require 'engine'
require 'json'

module Engine
  TEST_CASES = {
    GAMES_BY_TITLE['1846'] => {
      3099 => {
        'Blondie' => 7123,
        'Emilybry26' => 6407,
        'MrDiskord' => 4073,
        'mfmise' => 6550,
        'sirstevie3' => 4907,
      },
      # bankruptcy sending a corp into receivership, unable to buy a train on
      # the turn of the bankruptcy, and then buying a train on its next turn
      # thanks to company income; also includes emergency share issuing
      'hs_gcumggit_1595777670' => {
        'Player 1' => 0,
        'Player 2' => 1390,
        'Player 3' => 0,
      },
      # President selling a share to buy a 4T when cash + corp treasury can
      # afford 3/5T
      'hs_cvjhogoy_1599504419' => {
        'Player 3' => 295,
        'Player 2' => 285,
        'Player 1' => 190,
      },
      'hs_sudambau_1600037415' => {
        'Player 1' => 530,
        'Player 2' => 508,
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
      5585 => {
        'Kerubin08' => 6222,
        'lychenus' => 5045,
        'ryu' => 4889,
        'kiwijohn' => 3237,
      },
    },
    GAMES_BY_TITLE['18AL'] => {
      4714 => {
        'Adam' => 3037,
        'Bertil' => 2836,
        'Daisy' => 2522,
        'Cecilia' => 2498,
      },
      # In this game all trains are bought from depot.
      # One corporation is without trains, but as depot is
      # empty it does not have to buy any trains.
      # Fix of issue #1446
      1446 => {
        'Player 2' => 4120,
        'Player 4' => 4057,
        'Player 3' => 3487,
        'Player 1' => 3362,
      },
    },
    GAMES_BY_TITLE['18GA'] => {
      9222 => {
        'SunnyD' => 5923,
        'LJHall' => 5382,
        'Helen ' => 3978,
      },
    },
    GAMES_BY_TITLE['18MS'] => {
      9882 => {
        'TIE53' => 4407,
        'Mark Derrick' => 3783,
        'MontyBrewster71' => 3357,
      },
    },
    GAMES_BY_TITLE['18TN'] => {
      7818 => {
        'starchitect' => 5615,
        'nigelsandwich' => 5368,
        'wynad' => 4355,
        'MontyBrewster71' => 4354,
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
