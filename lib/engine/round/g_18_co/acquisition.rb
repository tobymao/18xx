# frozen_string_literal: true

require_relative '../merger'

module Engine
  module Round
    module G18CO
      class Acquisition < Merger
        attr_reader :entities

        def self.short_name
          'AR'
        end

        def name
          'Acquisition Round'
        end

        def offer
          @offering || []
        end

        def select_entities
          @offering = @game.acquirable_corporations.sort.reverse
          (@game.corporations - @offering).select(&:floated?).sort
        end
      end
    end
  end
end
