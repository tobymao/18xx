# frozen_string_literal: true

Dir['./models/**/*.rb'].each { |file| require file }
require './lib/engine'
Sequel.extension :pg_json_ops
DB.extension :pg_array, :pg_advisory_lock, :pg_json, :pg_enum

def generate_logos(game_title, simple = false, overwrite = false, minors = false)
  return 'invalid title, use GAME_TITLE' unless (game_class = Engine.game_by_title(game_title))

  players = Array.new(game_class::PLAYER_RANGE.max) { |n| "Player #{n + 1}" }
  game = game_class.new(players)

  # Regenerate to avoid corps that are hidden
  corporations = game.send(:init_corporations, game.stock_market)
  corporations.concat(game.send(:init_minors)) if minors
  # TODO: special handling for 18ZOO maps, 1822+, maybe more?

  corporations.each do |corp|
    next if simple && corp.logo == corp.simple_logo

    filename = "public#{simple ? corp.simple_logo : corp.logo}"

    if File.exist?(filename) && !overwrite
      puts "File #{filename} already exists"
    else
      text_adjust = ' textLength="7.2" lengthAdjust="spacingAndGlyphs"'
      if /^\d+$/.match?(corp.id)
        # numbered minors/privates; force white on black due to 1822
        text_color = ' fill="#fff"'
        bg_color = '' # default == black
        font_size = 5
        extra = ''
      else
        text_color = corp.text_color == 'black' ? '' : " fill=\"#{corp.text_color}\"".gsub('#ffffff', '#fff')
        bg_color = if ['black', '#000', '#000000'].include?(corp.color)
                     ''
                   else
                     " fill=\"#{corp.color}\"".gsub('#ffffff', '#fff')
                   end
        font_size, extra =
          case corp.id.size
          when 1, 2
            [4, '']
          when 3
            text_adjust = '' if /[Iijlt]/.match?(corp.id)
            [3.25, text_adjust]
          when 4
            text_adjust = '' if /^[A-Z][a-z]+$/.match?(corp.id)
            [3, text_adjust]
          else
            [2.5, text_adjust]
          end
      end

      y = 3.8 + (font_size * 0.4)
      y = y.to_int if (y % 1).zero?

      svg = <<~SVG.chomp
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 8 8"><circle cx="4" cy="4" r="4"#{bg_color}/><text x="4" y="#{y}" text-anchor="middle" font-weight="700" font-size="#{font_size}"#{extra} font-family="Arial"#{text_color}>#{corp.id.gsub('&', '&amp;')}</text></svg>
      SVG
      File.write(filename, svg)
      puts "Generated #{filename}"
    end
  end
end

def generate_all_logos(simple = true, overwrite = false, minors = false)
  Engine.all_game_titles.each { |title| generate_logos(title, simple, overwrite, minors) }
end
