# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class BorrowTrain < Base
      ACTIONS = %w[borrow_train pass].freeze
      def actions(entity)
        return [] unless can_borrow_train?(entity)

        ACTIONS
      end

      def description
        'Borrow Train'
      end

      def pass_description
        'Pass (Borrow Train)'
      end

      def blocks?
        can_borrow_train?(current_entity)
      end

      def can_borrow_train?(entity)
        !borrowable_trains(entity).empty?
      end

      def borrowable_trains(entity)
        abilites = @game.abilities(entity, :train_borrow)
        return [] unless abilites

        Array(abilites).map do |a|
          a.train_types.map { |typ| @game.depot.depot_trains.find { |t| t.sym == typ } }.compact
        end.flatten.uniq
      end

      def process_borrow_train(action)
        @game.borrow_train(action)
        pass!
      end
    end
  end
end
