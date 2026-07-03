# frozen_string_literal: true

require 'lib/truncate'
require 'lib/settings'

module View
  module Game
    class MyEntityOrder < Snabberb::Component
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

        children << render_entity_list(context_entities, active_context_entity) if context_entities

        entities =
          if @round.active_step.respond_to?(:override_entities)
            @round.active_step.override_entities
          else
            @round.entities
          end.dup

        # Ensure the current operating entity is at least visible or marked active
        current_operating = @round.current_entity
        entities.unshift(current_operating) if current_operating && !entities.include?(current_operating)

        children << render_entity_list(entities, current_operating)

        h(:div, { style: { display: 'flex', flexDirection: 'column', gap: '0.25rem' } }, children)
      end

      private

      def render_entity_list(entities, acting_entity)
        badges_with_arrows = []

        # Determine who has already operated if the round supports it
        # Most 18xx operating rounds maintain an internal array or index of finished entities
        finished_entities = @round.respond_to?(:finished_entities) ? @round.finished_entities : []

        entities.each_with_index do |entity, index|
          next unless entity

          is_active = entity == acting_entity
          has_operated = finished_entities.include?(entity) ||
                         (entities.index(acting_entity) && index < entities.index(acting_entity) && !is_active)

          # Clean display name: remove the bracketed owner string entirely
          display_text = entity.respond_to?(:name) ? entity.name : entity.to_s

          # Style mapping based on state
          badge_style = {
            display: 'inline-block',
            padding: '0.2rem 0.6rem',
            borderRadius: '4px',
            fontSize: '0.85rem',
            transition: 'all 0.2s ease',
          }

          if is_active
            # Vibrant highlight styling for current turn
            badge_style.merge!(
              border: '2px solid #dc3545',
              backgroundColor: '#f8d7da',
              color: '#721c24',
              fontWeight: 'bold',
              boxShadow: '0 0 4px rgba(220, 53, 69, 0.5)'
            )
          elsif has_operated
            # Greyed out styling for already operated entities
            badge_style.merge!(
              border: '1px solid #dee2e6',
              backgroundColor: '#e9ecef',
              color: '#6c757d',
              fontWeight: 'normal',
              opacity: '0.6'
            )
          else
            # Default upcoming queue styling
            badge_style.merge!(
              border: '1px solid #ced4da',
              backgroundColor: '#ffffff',
              color: '#212529',
              fontWeight: 'normal'
            )
          end

          badges_with_arrows << h(:span, { style: badge_style }, display_text)

          # Add an arrow separator between items, but omit it after the last element
          next unless index < entities.size - 1

          badges_with_arrows << h(:span, {
                                    style: {
                                      margin: '0 0.4rem',
                                      color: '#adb5bd',
                                      fontWeight: 'bold',
                                      fontSize: '0.85rem',
                                    },
                                  }, '→')
        end

        h(:div, { style: { display: 'flex', flexWrap: 'wrap', alignItems: 'center', padding: '0.2rem' } }, badges_with_arrows)
      end
    end
  end
end
