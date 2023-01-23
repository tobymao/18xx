# frozen_string_literal: true

require 'spec_helper'
require 'assets'

TEST_CASES = [
  ['1889',
   314,
   [[6, 'stock_round', 'Pass (Share)'],
    [13, 'float', 'KO receives ¥700'],
    [21, 'lay_track', '1889: Phase 2 - Operating Round 1.1 (of 1) - Lay/Upgrade Track'],
    [22, 'buy_train',
     ['KO must buy an available train',
      '!!johnhawkhaines must contribute']],
    [46, 'run_routes', '1889: Phase 2 - Operating Round 2.1 (of 1) - Run Routes'],
    [47, 'dividends', '1889: Phase 2 - Operating Round 2.1 (of 1) - Pay or Withhold Dividends'],
    [78,
     'buy_company',
     ['1889: Phase 3 - Operating Round 3.1 (of 1) - Buy Companies',
      'Owning corporation may ignore building cost for mountain hexes']],
    [81,
     'track_and_buy_company',
     ['1889: Phase 3 - Operating Round 3.1 (of 1) - Lay/Upgrade Track',
      'Show companies from other players']],
    [87,
     'special_track',
     ['1889: Phase 3 - Operating Round 3.1 (of 1) - Lay Track for Ehime Railway',
      'Blocks C4 while owned by a player.']],
    [336, 'discard_train', 'Discard Trains'],
    [346, 'buy_train_emr', 'TR must buy an available train'],
    [445,
     'buy_train_emr_shares',
     ['KO has ¥582',
      'johnhawkhaines must contribute ¥518 for KO to afford a train from the Depot',
      'johnhawkhaines has ¥74 in cash',
      'johnhawkhaines has ¥650 in sellable shares',
      'johnhawkhaines must sell shares to raise at least ¥444',
      '!!Bankruptcy']],
    [nil, 'endgame', '1889: Phase D - Operating Round 7.1 (of 3) - Game Over - Bankruptcy']]],
  ['1882',
   5236,
   [[399, 'sc_home_token', '1882: Phase 4 - Stock Round 6 - Place Home Token'],
    [229, 'qll_home_token', '1882: Phase 3 - Operating Round 4.1 (of 1) - Place Home Token'],
    [370, 'nwr_place_token', '1882: Phase 4 - Operating Round 5.2 (of 2) - NWR: Place Token'],
    [371, 'nwr_lay_track', '1882: Phase 4 - Operating Round 5.2 (of 2) - NWR: Lay Track']]],
  ['1846',
   3099,
   [[0, 'draft', '1846: Phase I - Draft Round 1 - Draft Companies'],
    [18, 'draft', 'Mail Contract'],
    [49,
     'lay_track_or_token',
     ['1846: Phase I - Operating Round 1.1 (of 2) - Place a Token or Lay Track',
      # Minor charter stuff
      'Michigan Southern', 'Trains', '2', 'Cash', 'C15', '$60']],
    [74,
     'issue_shares',
     ['1846: Phase I - Operating Round 1.1 (of 2) - Place a Token or Lay Track',
      'Issue', '1 ($50)', '2 ($100)', '3 ($150)', '4 ($200)']],
    [94,
     'dividend',
     ['Pay or Withhold Dividends',
      '2 right',
      '1 right',
      '1 left']],
    [142,
     'assign',
     ['1846: Phase II - Operating Round 2.1 (of 2) - Assign Steamboat Company',
      'Blondie may assign Steamboat Company to a new hex and/or corporation or minor.',
      'Add $20 per port symbol to all routes run to the assigned location '\
      'by the owning/assigned corporation/minor.']],
    [nil, 'endgame', '1846: Phase IV - Operating Round 6.2 (of 2) - Game Over - Bank Broken']]],
  ['1846', 'hs_cvjhogoy_1599504419', [[49, 'buy_train_emr_shares', 'has $60 in sellable shares']]],
  ['1846', 'hs_sudambau_1600037415', [[37, 'buy_train', ['GT has $280', '!!can issue shares']]]],
  ['1846',
   'hs_sudambau_1600037415',
   [[60,
     'buy_train_bankrupt',
     ['B&amp;O has $0',
      'Player 3 must contribute $160 for B&amp;O to afford a train from the Depot.',
      'Player 3 has $15',
      'Player 3 has $0 in sellable shares',
      'Player 3 does not have enough liquidity to contribute towards B&amp;O buying a '\
      'train from the Depot. B&amp;O must buy a train from another corporation, or Player 3 '\
      'must declare bankruptcy.',
      'Declare Bankruptcy']]]],
  ['18AL',
   4714,
   [[nil, 'endgame', '18AL: Phase 5 - Operating Round 7.2 (of 3) - Game Over - Company hit max stock value']]],
  ['18TN',
   7818,
   [[nil, 'endgame', '18TN: Phase 8 - Operating Round 8.2 (of 3) - Game Over - Bank Broken']]],
  ['18MS',
   14_375,
   [[nil, 'endgame', '18MS: Phase D - Operating Round 10 (of 10) - Game end after OR 10 - Game Over']]],
  ['18MEX',
   13_315,
   [[278,
     'merge',
     ['Merge',
      'Decline',
      'Corporations that can merge with NdM']]]],
  ['18MEX',
   17_849,
   [[nil, 'endgame', '18MEX: Phase 4D - Operating Round 4.2 (of 2) - Game Over - Bankruptcy']]],
  ['1817',
   20_758,
   [[369,
     'choose_corp_size',
     ['1817: Phase 3 - Stock Round 2 - Buy or Sell Shares',
      'Strasburg Railroad',
      'Loans', '0/2',
      'Number of Shares:', '2', '5']]]],
  ['1817',
   15_528,
   [[196,
     'merge',
     ['Convert',
      'Merge',
      'Grand Trunk Western Railroad',
      'Corporations that can merge with A&amp;S']],
    [205, 'offer', ['Offer for Sale', 'Warren &amp; Trumbull Railroad']],
    [383,
     'merge_with_other_players',
     ['Convert',
      'Merge',
      'Pittsburgh, Shawmut and Northern Railroad',
      'Corporations that can merge with J']]]],
  ['1817',
   16_852,
   [[889, 'cash_crisis', ['Random Guy owes the bank $294 and must raise cash if possible.']]]],
  ['1817',
   16_281,
   [[809,
     'buy_sell_post_conversion',
     ['Merger Round 4.2 (of 2) - Buy/Sell Shares Post Conversion',
      'New York, Susquehanna and Western Railway']]]],
  ['1817NA',
   25_351,
   [[nil, 'endgame', '1817NA: Phase 7 - Acquisition Round 5.1 (of 2) - Game Over - Bankruptcy']]],
  ['18Chesapeake',
   1905,
   [[153, 'blocking_special_track', ['Lay Track for Columbia - Philadelphia Railroad']]]],
  ['18Chesapeake',
   22_383,
   [[56, 'removing_share_from_market',
     ['Stock Round 3 - Sell then Buy Shares',
      'GooQueen removes a 10% share of SRR from the game',
      'GooQueen buys a 10% share of SRR from the market for $95']]]],
  ['18CO',
   22_032,
   [[309,
     'corporate_share_buy',
     ['Pass (Share Buy)',
      'Buy Market Share',
      'Buy DPAC Share',
      'Buy CM Share']],
    [315,
     'corporate_share_sale',
     ['Pass (Share Sale)',
      'Kansas Pacific Railway',
      'Sell 1 ($40)',
      'Sell 2 ($80)',
      'Sell 3 ($120)']],
    [nil, 'pass', ['18CO: Phase 7 - Operating Round 6.2 (of 2) - Game Over - Bank Broken']]]],
  ['1867',
   21_268,
   [[531,
     'mid_convert',
     ['Choose Major Corporation']],
    [533,
     'buy_shares_post_merge',
     ['Buy Shares Post Merge',
      'Buy Treasury Share']],
    [698,
     'major_nationalize',
     ['Nationalize Major',
      'Choose if Major is nationalized',
      'Grand Trunk Railway']],
    [nil,
     'endgame',
     ['Operating Round 6.3 (of 3) - Game Over']]]],
  ['1860',
   19_354,
   [[215,
     'stock_round_1',
     ['!!<div>Fishbourne Ferry Company',
      '<div>Cowes Marina and Harbour',
      '<div>Brading Harbour Company']],
    [350,
     'stock_round_2',
     ['<div>Fishbourne Ferry Company',
      '<div>Cowes Marina and Harbour',
      '<div>Brading Harbour Company']],
    [444,
     'stock_round_3',
     ['<div>Fishbourne Ferry Company',
      '!!<div>Cowes Marina and Harbour',
      '!!<div>Brading Harbour Company']],
    [nil,
     'endgame',
     ['1860: Phase 9 - Operating Round 8.4 (Nationalization) - Game Over - Nationalization complete']]]],
].freeze

