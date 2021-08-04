# frozen_string_literal: true

require 'lib/truncate'
require 'lib/settings'

module View
  module Game
    class EntityOrder < Snabberb::Component
      needs :round

      include Lib::Settings

      def render
        children = []

        if @round.respond_to?(:context_entities)
          context_entities = @round.context_entities.dup
          active_context_entity = @round.active_context_entity
        elsif @round.active_step.respond_to?(:context_entities)
          context_entities = @round.active_step.context_entities.dup
          active_context_entity = @round.active_step.active_context_entity
        end
        if context_entities
          children << h(EntityList, round: @round, entities: context_entities, acting_entity: active_context_entity)
        end

        entities =
          if @round.active_step.respond_to?(:override_entities)
            @round.active_step.override_entities
          else
            @round.entities
          end.dup

        entities.unshift(@round.current_entity) if @round.current_entity && !entities.include?(@round.current_entity)

        children << h(EntityList, round: @round, entities: entities, acting_entity: @round.current_entity)
        h(:div, children)
      end
    end
  end
end
