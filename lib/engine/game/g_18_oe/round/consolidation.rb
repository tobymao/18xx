# frozen_string_literal: true

require_relative '../../../round/base'

module Engine
  module Round
    module G18OE
      class Consolidation < Engine::Round::Base
        def self.short_name
          'C'
        end

        def name
          'Consolidation Round'
        end

        def select_entities
          # Players who own at least one minor or regional corporation
          @game.players.select do |p|
            p.shares.map(&:corporation).any? { |c| %i[minor regional].include?(c.type) }
          end
        end

        def next_entity!
          return if @entity_index == @entities.size - 1

          next_entity_index!
        end

        def finished?
          @entity_index >= @entities.size || !active_step
        end
      end
    end
  end
end
