# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Exchange < Base
      attr_reader :from

      def setup(corporations:, from:)
        @corporations = corporations
        @from = Array(from).map(&:to_sym)
      end

      def corporations(game)
        candidates = if @corporations == 'any'
                       game.corporations
                     else
                       @corporations.map { |c| game.corporation_by_id(c) }
                     end
        candidates.reject(&:closed?)
      end
    end
  end
end
