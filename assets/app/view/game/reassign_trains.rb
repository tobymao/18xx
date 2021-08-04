# frozen_string_literal: true

require 'lib/settings'
require 'view/game/actionable'

module View
  module Game
    class ReassignTrains < Snabberb::Component
      include Actionable
      include Lib::Settings

      def render
        @step = @game.round.active_step
        @corporation = @game.current_entity

        click = lambda do
          process_action(Engine::Action::ReassignTrains.new(@game.current_entity, assignments: @assignments))
        end

        props = {
          style: {
            padding: '0.2rem 0.2rem',
          },
          on: { click: click },
        }

        children = []
        @assignments = []
        children << h(:h3, @step.help_text) if @step.respond_to?(:help_text)
        children << h('button', props, @step.description)

        children << render_trains

        h(:div, children)
      end

      def render_trains
        center_style_props = {
          display: 'flex',
          alignItems: 'center',
        }

        possible_corporations = @step.target_corporations(@corporation)
        children = @step.trains(@corporation).map do |train|
          @assignments << { corporation: train.owner, train: train }

          inner = []
          inner << h(:span, "#{train.name}:")
          possible_corporations.each do |corp|
            attrs = {
              type: 'radio',
              name: "train_#{train.id}-corp_#{@corporation.id}",
            }
            attrs[:checked] = 'checked' if train.owner == corp

            click_handler = lambda do
              @assignments.find { |assignment| assignment[:train] == train }[:corporation] = corp
            end

            radio_input = h(
              "input#train_#{train.id}-corp_#{corp.id}",
              style: {
                marginLeft: '1rem',
                marginRight: '3px',
              },
              props: attrs,
              on: { click: click_handler },
            )

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
            inner << h(:label, { style: center_style_props }, [radio_input, logo])
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
