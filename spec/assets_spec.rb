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
      expect(render(app_route: '/tiles/all')).not_to include('TODO')

      expect(render(app_route: '/tiles/57')).to include('57')
      expect(render(app_route: '/tiles/18Chesapeake')).to include('I9')
      expect(render(app_route: '/tiles/18Chesapeake/I9')).to include('I9')
      expect(render(app_route: '/tiles/18Chesapeake/X1')).to include('X1')

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

    it 'renders map' do
      expect(render(app_route: '/map/1889')).to include('Takamatsu')
      expect(render(app_route: '/map/18Chesapeake')).to include('Baltimore')
    end

    it 'renders new_game' do
      expect(render(app_route: '/new_game')).to include('Create New Game')
    end

    it 'renders game' do
      needs = {
        game_data: {
          id: 1,
          players: [{ name: 'Player 1' }, { name: 'Player 2' }],
          title: '1889',
          actions: [],
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
