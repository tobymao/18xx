# frozen_string_literal: true

require 'lib/bg_stats'
require 'lib/settings'
require 'view/game/actionable'

module View
  module Game
    class BgStatsLink < Snabberb::Component
      include Actionable
      include Lib::Settings

      def render
        return h(:div) unless show?

        gdata = @game_data.merge('result' => @game.result.transform_keys(&:to_s),
                                 'finished_at' => @game_data['finished_at'] || Time.now.to_i)
        h('a.button_link', { attrs: { href: Lib::BgStats.url(gdata, @game.meta), target: '_blank' } }, 'Log to BG Stats')
      end

      def show?
        @game.finished && !hotseat? && setting_for(:bg_stats) && @user && @game.player_by_id(@user['id'])
      end
    end
  end
end
