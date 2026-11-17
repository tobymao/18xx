# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Round
    module G18OE
      class Concession < Engine::Round::Stock
        def self.short_name
          'CR'
        end

        def name
          'Concession Round'
        end

        def select_entities
          @game.concessions.map(&:owner)
        end

        def finished?
          @game.finished || (@game.concessions.all?(&:closed?) && @pending_tokens.empty?)
        end

        def current_concession
          @game.concessions[@entity_index]
        end

        protected

        def finish_round; end
      end
    end
  end
end
