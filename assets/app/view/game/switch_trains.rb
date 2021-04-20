# frozen_string_literal: true

require 'lib/settings'
require 'view/game/actionable'
require 'view/game/alternate_corporations'

module View
  module Game
    class SwitchTrains < Snabberb::Component
      include Actionable
      include AlternateCorporations
      include Lib::Settings

      def render
        @step = @game.round.active_step
        @corporation = @game.current_entity

        click = lambda do
          process_action(Engine::Action::SwitchTrains.new(@game.current_entity, slots: slots))
        end

        props = {
          style: {
            padding: '0.2rem 0.2rem',
          },
          on: { click: click },
        }

        children = []

        children << h(:h3, @step.help_text) if @step.respond_to?(:help_text)
        children << h('button', props, @step.description)

        @slot_checkboxes = {}
        if @step.respond_to?(:slot_view) && (view = @step.slot_view(@corporation))
          children << send("render_#{view}")
        end

        h(:div, children)
      end

      # return checkbox values for slots (if any)
      def slots
        return if @slot_checkboxes.empty?

        @slot_checkboxes.keys.map do |k|
          k if Native(@slot_checkboxes[k]).elm.checked
        end.compact
      end

      def render_trains
        center_style_props = {
          display: 'flex',
          alignItems: 'center',
        }

        possible_corporations = @step.target_corporations(@corporation)
        children = @step.trains(@corporation).map do |train|
          inner = []
          inner << h(:span, "#{train.name}:")
          possible_corporations.each do |corp|
            attrs = {
              type: 'radio',
              id: "train_#{train.id}-corp_#{corp.id}",
              name: "train_#{train.id}-corp_#{@corporation.id}",
            }
            puts train.owner.name, corp.name, train.owner == corp
            attrs[:checked] = 'checked' if train.owner == corp
            puts attrs
            checkbox = h(
              :input,
              style: {
                marginLeft: '1rem',
                marginRight: '3px',
              },
              attrs: attrs
            )
            @slot_checkboxes["#{train.id};#{corp.id}"] = checkbox

            logo_props = {
              attrs: { src: logo_for_user(corp) },
              style: {
                height: '1.6rem',
                width: '1.6rem',
                padding: '1px',
                border: '2px solid currentColor',
                borderRadius: '0.5rem',
              },
            }
            logo = h(:img, logo_props)
puts logo_props
            inner << h(:label, { style: center_style_props }, [checkbox, logo])
            inner << h(:label, { style: center_style_props }, [checkbox, logo])
          
          end
          
          h(:div, { style: center_style_props }, inner)
        end

        h(:div, { style: { marginTop: '1rem' } }, children)
      end

      def logo_for_user(entity)
        setting_for(:simple_logos, @game) ? entity.simple_logo : entity.logo
      end
    end
  end
end