AUTO_ACTIONS_TEST_CASES = [
  ['1889',
   314,
   [[7, 'buy_to_float', [
    'Auto Buy Shares',
    'KO',
   ]]],
   ['1817',
    15_528,
    [[141, 'merger', [
      'Auto Pass in Mergers',
      'A&S',
      'Merger and Conversion Round',
    ]]]]],
].freeze

describe 'Assets' do
  before(:all) { @subject = Assets.new }

  subject { @subject }

  def render(**needs)
    subject.html('assets/app/app.rb', **needs)
  end

  describe '#html' do
    it 'renders logged out' do
      expect(render).to include('Welcome!')
    end

    it 'renders home logged in' do
      expect(render(user: { name: 'toby', settings: { consent: true } })).to include('Welcome toby!')
    end

    it 'consent logged in' do
      expect(render(user: { name: 'toby' })).to include('I agree to the privacy policy')
    end

    it 'renders about' do
      expect(render(app_route: '/about')).to include('created and maintained')
    end

    it 'renders tiles' do
      expect(render(app_route: '/tiles/all')).to include('Generic Map Hexes')

      expect(render(app_route: '/tiles/57')).to include('57')

      expect(render(app_route: '/tiles/18Chesapeake/all')).to include('I9')

      expect(render(app_route: '/tiles/18Chesapeake/I9')).to include('I9')
      expect(render(app_route: '/tiles/18Chesapeake/X1')).to include('X1')
      x2_x3 = render(app_route: '/tiles/18Chesapeake/X2+X3')
      expect(x2_x3).to include('X2')
      expect(x2_x3).to include('X3')

      aggregate_failures 'location name for all stop types' do
        with_loc_names = render(app_route: '/tiles/18Chesapeake/B2+H6+K3')
        %w[B2 Pittsburgh H6 Baltimore K3 Trenton Amboy D&amp;R].each do |str|
          expect(with_loc_names).to include(str)
        end
      end

      multiple_games = render(app_route: '/tiles/1889+18Chesapeake/all')
      expect(multiple_games).to include('Kouchi')
      expect(multiple_games).to include('Delmarva')

      %w[1889 18Chesapeake].each do |title|
        rendered = render(app_route: "/tiles/#{title}/all")

        expect(rendered).to include("#{title} Map Hexes")
        expect(rendered).to include("#{title} Tile Manifest")
        expect(rendered).not_to include('TODO')
      end
    end

    it 'renders login' do
      expect(render(app_route: '/login')).to include('Login')
    end

    it 'renders signup' do
      expect(render(app_route: '/signup')).to include('Signup')
    end

    context '/map' do
      {
        # games with config but not full implementation; just do a quick spot check
        '1817' => %w[Pittsburgh],
        '1817NA' => %w[
          Anchorage The Klondike Dawson City Hazelton Arctic Edmonton Winnipeg
          Quebec Europe Seattle Denver Toronto New York Hawaii Los Angeles
          Guadalajara Mexico City Miami New Orleans Belize South America
          20 30 40 50 60 80 15 10 B Asia
        ],
        '1846' => %w[Chicago],

        # games with full implementation; verify every string on the map
        '1889' => %w[
          1 10 11 12 13 14 2 20 3 30 4 40 5 6 60 7 8 80 9 A AR Anan Awaji B C D
          D100 D80 E ER F G H I IR Ikeda Imabari J K KO Komatsujima Kotohira
          Kouchi Kouen KU Kubokawa L Marugame Matsuyama Muki Muroto Nahari
          Nakamura Nangoku Naruto Niihama Ohzu Okayama Ritsurin SR Saijou
          Sakaide Sukumo T TR Takamatsu Tokushima UR Uwajima Yawatahama
        ],
        '18Chesapeake' => %w[
          1 10 100 11 12 13 14 2 3 30 4 40 5 50 6 60 7 8 80 9 A Allentown Amboy
          B B&amp;O B&amp;S Baltimore Berlin Burlington C C&amp;A C&amp;O
          C&amp;OC C-P Camden Charleroi Charlottesville Coal Columbia
          Connellsville D D&amp;R DC Delmarva E Easton F Fredericksburg G Green
          H Hagerstown Harrisburg I J K L LV Leesburg Lynchburg N&amp;W New
          Norfolk OO Ohio PLE PRR Peninsula Philadelphia Pittsburgh Princeton
          Richmond SRR Spring Strasburg Trenton Virginia Washington West
          Wilmington York
        ],
      }.each do |game_title, expected_strings|
        context game_title do
          it 'renders map' do
            rendered = render(app_route: "/map/#{game_title}")

            aggregate_failures 'expected strings' do
              expected_strings.each { |s| expect(rendered).to include(s) }
            end
          end
        end
      end
    end

    it 'renders new_game' do
      expect(render(app_route: '/new_game')).to include('Create New Game')
      expect(render(app_route: '/new_game', title: '1889')).to include('Shikoku 1889')
    end

    it 'renders game' do
      needs = {
        game_data: {
          id: 1,
          user: { id: 1, name: 'Player 1' },
          players: [{ id: 1, name: 'Player 1' }, { id: 2, name: 'Player 2' }],
          title: '1889',
          actions: [],
          loaded: true,
        },
        user: {
          id: 1,
          name: 'Player 1',
          settings: { consent: true },
        },
      }

      expect(render(app_route: '/game/1', **needs)).to include('Takamatsu E-Railroad')
      expect(render(app_route: '/game/1#entities', **needs)).to include('entities', 'Player 1', 'Awa Railroad')
      expect(render(app_route: '/game/1#map', **needs)).to include('Kotohira')
      expect(render(app_route: '/game/1#market', **needs)).to include('The Bank', 'Cash', 'Par value')
      expect(render(app_route: '/game/1#info', **needs)).to include('Trains', 'Game Phases', 'Shikoku 1889')
      expect(render(app_route: '/game/1#tiles', **needs)).to include('492')
      expect(render(app_route: '/game/1#spreadsheet', **needs)).to include('Value')
      expect(render(app_route: '/game/1#tools', **needs)).to include('Clone Game')
      expect(render(app_route: '/game/1#auto', **needs)).to include('Auto Actions')
    end

    def render_game_at_action(data, action_count, string, suffix = '')
      data['actions'] = data['actions'].take(action_count) if action_count
      data[:loaded] = true
      needs = {
        game_data: data,
        user: data['user'].merge(settings: { consent: true }),
      }

      html = render(app_route: "/game/#{needs[:game_data]['id']}#{suffix}", **needs)
      strings = Array(string)
      strings.each do |str|
        if /^!!/.match?(str)
          expect(html).not_to include(str.slice(2..))
        else
          expect(html).to include(str)
        end
      end
    end

    def render_game(jsonfile, action_count, string)
      data = JSON.parse(File.read(jsonfile))
      render_game_at_action(data, action_count, string)
    end

    TEST_CASES.each do |game, game_id, actions|
      data = JSON.parse(File.read("spec/fixtures/#{game}/#{game_id}.json"))
      actions.each do |action_config|
        action, step, string = action_config
        describe "#{game} #{game_id}" do
          it "renders #{step} #{action}" do
            render_game_at_action(data.dup, action, string)
          end
        end
      end
    end

    AUTO_ACTIONS_TEST_CASES.each do |game, game_id, actions|
      data = JSON.parse(File.read("spec/fixtures/#{game}/#{game_id}.json"))
      actions.each do |action_config|
        action, step, string = action_config
        describe "#{game} #{game_id}" do
          it "renders auto #{step} #{action}" do
            render_game_at_action(data.dup, action, string, '#auto')
          end
        end
      end
    end

    it 'renders tutorial to the end' do
      render_game('public/assets/tutorial.json', nil, 'Good luck and have fun!')
    end
  end
end
