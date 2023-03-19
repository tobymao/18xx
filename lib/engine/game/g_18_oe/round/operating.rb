# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Round
    module G18OE
      class Operating < Operating
        def select_entities
          # minors and regionals in float order, majors in stock order
          @game.minor_regional_order + (@game.corporations.select(&:floated?) - @game.minor_regional_order).sort
        end
      end
    end
  end
end
