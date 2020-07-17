# frozen_string_literal: true

require_relative 'base'

module Engine
  module Round
    class Operating < Base
      def name
        'Operating Round'
      end

      def select_entities
        @game.minors + @game.corporations.select(&:floated?).sort
      end

      def setup
        @home_token_timing = @game.class::HOME_TOKEN_TIMING
        @game.payout_companies
        @entities.each { |c| @game.place_home_token(c) } if @home_token_timing == :operating_round
        start_operating unless @entities.empty?
      end

      def before_process(_action)
        # this is crap, we should block when this happens
        @just_sold_company&.remove_ability_when(:sold)
        @just_sold_company = nil
      end

      def after_process(_action)
        if active_step
          return if @entities[@entity_index].owner&.player?
        end

        next_entity!
      end

      def force_next_entity!
        @steps.each(&:pass!)
        next_entity!
        clear_cache!
      end

      def next_entity!
        return if @entity_index == @entities.size - 1

        next_entity_index!
        @steps.each(&:unpass!)
        start_operating
      end

      def start_operating
        entity = @entities[@entity_index]
        if (ability = teleported?(entity))
          entity.remove_ability(ability)
        end
        entity.trains.each { |train| train.operated = false }
        @game.place_home_token(entity) if @home_token_timing == :operate
        skip_steps
        @game.log << "#{entity.owner.name} operates #{entity.name}" unless finished?
        next_entity! if finished?
      end

      def recalculate_order
        # Selling shares may have caused the corporations that haven't operated yet
        # to change order. Re-sort only them.
        index = @entity_index + 1
        @entities[index..-1] = @entities[index..-1].sort if index < @entities.size - 1
      end

      def teleported?(entity)
        entity.abilities(:teleport)&.find(&:used?)
      end
    end
  end
end
