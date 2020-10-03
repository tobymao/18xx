# frozen_string_literal: true

require_relative 'g_1846'

module Engine
  module Game
    class G1846TwoPlayerVariant < G1846
      DEV_STAGE = :alpha

      GAME_RULES_URL = {
        '1846 Rules' => 'https://s3-us-west-2.amazonaws.com/gmtwebsiteassets/1846/1846-RULES-GMT.pdf',
        '1846 2p Variant Rules' => 'https://boardgamegeek.com/thread/1616729/draft-2-player-1846-rules-game-designer',
      }.freeze

      CERT_LIMIT = { 2 => 19 }.freeze

      def self.title
        '1846 2p Variant'
      end
    end
  end
end
