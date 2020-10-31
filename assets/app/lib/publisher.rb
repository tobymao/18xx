# frozen_string_literal: true

require_tree 'engine'

module Lib
  module Publisher
    def self.link_list(component: nil, publishers: [])
      # show publishers for all playable games on the welcome page
      publishers = Engine::VISIBLE_GAMES.flat_map { |g| g::GAME_PUBLISHER }.compact.uniq.sort if publishers.empty?

      publishers.map! do |p|
        publisher = Engine::Publisher::INFO[p]

        if component
          component.h(:a, { attrs: { href: publisher[:url] } }, publisher[:name])
        else
          "<a href='#{publisher[:url]}'>#{publisher[:name]}</a>"
        end
      end

      if publishers.size > 1
        if publishers.size > 2
          commas = (publishers.size - 1).times.map { ', ' }
          publishers = publishers.zip(commas).flatten.compact
        end
        publishers.insert(-2, ' and ')
      end

      publishers
    end
  end
end
