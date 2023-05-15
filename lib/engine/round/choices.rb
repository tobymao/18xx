# frozen_string_literal: true

require_relative 'base'

module Engine
  module Round
    class Choices < Base
      def name
        'Choices'
      end

      def self.short_name
        'Choices'
      end

      def show_in_history?
        false
      end
    end
  end
end
