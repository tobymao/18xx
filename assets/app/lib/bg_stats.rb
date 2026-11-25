# frozen_string_literal: true

# backtick_javascript: true

module Lib
  module BgStats
    URL = 'https://app.bgstatsapp.com/createPlay.html?data='
    SOURCE = '18xx.games'

    def self.url(gdata, meta)
      URL + `encodeURIComponent(JSON.stringify(#{play(gdata, meta).to_n}))`
    end

    def self.play(gdata, meta)
      players = gdata['players']
      scores = players.map { |player| gdata['result'][player['id'].to_s] }

      {
        sourceName: SOURCE,
        sourcePlayId: gdata['id'].to_s,
        playDate: Time.at(gdata['finished_at'].to_i).strftime('%F %T'),
        location: SOURCE,
        comments: (gdata['description'] unless gdata['description'].to_s.empty?),
        game: {
          name: meta.display_title,
          sourceGameId: meta.title,
          bggId: meta::BGG_ID,
          noPoints: false,
          highestWins: true,
        }.compact,
        players: players.each_with_index.map do |player, seat|
          score = scores[seat]
          rank = 1 + scores.count { |other| other > score }
          {
            name: player['name'],
            sourcePlayerId: player['id'].to_s,
            score: score,
            rank: rank,
            winner: rank == 1,
            startPlayer: seat.zero?,
          }
        end,
      }.compact
    end
  end
end
