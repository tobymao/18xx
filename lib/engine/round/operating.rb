# frozen_string_literal: true

require_relative 'base'

module Engine
  module Round
    class Operating < Base
      attr_reader :current_operator, :current_operator_acted

      def self.short_name
        'OR'
      end

      def name
        'Operating Round'
      end

      def select_entities
        @game.operating_order
      end

      def setup
        @current_operator = nil
        @home_token_timing = @game.class::HOME_TOKEN_TIMING
        @game.payout_companies
        @entities.each { |c| @game.place_home_token(c) } if @home_token_timing == :operating_round
        (@game.corporations + @game.minors + @game.companies).each(&:reset_ability_count_this_or!)
        after_setup
      end

      def any_to_act?
        @entities.any? { |entity| !skip_entity?(entity) }
      end

      def after_setup
        start_operating if any_to_act?
      end

      def after_process(action)
        return if action.type == 'message'

        @current_operator_acted = true if action.entity.corporation == @current_operator

        if active_step
          entity = @entities[@entity_index]
          return if entity.owner&.player? || entity.receivership?
        end

        after_end_of_turn(@current_operator)

        next_entity! unless @game.finished
      end

      def after_end_of_turn(operator); end

      def force_next_entity!
        @steps.each(&:pass!)
        next_entity!
        clear_cache!
      end

      def skip_entity?(entity)
        entity.closed?
      end

      def next_entity!
        return if @entity_index == @entities.size - 1

        next_entity_index!
        return next_entity! if skip_entity?(@entities[@entity_index])

        @steps.each(&:unpass!)
        @steps.each(&:setup)
        start_operating
      end

      def start_operating
        entity = @entities[@entity_index]
        return next_entity! if skip_entity?(entity)

        @current_operator = entity
        @current_operator_acted = false
        entity.trains.each { |train| train.operated = false }
        @log << "#{@game.acting_for_entity(entity).name} operates #{entity.name}" unless finished?
        @game.place_home_token(entity) if @home_token_timing == :operate
        skip_steps
        return unless finished?

        after_end_of_turn(entity)
        next_entity!
      end

      def recalculate_order
        unsorted_corps = @entities.pop(@entities.size - @entity_index - 1)
        @entities.concat(@game.operating_order.select { |e| unsorted_corps.include?(e) })
      end

      def operating?
        true
      end

      def finished?
        finished = super || !any_to_act?
        @current_operator = nil if finished
        finished
      end
    end
  end
end
