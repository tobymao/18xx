# frozen_string_literal: true

require 'game_manager'
require 'lib/profile_link'

module View
  module Game
    class GameDetails < Snabberb::Component
      include GameManager
      include Lib::ProfileLink

      def render
        h('div.margined', [
          h(:h3, 'Game Details'),
          *render_game_info,
        ])
      end

      def format_time(ts)
        return '' unless ts

        t = Time.at(ts.to_i)
        t > Time.now - 82_800 ? t.strftime('%T') : t.strftime('%F')
      end

      def info_row(label, value)
        h(:p, "#{label}: #{value}")
      end

      def render_game_info
        user = @game_data['user']
        [
          info_row('Description', @game_data['description']),
          h(:p, ['Host: ', user ? profile_link(user['id'], user['name']) : '']),
          info_row('Created', format_time(@game_data['created_at'])),
          info_row('Last Updated', format_time(@game_data['updated_at'])),
        ]
      end
    end
  end
end
