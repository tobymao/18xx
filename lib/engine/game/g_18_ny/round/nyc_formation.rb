# frozen_string_literal: true

require_relative '../../../round/merger'

module Engine
  module Game
    module G18NY
      module Round
        class NYCFormation < Engine::Round::Merger
          def self.round_name
            'NYC Formation Round'
          end

          def self.short_name
            'NYC'
          end

          def select_entities
            [@game.nyc_corporation]
          end
        end
      end
    end
  end
end
