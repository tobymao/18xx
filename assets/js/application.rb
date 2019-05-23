# frozen_string_literal: true

require 'component'
require 'view/game'

require 'engine/player'
require 'engine/game/base'
require 'engine/game/g_1889'

class App < Component
  def initialize
    @players = [
      Engine::Player.new('Ambie'),
      Engine::Player.new('Talbot'),
      Engine::Player.new('Toby'),
    ]
    @game = Engine::Game::G1889.new(@players)
  end

  def render
    c(View::Game, game: @game)
  end
end

app = App.new
app.attach('app')
