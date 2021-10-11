# frozen_string_literal: true

require_relative 'base'

module Engine
  module Round
    class Draft < Base
      def initialize(game, steps, **opts)
        @reverse_order = opts[:reverse_order] || false
        @snake_order = opts[:snake_order] || false
        @rotating_order = opts[:rotating_order] || false
        @snaking_up = true

        super
      end

      def self.short_name
        'DR'
      end

      def name
        'Draft Round'
      end

      def select_entities
        @reverse_order ? @game.players.reverse : @game.players
      end

      def setup
        @steps.each(&:unpass!)
        @steps.each(&:setup)
      end

      def next_entity_index!
        @entities.rotate! if @rotating_order && @entity_index == (@entities.size - 1)
        return super unless @snake_order

        if (@snaking_up && @entity_index == (@entities.size - 1)) ||
           (!@snaking_up && @entity_index.zero?)
          @snaking_up = !@snaking_up
        else
          plus_or_minus = @snaking_up ? :+ : :-
          @game.next_turn!
          @entity_index = @entity_index.send(plus_or_minus, 1) % @entities.size
        end
      end
    end
  end
end
