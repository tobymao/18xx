# frozen_string_literal: true

module Lib
  module Publisher
    def self.link_list(component: nil, publishers: [])
      # show publishers for all playable games on the welcome page
      if publishers.empty?
        publishers = Engine::VISIBLE_GAMES
          .flat_map { |g| g::GAME_PUBLISHER }
          .reject { |p| Engine::Publisher::INFO.dig(p, :hidden) }
          .compact
          .uniq
          .sort
      end

      publishers = publishers.map do |p|
        publisher = Engine::Publisher::INFO[p]

        if component
          component.h(:a, { attrs: { href: publisher[:url] } }, publisher[:name])
        else
          "<a href='#{publisher[:url]}'>#{publisher[:name]}</a>"
        end
      end

      if publishers.size > 1
        if publishers.size > 2
          commas = Array.new(publishers.size - 1) { ', ' }
          publishers = publishers.zip(commas).flatten.compact
        end
        publishers.insert(-2, ' and ')
      end

      publishers
    end
  end
end
