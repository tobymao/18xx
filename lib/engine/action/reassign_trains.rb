# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class ReassignTrains < Base
      attr_reader :assignments

      def initialize(entity, assignments: nil)
        super(entity)
        @assignments = assignments
      end

      def self.h_to_args(h, game)
        assignments = h['assignments'].map do |assignment|
          {
            train: game.train_by_id(assignment['train']),
            corporation: game.corporation_by_id(assignment['corporation']),
          }
        end
        {
          assignments: assignments,
        }
      end

      def args_to_h
        assignments = @assignments.map do |item|
          {
            'train' => item[:train].id,
            'corporation' => item[:corporation].id,
          }
        end

        {
          'assignments' => assignments,
        }
      end
    end
  end
end
