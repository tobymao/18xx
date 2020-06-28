# frozen_string_literal: true

require_relative '../action/par'
require_relative '../action/bid'
require_relative '../game_error'
require_relative '../step/end_game'
require_relative '../step/message'
require_relative 'base'

module Engine
  module Round
    class Auction < Base
      attr_reader :entities, :index, :steps

      DEFAULT_STEPS = [
        Step::EndGame,
        Step::Message,
      ].freeze

      def initialize(game, steps)
        @game = game
        @index = 0
        @entities = select_entities

        @steps = (DEFAULT_STEPS + steps).map do |step|
          step = step.new(@game, self)
          step.setup
          step.round_state.each do |key, value|
            singleton_class.class_eval { attr_accessor key }
            send("#{key}=", value)
          end
          step
        end
      end

      def select_entities
        @game.players
      end

      def current_entity
        active_entities[0]
      end

      def description
        active_step.description
      end

      def active_entities
        active_step.active_entities
      end

      def pass_description
        active_step.pass_description
      end

      def process_action(action)
        clear_cache!
        step = @steps.find { |s| s.actions(action.entity).include?(action.type) }
        raise GameError, "No step found for this action: #{action.to_h}" unless step

        step.send("process_#{action.type}", action)
      end

      def active_step
        @active_step ||= @steps.find(&:blocking?)
      end

      def finished?
        !active_step
      end

      private

      def clear_cache!
        @active_step = nil
      end

      def next_index!
        @index = (@index + 1) % @entities.size
      end
    end
  end
end
