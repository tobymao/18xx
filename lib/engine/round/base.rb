# frozen_string_literal: true

if RUBY_ENGINE == 'opal'
  require_tree '../step'
else
  require 'require_all'
  require_rel '../step'
end

module Engine
  module Round
    class Base
      attr_reader :entities, :entity_index, :round_num, :steps

      DEFAULT_STEPS = [
        Step::EndGame,
        Step::Message,
      ].freeze

      def initialize(game, steps, **opts)
        @game = game
        @entity_index = 0
        @round_num = opts[:round_num] || 1
        @entities = select_entities

        @steps = (DEFAULT_STEPS + steps).map do |step, step_opts|
          step_opts ||= {}
          step = step.new(@game, self, **step_opts)
          step.setup
          step.round_state.each do |key, value|
            singleton_class.class_eval { attr_accessor key }
            send("#{key}=", value)
          end
          step
        end
      end

      def setup; end

      def name
        raise NotImplementedError
      end

      def select_entities
        raise NotImplementedError
      end

      def current_entity
        active_entities[0]
      end

      def description
        active_step.description
      end

      def active_entities
        active_step&.active_entities || []
      end

      # TODO: This is deprecated
      def can_act?(entity)
        active_step&.current_entity == entity
      end

      def teleported?(_entity)
        false
      end

      def pass_description
        active_step.pass_description
      end

      def process_action(action)
        type = action.type
        clear_cache!

        before_process(action)

        step = @steps.find do |s|
          next unless s.active?

          process = s.actions(action.entity).include?(type)
          blocking = s.blocking?
          @game.game_error("Step #{s.description} cannot process #{action.to_h}") if blocking && !process

          blocking || process
        end
        @game.game_error("No step found for action #{type} at #{action.id}") unless step

        step.acted = true
        step.send("process_#{action.type}", action)

        skip_steps
        clear_cache!
        after_process(action)
      end

      def actions_for(entity)
        actions = []
        return actions unless entity

        @steps.each do |step|
          next unless step.active?

          available_actions = step.actions(entity)
          actions.concat(available_actions)
          break if step.blocking?
        end
        actions.uniq
      end

      def active_step(entity = nil)
        return @steps.find { |step| step.active? && step.actions(entity).any? } if entity

        @active_step ||= @steps.find { |step| step.active? && step.blocking? }
      end

      def finished?
        !active_step
      end

      def goto_entity!(entity)
        @entity_index = @entities.find_index(entity)
      end

      def next_entity_index!
        @entity_index = (@entity_index + 1) % @entities.size
      end

      def reset_entity_index!
        @entity_index = 0
      end

      def clear_cache!
        @active_step = nil
      end

      private

      def skip_steps
        @steps.each do |step|
          next if !step.active? || !step.blocks?
          break if step.blocking?

          step.skip!
        end
      end

      def before_process(_action); end

      def after_process(_action); end
    end
  end
end
