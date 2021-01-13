# frozen_string_literal: true

require_relative '../operating'

module Engine
  module Round
    module G1867
      class Operating < Operating
        def skip_entity?(entity)
          !entity.floated? || !@game.corporations.include?(entity)
        end
      end
    end
  end
end
