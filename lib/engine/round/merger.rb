# frozen_string_literal: true

require_relative 'base'

module Engine
  module Round
    class Merger < Base
      def name
        self.class.round_name
      end

      def self.round_name
        raise NotImplementedError
      end

      def merger?
        true
      end

      def use_operating_round_view?(_actions)
        true
      end
    end
  end
end
