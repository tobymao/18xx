# frozen_string_literal: true

require_relative '../operating'
require_relative '../../token'
require_relative '../half_pay'
require_relative '../issue_shares'
require_relative '../minor_half_pay'

module Engine
  module Round
    module G1846
      class Operating < Operating
        def select_entities
          @game.minors + @game.corporations.select(&:floated?).sort
        end
      end
    end
  end
end
