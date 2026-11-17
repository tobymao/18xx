# frozen_string_literal: true

require_relative '../../../round/choices'

module Engine
  module Round
    module G18OE
      class FastStart < Engine::Round::Choices
        def self.short_name
          'FS'
        end

        def name
          'Fast Start Round'
        end

        def select_entities
          []
        end

        def setup
          @entities = @game.fast_start_minors.map { |minor| @game.company_by_id(minor.id) }
          @log << "-- #{name} --"
        end
      end
    end
  end
end
