# frozen_string_literal: true

require_relative '../../../round/merger'

module Engine
  module Game
    module G18CO
      module Round
        class Acquisition < Engine::Round::Merger
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
end
