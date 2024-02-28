# frozen_string_literal: true

require_relative '../../../round/merger'

module Engine
  module Game
    module G1832
      module Round
        class Merger < Engine::Round::Merger
          def self.round_name
            'Merger and Takeover Round'
          end

          def self.short_name
            'MR & T'
          end

          def select_entities
            @game.merge_corporations.sort
          end

          def setup
            super
            skip_steps
            next_entity! if finished?
          end
        end
      end
    end
  end
end
