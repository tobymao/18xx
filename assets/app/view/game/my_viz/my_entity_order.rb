# frozen_string_literal: true

require 'lib/truncate'
require 'lib/settings'

module View
  module Game
    class MyEntityOrder < Snabberb::Component
      needs :round
      needs :game, store: true

      include Lib::Settings

      def render
        if @game.respond_to?(:finished?) && @game.finished?
          return h(:div,
                   { style: { display: 'flex', alignItems: 'center', padding: '0.5rem', fontFamily: '"Helvetica Neue", Helvetica, Arial, sans-serif', fontWeight: 'bold', fontSize: '1.5rem', color: '#dc3545' } }, 'Game Over / Match Finished')
        end

        is_or = @round.respond_to?(:operating?) && @round.operating?

        # Fractional round numbering format (e.g., OR 1/2) derived from the game engine state
        header_text = if is_or
                        current_or = @round.respond_to?(:number) ? @round.number : '1'
                        total_ors = @game.respond_to?(:operating_rounds) ? @game.operating_rounds : '2'
                        "OR #{current_or}/#{total_ors}"
                      else
                        'SR'
                      end

        header_el = h(:div, {
                        style: {
                          fontSize: '1.8rem',
                          fontWeight: 'bold',
                          color: '#111111',
                          fontFamily: '"Helvetica Neue", Helvetica, Arial, sans-serif',
                          letterSpacing: '0.5px',
                          marginRight: '1.2rem',
                          display: 'inline-block',
                          verticalAlign: 'middle',
                          lineHeight: '1',
                        },
                      }, header_text)

        # For Stock Rounds, display only the large SR label and skip company processing entirely
        return h(:div, { style: { display: 'flex', alignItems: 'center', padding: '0.5rem' } }, [header_el]) unless is_or

        # Gather operating entities for the queue
        if @round.respond_to?(:context_entities)
          context_entities = @round.context_entities.dup
          active_context_entity = @round.active_context_entity
        elsif @round.active_step.respond_to?(:context_entities)
          context_entities = @round.active_step.context_entities.dup
          active_context_entity = @round.active_step.active_context_entity
        end

        entities =
          if @round.active_step.respond_to?(:override_entities)
            @round.active_step.override_entities
          else
            @round.entities
          end.dup

        current_operating = @round.current_entity
        entities.unshift(current_operating) if current_operating && !entities.include?(current_operating)

        # Build row layout containing both the round identifier and simple markers together
        row_children = [header_el]
        list_entities = context_entities || entities
        acting_entity = context_entities ? active_context_entity : current_operating

        row_children.concat(build_marker_list(list_entities, acting_entity))

        h(:div, {
            style: {
              display: 'flex',
              flexDirection: 'row',
              alignItems: 'center',
              flexWrap: 'wrap',
              gap: '0.3rem',
              padding: '0.5rem',
            },
          }, row_children)
      end

      private

      def build_marker_list(entities, acting_entity)
        elements = []
        finished_entities = @round.respond_to?(:finished_entities) ? @round.finished_entities : []

        entities.each_with_index do |entity, index|
          next unless entity

          is_active = entity == acting_entity
          has_operated = finished_entities.include?(entity) ||
                         (entities.index(acting_entity) && index < entities.index(acting_entity) && !is_active)

          # Replicate exact simple vs fancy logo selection logic from game_status.rb
          logo_src = begin
            setting_for(:simple_logos, @game) ? entity.simple_logo : entity.logo
          rescue StandardError
            nil
          end

          corp_color = entity.respond_to?(:color) && entity.color ? entity.color : '#ffffff'
          text_color = entity.respond_to?(:text_color) && entity.text_color ? entity.text_color : '#000000'

          # Clean token circle container matching render_unplaced_tokens
          marker_style = {
            width: '24px',
            height: '24px',
            borderRadius: '50%',
            boxSizing: 'border-box',
            display: 'inline-block',
            border: '1px solid #333333',
            backgroundColor: corp_color,
            color: text_color,
            textAlign: 'center',
            lineHeight: '22px',
            fontSize: '0.65rem',
            fontWeight: 'bold',
            verticalAlign: 'middle',
            overflow: 'hidden',
          }

          marker_content = if logo_src
                             h(:img, {
                                 attrs: { src: logo_src },
                                 style: {
                                   width: '100%',
                                   height: '100%',
                                   display: 'block',
                                 },
                               })
                           else
                             display_text = entity.respond_to?(:id) ? entity.id.to_s[0..2] : entity.to_s[0..2]
                             h(:span, display_text)
                           end

          # Wrap individual token markers to apply state highlights cleanly
          item_style = {
            display: 'inline-flex',
            alignItems: 'center',
            justifyContent: 'center',
            borderRadius: '50%',
            padding: '4px',
            transition: 'all 0.2s ease',
          }

          if is_active
            # Highlight wrapper for the active company currently "at go"
            item_style.merge!(
              backgroundColor: '#f8d7da',
              border: '2px solid #dc3545'
            )
          elsif has_operated
            # Clear faded presentation for completed entities
            item_style.merge!(
              opacity: '0.4'
            )
          end

          elements << h(:div, { style: item_style }, [h(:div, { style: marker_style }, [marker_content])])

          # Append structural arrow separators between sequential elements
          next unless index < entities.size - 1

          elements << h(:span, {
                          style: {
                            margin: '0 0.1rem',
                            color: '#868e96',
                            fontWeight: 'bold',
                            fontSize: '1rem',
                            alignSelf: 'center',
                          },
                        }, '→')
        end

        elements
      end
    end
  end
end
