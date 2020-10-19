# frozen_string_literal: true

require_relative '../merger'

module Engine
  module Round
    module G1817
      class Merger < Merger
        def name
          'Merger and Conversion Round'
        end

        def select_entities
          @game
            .corporations
            .select { |c| c.floated? && c.share_price.normal_movement? && !c.share_price.acquisition? }
            .sort
        end

        def setup
          super
          skip_steps
          next_entity! if finished?
        end

        def after_process(action)
          return if action.free?
          return if active_step

          @converted = nil
          @game.players.each(&:unpass!)
          next_entity!
        end

        def next_entity!
          next_entity_index! if @entities.any?
          return if @entity_index.zero?

          @steps.each(&:unpass!)
          @steps.each(&:setup)

          skip_steps
          next_entity! if finished?
        end

        def entities
          if @converted
            @game.players
          else
            @entities
          end
        end
      end
    end
  end
end
