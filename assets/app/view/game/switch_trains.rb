# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/alternate_corporations'

module View
  module Game
    class SwitchTrains < Snabberb::Component
      include Actionable
      include AlternateCorporations

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
        possible_corporations = @step.target_corporations(@corporation)
        children = @step.trains(@corporation).map do |train|
          inner = []
          inner << h(:span, train.name)
          inner << h(:span, '-->')
          # train Name
          # train owner
          possible_corporations.each do |corp|
            attrs = {
              type: 'radio',
              id: "train_#{train.id}_corp_#{corp.id}",
              name: "train_#{train.id}",
            }

            attrs[:checked] = 'checked' if train.owner == corp

            checkbox = h(
              'input.no_margin',
              style: {
                width: '1rem',
                height: '1rem',
                padding: '0 0 0 0.2rem',
              },
              attrs: attrs
            )
            @slot_checkboxes["train_#{train.id}_corp_#{corp.id}"] = checkbox
            inner << h(:label, [checkbox, corp.name])
          end
          # -> checkbox for new corporations

          h(:div, inner)
        end

        h(:div, children)
      end
    end
  end
end
