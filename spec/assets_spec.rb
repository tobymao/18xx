# frozen_string_literal: true

require 'spec_helper'
require 'assets'

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
      expect(render(app_route: '/tiles/18Chesapeake')).to include('I9')
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

      multiple_games = render(app_route: '/tiles/1889+18Chesapeake')
      expect(multiple_games).to include('Kouchi')
      expect(multiple_games).to include('Delmarva')

      %w[1889 18Chesapeake].each do |title|
        expect(render(app_route: "/tiles/#{title}")).to include("#{title} Map Hexes")
        expect(render(app_route: "/tiles/#{title}")).to include("#{title} Tile Manifest")
        expect(render(app_route: "/tiles/#{title}")).not_to include('TODO')
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
      expect(render(app_route: '/game/1#entities', **needs)).to include('Entities', 'Player 1', 'Awa Railroad')
      expect(render(app_route: '/game/1#map', **needs)).to include('Kotohira')
      expect(render(app_route: '/game/1#market', **needs)).to include('Bank Cash')
      expect(render(app_route: '/game/1#info', **needs)).to include('Upcoming')
      expect(render(app_route: '/game/1#tiles', **needs)).to include('492')
      expect(render(app_route: '/game/1#spreadsheet', **needs)).to include('Value')
      expect(render(app_route: '/game/1#tools', **needs)).to include('Clone this')
    end

    TEST_CASES = [
      ['1889', 314, 6, 'stock_round', 'Pass (Share)'],
      ['1889', 314, 13, 'float', 'KO receives ¥700'],
      ['1889', 314, 21, 'lay_track', '1889: Operating Round 1.1 (of 1) - Lay Track'],
      ['1889', 314, 22, 'buy_train', 'KO must buy an available train'],
      ['1889', 314, 46, 'run_routes', '1889: Operating Round 2.1 (of 1) - Run Routes'],
      ['1889', 314, 47, 'dividends', '1889: Operating Round 2.1 (of 1) - Pay or Withhold Dividends'],
      ['1889', 314, 78, 'buy_company',
       ['1889: Operating Round 3.1 (of 1) - Buy Companies',
        'Owning corporation may ignore building cost for mountain hexes']],
      ['1889', 314, 81, 'track_and_buy_company',
       ['1889: Operating Round 3.1 (of 1) - Lay Track',
        'Blocks Takamatsu (K4) while owned by a player.']],
      ['1889', 314, 87, 'special_track',
       ['1889: Operating Round 3.1 (of 1) - Lay Track for Ehime Railway',
        'Blocks C4 while owned by a player.']],
      ['1889', 314, 336, 'discard_train', 'Discard Trains'],
      ['1889', 314, 346, 'buy_train_emr', 'TR must buy an available train'],
      ['1889', 314, 445, 'buy_train_emr_shares',
       ['KO has ¥582'],
       ['johnhawkhaines must contribute ¥518 for KO to afford a train from the Depot'],
       ['johnhawkhaines has ¥74 in cash'],
       ['johnhawkhaines has ¥650 in sellable shares'],
       ['johnhawkhaines must sell shares to raise at least ¥444'],
       ['!!Bankruptcy']],
      ['1889', 314, nil, 'endgame', '1889: Operating Round 7.1 (of 3) - Game Over - Bankruptcy'],
      ['1882', 5236, 399, 'sc_home_token', '1882: Stock Round 6 - Place Home Token'],
      ['1882', 5236, 229, 'qll_home_token', '1882: Operating Round 4.1 (of 1) - Place Home Token'],
      ['1882', 5236, 370, 'nwr_place_token', '1882: Operating Round 5.2 (of 2) - NWR: Place Token'],
      ['1882', 5236, 371, 'nwr_lay_track', '1882: Operating Round 5.2 (of 2) - NWR: Lay Track'],
      ['1846', 3099, 0, 'draft', '1846: Draft Round 1 - Draft Companies'],
      ['1846', 3099, 18, 'draft', 'Mail Contract'],
      ['1846', 3099, 49, 'lay_track_or_token',
       ['1846: Operating Round 1.1 (of 2) - Place a Token or Lay Track',
        # Minor charter stuff
        'Michigan Southern', 'Trains', '2', 'Cash', 'C15', '$60']],
      ['1846', 3099, 185, 'assign',
       ['1846: Operating Round 2.1 (of 2) - Assign Steamboat Company',
        'Blondie may assign Steamboat Company to a new corporation or minor.',
        'Add $20 per port symbol to all routes run to the assigned location '\
        'by the owning/assigned corporation/minor.']],
      ['1846', 3099, nil, 'endgame', '1846: Operating Round 6.2 (of 2) - Game Over - Bank Broken'],
      ['1846', 'hs_cvjhogoy_1599504419', 48, 'buy_train_emr_shares', 'has $60 in sellable shares'],
      ['1846', 'hs_sudambau_1600037415', 37, 'buy_train',
       ['GT has $280',
        '!!can issue shares']],
      ['1846', 'hs_sudambau_1600037415', 41, 'buy_train_issuing',
       ['B&amp;O has $120',
        'B&amp;O can issue shares to raise up to $40',
        '!!Bankruptcy']],
      ['1846', 'hs_sudambau_1600037415', 50, 'buy_train_president_cash',
       ['B&amp;O has $146',
        'Player 3 must contribute $14 for B&amp;O to afford a train from the Depot.',
        'Player 3 has $15',
        'Player 3 has $0 in sellable shares',
        '!!Bankruptcy']],
      ['1846', 'hs_sudambau_1600037415', 60, 'buy_train_bankrupt',
       ['B&amp;O has $0',
        'Player 3 must contribute $160 for B&amp;O to afford a train from the Depot.',
        'Player 3 has $15',
        'Player 3 has $0 in sellable shares',
        'Player 3 must sell shares to raise at least $145.',
        'Player 3 does not have enough liquidity to contribute towards B&amp;O buying a '\
         'train from the Depot. B&amp;O must buy a train from another corporation, or Player 3 '\
         'must declare bankruptcy.',
        'Declare Bankruptcy']],
      ['18_al', 4714, nil, 'endgame', '18AL: Operating Round 7.2 (of 3) - Game Over - Company hit max stock value'],
      ['18_ga', 8643, nil, 'endgame', '18GA: Operating Round 8.1 (of 3) - Game Over - Bank Broken'],
      ['18_tn', 7818, nil, 'endgame', '18TN: Operating Round 8.2 (of 3) - Game Over - Bank Broken'],
      ['18_ms', 9882, nil, 'endgame', '18MS: Operating Round 5.2 (of 2) - Game Over - Last OR in game'],
    ].freeze

    def render_game(jsonfile, no_actions, string)
      data = JSON.parse(File.read(jsonfile))
      data['actions'] = data['actions'].take(no_actions) if no_actions
      data[:loaded] = true
      needs = {
        game_data: data,
        user: data['user'].merge(settings: { consent: true }),
        disable_user_errors: true,
      }

      html = render(app_route: "/game/#{needs[:game_data]['id']}", **needs)
      strings = Array(string)
      strings.each do |str|
        if str =~ /^!!/
          expect(html).not_to include(str.slice(2..))
        else
          expect(html).to include(str)
        end
      end
    end

    TEST_CASES.each do |game, game_id, action, step, string|
      describe "#{game} #{game_id}" do
        it "renders #{step}" do
          render_game("spec/fixtures/#{game}/#{game_id}.json", action, string)
        end
      end
    end

    it 'renders tutorial to the end' do
      render_game('public/assets/tutorial.json', nil, 'Good luck and have fun!')
    end
  end
end
