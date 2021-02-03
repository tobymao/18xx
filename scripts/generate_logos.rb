# frozen_string_literal: true
# rubocop:disable all

Dir['./models/**/*.rb'].sort.each { |file| require file }
require './lib/engine'
Sequel.extension :pg_json_ops
DB.extension :pg_array, :pg_advisory_lock, :pg_json, :pg_enum

def generate_logos(game_title, simple=false)
  game_class = Engine::GAMES_BY_TITLE[game_title]
  players = Engine.player_range(game_class).max.times.map { |n| "Player #{n + 1}" }
  game = game_class.new(players)

  # Regenerate to avoid corps that are hidden
  corporations = game.send(:init_corporations, game.stock_market)

  corporations.each do |corp|
    next if simple && !corp.simple_logo

    filename =
      if simple
        "public#{corp.simple_logo}"
      else
        "public#{corp.logo}"
      end

    if File.exist?(filename)
      puts "File #{filename} already exists"
    else
      svg = <<-SVG
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 8 8"><circle cx="4" cy="4" r="4" fill="#{corp.color}"/><text x="4" y="5" text-anchor="middle" font-weight="700" font-size="3" font-family="Arial" fill="#{corp.text_color}">#{corp.id.gsub('&', '&amp;')}</text></svg>
      SVG
      File.write(filename, svg)
      puts "Generated #{filename}"
    end


  end
end
