# frozen_string_literal: true

require_relative '../operating'

module Engine
  module Round
    module G1867
      class Operating < Operating
        def select_entities
          minors, majors = @game.corporations.select(&:floated?).sort.partition(&:type)
          minors + majors
        end
      end
    end
  end
end
