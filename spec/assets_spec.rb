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
      expect(render(user: { name: 'toby' })).to include('Welcome toby!')
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

      %w[1830 1889 18Chesapeake].each do |title|
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
        ]
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
        },
        user: {
          id: 1,
          name: 'Player 1'
        }
      }

      expect(render(app_route: '/game/1', **needs)).to include('Takamatsu E-Railroad')
      expect(render(app_route: '/game/1#players', **needs)).to include('Player 1')
      expect(render(app_route: '/game/1#corporations', **needs)).to include('Awa Railroad')
      expect(render(app_route: '/game/1#map', **needs)).to include('Kotohira')
      expect(render(app_route: '/game/1#market', **needs)).to include('Bank Cash')
      expect(render(app_route: '/game/1#trains', **needs)).to include('Upcoming')
      expect(render(app_route: '/game/1#tiles', **needs)).to include('492')
      expect(render(app_route: '/game/1#companies', **needs)).to include('Companies')
      expect(render(app_route: '/game/1#spreadsheet', **needs)).to include('Worth')
      expect(render(app_route: '/game/1#tools', **needs)).to include('Clone this')
    end
  end
end
