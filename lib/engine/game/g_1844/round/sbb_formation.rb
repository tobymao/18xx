# frozen_string_literal: true

require_relative '../../../round/merger'

module Engine
  module Game
    module G1844
      module Round
        class SBBFormation < Engine::Round::Merger
          def self.round_name
            'SBB Formation Round'
          end

          def self.short_name
            'SBB'
          end

          def setup
            @game.form_sbb!
          end

          def select_entities
            [@game.sbb]
          end

          def force_next_entity!
            clear_cache!
          end
        end
      end
    end
  end
end
